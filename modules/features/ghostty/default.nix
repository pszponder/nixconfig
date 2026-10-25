{ inputs, self, ... }: {
  flake.wrappers.ghostty =
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
        default = ./config;
        description = "Ghostty configuration file.";
      };

      config = {
        package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.ghostty;
        flags."--config-file" = config.configFile;
        flagSeparator = "=";
      };
    };

  flake.nixosModules.ghostty = {
    imports = [ self.wrappers.ghostty.install ];
    wrappers.ghostty.enable = true;
  };
}
