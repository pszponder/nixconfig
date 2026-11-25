{ self, inputs, ... }:
let
  hostName = builtins.baseNameOf (toString ./.);
in
{
  flake.nixosConfigurations.${hostName} = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.modules.nixos.workstation
      self.modules.nixos.piotr
      self.modules.nixos.nixMaintenance
      self.modules.nixos.desktopPackages
      self.modules.nixos.webapps
      self.modules.nixos.gnome
      self.modules.nixos.docker
      self.modules.nixos.printing
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

        disko.devices.disk.main.device = "/dev/vda";
      })
    ];
  };
}
