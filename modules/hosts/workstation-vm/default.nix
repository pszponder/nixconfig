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
      self.modules.nixos.encryptedRoot
      ./_hardware-configuration.nix
      {
        networking.hostName = hostName;
        disko.devices.disk.main.device = "/dev/vda";
      }
    ];
  };
}
