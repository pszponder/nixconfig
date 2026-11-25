{
  flake.modules.nixos.piotr = {
    users.users.piotr = {
      isNormalUser = true;
      description = "Piotr";
    };
  };
}
