{
  flake.modules.nixos.webapps =
    { lib, pkgs, ... }:
    let
      # Add or remove web apps here; each icon is fetched and hash-checked by Nix.
      webapps = [
        {
          name = "ChatGPT";
          url = "https://chatgpt.com";
          iconUrl = "https://chatgpt.com/cdn/assets/favicon-180x180.9e0103ce69.png";
          iconHash = "sha256-xFCh48N1v1xtHbEDJ7WaWPW9bkmQ/9v28pLj0WHGaN4=";
        }
        {
          name = "Gmail";
          url = "https://mail.google.com";
          iconUrl = "https://ssl.gstatic.com/ui/v1/icons/mail/rfr/gmail.ico";
          iconHash = "sha256-KlyD3X9GNIECGLpw4/6VUPtdiH40nLRtd0GescdLwpk=";
        }
        {
          name = "Google Docs";
          url = "https://docs.google.com";
          iconUrl = "https://ssl.gstatic.com/docs/documents/images/kix-favicon7.ico";
          iconHash = "sha256-1A6TdrL4yPpeA3LD3ay19gRFOc8dJku8vugFfa9x7ZY=";
        }
        {
          name = "Google Photos";
          url = "https://photos.google.com";
          iconUrl = "https://storage.googleapis.com/gweb-mobius-cdn/photos/uploads/383ce0413fa82bcaf6de49fd7997678b21b9762e.svg";
          iconHash = "sha256-W2NtG1tZy05Lm5LSXH7NSij/cv50LtDChir104PZq8g=";
        }
        {
          name = "Grok";
          url = "https://grok.com";
          iconUrl = "https://grok.com/images/android-chrome-192x192.png";
          iconHash = "sha256-doy796dSjW57OvgRLXzeQ+tsnImJrZsGvoBH2uEidGM=";
        }
        {
          name = "X";
          url = "https://x.com";
          iconUrl = "https://x.com/apple-touch-icon.png";
          iconHash = "sha256-qDVC6wVjJClJ19vecgAU+3q0iuFO1Z9D7sNJB8uQxHc=";
        }
        {
          name = "YouTube";
          url = "https://www.youtube.com";
          iconUrl = "https://www.youtube.com/s/desktop/bf021a32/img/favicon_144x144.png";
          iconHash = "sha256-453D2ML4KtI3UTKo789SHCMtXizwir65vr4a2Ur7IVc=";
        }
        {
          name = "YouTube Music";
          url = "https://music.youtube.com";
          iconUrl = "https://music.youtube.com/img/favicon_144.png";
          iconHash = "sha256-EeHjawpnPC0RgpdCUJRpeVk8inVqRIUdD0UpcowaRwk=";
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
          iconSource = pkgs.fetchurl {
            url = app.iconUrl;
            hash = app.iconHash;
          };
          # Desktop icons support PNG and SVG; convert ICO sources at build time.
          icon =
            if lib.hasSuffix ".ico" app.iconUrl then
              pkgs.runCommand "${id}-icon.png" { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
                magick "${iconSource}[0]" "PNG:$out"
              ''
            else
              iconSource;
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
