{
  pkgs,
  privateVars,
  ...
}: {
  # ── Networking ────────────────────────────────────────────────────────────
  networking = {
    networkmanager.enable = true;
  };

  # ── Locale, time & keyboard ───────────────────────────────────────────────
  time.timeZone = privateVars.timezone;

  i18n.defaultLocale = privateVars.locale;

  console.useXkbConfig = true;

  # ── User ──────────────────────────────────────────────────────────────────
  users.users.${privateVars.username} = {
    isNormalUser = true;
    description = privateVars.fullname;
    extraGroups = ["wheel" "networkmanager" "audio" "video" "input" "gamemode"];
    shell = pkgs.bash;
  };

  # ── Shell ─────────────────────────────────────────────────────────────────
  programs.fish.enable = true;

  # ── SSH ───────────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # ── Nix ───────────────────────────────────────────────────────────────────
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
    trusted-users = ["root" privateVars.username];
    max-jobs = "auto";
    cores = 0;
    log-lines = 50;
  };

  nixpkgs.config.allowUnfree = true;

  # ── System packages ───────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    gcc
    gnumake
    pkg-config # build tools needed system-wide
    wl-clipboard # Wayland clipboard (compositor-agnostic)
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.nh = {
    enable = true;
    flake = "/home/${privateVars.username}/nixfiles";
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 3";
    };
  };

  # ── Flatpak ───────────────────────────────────────────────────────────────
  services.flatpak.enable = true;
  # Add Flathub once after install:
  # flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

  # ── Fonts ─────────────────────────────────────────────────────────────────
  fonts.packages = with pkgs; [
    adwaita-fonts
    noto-fonts
    noto-fonts-color-emoji
    (nerd-fonts.iosevka)
    (nerd-fonts.symbols-only)
  ];

  # ── Security ──────────────────────────────────────────────────────────────
  security = {
    protectKernelImage = true;
    # wheelNeedsPassword = false;  # Passwordless sudo for wheel (optional)
  };
}
