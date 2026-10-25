{ inputs, moduleWithSystem, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      cache = pkgs.runCommand "bat-theme-cache" { } ''
        mkdir -p "$out/config/themes" "$out/cache"
        cp ${./themes}/* "$out/config/themes/"
        BAT_CONFIG_DIR="$out/config" BAT_CACHE_PATH="$out/cache" ${pkgs.bat}/bin/bat cache --build
      '';
    in
    {
      packages.configured-bat = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.bat;
        env = {
          BAT_THEME = "Catppuccin Mocha";
          BAT_CACHE_PATH = "${cache}/cache";
        };
      };
    };
  flake.nixosModules.bat = moduleWithSystem (
    { self', ... }: {
      environment.systemPackages = [ self'.packages.configured-bat ];
    }
  );
}
