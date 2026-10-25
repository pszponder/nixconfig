{ self, ... }: {
  # Extend the original NixOS configuration with repository features.
  flake.nixosModules.tpx1Configuration = {
    imports = [
      ./_configuration.nix
      self.nixosModules.kanata
    ];
  };
}
