{ self, ... }:
{
  flake.modules.nixos.workstation = { lib, ... }: {
    imports = with self.modules.nixos; [
      common
      basePackages
    ];

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
