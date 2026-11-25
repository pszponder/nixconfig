{ lib, ... }:
{
  disko.devices.disk.main.content.partitions.system = {
    type = "8309";
    size = "100%";
    content = {
      type = "luks";
      name = lib.mkDefault "cryptroot";
      extraFormatArgs = [
        "--type"
        "luks2"
      ];
      content = {
        type = "filesystem";
        format = "ext4";
        mountpoint = "/";
      };
    };
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 9 * 1024;
    }
  ];
}
