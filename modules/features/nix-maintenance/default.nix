{
  flake.modules.nixos.nixMaintenance =
    { config, lib, ... }:
    let
      cfg = config.services.nix-maintenance;
    in
    {
      options.services.nix-maintenance = {
        enable = lib.mkEnableOption "scheduled NixOS upgrades and garbage collection";
        flake = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "/etc/nixos";
          description = "Flake path or URI to use for scheduled NixOS upgrades.";
        };
      };

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = cfg.flake != null;
            message = "services.nix-maintenance.flake must be set when scheduled Nix maintenance is enabled.";
          }
        ];

        nix.gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 30d";
        };

        system.autoUpgrade = {
          enable = true;
          inherit (cfg) flake;
          dates = "Sun 18:00";
          randomizedDelaySec = "45min";
          flags = [ "--print-build-logs" ];
          allowReboot = false;
          runGarbageCollection = true;
        };
      };
    };
}
