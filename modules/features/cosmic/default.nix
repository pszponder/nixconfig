_: {
  flake.modules.nixos.cosmic = _: {
    services = {
      desktopManager.cosmic.enable = true;
      displayManager.cosmic-greeter.enable = true;
      system76-scheduler.enable = true;
    };

    programs.firefox.preferences."widget.gtk.libadwaita-colors.enabled" = false;
  };
}
