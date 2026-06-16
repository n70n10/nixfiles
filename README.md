# nixfiles

Flake-based NixOS configuration for two machines:

- **desktop-studio** — AMD CPU + AMD GPU, NixOS 26.05
- **laptop-yellow** — Intel CPU + NVIDIA GPU (Prime offload), NixOS 26.05

Hardware configurations and personal variables live in a separate private
repository (`nixfiles-private`). This repo is the public half — no hostnames,
usernames, or UUIDs appear here.

## Repository layout

```
flake.nix
hosts/
  desktop-studio/default.nix    # keyboard layout, hardware import
  laptop-yellow/default.nix
modules/
  amd-gpu.nix                   # AMD GPU, VA-API, CoreCtrl
  nvidia-gpu.nix                # NVIDIA, Prime offload
  shared/
    default.nix                 # barrel: imports all shared modules + home-manager
    boot.nix                    # bootloader, kernel, zram, sysctl
    core.nix                    # networking, locale, user, SSH, nix settings
    gaming.nix                  # Steam, Gamemode, Gamescope, MangoHud, ananicy-cpp
    hardware.nix                # Pipewire, printing, Bluetooth, firmware
    plasma.nix                  # KDE Plasma 6
    virtualisation.nix          # Docker, Podman, Distrobox
users/
  default.nix                   # home-manager: packages, LSPs, formatters
```

---

## Installation

The process has two phases: get a minimal bootable system from the live ISO,
then switch it to this flake configuration on first boot.

### Prerequisites

- NixOS minimal ISO (26.05) written to a USB drive
- A second USB drive containing your GitHub SSH keys
- Internet connection (Ethernet recommended; Wi-Fi steps included below)
- The target disk will be **fully erased**

---

### Phase 1 — Live ISO

#### 1. Boot and connect to the network

Boot the USB. The shell drops you in as `root`.

**Ethernet** — usually comes up automatically. Verify with:

```bash
ip a
```

**Wi-Fi** — use `iwctl`:

```bash
iwctl
[iwd] device list
[iwd] station wlan0 scan
[iwd] station wlan0 get-networks
[iwd] station wlan0 connect "SSID"
[iwd] quit
```

Confirm connectivity:

```bash
ping -c 3 nixos.org
```

---

#### 2. Set variables

```bash
# Target disk — verify with: lsblk
DISK=/dev/nvme0n1          # or /dev/sda, /dev/vda, etc.

# Derive partition names
if [[ "$DISK" == *nvme* ]]; then
  PART_EFI="${DISK}p1"
  PART_ROOT="${DISK}p2"
else
  PART_EFI="${DISK}1"
  PART_ROOT="${DISK}2"
fi
```

---

#### 3. Partition the disk with cfdisk

```bash
cfdisk "$DISK"
```

Inside cfdisk:

1. Select **gpt** label type if prompted
2. Create a **1G** partition → type **EFI System**
3. Create a partition with the remaining space → type **Linux filesystem**
4. **Write** and quit

---

#### 4. Format the EFI partition

```bash
mkfs.fat -F 32 -n ESP "$PART_EFI"
```

---

#### 5. Create the LUKS2 container

```bash
cryptsetup luksFormat \
  --type luks2 \
  --cipher aes-xts-plain64 \
  --key-size 512 \
  --hash sha512 \
  --pbkdf argon2id \
  "$PART_ROOT"
```

Type `YES` (uppercase) and enter a strong passphrase when prompted.

Open the container:

```bash
cryptsetup open "$PART_ROOT" cryptroot
```

---

#### 6. Create the Btrfs filesystem and subvolumes

```bash
mkfs.btrfs -L nixos /dev/mapper/cryptroot

mount /dev/mapper/cryptroot /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@log

umount /mnt
```

| Subvolume | Mountpoint  | Notes                              |
|-----------|-------------|------------------------------------|
| `@`       | `/`         | Root                               |
| `@home`   | `/home`     | Survives root rollbacks            |
| `@nix`    | `/nix`      | Store — large, no snapshots needed |
| `@log`    | `/var/log`  | Excluded from root snapshots       |

---

#### 7. Mount everything

