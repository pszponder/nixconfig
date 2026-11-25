{
  disko.devices.disk.main = {
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        EFI = {
          label = "EFI";
          uuid = "bad6a9b9-8ab9-4824-b9aa-51f147e7fe6b";
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
            name = "tpx1-crypt";
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
