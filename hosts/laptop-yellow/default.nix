{
  privateVars,
  nixfiles-private,
  ...
}: {
  imports = [
    "${nixfiles-private}/hardware/${privateVars.hostnames.laptop-yellow}.nix"

    ../../modules/shared/default.nix
    ../../modules/nvidia-gpu.nix
  ];

  networking.hostName = privateVars.hostnames.laptop-yellow;

  services.xserver.xkb = {
    layout = "ie";
    options = "eurosign:e,caps:escape";
  };

  system.stateVersion = "26.05";
}