```bash
BTRFS_OPTS="noatime,compress=zstd:3,space_cache=v2"

mount -o "${BTRFS_OPTS},subvol=@"     /dev/mapper/cryptroot /mnt
mkdir -p /mnt/{home,nix,var/log,boot}
mount -o "${BTRFS_OPTS},subvol=@home" /dev/mapper/cryptroot /mnt/home
mount -o "${BTRFS_OPTS},subvol=@nix"  /dev/mapper/cryptroot /mnt/nix
mount -o "${BTRFS_OPTS},subvol=@log"  /dev/mapper/cryptroot /mnt/var/log
mount "$PART_EFI" /mnt/boot
```

Verify the hierarchy with `lsblk`.

---

#### 8. Generate configuration

```bash
nixos-generate-config --root /mnt
```

This writes two files to `/mnt/etc/nixos/`:

- `hardware-configuration.nix` — filesystems, LUKS device, detected hardware
- `configuration.nix` — minimal starting point; needs a few edits before install

Open `configuration.nix` and make these minimal changes:

```bash
nano /mnt/etc/nixos/configuration.nix
```

Ensure the following are set (uncomment or add):

```nix
networking.hostName = "temporary";       # will be overridden by the flake later
networking.networkmanager.enable = true; # needed to connect after reboot

users.users.nixos = {                    # use your preferred username
  isNormalUser = true;
  extraGroups = [ "wheel" "networkmanager" ];
  initialPassword = "changeme";          # change on first boot
};

services.openssh.enable = true;
```

---

#### 9. Install

```bash
nixos-install
```

You will be prompted to set the root password. Then:

```bash
umount -R /mnt
cryptsetup close cryptroot
reboot
```

Remove the USB when the screen goes blank. The system will prompt for the
LUKS passphrase and boot into a minimal NixOS desktop.

---

### Phase 2 — First boot

Log in, open a terminal, and change your password:

```bash
passwd
```

---

#### 10. Copy SSH keys from the USB drive

```bash
# Mount the USB drive (adjust the device as needed — check with: lsblk)
mkdir -p /mnt/usb
mount /dev/sdb1 /mnt/usb

mkdir -p ~/.ssh
cp /mnt/usb/id_ed25519{,.pub} ~/.ssh/
chmod 600 ~/.ssh/id_ed25519

umount /mnt/usb
```

Start the SSH agent and add the key:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

Test access:

```bash
ssh -T git@github.com
```

---

#### 11. Add the hardware configuration to nixfiles-private

Clone the private repo:

```bash
cd ~
git clone git@github.com:n70n10/nixfiles-private.git
```

Copy the generated hardware configuration. The file must be named after the
machine's hostname, which must match `privateVars.hostnames.<role>` in
`nixfiles-private/vars.nix`:

```bash
# ROLE is the directory name under hosts/ in the public repo
ROLE=desktop-studio       # or: laptop-yellow

cp /etc/nixos/hardware-configuration.nix \
   ~/nixfiles-private/hardware/$(hostname).nix

cd ~/nixfiles-private
git add hardware/$(hostname).nix
git commit -m "hardware: add $(hostname)"
git push
```

---

#### 12. Clone nixfiles and switch

```bash
cd ~
git clone git@github.com:n70n10/nixfiles.git

# Enable flakes
export NIX_CONFIG="experimental-features = nix-command flakes"

nh os switch ~/nixfiles
```

`nh` detects the hostname automatically and applies the matching configuration.
After the switch completes, reboot to ensure the bootloader entry and initrd
are both updated:

```bash
reboot
```

The system will now boot fully into the flake-managed configuration.

---

## Ongoing maintenance

### Rebuilding

```bash
nh os switch ~/nixfiles   # build + activate
nh os boot   ~/nixfiles   # build + set as next boot entry
nh os test   ~/nixfiles   # build + activate without touching the boot default
```

### Updating

```bash
nix flake update ~/nixfiles
nh os switch ~/nixfiles
```

### Adding a new machine

1. Add an entry to `nixfiles-private/vars.nix`:
   ```nix
   hostnames.new-role-name = "actual-hostname";
   ```
2. Add the hardware configuration:
   ```bash
   cp /etc/nixos/hardware-configuration.nix \
      ~/nixfiles-private/hardware/actual-hostname.nix
   ```
3. Create `hosts/new-role-name/default.nix` in this repo.
4. Commit and push both repos.
5. Run `nh os switch ~/nixfiles`.
