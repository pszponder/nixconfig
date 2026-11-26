{ inputs, self, ... }:
{
  flake.nixosConfigurations.tpx1-encrypted = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.modules.nixos; [
      workstationCommon
      gnome
      tpx1EncryptedHardware
      kanata
      fingerprint
      inputs.disko.nixosModules.disko
      ./_disk.nix
      {
        networking.hostName = "tpx1-encrypted";
        system.stateVersion = "26.05";
      }
    ];
  };
}
