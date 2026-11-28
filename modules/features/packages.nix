{ inputs, ... }:
{
  flake.modules.nixos.commonPackages = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      dnsutils
      git
      jq
      less
      openssh
      ripgrep
      util-linux
      wget
    ];
  };

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
        llmAgents.claude-code
        cmake-language-server
        llmAgents.codex
        delta
        devenv
        direnv
        eza
        fd
        fzf
        gawk
        gcc
        gh
        llmAgents.herdr
        llmAgents.herdr-core
        jujutsu
        just
        kanata
        nix-direnv
        nix-zsh-completions
        nixd
        llmAgents.opencode2
        llmAgents.pi
        llmAgents.sandbox-runtime
        starship
        stow
        tmux
        tree-sitter
        vim
        zoxide
        zsh-autosuggestions
        zsh-completions
        zsh-fzf-tab
        zsh-syntax-highlighting
        zsh-vi-mode
      ];
    };
}
