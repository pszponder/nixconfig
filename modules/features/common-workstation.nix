{ self, ... }:
{
  flake.modules.nixos.workstationCommon =
    { pkgs, ... }:
    {
      imports = with self.modules.nixos; [
        workstation
        piotr
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
      system.autoUpgrade.flake = "/home/piotr/repos/github/pszponder/nixconfig";
    };
}
