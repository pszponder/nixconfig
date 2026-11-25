{
  flake.modules.nixos.tpx1Hardware = {
    imports = [
      ./_hardware-configuration.nix
    ];
    disko.devices.disk.main.device = "/dev/disk/by-id/wwn-0x5002538d41d1f7ec";
  };
}
