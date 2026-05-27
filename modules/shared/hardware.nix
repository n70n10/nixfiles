{...}: {
  # ── PipeWire ──────────────────────────────────────────────────────────────
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
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

  # ── Firmware ──────────────────────────────────────────────────────────────
  hardware.enableRedistributableFirmware = true;
}
