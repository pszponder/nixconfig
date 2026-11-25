{ self, inputs, ... }:
let
  hostName = builtins.baseNameOf (toString ./.);
in
{
  flake.nixosConfigurations.${hostName} = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.modules.nixos.workstation
      self.modules.nixos.desktopPackages
      self.modules.nixos.webapps
      self.modules.nixos.gnome
      self.modules.nixos.docker
      self.modules.nixos.printing
      inputs.disko.nixosModules.disko
      ./_disk.nix
      ./_hardware-configuration.nix
      {
        networking.hostName = hostName;
        disko.devices.disk.main.device = "/dev/vda";
      }
    ];
  };
}
