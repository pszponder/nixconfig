{
  flake.modules.nixos.printing =
    { pkgs, ... }:
    {
      services = {
        printing = {
          enable = true;
          browsed.enable = false;
        };
        avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
        };
      };

      # The IPP Everywhere setup probes the physical printer. Run it separately
      # so an unreachable printer cannot prevent CUPS from starting.
      systemd.services.setup-brother-printer = {
        wantedBy = [ "multi-user.target" ];
        requires = [ "cups.service" ];
        after = [
          "cups.service"
          "avahi-daemon.service"
        ];
        path = [ pkgs.cups ];
        environment.LC_ALL = "C";
        serviceConfig = {
          Type = "oneshot";
          Restart = "on-failure";
          RestartSec = "1min";
        };
        script = ''
          printer=HL-L2350DW-2
          uri=ipp://BRWA8934A36F562.local:631/ipp/print

          if [ "$(lpstat -v "$printer")" != "device for $printer: $uri" ]; then
            lpadmin -p "$printer" -E -v "$uri" -m everywhere -D 'Brother HL-L2350DW'
          fi
          if [ "$(lpstat -d)" != "system default destination: $printer" ]; then
            lpadmin -d "$printer"
          fi
        '';
      };
    };
}
