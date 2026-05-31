{privateVars, ...}: {
  imports = [
    ./boot.nix
    ./core.nix
    ./hardware.nix
    ./gaming.nix
    ./plasma.nix
    ./virtualisation.nix
  ];

  home-manager = {
    extraSpecialArgs = {inherit privateVars;};
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "nixsave";
    users."${privateVars.username}" = import ../../users/default.nix;
  };
}
