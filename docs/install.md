# Install or reinstall a configured host

For routine configuration changes on an installed NixOS host, use `just deploy HOST USER@TARGET`. Continue below when you intend to erase the configured target disk. See [remote deployment](maintenance.md#update-an-existing-nixos-host-over-ssh).

**Back up the target or take a VM snapshot before installing.** A clean install replaces the OS, existing encryption keys, user accounts and data on the selected disk.

You can [install directly from a NixOS USB](#install-directly-from-a-nixos-usb) with a copy of this repository. For the SSH workflow in steps 1–4, run the controller commands from a second x86_64 Linux machine with Nix flakes and the repository. The controller can be the computer hosting the VM.

To rehearse a supplied host’s installation on a disposable VM disk, run `just install-test HOST` from the checkout.

## Connect the live installer to the internet

Boot the **NixOS minimal USB or ISO** using its UEFI boot entry. The live console logs you in as `nixos`. Run these commands at that prompt. For the supplied hosts, the following should print `UEFI`. If it prints nothing, reboot and select the UEFI entry.

```sh
test -d /sys/firmware/efi && echo UEFI
```

**Ethernet or a VM with a virtual network adapter:** connect the cable or enable the adapter and give DHCP a few seconds.

**Wi-Fi:** run `sudo nmtui`. Use the arrow keys to choose **Activate a connection**, press Enter, select your network, and enter the Wi-Fi password. Once the connection has an asterisk beside it, use Tab to select **Back**, then **Quit**.

Check connectivity before fetching any tools:

```sh
nmcli device status
curl -fsSL https://cache.nixos.org/nix-cache-info
```

Look for a connected Ethernet or Wi-Fi device and a response containing `StoreDir: /nix/store`. If the device is disconnected, reopen `sudo nmtui`. If Wi-Fi is disabled, run `sudo nmcli radio wifi on` and try again. [NixOS installer networking](https://nixos.org/manual/nixos/stable/#sec-installation-manual-networking)

## Install directly from a NixOS USB

1. **Get the tools and clone your repository.** From the live user's home directory, open a temporary shell with Git and Just. Run the remaining steps in that shell. The manual commands below do not require Just, but including it makes the documented shortcuts available.

   ```sh
   cd ~
   nix-shell -p git just
   git clone https://github.com/pszponder/nixconfig.git
   cd nixconfig
   ```

   Make sure you are on the desired branch.

2. **Optional: look up the host and verify its configured disk.** If you already know the host name and have confirmed which physical drive its configuration selects, skip this step and pass the host name directly to the shortcut in step 3. Use the commands below if you need to look up the host or verify the disk, especially after changing the disk configuration. This example selects Kamigawa.

   ```sh
   # List the host configurations in this checkout.
   ls modules/hosts

   # Select the host you intend to install.
   host=kamigawa

   # Read the whole-disk path Disko will use for this host.
   disk=$(nix --extra-experimental-features 'nix-command flakes' eval --raw ".#nixosConfigurations.$host.config.disko.devices.disk.main.device")

   # Show the configured path. For a WWN-based path, the drive's WWN is in the name.
   echo "$disk"

   # Resolve that path to a device such as /dev/sda. If it prints nothing, stop.
   readlink -e "$disk"

   # Find that device in the PATH column and check its serial or WWN against
   # the drive you backed up. Use the size and model as additional checks.
   lsblk -d -o PATH,SIZE,MODEL,SERIAL,WWN
   ```

   Match the resolved path, model, and serial or WWN to the whole drive you backed up. If the path is missing or identifies another drive, stop here. Both ThinkPad variants select the same SSD. Use `tpx1` for a fresh encrypted ThinkPad install. The `tpx1-unencrypted` output describes the existing plain ext4 layout.

3. **Build and install.** Choose the shortcut or the manual commands below. Both erase the disk selected by the host configuration.

   **Shortcut:** Run `just install-local kamigawa` from the checkout, replacing `kamigawa` with your host name. The recipe evaluates the configuration, then Disko erases and mounts the target disk. The full system build runs during installation using the target disk’s Nix store. A build failure at that point leaves the previous installation erased. Enter the new disk passphrase if prompted, then continue to step 4 once the recipe succeeds.

   **Manual install:** If you skipped step 2, set `host=kamigawa` first, replacing `kamigawa` with your host name. Run each command in the checkout and continue only after it succeeds. First check that the selected host configuration evaluates.

   ```sh
   nix --extra-experimental-features 'nix-command flakes' eval --raw \
     ".#nixosConfigurations.$host.config.system.build.toplevel.drvPath" > /dev/null
   ```

   **The next command erases the disk selected by the host configuration.** It runs the repo’s pinned Disko to partition, format, and mount the filesystems under `/mnt`. For LUKS, enter the new disk passphrase when prompted.

   ```sh
   sudo nix --extra-experimental-features 'nix-command flakes' run --inputs-from . disko -- \
     --mode destroy,format,mount --flake ".#$host"
   ```

   Install the selected NixOS system onto those mounted filesystems.

   ```sh
   sudo nixos-install \
     --option extra-substituters https://cache.numtide.com \
     --option extra-trusted-public-keys niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g= \
     --flake ".#$host" --no-root-passwd
   ```

   If `nixos-install` fails after Disko succeeds, keep the filesystems mounted. Once you resolve the error, retry only the `nixos-install` command above. Running the shortcut again erases the disk again.

4. **Set the login password and boot.** After the install succeeds, set Piotr's account password. Reboot after `passwd` succeeds and remove the USB or eject the VM's ISO as it restarts.

   ```sh
   sudo nixos-enter --root /mnt --command 'passwd piotr'
   sudo reboot
   ```

   For LUKS, enter the disk passphrase at boot. Then log in as `piotr` with the account password. Reconnect Wi-Fi if needed. See the [first-boot checks and checkout location](#4-set-the-login-password-and-boot).

## 1. Connect to the target

| Target at startup                                    | How to connect                                                                                                                                                     |
| ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Ubuntu or installed NixOS with SSH and working kexec | Use the existing SSH account. It needs root access or passwordless sudo. The recipe starts a temporary NixOS installer in RAM. Ubuntu does not need Nix installed. |
| Empty VM, inaccessible OS, or kexec unavailable      | Boot a NixOS installer ISO in the VM, or a NixOS USB on the laptop. Choose UEFI mode and connect it to the network.                                                |
| Already running the live NixOS installer             | Use its SSH account. The recipe recognizes the installer and proceeds directly to disk setup.                                                                      |

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

| Target                         | Set the host variable on the controller       | Disk and hardware                                                                                                      |
| ------------------------------ | --------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| ThinkPad with unencrypted root | `host=tpx1-unencrypted`                       | Same physical SSD as the encrypted variant.                                                                            |
| Encrypted ThinkPad             | `host=tpx1`                                   | `wwn-0x5002538d41d1f7ec` in the [hardware module](../modules/hosts/tpx1/hardware.nix).                                 |
| Kamigawa desktop               | `host=kamigawa`                               | Samsung SSD 870 EVO 4 TB, `wwn-0x5002538f31b2732f` in the [host configuration](../modules/hosts/kamigawa/default.nix). |
| New machine                    | `host=office-pc` (choose its actual hostname) | Add a host once using the steps below.                                                                                 |

Set `host` once using the table. For a preconfigured host, proceed directly to the disk check below.

### First installation on a new host

Create the host directory and adapt its disk and boot settings for the actual machine. On a NixOS USB or ISO, follow the [hardware scan walkthrough](new-host.md#desktop-walkthrough) to capture the target's drivers with `--no-filesystems`. Disko supplies the mounts.

For a new target running Ubuntu with working kexec, create the host definition and disk layout first. From the controller, run only the kexec phase with hardware generation. This interrupts Ubuntu and starts a temporary installer in RAM. Disk partitioning comes later.

```sh
nix run .#nixos-anywhere -- --flake ".#$host" --target-host "$target" \
  --phases kexec --generate-hardware-config nixos-generate-config \
  "modules/hosts/$host/_hardware-configuration.nix"
target=root@$address
```

Verify the temporary installer's SSH fingerprint at the console when reconnecting. For either discovery method, review the generated hardware file, then run `git add -- "modules/hosts/$host"` before evaluating or building the host.

### Verify the selected disk

Evaluate the device in the controller checkout. Pass its path over standard input to SSH so the target resolves it against its own devices.

```sh
config=".#nixosConfigurations.$host.config"
disk=$(nix eval --raw "$config.disko.devices.disk.main.device") &&
  printf '%s\n' "$disk" | ssh "$target" '
    IFS= read -r disk && device=$(readlink -e -- "$disk") &&
      lsblk -dn -o PATH,TYPE,SIZE,MODEL,SERIAL,WWN -- "$device"
  '
```

Continue only if the output identifies the intended whole disk by type, size and serial or WWN. Kamigawa has two SSDs of the same model and size. If the path is missing or the identifier differs, correct the host configuration and repeat the check.

### Verify headless access

For a host you will administer over SSH, run these on the controller before formatting. Choose the public key you intend to use for `piotr`.

```sh
nix eval --json "$config.services.openssh.enable"
nix eval --json "$config.users.users.piotr.openssh.authorizedKeys.keys"
cat ~/.ssh/id_ed25519.pub
```

The first result must be `true`. Match the public key's type and base64 data to an entry in the second result. If either check fails, update the [host SSH settings](new-host.md#add-a-remote-development-host) and repeat. For an encrypted headless VM, open the hypervisor or provider console and verify that you can see early boot and send keystrokes there, or verify the host's configured early unlock method. The installed SSH service starts after root is unlocked.

## 3. Build and install

From the selected checkout, use an interactive terminal. If your controller needs the Numtide binary cache for the workstation packages, enable it for this shell:

```sh
export NIX_CONFIG="extra-substituters = https://cache.numtide.com
extra-trusted-public-keys = niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
```

Run the optional VM rehearsal for a supplied host and build the system before installing.

```sh
nix build --no-link -L ".#checks.x86_64-linux.${host}-install"  # optional VM rehearsal
nix build --no-link ".#nixosConfigurations.${host}.config.system.build.toplevel"
```

For a configured host, run the following on the controller. **This erases the selected disk on the SSH target.** The pinned nixos-anywhere tool starts a temporary installer if needed, runs Disko, and installs the host. The phase list leaves the installer running for password setup.

```sh
nix run .#nixos-anywhere -- --flake ".#$host" --target-host "$target" \
  --phases kexec,disko,install
```

The equivalent shortcut is `just install "$host" "$target"`. Run only one installation command.

For encrypted hosts, enter the new LUKS passphrase twice during disk setup. Keep a recovery copy of that passphrase. The EFI partition is unencrypted. Root and the swap file live inside LUKS2.

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

For `tpx1-unencrypted`, expect ext4 root and a swap partition. For the encrypted workstations, expect ext4 on the host's encrypted root mapping (`/dev/mapper/kamigawa-crypt` on Kamigawa and `/dev/mapper/tpx1-crypt` on the encrypted ThinkPad), active `/swapfile`, and the selected hostname. Restore the installed repository revision at `~/repos/github/pszponder/nixconfig` for manual updates. Run `just bootstrap` for dotfiles and `just switch` for normal updates.
