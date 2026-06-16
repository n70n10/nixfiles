{
  description = "n70n10 awesome nix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixfiles-private = {
      url = "git+ssh://git@github.com/n70n10/nixfiles-private.git";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    nixfiles-private,
    ...
  }: let
    privateVars = import "${nixfiles-private}/vars.nix";

    mkHost = role: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit privateVars nixfiles-private;};
      modules = [
        ./hosts/${role}/default.nix
        home-manager.nixosModules.home-manager
      ];
    };
  in {
    nixosConfigurations = nixpkgs.lib.mapAttrs'
      (role: hostname: nixpkgs.lib.nameValuePair hostname (mkHost role))
      privateVars.hostnames;
  };
}
