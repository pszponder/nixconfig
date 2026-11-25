{ inputs, self, ... }:
{
  flake.nixosConfigurations.tpx1-encrypted = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.modules.nixos; [
      workstation
      piotr
      nixMaintenance
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
      ({ pkgs, ... }: {
        networking.hostName = "tpx1-encrypted";
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
    ];
  };
}
