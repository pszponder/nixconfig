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
          description = "Flake path or URI to use for nh and scheduled NixOS upgrades.";
        };
      };

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = cfg.flake != null;
            message = "services.nix-maintenance.flake must be set when scheduled Nix maintenance is enabled.";
          }
        ];

        programs.nh = {
          enable = true;
          inherit (cfg) flake;
          clean = {
            enable = true;
            dates = "weekly";
            # Preserve development roots and at least three rollback generations.
            extraArgs = "--keep-since 30d --keep 3 --no-gcroots";
          };
        };

        system.autoUpgrade = {
          enable = true;
          inherit (cfg) flake;
          dates = "Sun 18:00";
          randomizedDelaySec = "45min";
          # Flake inputs are updated explicitly; --upgrade only updates channels.
          upgrade = false;
          flags = [
            "--update-input"
            "nixpkgs"
            "--print-build-logs"
          ];
          allowReboot = false;
        };
      };
    };
}
