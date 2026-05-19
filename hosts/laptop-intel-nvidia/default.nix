{ config, pkgs, privateVars, nfs-private, ... }:

{
  imports = [
    "${nfs-private}/laptop-intel-nvidia"

    ../../modules/shared/default.nix
    ../../modules/nvidia-gpu.nix
  ];

  networking.hostName = privateVars.hostnames.laptop-intel-nvidia;

  services.xserver.xkb = {
    layout  = "ie";
    options = "eurosign:e,caps:escape";
  };

  system.stateVersion = "25.11";
}
