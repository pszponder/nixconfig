{ lib, pkgs, ... }:
let
  workspaceNumbers = map toString (lib.range 1 9);
  emptyBindings = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
in
{
  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/desktop/wm/keybindings" = {
          close = [ "<Super>w" ];
          maximize = emptyBindings;
          toggle-maximized = [ "<Super>m" ];
          # Free Super+H for tiling.
          minimize = [ "<Super><Shift>m" ];
        }
        // lib.genAttrs (map (n: "switch-to-workspace-${n}") workspaceNumbers) (key: [
          "<Super>${lib.removePrefix "switch-to-workspace-" key}"
        ])
        // lib.genAttrs (map (n: "move-to-workspace-${n}") workspaceNumbers) (key: [
          "<Super><Shift>${lib.removePrefix "move-to-workspace-" key}"
        ]);
        "org/gnome/mutter/keybindings" = {
          toggle-tiled-left = [ "<Super>h" ];
          toggle-tiled-right = [ "<Super>l" ];
        };
        "org/gnome/shell/keybindings" = {
          toggle-message-tray = [ "<Super>v" ];
        }
        // lib.genAttrs (map (n: "switch-to-application-${n}") workspaceNumbers) (_: emptyBindings);
        "org/gnome/settings-daemon/plugins/media-keys" = {
          home = [ "<Super>f" ];
          www = [
            "<Super><Shift>Return"
            "<Super>b"
          ];
          screensaver = [ "<Control><Alt>Delete" ];
          logout = emptyBindings;
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/"
          ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal" = {
          name = "Launch default terminal";
          command = "${pkgs.xdg-terminal-exec}/bin/xdg-terminal-exec";
          binding = "<Super>Return";
        };
      };
    }
  ];
}
