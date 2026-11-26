# Add a NixOS host

## Install a persistent VM

1. Create an x86_64 guest, enable UEFI, attach a blank virtual disk, and connect a network adapter with internet access. For the workstation template, a 64 GiB disk leaves room for its 9 GiB swap file, packages, and future generations. Attach the NixOS installer ISO and boot the guest.
2. Create a host such as `lab-vm` using the [desktop walkthrough](#desktop-walkthrough). Scan **inside the guest** and select its virtual disk. If the hypervisor exposes no unique disk ID, give the virtual drive a serial or use its verified guest device path and keep the controller order fixed. For a local scan in a writable checkout, copy the template files and run `just bootstrap-hardware lab-vm` inside the guest.
3. Stage the host files. From that checkout in the guest run `just install-local lab-vm`. Alternatively, authorize your controller's public key on the live ISO and run `just install lab-vm nixos@GUEST_IP` from the controller checkout containing the host files. With NAT, configure SSH forwarding or use a reachable bridged interface.
4. Save the host files outside the live session. At the guest console run `sudo nixos-enter --root /mnt --command "passwd piotr"`, detach the ISO, and reboot from the virtual disk. Unlock LUKS at the VM console if enabled. Verify `hostname`, `findmnt /`, and `swapon --show`.

## Add a remote development host

For an x86_64 UEFI mini PC on your LAN, use a dedicated host directory, wired Ethernet with a DHCP reservation, and SSH key access. Keep project toolchains in each repository’s development shell. For a hosted VM, use the provider-specific boot and storage guidance [below](#creating-a-cloud-host) and reuse the SSH and development setup here.

1. **Boot the installer.** Back up the intended SSD and boot the [NixOS minimal ISO](https://nixos.org/download/) from USB in UEFI mode. At the live console, start SSH with `sudo systemctl start sshd` and put your laptop’s public key in the live user’s `~/.ssh/authorized_keys`. Use `ip -br address` to find the installer IP, then verify access and identify the drive from your laptop. Replace `INSTALLER_IP` with the address shown at the console.

   ```sh
   host=devbox
   target=nixos@INSTALLER_IP
   ssh "$target" 'sudo -n true && test -d /sys/firmware/efi &&
     lsblk -o NAME,SIZE,MODEL,SERIAL,TYPE,MOUNTPOINTS &&
     ls -l /dev/disk/by-id/'
   ```

2. **Create the host files.** Copy `default.nix` and `_disk.nix` from `kamigawa` into `modules/hosts/devbox/` and generate the new `_hardware-configuration.nix` using the [hardware scan commands](#desktop-walkthrough). Use the verified whole-drive ID in `default.nix`. Keep Disko, the disk layout, and the hardware import. Replace `workstationCommon` and `gnome` with `common` and `piotr` for a headless server. Set `system.stateVersion` at first install and retain it on upgrades. For a UEFI server with DHCP, add these settings beside `networking.hostName`:

   ```nix
   boot.loader.systemd-boot.enable = true;
   boot.loader.efi.canTouchEfiVariables = true;
   networking.useDHCP = true;
   users.users.piotr.openssh.authorizedKeys.keys = [
     "ssh-ed25519 REPLACE_WITH_YOUR_PUBLIC_KEY"
   ];
   services.openssh = {
     enable = true;
     settings = {
       PasswordAuthentication = false;
       KbdInteractiveAuthentication = false;
       PermitRootLogin = "no";
     };
   };
   ```

3. **Choose how the server boots.** The template’s LUKS layout needs a passphrase at the console before SSH starts. Keep the encrypted root layout and give the mapper a host-specific name such as `devbox-crypt`. For unattended reboot, configure and test an unlock method appropriate to the host. Review the swap size for the available disk space.

4. **Build and verify before installing.** From your laptop, stage the host files and check that the evaluated disk path matches the whole drive you identified:

   ```sh
   git add -- "modules/hosts/$host"
   nix eval --raw ".#nixosConfigurations.$host.config.disko.devices.disk.main.device"
   just build "$host"
   ```

   For the template’s LUKS layout, run `just install-test "$host"` to rehearse on a disposable VM disk. **`just install "$host" "$target"` erases the selected drive.** Run it after the build and the [remote disk and headless access checks](install.md#verify-the-selected-disk) succeed, then [set Piotr’s login password and boot from the SSD](install.md#4-set-the-login-password-and-boot).

5. **Verify access and start developing.** Use the router’s DHCP reservation for a stable LAN address. Connect as `piotr`, run `sudo -v` to verify elevation, and reboot once more to check that the machine is reachable with the chosen unlock procedure. Use [`just deploy devbox piotr@DEVBOX_IP`](maintenance.md#update-an-existing-nixos-host-over-ssh) for later system updates. On the server, clone a project, run `tmux new -s dev`, and enter its shell with `nix develop` if it defines one. For a web app listening on the server’s loopback port 3000, run `ssh -L 3000:localhost:3000 piotr@DEVBOX_IP` from your laptop and open `http://localhost:3000`. For access away from home, use a private VPN and keep SSH off the router’s public port forwards.

## Add a desktop

For a second desktop that should feel like the ThinkPad, start with `kamigawa` as a **directory template**. The [shared workstation profile](../modules/features/common-workstation.nix) supplies packages, bootloader, kernel, networking, and maintenance. [Piotr’s account module](../modules/users/piotr/default.nix) grants the `wheel`, `docker`, and `networkmanager` groups wherever it is imported. Keep the hostname, disk identity, hardware, and `system.stateVersion` in the host directory. The ThinkPad adds its own disk, drivers, fingerprint reader, and Kanata configuration. Give the desktop its own host directory so future shared changes reach both machines and hardware changes stay local.

## Desktop walkthrough

1. **Collect the desktop's hardware information.** Back up the intended drive. Boot a NixOS installer USB in UEFI mode, connect it to the network and authorize the controller's SSH key. Run these commands on the controller, replacing the example address. Identify the drive by model, size and serial, especially if the desktop also has a data drive.

   ```sh
   host=new-host
   target=nixos@192.0.2.10
   ssh "$target" 'test -d /sys/firmware/efi && echo UEFI'
   ssh "$target" 'lsblk -o NAME,SIZE,MODEL,SERIAL,TYPE,MOUNTPOINTS; ls -l /dev/disk/by-id/'
   ```

2. **Create the host in the same checkout.** Choose an unused hostname. The template takes its flake output name and hostname from its directory. On the controller:

   ```sh
   host_dir="modules/hosts/$host"
   mkdir "$host_dir" && cp modules/hosts/kamigawa/{default,_disk}.nix "$host_dir/"
   scan=$(mktemp)
   ssh "$target" 'sudo -n nixos-generate-config --show-hardware-config --no-filesystems' > "$scan" &&
     test -s "$scan" && cp "$scan" "$host_dir/_hardware-configuration.nix"
   ```

   The scan supplies the new host’s hardware configuration. Disko declares the filesystems. If the machine is running Ubuntu and you prefer to install directly over SSH, the [installer walkthrough](install.md#first-installation-on-a-new-host) includes hardware generation during the transition to the temporary installer.

3. **Edit the new host's `default.nix`.** Replace Kamigawa’s disk identifier with the verified whole-drive path, such as `/dev/disk/by-id/…`. Give the mapper in `_disk.nix` a host-specific name. The [shared encrypted layout](../modules/hosts/_encrypted-disk.nix) defines the partitions, filesystems, and swap. Add desktop-only settings in the existing module block beside `networking.hostName`. For example, enable SSH there if you want to update the machine remotely. Replace the example text with the complete contents of your controller's public key file:

   ```nix
   services.openssh.enable = true;
   users.users.piotr.openssh.authorizedKeys.keys = [
     "ssh-ed25519 REPLACE_WITH_YOUR_PUBLIC_KEY"
   ];
   ```

   The host imports `gnome` alongside `workstationCommon` to select GNOME and GDM. To use another desktop, replace the host’s `gnome` import with the configuration for your chosen session and display manager.

   Review the generated drivers and add settings for peripherals that actually exist, such as a discrete GPU requiring a particular driver. To change a feature for both desktops, edit the module they both import. To change only this desktop, edit its host directory.

4. **Verify the selection before installing.** Stage the new files so Nix can see them. Compare the evaluated device with the disk you identified in step 1. The VM test exercises formatting, LUKS unlock, boot and a generation switch. Physical GPU, network and peripheral support need a check on the actual desktop.

   ```sh
   git add -- "$host_dir"
   nix eval --raw ".#nixosConfigurations.$host.config.disko.devices.disk.main.device"
   just build "$host"
   just install-test "$host"
   ```

5. **Install, then set the login password.** Complete the [remote disk check](install.md#verify-the-selected-disk) and, for SSH-managed machines, the headless access check below it. From an interactive terminal run `just install "$host" "$target"`. **This erases the selected drive.** Enter the new LUKS passphrase when prompted. With the installer still running, set Piotr's login password, reboot from the drive, and unlock it at the desktop console. The [first-boot instructions](install.md#4-set-the-login-password-and-boot) include the commands for USB and kexec installations.

6. Save the host configuration in Git and restore the checkout at `~/repos/github/pszponder/nixconfig` on the installed desktop for scheduled maintenance. Use `just switch` locally or `just deploy new-host piotr@DESKTOP_IP` remotely for later changes. Use `just install` again only for a deliberate clean reinstall.

## Creating a cloud host

Provision a disposable instance first. Choose a unique host directory such as `hetzner-web`, `do-dev`, or `ec2-build`. Record the guest architecture, boot mode, root volume identifier, network setup, SSH user, and recovery-console access. A hardware scan describes devices; it doesn't capture the cloud account's network, firewall, or volume settings.

For a **graphical UEFI VM**, follow the desktop steps. Generate the hardware configuration inside the guest. For a **headless server**, keep the host-directory pattern and select the services it needs. For a compatible x86_64 UEFI guest, replace `workstationCommon` and `gnome` with `common` and `piotr` as in the [remote development host](#add-a-remote-development-host). Configure the guest’s bootloader and networking for the provider. Retain the disko module, the host’s `_disk.nix`, and the guest hardware module, and put the following settings beside the host's disk selection:

```nix
boot.loader.systemd-boot.enable = true;
services.openssh.enable = true;
users.users.piotr.openssh.authorizedKeys.keys = [
  "ssh-ed25519 REPLACE_WITH_YOUR_PUBLIC_KEY"
];
system.stateVersion = "26.05"; # Choose at first install and retain on upgrades.
```

Set up the instance's required networking and allow SSH from the controller in the provider firewall. For UEFI, verify how the guest persists boot entries and whether it needs the removable-media boot path. For legacy BIOS, supply a BIOS-compatible disko layout and bootloader, such as GPT with a BIOS boot partition and GRUB. The sample disk layout and its VM check assume UEFI. The supplied checks run on x86_64 Linux; ARM instances need an appropriate configuration and builder.

**Decide how the VM will unlock after a reboot.** The sample LUKS layout prompts before ordinary SSH starts. Verify that you can see and type at the early boot prompt through the provider console. If you need unattended reboot, choose a suitable storage and unlock policy before installing. On EC2, encrypted EBS is one option when provider-managed encryption meets your requirements. [AWS EBS encryption](https://docs.aws.amazon.com/ebs/latest/userguide/ebs-encryption.html)

| Provider | Starting point and host-specific decisions |
| --- | --- |
| **Hetzner Cloud** | The upstream nixos-anywhere quickstart uses a Hetzner VM. Start from an SSH-accessible image with root or passwordless sudo, or activate Hetzner Rescue and SSH into the rescue system. Verify firmware mode, whole disk, public networking and any private networks on this instance. After installation, boot from the local disk. [nixos-anywhere quickstart](https://nix-community.github.io/nixos-anywhere/quickstart.html) · [Hetzner Rescue](https://docs.hetzner.com/cloud/servers/getting-started/rescue-system/) |
| **DigitalOcean** | Start with an SSH-accessible Linux Droplet. Check its actual firmware mode before choosing a disko layout. Record the public interface, gateway and VPC settings, and distinguish the Droplet root disk from attached volumes. Test access to the recovery console. DigitalOcean also provides a recovery ISO if the installed system becomes inaccessible. [Droplet recovery](https://docs.digitalocean.com/products/droplets/how-to/recovery/) · [Recovery Console](https://docs.digitalocean.com/products/droplets/how-to/connect-with-recovery-console/) |
| **AWS EC2** | For a new instance, the simplest route is an official NixOS AMI for the region and architecture. Preserve its EC2 guest, boot and root filesystem configuration in the host module, add the desired user and services, then use `just deploy` with the AMI's authorized login. For a deliberate disko reinstall from Ubuntu, snapshot the root EBS volume, identify it inside the guest, check boot mode and storage/network drivers, and verify serial-console access and permissions before choosing interactive LUKS. [Official NixOS AMIs](https://nixos.org/download/#nixos-amazon) · [Identify the EC2 root device](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/find-root-device-type.html) · [EC2 serial-console prerequisites](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-serial-console-prerequisites.html) |

For each cloud host, build the host output and verify the evaluated disk before a clean install. On the disposable instance, reboot once, reconnect over SSH using the **installed** account, verify the root filesystem and network, and try `just deploy HOST USER@TARGET test`. This tests provider boot and connectivity in addition to what the local VM test covers.
