{ config, pkgs, lib, ... }:

{
  # ── NVIDIA GPU ────────────────────────────────────────────────────────────
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open    = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;

    modesetting.enable          = true;
    nvidiaSettings              = true;
    powerManagement.enable      = true;  # Enable on laptops
    powerManagement.finegrained = true;

    prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  boot.kernelParams  = [
    "nvidia-drm.fbdev=1"
  ];

  hardware.graphics = {
    enable      = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ nvidia-vaapi-driver ];
  };

  # ── Wayland env vars ──────────────────────────────────────────────────────
  environment.variables = {
    GBM_BACKEND               = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME         = "nvidia";
  };

  # ── CPU microcode ─────────────────────────────────────────────────────────
  hardware.cpu.intel.updateMicrocode = true;
}
