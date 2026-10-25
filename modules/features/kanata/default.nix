{ self, ... }:
{
  # Reusable wrapper; flake-parts also exposes packages.<system>.kanata.
  flake.wrappers.kanata =
    {
      config,
      lib,
      pkgs,
      wlib,
      ...
    }:
    {
      imports = [ wlib.modules.default ];

      options.configFile = lib.mkOption {
        type = lib.types.path;
        default = ./kanata.kbd;
        description = "Kanata keyboard configuration file.";
      };

      config = {
        package = pkgs.kanata;
        flags."--cfg" = config.configFile;
      };
    };

  flake.nixosModules.kanata = { config, ... }: {
    # Install the wrapper using the library's NixOS integration.
    imports = [ self.wrappers.kanata.install ];
    wrappers.kanata.enable = true;

    # NixOS manages device access and startup, and supplies --cfg itself.
    services.kanata = {
      enable = true;
      keyboards.default.configFile = config.wrappers.kanata.configFile;
    };
  };
}
