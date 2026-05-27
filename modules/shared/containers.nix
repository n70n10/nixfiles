{ pkgs, privateVars, ... }: {

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  users.users.${privateVars.username} = {
    extraGroups = [ "podman" ];
  };

  # 3. Clean system packages
  environment.systemPackages = with pkgs; [
    distrobox
    podman-compose
    docker-compose
    runc
    conmon
    skopeo
    slirp4netns
    fuse-overlayfs
  ];
}
