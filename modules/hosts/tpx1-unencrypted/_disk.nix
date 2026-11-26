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
        root = {
          priority = 2;
          label = "root";
          uuid = "bf2cff40-3f0b-4ca7-9306-a00cb1c3402c";
          end = "-9G";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
        swap = {
          priority = 3;
          uuid = "9719d152-462d-46d5-ba3e-7f59318279fd";
          type = "8200";
          size = "100%";
          content.type = "swap";
        };
      };
    };
  };

}
