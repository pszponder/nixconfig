{
  flake.modules.nixos.encryptedAutologin =
    { config, lib, ... }:
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
        boot.plymouth.enable = true;
        services.displayManager.autoLogin = {
          enable = true;
          user = config.encryptedAutologin.user;
        };
      };
    };
}
