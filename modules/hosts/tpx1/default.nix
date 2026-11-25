{ inputs, self, ... }:
{
  flake.nixosConfigurations.tpx1 = inputs.nixpkgs.lib.nixosSystem {
    modules = [ self.modules.nixos.tpx1 ];
  };

  flake.modules.nixos.tpx1.imports = with self.modules.nixos; [
    inputs.disko.nixosModules.disko
    ./_disk.nix
    ({ pkgs, ... }: {
      networking.hostName = "tpx1";
      boot = {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        kernelPackages = pkgs.linuxPackages_latest;
      };
      networking.networkmanager.enable = true;
      users.users.piotr.extraGroups = [
        "docker"
        "wheel"
        "networkmanager"
      ];
      services.nix-maintenance = {
        enable = true;
        flake = "/home/piotr/repos/github/pszponder/nixconfig";
      };
      system.stateVersion = "26.05";
    })
    workstation
    piotr
    nixMaintenance
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
