{
  flake.modules.nixos.nixMaintenance = {
    nix.gc = {
      automatic = true;
      dates = "weekly";
      # Keep recent generations; live build and development roots remain protected.
      options = "--delete-older-than 30d";
    };

    system.autoUpgrade = {
      enable = true;
      dates = "Sun 18:00";
      randomizedDelaySec = "45min";
      # Flake inputs are updated explicitly; --upgrade only updates channels.
      upgrade = false;
      flags = [
        "--update-input"
        "nixpkgs"
        "--print-build-logs"
      ];
      allowReboot = false;
    };
  };
}
