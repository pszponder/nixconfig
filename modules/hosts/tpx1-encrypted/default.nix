{ inputs, self, ... }:
{
  flake.nixosConfigurations.tpx1-encrypted = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.modules.nixos; [
      workstation
      desktopPackages
      webapps
      gnome
      docker
      printing
      tpx1EncryptedHardware
      kanata
      fingerprint
      inputs.disko.nixosModules.disko
      ./_disk.nix
      { networking.hostName = "tpx1-encrypted"; }
    ];
  };
}
