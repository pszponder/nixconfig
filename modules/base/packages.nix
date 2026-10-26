{ inputs, ... }:
{
  flake.modules.nixos.basePackages =
    { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      llmAgents = inputs.llm-agents.packages.${system};
      unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      programs.zsh.enable = true;
      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
      };

      environment.systemPackages =
        (with pkgs; [
          atuin
          bashInteractive
          bat
          bash-completion
          bash-language-server
          clang-tools
          cmake-language-server
          delta
          direnv
          dnsutils
          eza
          fd
          fzf
          gawk
          git
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
          util-linux
          vim
          wget
          zoxide
          zsh-autosuggestions
          zsh-completions
          zsh-fzf-tab
          zsh-syntax-highlighting
          zsh-vi-mode
        ])
        ++ [
          llmAgents.codex
          unstable.devenv
        ];
    };
}
