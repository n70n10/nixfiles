{ pkgs, privateVars, ... }: {

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = false;
    defaultNetwork.settings.dns_enabled = true;
  };

  users.users.${privateVars.username} = {
    extraGroups = [ "docker" ];
  };

  # 3. Clean system packages
  environment.systemPackages = with pkgs; [
    distrobox
    docker-compose
    lazydocker
  ];
}
