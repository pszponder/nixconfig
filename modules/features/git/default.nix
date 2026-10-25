{ inputs, self, ... }: {
  flake.wrappers.git = { pkgs, ... }: {
    imports = [ inputs.wrappers.wrapperModules.git ];

    runtimePkgs = [
      pkgs.less
      pkgs.delta
      pkgs.openssh
      self.packages.${pkgs.stdenv.hostPlatform.system}.configured-neovim
    ];
    settings = {
      user.useConfigOnly = true;
      core.excludesFile = "${./config/ignore}";
      include.path = toString (
        pkgs.replaceVars ./config/defaults {
          deltaTheme = ./catppuccin.gitconfig;
        }
      );
      "includeIf \"gitdir:~/repos/github/pszponder/\"".path = "${./config/github_pszponder}";
    };
  };

  flake.nixosModules.git = {
    imports = [ self.wrappers.git.install ];
    wrappers.git.enable = true;
  };
}
