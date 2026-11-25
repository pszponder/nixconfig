# Nix Config

A multi-host dendritic NixOS configuration, inspired by [Renato Garcia's simple dendritic config](https://renatogarcia.blog.br/posts/a-simple-nix-dendritic-config.html).

`import-tree` discovers Flake Parts modules under `modules/`. Reusable NixOS aspects live under `flake.modules.nixos`; the host explicitly selects its aspects.

- `modules/parts.nix`: module registration and supported systems.
- `modules/features/common.nix`: shared NixOS settings and Nerd Fonts.
- `modules/features/packages.nix`: shared admin tools and workstation packages.
- `modules/profiles/`: reusable host profiles such as the workstation profile.
- `modules/hosts/`: named host configurations, disk selection, hardware drivers, and host-specific features.
- `modules/installation/`: installer package and VM installation checks. Each host declares its partitions, filesystems, and mount points in its own `_disk.nix`.
- `modules/users/piotr/default.nix`: user account.
- `modules/features/`: GNOME, desktop packages, Docker, and Kanata.

Nix installs applications and manages system configuration. Application dotfiles belong in [pszponder/dotfiles](https://github.com/pszponder/dotfiles). macOS and Ubuntu configuration are deferred.

## Choose a command

| What you want to do                                                  | Command                         | What happens to the disk                                                           |
| -------------------------------------------------------------------- | ------------------------------- | ---------------------------------------------------------------------------------- |
| Update a running NixOS host over SSH                                 | `just deploy HOST USER@TARGET`  | Activates a new system generation using the existing filesystems.                  |
| Install on a blank disk, replace Ubuntu, or wipe and reinstall NixOS | `just install HOST USER@TARGET` | **Erases the configured target disk** and creates the host’s declared disk layout. |
| Rehearse a clean install before touching the target                  | `just install-test HOST`        | Uses a disposable VM disk.                                                         |

`HOST` selects the flake configuration. `USER@TARGET` selects the SSH destination. For example, after installing `workstation-vm` and configuring SSH on it, use `just deploy workstation-vm piotr@VM_IP` for subsequent changes. When logged into the installed host, use `just switch`. See the [remote deployment guide](docs/maintenance.md#update-an-existing-nixos-host-over-ssh) for preview and activation options.

## Install or reinstall a host

To bring up a desktop with the ThinkPad’s software or create a DigitalOcean, Hetzner, or AWS host, start with [Add a desktop or cloud VM](docs/new-host.md).

Follow the [encrypted workstation installation guide](docs/encrypted-install.md) to install from Ubuntu, installed NixOS, or live media. Choose `tpx1-encrypted` for the ThinkPad, `workstation-vm` for a compatible guest, or add a named host with its own disk and hardware module. Use `just install-test HOST` and `just install HOST USER@TARGET` from the same checkout.

## Clean install on `tpx1`

Run these commands from a second x86_64-linux machine with Nix flakes and just. Use the same checkout for installation and later updates. Stage any new Nix files so the flake can see them. If the controller does not already use the Numtide cache, enable it for this shell before building the desktop configuration:

```sh
export NIX_CONFIG="extra-substituters = https://cache.numtide.com
extra-trusted-public-keys = niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
```

1. Back up the laptop. The install recipe **erases the drive** selected in `modules/hosts/tpx1/hardware.nix`. It creates a 1 GiB EFI partition, ext4 root and about 9 GiB swap. The disk WWN and partition GUIDs match the current laptop. For a replacement disk, verify its whole-disk ID and change the WWN. For another machine, create its own host configuration, disk identifiers and hardware scan.
2. Run `just install-test tpx1` to exercise the layout, UEFI boot and activation of a second system generation on a disposable VM disk. The test uses a smaller swap reservation to fit its 4 GiB virtual disk.
3. Boot a NixOS installer USB on the laptop in UEFI mode and connect it to the network. From its console, run `sudo systemctl start sshd` and authorize your controller's SSH key for the live installer user. From the controller, check SSH, passwordless sudo, and the target drive. Replace `INSTALLER_IP` with the live address.

   ```sh
   ssh nixos@INSTALLER_IP 'sudo -n true && lsblk -o NAME,SIZE,MODEL,MOUNTPOINTS && ls -l /dev/disk/by-id/wwn-0x5002538d41d1f7ec'
   just install tpx1 nixos@INSTALLER_IP
   ```

4. The recipe detects the live installer, runs the disk and installation phases, and leaves the USB environment running. Set the local login password before rebooting, then remove the USB at reboot.

   ```sh
   ssh -t nixos@INSTALLER_IP 'sudo nixos-enter --root /mnt --command "passwd piotr"'
   ssh nixos@INSTALLER_IP 'sudo reboot'
   ```

5. Log in locally as `piotr`. Clone the installed revision into `~/repos/github/pszponder/nixconfig`, the location used by scheduled maintenance. Run `just bootstrap` there for dotfiles and restore private keys separately. Use `just switch tpx1` for subsequent changes. Remote updates require configuring SSH access on the installed system as described in [maintenance](docs/maintenance.md).

### Encrypted installation

Follow the [encrypted reinstall guide](docs/encrypted-install.md) for the ThinkPad or a VM, starting from Ubuntu, installed NixOS, or a live NixOS USB or ISO.

## Applying the flake to an existing installation

On the original laptop, the declared partition GUIDs match the existing filesystems. A normal `just switch tpx1` activates a generation without running the disk installer.

For a different graphical or manual installation, first compare `lsblk -o NAME,PARTUUID,FSTYPE,MOUNTPOINTS` and the installed boot configuration with the host's disk module. Adapt the host's disk, filesystem and boot declarations to the installed layout before switching. Preserve its `system.stateVersion`. Run `just bootstrap-hardware tpx1` from the installed system to refresh driver detection. It uses `--no-filesystems` because disko supplies mounts and swap. Review the diff before activating. The existing user's password is retained.

## Package channels

NixOS and `pkgs` use the pinned `nixos-unstable` input by default. Modules that import `common` can also accept `pkgsStable` as an argument and use, for example, `pkgsStable.hello` to select a package from the pinned stable `nixos-26.05` input. Both package sets use the system's Nixpkgs configuration.

## Working on the configuration

After setting up your GitHub SSH key, switch an HTTPS clone's origin to SSH:

```sh
just remote-ssh
```

Enter the development environment with `devenv shell`, then run:

```sh
just validate
just build tpx1
```

New Nix files must be added to Git before Git-backed flake commands can see them. Review and stage the refactor before running these commands. For an unstaged working-tree check, use `nix flake check path:.` and `nix build path:.#nixosConfigurations.tpx1.config.system.build.toplevel`.

After reviewing the build, activate with `just switch tpx1`. The hardware file and `system.stateVersion` retain their existing values.

For package updates, cleanup, automatic upgrade schedules, and troubleshooting, see the [maintenance guide](docs/maintenance.md).

## Dotfiles bootstrap

The Stow checkout defaults to `~/repos/github/pszponder/dotfiles`. After resolving old managed links and reviewing the dotfiles configuration, run as your regular user:

```sh
just bootstrap
# Or select an existing checkout:
just bootstrap-dotfiles /path/to/dotfiles
```

The script clones `pszponder/dotfiles` over HTTPS when needed, validates the origin and Stow layout, and runs `just stow` inside the checkout. It does not pull updates or invoke the repository's application installers. The Stow recipe backs up conflicting files under `~/.dotfiles-backup` before creating symlinks. Bootstrap is intentionally separate from system activation.

See the [host-name ideas](docs/hostnames.md) for future machines.
