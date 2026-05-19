{ pkgs, privateVars, ... }:

{
  # ── Ghostty terminal ──────────────────────────────────────────────────────
  programs.ghostty.enable = true;

  home = {
    username      = privateVars.username;
    homeDirectory = "/home/${privateVars.username}";

    packages = with pkgs; [
      # Editors
      emacs-pgtk

      # CLI tools
      atuin bash-preexec bat chezmoi dysk eza fd gh git glab ripgrep
      shellcheck starship stress-ng tealdeer television trash-cli
      ugrep yq zoxide

      # Dev tools
      lazygit delta jq nil nixfmt

      # Utilities
      fastfetch
    ];

    sessionPath = [ "$HOME/.local/bin" ];

    stateVersion  = "25.11";
  };

  programs.home-manager.enable = true;
}
