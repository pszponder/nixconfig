{ inputs, ... }:
{
  flake.modules.nixos.basePackages =
    { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      llmAgents = inputs.llm-agents.packages.${system};
    in
    {
      programs = {
        zsh.enable = true;
        neovim = {
          enable = true;
          viAlias = true;
          vimAlias = true;
        };
      };

      environment.systemPackages = with pkgs; [
        atuin
        bashInteractive
        bat
        bash-completion
        bash-language-server
        bubblewrap
        clang-tools
        cmake-language-server
        llmAgents.codex
        delta
        devenv
        direnv
        dnsutils
        eza
        fd
        fzf
        gawk
        gcc
        git
        llmAgents.herdr
        jq
        jujutsu
        just
        kanata
        less
        nix-direnv
        nix-zsh-completions
        nixd
        openssh
        ripgrep
        starship
        stow
        tmux
        tree-sitter
        util-linux
        vim
        wget
        zoxide
        zsh-autosuggestions
        zsh-completions
        zsh-fzf-tab
        zsh-syntax-highlighting
        zsh-vi-mode
      ];
    };
}
