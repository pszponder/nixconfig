_: {
  flake.nixosModules.docker = {
    virtualisation.docker.enable = true;
    users.users.piotr.extraGroups = [ "docker" ];
  };
}
