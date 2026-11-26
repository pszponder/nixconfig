{ inputs, self, ... }:
{
  flake.nixosConfigurations.tpx1-unencrypted = inputs.nixpkgs.lib.nixosSystem {
    modules = [ self.modules.nixos.tpx1-unencrypted ];
  };

  flake.modules.nixos.tpx1-unencrypted.imports = with self.modules.nixos; [
    inputs.disko.nixosModules.disko
    ./_disk.nix
    {
      networking.hostName = "tpx1-unencrypted";
      system.stateVersion = "26.05";
    }
    workstationCommon
    gnome
    tpx1Hardware
    kanata
    fingerprint
  ];
}
