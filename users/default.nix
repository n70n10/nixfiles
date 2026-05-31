{
  pkgs,
  privateVars,
  ...
}: {
  # ── Ghostty terminal ──────────────────────────────────────────────────────
  programs.ghostty.enable = true;

  home = {
    username = privateVars.username;
    homeDirectory = "/home/${privateVars.username}";

    packages = with pkgs; [
      # Editors
      emacs-pgtk

      # CLI tools
      atuin
      bash-preexec
      bat
      chezmoi
      dysk
      eza
      fd
      gh
      git
      glab
      ripgrep
      shellcheck
      starship
      stress-ng
      tealdeer
      television
      trash-cli
      ugrep
      yq
      zoxide

      # Dev tools
      lazygit
      delta
      jq

      # LSP servers
      bash-language-server
      shellcheck
      fish-lsp
      yaml-language-server
      lua-language-server
      vscode-langservers-extracted # JSON
      nil # Nix
      taplo # TOML
      markdown-oxide # Markdown
      dockerfile-language-server

      # Formatters
      shfmt # Bash
      alejandra # Nix
      prettier # YAML, JSON, Markdown
      # taplo doubles as formatter (already above)

      # Spell checking
      hunspell
      hunspellDicts.en_US
      hunspellDicts.en_GB-ise
      hunspellDicts.it_IT

      # Utilities
      fastfetch
    ];

    sessionPath = ["$HOME/.local/bin"];

    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
