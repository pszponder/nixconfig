{
  flake.modules.nixos.printing = {
    services = {
      printing.enable = true;
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };

    hardware.printers = {
      ensurePrinters = [
        {
          name = "HL-L2350DW-2";
          description = "Brother HL-L2350DW";
          deviceUri = "ipp://BRWA8934A36F562.local:631/ipp/print";
          model = "everywhere";
        }
      ];
      ensureDefaultPrinter = "HL-L2350DW-2";
    };
  };
}
