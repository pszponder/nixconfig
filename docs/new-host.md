# Add a desktop or cloud VM as a NixOS host

For a second desktop that should feel like the ThinkPad, start with `kamigawa` as a **directory template**. Both hosts import the same [workstation profile](../modules/features/workstation.nix) for the common baseline, development tools, and audio. Set boot, networking, account groups, maintenance, and `system.stateVersion` in the host definition. Each host explicitly selects its desktop session, graphical applications, Docker, and printing. The ThinkPad adds its own disk, drivers, fingerprint reader, and Kanata configuration. Give the desktop its own host directory so future shared changes reach both machines and hardware changes stay local.

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

   The scan supplies the new host’s hardware configuration. Disko declares the filesystems. If the machine is running Ubuntu and you prefer to install directly over SSH, the [installer walkthrough](encrypted-install.md#3-build-and-install) includes hardware generation during the transition to the temporary installer.

3. **Edit the new host's `default.nix`.** Replace Kamigawa’s disk identifier with the verified whole-drive path, such as `/dev/disk/by-id/…`. Review the new host’s `_disk.nix` for its partition sizes, encryption, filesystems, and mount points. Add desktop-only settings in the existing module block beside `networking.hostName`. For example, enable SSH there if you want to update the machine remotely. Replace the example text with the complete contents of your controller's public key file:

   ```nix
   services.openssh.enable = true;
   users.users.piotr.openssh.authorizedKeys.keys = [
     "ssh-ed25519 REPLACE_WITH_YOUR_PUBLIC_KEY"
   ];
   ```

   Choose the desktop session in this host’s module list. Keep `self.modules.nixos.gnome` for the ThinkPad’s GNOME session and GDM login. For Niri or Hyprland, remove that import and set `programs.niri.enable = true;` or `programs.hyprland.enable = true;` in the host’s configuration block. Select a display manager separately if you want graphical login. The disk layout, install command and future rebuilds use the same host name regardless of desktop choice.

   Review the generated drivers and add settings for peripherals that actually exist, such as a discrete GPU requiring a particular driver. To change a feature for both desktops, edit the module they both import. To change only this desktop, edit its host directory.

4. **Verify the selection before installing.** Stage the new files so Nix can see them. Compare the evaluated device with the disk you identified in step 1. The VM test exercises formatting, LUKS unlock, boot and a generation switch. Physical GPU, network and peripheral support need a check on the actual desktop.

   ```sh
   git add -- "$host_dir"
   nix eval --raw ".#nixosConfigurations.$host.config.disko.devices.disk.main.device"
   just build "$host"
   just install-test "$host"
   ```

5. **Install, then set the login password.** From an interactive terminal run `just install "$host" "$target"`. **This erases the selected drive.** Enter the new LUKS passphrase when prompted. With the installer still running, set Piotr's login password, reboot from the drive, and unlock it at the desktop console. The [first-boot instructions](encrypted-install.md#4-set-the-login-password-and-boot) include the commands for USB and kexec installations.

6. Save the host configuration in Git and restore the checkout at `~/repos/github/pszponder/nixconfig` on the installed desktop for scheduled maintenance. Use `just switch` locally or `just deploy new-host piotr@DESKTOP_IP` remotely for later changes. Use `just install` again only for a deliberate clean reinstall.

## Creating a cloud host

Provision a disposable instance first. Choose a unique host directory such as `hetzner-web`, `do-dev`, or `ec2-build`. Record the guest architecture, boot mode, root volume identifier, network setup, SSH user, and recovery-console access. A hardware scan describes devices; it doesn't capture the cloud account's network, firewall, or volume settings.

For a **graphical UEFI VM**, follow the desktop steps. Generate the hardware configuration inside the guest. For a **headless server**, keep the host-directory pattern and select the services it needs. For example, on a compatible x86_64 UEFI guest where you want interactive LUKS, remove the GNOME, desktop package, web app, Docker and printing imports unless needed. Replace the `workstation` import with `self.modules.nixos.common` and keep `self.modules.nixos.piotr` if you want that account. Review the copied NetworkManager, kernel, account groups, and maintenance settings for the server. Retain the disko module, the host’s `_disk.nix`, and the guest hardware module, and put the following settings beside the host's disk selection:

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
