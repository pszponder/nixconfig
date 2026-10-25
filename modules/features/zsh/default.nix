{ inputs, self, ... }: {
  flake.wrappers.zsh =
    { pkgs, ... }:
    let
      self' = {
        packages = self.packages.${pkgs.stdenv.hostPlatform.system};
      };
    in
    {
      imports = [ inputs.wrappers.wrapperModules.zsh ];
      # Prefer the configured shell over NixOS's unwrapped system shell.
      drv.meta.priority = 0;
      hmSessionVariables = null;
      skipGlobalRC = true;
      zshenv.content = ". ${self'.packages.configured-shell-environment}";
      zshrc.path = pkgs.replaceVars ./zshrc {
        zshCompletions = pkgs.zsh-completions;
        nixZshCompletions = pkgs.nix-zsh-completions;
        zshViMode = pkgs.zsh-vi-mode;
        zshFzfTab = pkgs.zsh-fzf-tab;
        zshAutosuggestions = pkgs.zsh-autosuggestions;
        zshSyntaxHighlighting = pkgs.zsh-syntax-highlighting;
        viModeSettings = ./vi-mode-settings.zsh;
        viModeBindings = ./vi-mode-bindings.zsh;
        interactive = ./interactive.zsh;
        aliases = ../shell/aliases;
        functions = ../shell/functions.sh;
        fzfIntegration = self'.packages.configured-fzf-zsh-integration;
      };
    };

  perSystem = { self', ... }: {
    packages.configured-zsh = self'.packages.zsh;
  };

  flake.nixosModules.zsh = {
    imports = [ self.wrappers.zsh.install ];
    wrappers.zsh.enable = true;
    programs.zsh.enable = true;
  };
}
