{ pkgs, privateVars, ... }: {

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };

  users.users.${privateVars.username} = {
    extraGroups = [ "docker" ];
  };

  environment.systemPackages = with pkgs; [
    distrobox
    docker-compose
    lazydocker
  ];
}
