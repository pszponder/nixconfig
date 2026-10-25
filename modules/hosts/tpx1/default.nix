{ self, inputs, ... }: {

  # Define nixosConfiguration with hostname "tpx1"
  flake.nixosConfigurations.tpx1 = inputs.nixpkgs.lib.nixosSystem {
    # Define modules to import
    modules = with self.nixosModules; [
      tpx1Configuration
      tpx1Hardware
    ];
  };
}

