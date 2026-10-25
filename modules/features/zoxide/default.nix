{ moduleWithSystem, ... }:
{
  perSystem = { pkgs, ... }: {
    packages.configured-zoxide = pkgs.zoxide;
  };
  flake.nixosModules.zoxide = moduleWithSystem (
    { self', ... }: {
      environment.systemPackages = [ self'.packages.configured-zoxide ];
    }
  );
}
