{ inputs, self, ... }:
{
  flake.nixosConfigurations.tpx1 = inputs.nixpkgs.lib.nixosSystem {
    modules = [ self.modules.nixos.tpx1 ];
  };

  flake.modules.nixos.tpx1.imports = with self.modules.nixos; [
    inputs.disko.nixosModules.disko
    ./_disk.nix
    { networking.hostName = "tpx1"; }
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
}
