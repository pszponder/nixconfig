{ moduleWithSystem, ... }:
{
  perSystem = { pkgs, ... }: {
    packages.configured-shell-environment = pkgs.writeText "shell-environment.sh" (
      builtins.readFile ./environment.sh
    );
  };
  flake.nixosModules.shell = moduleWithSystem (
    { pkgs, self', ... }: {
      hjem.users.piotr.files = {
        ".bashrc".source = self'.packages.configured-bash-rc;
        ".bash_profile".source = ./bash_profile;
        ".profile".source = self'.packages.configured-shell-environment;
      };
      environment.systemPackages = with pkgs; [
        ripgrep
        gawk
        jq
        less
        util-linux
        fd
        eza
        dnsutils
      ];
      environment.extraInit = ''
        if [ "$(id -un)" = piotr ]; then
          . ${self'.packages.configured-shell-environment}
        fi
      '';
    }
  );
}
