{ disko }:
{
  imports = [ disko.nixosModules.disko ];
  disko.devices.disk.main = {
    type = "disk";
    content = {
      type = "gpt";
      partitions.EFI = {
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
    };
  };
}
