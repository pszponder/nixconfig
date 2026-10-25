{ inputs, moduleWithSystem, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      config = pkgs.writeTextDir "direnvrc" "source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc";
    in
    {
      packages.configured-direnv = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.direnv;
        env.DIRENV_CONFIG = config;
      };
      packages.configured-direnv-config = config;
    };
  flake.nixosModules.direnv = moduleWithSystem (
    { self', ... }: {
      environment.systemPackages = [ self'.packages.configured-direnv ];
    }
  );
}
