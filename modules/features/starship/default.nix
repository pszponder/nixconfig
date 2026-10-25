{ inputs, moduleWithSystem, ... }:
{
  perSystem = { pkgs, ... }: {
    packages.configured-starship = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.starship;
      env.STARSHIP_CONFIG = "${./starship.toml}";
    };
  };
  flake.nixosModules.starship = moduleWithSystem (
    { self', ... }: {
      environment.systemPackages = [ self'.packages.configured-starship ];
    }
  );
}
