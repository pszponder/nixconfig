{ lib, ... }: {
  xdg.mime = {
    enable = true;
    defaultApplications = {
      "text/html" = "brave-browser.desktop";
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";
      "x-scheme-handler/about" = "brave-browser.desktop";
      "x-scheme-handler/unknown" = "brave-browser.desktop";
    };
  };

  # System defaults; users can override these in their own dconf database.
  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          clock-format = "12h";
          show-battery-percentage = true;
        };
        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = true;
          night-light-schedule-automatic = true;
        };
        "org/gnome/desktop/session".idle-delay = lib.gvariant.mkUint32 300;
        "org/gnome/settings-daemon/plugins/power" = {
          idle-dim = true;
          power-saver-profile-on-low-battery = true;
          sleep-inactive-ac-type = "suspend";
          sleep-inactive-ac-timeout = lib.gvariant.mkInt32 900;
          sleep-inactive-battery-type = "suspend";
          sleep-inactive-battery-timeout = lib.gvariant.mkInt32 600;
        };
        "org/gnome/desktop/default-applications/terminal" = {
          exec = "ghostty";
          exec-arg = "-e";
        };
        "org/gnome/mutter".dynamic-workspaces = false;
        "org/gnome/desktop/wm/preferences".num-workspaces = lib.gvariant.mkInt32 9;
        "org/gnome/shell" = {
          always-show-log-out = true;
          favorite-apps = [
            "org.gnome.Nautilus.desktop"
            # "firefox.desktop"
            "brave-browser.desktop"
            # "brave-origin.desktop"
            "com.mitchellh.ghostty.desktop"
            "code.desktop"
            # "dev.zed.Zed.desktop"
            "md.obsidian.Obsidian.desktop"
            "discord.desktop"
          ];
        };
        "org/gnome/desktop/background" = {
          picture-uri = "file://${../../../assets/catppuccin-latte.png}";
          picture-uri-dark = "file://${../../../assets/catppuccin-mocha.png}";
          picture-options = "zoom";
        };
      };
    }
  ];
}
