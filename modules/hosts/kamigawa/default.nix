{ self, inputs, ... }:
let
  hostName = builtins.baseNameOf (toString ./.);
in
{
  flake.nixosConfigurations.${hostName} = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.modules.nixos; [
      workstationCommon
      gnome
      inputs.disko.nixosModules.disko
      ./_disk.nix
      ./_hardware-configuration.nix
      {
        networking.hostName = hostName;
        system.stateVersion = "26.05";

        disko.devices.disk.main.device = "/dev/disk/by-id/wwn-0x5002538f31b2732f";
      }
    ];
  };
}
