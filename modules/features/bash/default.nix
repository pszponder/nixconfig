{ self, ... }:
{
  perSystem =
    { pkgs, self', ... }:
    let
      rc = pkgs.replaceVars ./bashrc {
        shellEnvironment = self'.packages.configured-shell-environment;
        bashCompletion = pkgs.bash-completion;
        interactive = ./interactive.bash;
        aliases = ../shell/aliases;
        functions = ../shell/functions.sh;
        fzfIntegration = self'.packages.configured-fzf-bash-integration;
      };
    in
    {
      packages.configured-bash-rc = rc;
      packages.configured-bash = self'.packages.bash;
    };

  flake.wrappers.bash = { pkgs, wlib, ... }: {
    imports = [ wlib.modules.default ];
    package = pkgs.bashInteractive;
    # Prefer the configured shell over NixOS's unwrapped system shell.
    drv.meta.priority = 0;
    flags."--rcfile" = self.packages.${pkgs.stdenv.hostPlatform.system}.configured-bash-rc;
  };

  flake.nixosModules.bash = {
    imports = [ self.wrappers.bash.install ];
    wrappers.bash.enable = true;
  };
}
