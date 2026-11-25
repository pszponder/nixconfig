# Install or reinstall an encrypted workstation

For routine configuration changes on an installed NixOS host, use `just deploy HOST USER@TARGET`. Continue below when you intend to erase the configured target disk. See [remote deployment](maintenance.md#update-an-existing-nixos-host-over-ssh).

Run the commands from a second x86_64 Linux machine with Nix flakes, just, and this repository. The controller can be the computer hosting the VM. The target is the laptop or VM whose disk you intend to erase. **Back up the target or take a VM snapshot before installing.** A clean install replaces the OS, existing encryption keys, user accounts and data on the selected disk.

## 1. Connect to the target

| Target at startup | How to connect |
| --- | --- |
| Ubuntu or installed NixOS with SSH and working kexec | Use the existing SSH account. It needs root access or passwordless sudo. The recipe starts a temporary NixOS installer in RAM. Ubuntu does not need Nix installed. |
| Empty VM, inaccessible OS, or kexec unavailable | Boot a NixOS installer ISO in the VM, or a NixOS USB on the laptop. Choose UEFI mode and connect it to the network. |
| Already running the live NixOS installer | Use its SSH account. The recipe recognizes the installer and proceeds directly to disk setup. |

Open the laptop or VM console now. You’ll need it to unlock the encrypted disk on first boot and after subsequent reboots. If starting from Ubuntu on a laptop with Wi-Fi, the live USB path lets you establish networking in the installer before starting.

For the live installer, run `sudo systemctl start sshd` and `ip -br address` at its console. To authorize your controller, either add its **public** key to the live user's `~/.ssh/authorized_keys`, or set a temporary live user password with `sudo passwd nixos` and run `ssh-copy-id nixos@TARGET_IP` from the controller if password SSH is enabled. For an existing OS, use a key authorized for that OS's installation account. Keep a copy of the public key in the account's `~/.ssh/authorized_keys` so it can be carried into the temporary installer.

From the controller, substitute your target's actual IP and username:

```sh
address=192.0.2.10
target=ubuntu@$address    # use nixos@$address for a live ISO or USB
ssh "$target" 'id -un; sudo -n true && lsblk -o NAME,PATH,SIZE,MODEL,TYPE,MOUNTPOINTS && ls -l /dev/disk/by-id/'
ssh "$target" 'test -d /sys/firmware/efi && echo UEFI'
```

Proceed once you can identify the intended whole disk, authenticate and run sudo without a password. The supplied workstation configurations use UEFI. For a BIOS-mode VM, enable UEFI in the hypervisor and boot the installer ISO in that mode.

## 2. Select or add a host

Each target has its own flake output. Keep the host configurations together in this checkout. For a reinstall, reuse the existing output after checking the drive identity.

| Target | Set the host variable on the controller | Disk and hardware |
| --- | --- | --- |
| Original ThinkPad | `host=tpx1-encrypted` | Verify the WWN in [the encrypted host hardware module](../modules/hosts/tpx1-encrypted/hardware.nix). |
| Kamigawa desktop | `host=kamigawa` | Verify the drive WWN in the [host configuration](../modules/hosts/kamigawa/default.nix). |
| New machine | `host=office-pc` (choose its actual hostname) | Add a host once using the steps below. |

### First installation on a new host

For a worked desktop example and provider-specific cloud choices, see [Add a desktop or cloud VM](new-host.md).

1. Pick an unused hostname. Copy Kamigawa’s host definition and disk layout as a starting point. The directory name becomes the flake output and the installed hostname.

   ```sh
   host=office-pc
   host_dir="modules/hosts/$host"
   mkdir "$host_dir" && cp modules/hosts/kamigawa/{default,_disk}.nix "$host_dir/"
   ```

2. In the new directory's `default.nix`, set `disko.devices.disk.main.device` to the target's verified whole-disk path, preferably under `/dev/disk/by-id/`. The copied [disk layout](../modules/hosts/kamigawa/_disk.nix) supplies LUKS2, ext4 root and a 9 GiB swap file. Allow space for swap, the desktop system and future generations.
3. Set up the new host's `_hardware-configuration.nix`. If the target is booted into a NixOS installer or running NixOS, capture and review its hardware scan:

   ```sh
   scan=$(mktemp)
   ssh "$target" 'sudo -n nixos-generate-config --show-hardware-config --no-filesystems' > "$scan" &&
     test -s "$scan" && cp "$scan" "$host_dir/_hardware-configuration.nix"
   ```

   Starting from Ubuntu, you can boot the installer ISO for this scan, or use the pinned installer's hardware-generation option during installation as described below. Disko supplies filesystem declarations, so the scan excludes them.

4. Stage the new directory with `git add -- "$host_dir"`. Review and retain the host configuration, including the final hardware scan, for subsequent reinstalls and updates. The copied layout has an automatic VM check. If you change the filesystem, mount points, or swap strategy, review the assertions in `modules/installation/default.nix` and adapt the test for that host.

The supplied workstation hosts use UEFI and systemd-boot. For a different boot scheme, disk topology, or CPU architecture, supply appropriate host modules and a compatible builder. The shipped examples and VM checks target x86_64 Linux.

If you want SSH **after** installation, enable `services.openssh.enable` and declare the controller’s public key in `users.users.piotr.openssh.authorizedKeys.keys` in the target configuration before building. The Ubuntu or installer SSH account is temporary. With local console login only, the installed configuration needs no SSH key.

## 3. Build and install

From the selected checkout, use an interactive terminal. Apply the controller cache settings in the [README](../README.md#clean-install-on-tpx1) if needed.

```sh
just install-test "$host"
nix build --no-link ".#nixosConfigurations.${host}.config.system.build.toplevel"
just install "$host" "$target"
```

For a first installation from Ubuntu that needs a hardware scan, use the following command **in place of** `just install`. It enters the temporary NixOS installer, writes the detected hardware module back to the controller before building the real system, then partitions and installs. The earlier VM check only covers the configuration available at the time it runs. Review the generated file, repeat the check and save it in Git.

```sh
nix run .#nixos-anywhere -- --flake ".#$host" --target-host "$target" \
  --phases kexec,disko,install \
  --generate-hardware-config nixos-generate-config "$host_dir/_hardware-configuration.nix"
```

The first command exercises installation and a generation switch on a disposable VM disk. The last command asks for confirmation, enters the installer if needed, **erases the selected target disk**, and prompts twice for the LUKS passphrase. Keep a recovery copy of that passphrase. The EFI partition is unencrypted. Root and the swap file live inside LUKS2.

## 4. Set the login password and boot

The recipe leaves the installer running with the new system mounted at `/mnt`. From the controller, use `root` for the temporary installer reached via kexec. For a live USB or ISO, you can use the original `nixos` account:

```sh
installer=root@$address       # or installer=nixos@$address for live media
ssh -t "$installer" 'sudo nixos-enter --root /mnt --command "passwd piotr"'
```

If SSH reports a changed host key after the OS transition, verify the new fingerprint at the target console before replacing the old known-hosts entry. You can also run the same `sudo nixos-enter` command directly at the installer console. This sets the login password independently of the LUKS passphrase.

Reboot from the installer console or with `ssh "$installer" 'sudo reboot'`. Eject the ISO or USB at reboot, boot from the target disk, enter the LUKS passphrase at the console, and log in as `piotr`. Check the result:

```sh
findmnt -no SOURCE,FSTYPE /
swapon --show
hostname
```

Expect ext4 on `/dev/mapper/cryptroot` (`tpx1-crypt` on the encrypted ThinkPad), active `/swapfile`, and the selected hostname. Restore the installed repository revision at `~/repos/github/pszponder/nixconfig` for scheduled maintenance. Run `just bootstrap` for dotfiles and `just switch` for normal updates.
