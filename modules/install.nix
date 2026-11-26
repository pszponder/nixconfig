{ self, ... }:
let
  installTest =
    host: layout:
    (host.extendModules {
      modules = [
        layout
        {
          disko.tests = {
            extraConfig.specialisation.updated.configuration.environment.etc."install-test-generation".text =
              "updated";
            extraChecks = ''
              machine.wait_for_unit("multi-user.target")
              machine.succeed("mountpoint /boot && swapon --show=NAME --noheadings | grep .")
              machine.succeed("touch /root/installation-persisted")
              # The VM shares a read-only 9p store. Nix needs to set its directory ownership.
              machine.succeed("mkdir -p /root/store-upper /root/store-work")
              machine.succeed("mount -t overlay overlay -o lowerdir=/nix/store,upperdir=/root/store-upper,workdir=/root/store-work /nix/store")
              # Import the installation closure into the booted guest's empty Nix database.
              machine.succeed("registration=$(grep -lFx \"$(readlink -f /run/current-system)\" /nix/store/*-closure-info/registration | head -n1) && nix-store --load-db < \"$registration\"")
              machine.succeed("nixos-rebuild switch --store-path $(readlink -f /run/current-system/specialisation/updated)")
              machine.succeed("grep -Fx updated /etc/install-test-generation && test -f /root/installation-persisted")
            '';
          };
        }
      ];
    }).config.system.build.installTest;
in
{
  perSystem =
    {
      pkgs,
      lib,
      system,
      ...
    }:
    let
      plain = _: {
        # disko's test VM supplies a sparse 4 GiB disk.
        disko.devices.disk.main.content.partitions.root.end = lib.mkForce "-512M";
      };
      encrypted =
        host:
        let
          mapper = host.config.disko.devices.disk.main.content.partitions.system.content.name;
        in
        {
          swapDevices = lib.mkForce [
            {
              device = "/swapfile";
              size = 256;
            }
          ];
          disko = {
            # The disko test installer creates this fixture on its temporary root.
            devices.disk.main.content.partitions.system.content.passwordFile = "/tmp/secret.key";
            tests = {
              enableOCR = true;
              bootCommands = ''
                machine.wait_for_text("[Pp]assphrase")
                machine.send_chars("secretsecret\n")
              '';
              extraChecks = lib.mkAfter ''
                machine.succeed("cryptsetup status ${mapper} | grep -iw LUKS2")
                machine.succeed("test $(findmnt -no MAJ:MIN /) = $(lsblk -dnro MAJ:MIN /dev/mapper/${mapper})")
                machine.succeed("test $(swapon --noheadings --show=NAME) = /swapfile && test $(findmnt -no TARGET -T /swapfile) = /")
              '';
            };
          };
        };
      testLayouts = {
        kamigawa = encrypted;
        tpx1 = plain;
        tpx1-encrypted = encrypted;
      };
      hosts = lib.filterAttrs (
        _: host: host.pkgs.stdenv.hostPlatform.system == system
      ) self.nixosConfigurations;
      missing = lib.subtractLists (builtins.attrNames testLayouts) (builtins.attrNames hosts);
    in
    {
      packages.nixos-anywhere = pkgs.nixos-anywhere;
      checks =
        assert lib.assertMsg (
          missing == [ ]
        ) "Choose an install test layout in modules/install.nix for: ${lib.concatStringsSep ", " missing}";
        lib.mapAttrs' (
          name: host: lib.nameValuePair "${name}-install" (installTest host (testLayouts.${name} host))
        ) hosts;
    };
}
