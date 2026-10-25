{ moduleWithSystem, ... }:
{
  perSystem = { pkgs, ... }: {
    packages.configured-jujutsu = pkgs.jujutsu;
  };
  flake.nixosModules.jujutsu = moduleWithSystem (
    { self', ... }: {
      environment.systemPackages = [ self'.packages.configured-jujutsu ];
    }
  );
}
