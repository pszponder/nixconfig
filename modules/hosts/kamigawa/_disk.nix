{
  disko.devices.disk.main = {
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        EFI = {
          priority = 1;
          type = "EF00";
          size = "1G";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [
              "fmask=0077"
              "dmask=0077"
            ];
          };
        };
        system = {
          type = "8309";
          size = "100%";
          content = {
            type = "luks";
            name = "kamigawa-crypt";
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
