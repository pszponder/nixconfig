{ inputs, moduleWithSystem, ... }: {
  perSystem = { pkgs, ... }: {
    packages.configured-devenv =
      inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.devenv;
  };
  flake.nixosModules.devenv = moduleWithSystem (
    { self', ... }: {
      environment.systemPackages = [ self'.packages.configured-devenv ];
    }
  );
}
