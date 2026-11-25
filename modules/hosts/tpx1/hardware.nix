{
  flake.modules.nixos.tpx1Hardware = {
    imports = [
      ./_hardware-configuration.nix
    ];
    disko.devices.disk.main = {
      device = "/dev/disk/by-id/wwn-0x5002538d41d1f7ec";
      content.partitions.EFI = {
        label = "EFI";
        uuid = "bad6a9b9-8ab9-4824-b9aa-51f147e7fe6b";
      };
    };
  };
}
