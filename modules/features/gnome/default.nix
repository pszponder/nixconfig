_: {
  flake.modules.nixos.gnome = { pkgs, ... }: {
    imports = [
      ./_preferences.nix
      ./_keybindings.nix
    ];

    services = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      gnome.core-developer-tools.enable = false;
      gnome.games.enable = false;
      xserver.xkb = {
        layout = "us";
        variant = "";
      };
    };

    programs.dconf.enable = true;
    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      gnome-user-docs
    ];

    environment.systemPackages = [
      pkgs.xdg-terminal-exec
    ];
  };
}
