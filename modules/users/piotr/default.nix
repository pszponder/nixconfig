{
  flake.modules.nixos.piotr =
    {
      config,
      lib,
      options,
      ...
    }:
    {
      config = lib.mkMerge [
        {
          users.users.piotr = {
            isNormalUser = true;
            description = "Piotr";
            extraGroups = [
              "wheel"
              "docker"
              "networkmanager"
            ];
          };
        }
        (lib.optionalAttrs (options ? encryptedAutologin.user) {
          encryptedAutologin.user = lib.mkDefault config.users.users.piotr.name;
        })
      ];
    };
}
