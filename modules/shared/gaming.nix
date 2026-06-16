{pkgs, ...}: {
  programs.gamescope = {
    enable = true;
    capSysNice = false; # broken in NixOS :(
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = [pkgs.proton-ge-bin];
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
  };

  environment.systemPackages = with pkgs; [
    mangohud
  ];
}
