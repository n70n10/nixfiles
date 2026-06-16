{...}: {
  # ── PipeWire ──────────────────────────────────────────────────────────────
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # Low-latency config: halve the default quantum (1024 → 512) for ~10ms
    # less audio latency during gaming. Drop to 256 if you have no xruns.
    extraConfig.pipewire."99-low-latency" = {
      context.properties = {
        default.clock.rate = 48000;
        default.clock.quantum = 512;
        default.clock.min-quantum = 256;
      };
    };
  };

  # ── Printing (AirPrint) ───────────────────────────────────────────────────
  services.printing = {
    enable = true;
    browsing = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # ── Bluetooth ─────────────────────────────────────────────────────────────
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Enable = "Source,Sink,Media,Socket";
  };

  # ── Disk / power ──────────────────────────────────────────────────────────
  services.udisks2.enable = true;
  services.fstrim.enable = true;

  powerManagement.cpuFreqGovernor = "performance";
  services.irqbalance.enable = true;

  # ── Firmware ──────────────────────────────────────────────────────────────
  hardware.enableRedistributableFirmware = true;
}
