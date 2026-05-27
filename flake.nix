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
  in {
    nixosConfigurations = {
      "${privateVars.hostnames.desktop-amd-amd}" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit privateVars nixfiles-private;};
        modules = [
          ./hosts/desktop-amd-amd/default.nix
          home-manager.nixosModules.home-manager
        ];
      };

      "${privateVars.hostnames.laptop-intel-nvidia}" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit privateVars nixfiles-private;};
        modules = [
          ./hosts/laptop-intel-nvidia/default.nix
          home-manager.nixosModules.home-manager
        ];
      };
    };
  };
}
