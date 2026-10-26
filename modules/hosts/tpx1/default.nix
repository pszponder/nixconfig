{ inputs, self, ... }:
{
  flake.nixosConfigurations.tpx1 = inputs.nixpkgs.lib.nixosSystem {
    modules = [ self.modules.nixos.tpx1 ];
  };

  flake.modules.nixos.tpx1 = { pkgs, ... }: {
    imports = with self.modules.nixos; [
      baseConfiguration
      basePackages
      tpx1Hardware
      piotr
      desktopPackages
      gnome
      docker
      kanata
    ];

    boot = {
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;
      kernelPackages = pkgs.linuxPackages_latest;
    };
    networking = {
      hostName = "tpx1";
      networkmanager.enable = true;
    };
    time.timeZone = "America/Denver";
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
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
    };
    security.rtkit.enable = true;
    services = {
      printing.enable = true;
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
    };
    # Preserve the compatibility defaults of the original installation.
    system.stateVersion = "26.05";
  };
}
