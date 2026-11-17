{
  flake.modules.nixos.webapps =
    { lib, pkgs, ... }:
    let
      # Dashboard Icons is also recommended by Omarchy. Pin the revision for reproducibility.
      iconBaseUrl = "https://raw.githubusercontent.com/homarr-labs/dashboard-icons/d4b500dc40a8e1043b1581cabb7208892cf35472/png";
      # Add or remove web apps here; each icon is fetched and hash-checked by Nix.
      webapps = [
        {
          name = "ChatGPT";
          url = "https://chatgpt.com";
          iconName = "chatgpt";
          iconHash = "sha256-TogafwFxgWgUOHSNJAkkChBOF2SGCEe0nolK+sAy9a0=";
        }
        {
          name = "Gmail";
          url = "https://mail.google.com";
          iconName = "gmail";
          iconHash = "sha256-ABl4wcL3X/jXcQNIKO/nqTlGNAj8a2RnrpUGMcduGdE=";
        }
        {
          name = "Google Docs";
          url = "https://docs.google.com";
          iconName = "google-docs";
          iconHash = "sha256-xN2P2nNl4VCbHcalDXjiejHagzYGGL8cKfFrYBEFnUw=";
        }
        {
          name = "Google Photos";
          url = "https://photos.google.com";
          iconName = "google-photos";
          iconHash = "sha256-IJR90l0DBsOi5kQgLJMr7/xgNlRa9QJskh8tpe6/PoA=";
        }
        {
          name = "Grok";
          url = "https://grok.com";
          iconName = "grok";
          iconHash = "sha256-c8qACA47PbWONCVlVSRFzdceWHGwi9KvJSLoTkOTNpE=";
        }
        {
          name = "X";
          url = "https://x.com";
          iconName = "x";
          iconHash = "sha256-Mqfi3t5eKflHJKJn+WdD/ekxA4w/O+E4At4Vm1SHkeI=";
        }
        {
          name = "YouTube";
          url = "https://www.youtube.com";
          iconName = "youtube";
          iconHash = "sha256-IXEiZv0BxEfja0Rh/4YSRzXEg8iSElLAEfCkNUcDFVI=";
        }
        {
          name = "YouTube Music";
          url = "https://music.youtube.com";
          iconName = "youtube-music";
          iconHash = "sha256-2XzJkhMPbmLjuHiD/kIh7qA9B5gZ3Uby60U2nQC2dqI=";
        }
      ];
    in
    {
      environment.systemPackages = [
        pkgs.google-chrome
      ]
      ++ map (
        app:
        let
          id = "webapp-${builtins.substring 0 16 (builtins.hashString "sha256" app.url)}";
          # Chrome identifies URL apps by host + "_" + path, not by our launcher ID.
          urlParts = builtins.match "https?://([^/?#]+)([^?#]*).*" app.url;
          host = lib.toLower (builtins.elemAt urlParts 0);
          path = builtins.elemAt urlParts 1;
          appName = "${host}_${if path == "" then "/" else path}";
          illegalChars = lib.stringToCharacters "<>:\"/\\|?*";
          sanitizedAppName = lib.replaceStrings illegalChars (map (_: "_") illegalChars) appName;
          # X11 trims surrounding underscores; Wayland keeps them in its desktop ID.
          wmClass = builtins.head (builtins.match "_*([^_](.*[^_])?)_*" sanitizedAppName);
          desktopId = "chrome-${lib.replaceStrings [ " " ] [ "_" ] sanitizedAppName}-Default";
          icon = pkgs.fetchurl {
            url = "${iconBaseUrl}/${app.iconName}.png";
            hash = app.iconHash;
          };
          launcher = pkgs.writeShellScript id ''
            exec ${pkgs.google-chrome}/bin/google-chrome-stable --profile-directory=Default --app=${lib.escapeShellArg app.url} "$@"
          '';
        in
        pkgs.makeDesktopItem {
          name = desktopId;
          desktopName = app.name;
          exec = "${launcher}";
          icon = "${icon}";
          terminal = false;
          startupWMClass = wmClass;
          categories = [ "Network" ];
        }
      ) webapps;
    };
}
