{ inputs, ... }: {
  flake.nixosModules.hjem = {
    imports = [ inputs.hjem.nixosModules.default ];
    hjem.users.piotr = {
      enable = true;
      clobberFiles = false;
    };
  };
}
