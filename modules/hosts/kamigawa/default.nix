{ self, inputs, ... }:
let
  hostName = builtins.baseNameOf (toString ./.);
in
{
  flake.nixosConfigurations.${hostName} = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.modules.nixos; [
      workstation
      piotr
      nixMaintenance
      desktopPackages
      webapps
      gnome
      docker
      printing
      inputs.disko.nixosModules.disko
      ./_disk.nix
      ./_hardware-configuration.nix
      ({ pkgs, ... }: {
        networking.hostName = hostName;
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

        disko.devices.disk.main.device = "/dev/disk/by-id/wwn-0x5002538f31b2732f";
      })
    ];
  };
}
