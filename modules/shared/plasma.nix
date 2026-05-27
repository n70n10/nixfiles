{
  pkgs,
  lib,
  ...
}: {
  # ── Desktop: KDE Plasma 6 ────────────────────────────────────────────────────
  services.desktopManager.plasma6.enable = true;

  # Plasma Login Manager
  services.displayManager.plasma-login-manager.enable = true;

  # Optional: auto-login (uncomment if desired)
  # services.displayManager.autoLogin = {
  #   enable = true;
  #   user = secrets.username;
  # };

  # Workaround for https://github.com/NixOS/nixpkgs/issues/432137
  # Qt can't find pipewire-0.3 at runtime — expose it via LD_LIBRARY_PATH
  environment.sessionVariables.LD_LIBRARY_PATH = lib.mkAfter [
    "${pkgs.pipewire}/lib"
    "${pkgs.libpulseaudio}/lib"
  ];
}
