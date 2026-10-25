{ inputs, moduleWithSystem, ... }:
{
  perSystem = { pkgs, ... }: {
    packages.configured-atuin = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.atuin;
      env = {
        ATUIN_CONFIG_DIR = "${./config}";
        ATUIN_THEME_DIR = "${./config/themes}";
      };
    };
  };
  flake.nixosModules.atuin = moduleWithSystem (
    { self', ... }: {
      environment.systemPackages = [ self'.packages.configured-atuin ];
    }
  );
}
