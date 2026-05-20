{ config, pkgs, privateVars, nixfiles-private, ... }:

{
  imports = [
    "${nixfiles-private}/hardware/desktop-amd-amd.nix"

    ../../modules/shared/default.nix
    ../../modules/amd-gpu.nix
  ];

  networking.hostName = privateVars.hostnames.desktop-amd-amd;

  services.xserver.xkb = {
    layout  = "us";
    options = "eurosign:e,caps:escape";
  };

  system.stateVersion = "25.11";
}
