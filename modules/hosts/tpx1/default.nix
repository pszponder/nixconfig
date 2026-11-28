{ inputs, self, ... }:
{
  flake.nixosConfigurations.tpx1 = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.modules.nixos; [
      workstation
      # gnome
      cosmic
      tpx1Hardware
      kanata
      fingerprint
      inputs.disko.nixosModules.disko
      ./_disk.nix
      {
        networking.hostName = "tpx1";
        system.stateVersion = "26.05";
      }
    ];
  };
}
