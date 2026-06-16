{
  privateVars,
  nixfiles-private,
  ...
}: {
  imports = [
    # Hardware file is named after the actual hostname, kept in nixfiles-private.
    "${nixfiles-private}/hardware/${privateVars.hostnames.desktop-studio}.nix"

    ../../modules/shared/default.nix
    ../../modules/amd-gpu.nix
  ];

  networking.hostName = privateVars.hostnames.desktop-studio;

  services.xserver.xkb = {
    layout = "us";
    options = "eurosign:e,caps:escape";
  };

  system.stateVersion = "26.05";
}
