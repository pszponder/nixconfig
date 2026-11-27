{
  imports = [ ../_encrypted-disk.nix ];

  disko.devices.disk.main.content.partitions = {
    system.content.name = "kamigawa-crypt";
  };
}
