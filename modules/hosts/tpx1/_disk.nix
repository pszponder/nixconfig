{
  imports = [ ../_encrypted-disk.nix ];

  disko.devices.disk.main.content.partitions = {
    EFI = {
      label = "EFI";
      uuid = "bad6a9b9-8ab9-4824-b9aa-51f147e7fe6b";
    };
    system.content.name = "tpx1-crypt";
  };
}
