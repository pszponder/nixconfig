{ self, ... }:
{
  flake.modules.nixos.workstation = { lib, pkgs, ... }: {
    imports = with self.modules.nixos; [
      common
      basePackages
      piotr
      encryptedAutologin
      nixMaintenance
      desktopPackages
      webapps
      docker
      printing
    ];

    boot = {
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;
      kernelPackages = pkgs.linuxPackages_latest;
    };
    networking.networkmanager.enable = true;

    time.timeZone = lib.mkDefault "America/Denver";
    security.rtkit.enable = true;
    services = {
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
    };
  };
}
