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
        # Desktop activation must launch the configured wrapper as well.
        filesToPatch = [
          "share/applications/*.desktop"
          "share/dbus-1/services/com.mitchellh.ghostty.service"
          "lib/systemd/user/app-com.mitchellh.ghostty.service"
        ];
        flags."--config-file" = config.configFile;
        flagSeparator = "=";
      };
    };

  flake.nixosModules.ghostty = {
    imports = [ self.wrappers.ghostty.install ];
    wrappers.ghostty.enable = true;
  };
}
