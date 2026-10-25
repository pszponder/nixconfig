{self, inputs, ...}: {

  # Define flake part nixosModule "tpx1Configuration" and pass in configuration from /etc/nixos/configuration.nix
  flake.nixosModules.tpx1Configuration = {pkgs, lib, ...}: {

    # Insert the contents of your original configuration from /etc/nixos/configuration.nix here
    # Help is available in the configuration.nix(5) man page, on
    # https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

    # Define modules to import
    imports = with self.nixosModules; [
      tpx1Hardware
      kanata
    ];

  
    # Enable Flakes
    nix.settings.experimental-features = [ 
      "nix-command" 
      "flakes"
    ];

    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Use latest kernel.
    boot.kernelPackages = pkgs.linuxPackages_latest;

    networking.hostName = "tpx1"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Enable networking
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "America/Denver";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    # Enable the GNOME Desktop Environment.
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      # jack.enable = true;
    };

    users.users."piotr" = {
      isNormalUser = true;
      description = "Piotr";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [
      #  thunderbird
      ];
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Applications w/ NixOS modules
    programs.firefox.enable = true;
    
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    # General-purpose packages
    environment.systemPackages = with pkgs; [
      devenv
      git
      jq
      vim
      wget
    ];

    # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
    # and migrated your data accordingly.
    #
    # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
    system.stateVersion = "26.05"; # Did you read the comment?
  };
}

