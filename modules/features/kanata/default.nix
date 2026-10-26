{
  flake.modules.nixos.kanata = {
    services.kanata = {
      enable = true;
      keyboards.default.configFile = ./kanata.kbd;
    };
  };
}
