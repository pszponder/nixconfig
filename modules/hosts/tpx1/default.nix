{ inputs, self, ... }:
{
  flake.nixosConfigurations = {
    tpx1 = inputs.nixpkgs.lib.nixosSystem {
      modules = [ self.modules.nixos.tpx1 ];
    };
    tpx1-encrypted = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        self.modules.nixos.tpx1Common
        self.modules.nixos.encryptedRoot
        { disko.devices.disk.main.content.partitions.system.content.name = "tpx1-crypt"; }
        { networking.hostName = "tpx1-encrypted"; }
      ];
    };
  };

  flake.modules.nixos = {
    tpx1.imports = [
      self.modules.nixos.efiDisk
      self.modules.nixos.tpx1Common
      ./_disk.nix
      { networking.hostName = "tpx1"; }
    ];
    tpx1Common.imports = with self.modules.nixos; [
      workstation
      desktopPackages
      webapps
      gnome
      docker
      printing
      tpx1Hardware
      kanata
      fingerprint
    ];
  };
}
