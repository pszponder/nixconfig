{ self, ... }: {
  flake.nixosModules.piotr = {
    imports = [ self.nixosModules.hjem ];

    users.users.piotr = {
      isNormalUser = true;
      description = "Piotr";
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
      ];
    };

    hjem.users.piotr = {
      enable = true;
      clobberFiles = false;
    };
  };
}
