{pkgs, ...}: {
  # ── Swap ─────────────────────────────────────────────────────────────────
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.page-cluster" = 0;
    "vm.max_map_count" = 2147483642;
  };

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

  boot.consoleLogLevel = 3;
  boot.kernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "udev.log_priority=3"
    "rd.systemd.show_status=auto"

    "split_lock_detect=off"
    "transparent_hugepage=madvise"
  ];

  # ── Bootloader ────────────────────────────────────────────────────────────
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.consoleMode = "auto";
    efi.canTouchEfiVariables = true;
  };
}
