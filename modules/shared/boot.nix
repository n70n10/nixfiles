{pkgs, ...}: {
  # ── Swap ─────────────────────────────────────────────────────────────────
  boot.zswap = {
    enable = true;
    compressor = "zstd";
    maxPoolPercent = 20;
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 16384; # 16GB (in MB)
    }
  ];

  # ── Kernel ────────────────────────────────────────────────────────────────
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd = {
    systemd.enable = true;
    supportedFilesystems = ["btrfs"];
    verbose = false;
  };

  boot.tmp.cleanOnBoot = true;

  # ── Plymouth boot splash ──────────────────────────────────────────────────
  boot.plymouth = {
    enable = true;
    theme = "bgrt";
  };

  # Silent boot — suppress kernel/systemd noise during splash
  boot.consoleLogLevel = 3;
  boot.kernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "udev.log_priority=3"
    "rd.systemd.show_status=auto"
  ];

  # ── Bootloader ────────────────────────────────────────────────────────────
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.consoleMode = "auto";
    efi.canTouchEfiVariables = true;
  };
}
