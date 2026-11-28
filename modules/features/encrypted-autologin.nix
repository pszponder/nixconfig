{
  flake.modules.nixos.encryptedAutologin =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      systemPartition = config.disko.devices.disk.main.content.partitions.system.content or { };
      encryptedRoot =
        (systemPartition.type or null) == "luks" && (systemPartition.content.mountpoint or null) == "/";
    in
    {
      options.encryptedAutologin.user = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Account to sign in automatically after unlocking the encrypted root filesystem.";
      };

      config = lib.mkIf (encryptedRoot && config.encryptedAutologin.user != null) {
        boot = {
          plymouth = {
            enable = true;
            theme = "nixos-bar";
            themePackages = [
              (pkgs.runCommand "plymouth-theme-nixos-bar" { } ''
                theme="$out/share/plymouth/themes/nixos-bar"
                stock="${config.boot.plymouth.package}/share/plymouth/themes/spinner"
                mkdir -p "$theme"
                cp "$stock"/*.png "$theme/"
                cp ${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake.png "$theme/watermark.png"

                # Keep Plymouth's native passphrase dialog and update screens.
                sed -e 's/^Name=Spinner$/Name=NixOS Bar/' \
                    -e "s|^ImageDir=.*|ImageDir=$theme|" \
                    -e 's/^WatermarkVerticalAlignment=.*/WatermarkVerticalAlignment=.35/' \
                    -e 's/^DialogVerticalAlignment=.*/DialogVerticalAlignment=.62/' \
                    -e 's/^ProgressBarForegroundColor=.*/ProgressBarForegroundColor=0x7ebae4/' \
                    -e '/^\[two-step\]$/a ProgressBarWidth=240\nProgressBarHeight=6\nProgressBarVerticalAlignment=.62' \
                    -e '/^\[boot-up\]$/a UseProgressBar=true' \
                    "$stock/spinner.plymouth" > "$theme/nixos-bar.plymouth"
              '')
            ];
          };
          loader.timeout = lib.mkDefault 1;
          consoleLogLevel = 3;
          kernelParams = [
            "quiet"
            "plymouth.use-simpledrm"
            "systemd.show_status=false"
          ];
        };
        services.displayManager.autoLogin = {
          enable = true;
          user = config.encryptedAutologin.user;
        };
      };
    };
}
