# Nix Config

A multi-host dendritic NixOS configuration, inspired by [Renato Garcia's simple dendritic config](https://renatogarcia.blog.br/posts/a-simple-nix-dendritic-config.html).

`import-tree` discovers Flake Parts modules under `modules/`. Reusable NixOS aspects live under `flake.modules.nixos`; the host explicitly selects its aspects.

- `modules/parts.nix`: module registration and supported systems.
- `modules/features/common.nix`: shared NixOS settings and Nerd Fonts.
- `modules/features/packages.nix`: shared admin tools and workstation packages.
- `modules/hosts/`: named host configurations, disk selection, hardware drivers, and host-specific features.
- `modules/install.nix`: installer package and VM installation checks. Encrypted workstations import the shared [_encrypted-disk.nix](modules/hosts/_encrypted-disk.nix) layout and set disk identifiers in their host directories. The [shared workstation profile](modules/features/common-workstation.nix) supplies packages and maintenance settings for all three workstations. Each host selects GNOME explicitly.
- `modules/users/piotr/default.nix`: user account.
- `modules/features/`: GNOME, desktop packages, Docker, and Kanata.

Nix installs applications and manages system configuration. Application dotfiles belong in [pszponder/dotfiles](https://github.com/pszponder/dotfiles). macOS and Ubuntu configuration are deferred.

## Install a host

`just` reads the recipes in this repository’s `justfile`. For a local install, boot the target from the NixOS USB or ISO, [connect it to the internet](docs/install.md#connect-the-live-installer-to-the-internet), and run the following at the live console. The first command makes Git and Just available in a temporary shell. Run the remaining commands inside that shell.

```sh
nix-shell -p git just
git clone https://github.com/pszponder/nixconfig.git
cd nixconfig
just --list
```

For either SSH workflow, run the setup on your controller (an x86_64 Linux machine with Nix and flakes enabled). If you already have a checkout, `cd` into it and skip the clone. For `just deploy`, include `nixos-rebuild` in the controller shell with `nix-shell -p git just nixos-rebuild`. The SSH target does not need Just.

From the checkout, choose one command below. Replace `HOST` with a configuration name such as `kamigawa` and `USER@TARGET` with the target’s SSH login and address. **Both install commands erase the disk selected by the host configuration.** Back it up and [match the configured disk to the physical drive](docs/install.md#install-directly-from-a-nixos-usb) on the target before confirming.

| Where you run the command | Command |
| --- | --- |
| On the target, booted from a NixOS USB or ISO, in this checkout | `just install-local HOST` |
| On your controller, with SSH access to the target | `just install HOST USER@TARGET` |
| On your controller, with [SSH login and sudo access on the installed NixOS system](docs/maintenance.md#update-an-existing-nixos-host-over-ssh) | `just deploy HOST USER@TARGET` |

New hosts use encrypted storage by default. The supplied hosts are `kamigawa`, `tpx1`, and `tpx1-encrypted`. The two ThinkPad configurations select the same physical SSD. Only `tpx1-encrypted` and `kamigawa` prompt for a disk passphrase. Both install commands leave the installer running so you can set Piotr’s password before rebooting.

- [Manual local install from the minimal ISO](docs/install.md#connect-the-live-installer-to-the-internet) or [manual install over SSH](docs/install.md#1-connect-to-the-target)
- [Install a persistent VM](docs/new-host.md#install-a-persistent-vm)
- [Add a physical host](docs/new-host.md) or [configure a DigitalOcean, Hetzner, or AWS guest](docs/new-host.md#creating-a-cloud-host)
- [Update over SSH](docs/maintenance.md#update-an-existing-nixos-host-over-ssh)

To rehearse a supplied host’s installation on a disposable VM disk, run `just install-test HOST`.

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

Enter the development environment with `devenv shell`. If you created any Nix files, review them and stage them with Git so the flake can see them. Then validate and build the host.

```sh
just validate
just build tpx1
```

For an unstaged working-tree check, use `nix flake check path:.` and `nix build path:.#nixosConfigurations.tpx1.config.system.build.toplevel`.

After reviewing the build, activate with `just switch tpx1`. The hardware file and `system.stateVersion` retain their existing values.

For package updates, cleanup, and troubleshooting, see the [maintenance guide](docs/maintenance.md).

## Dotfiles bootstrap

The Stow checkout defaults to `~/repos/github/pszponder/dotfiles`. After resolving old managed links and reviewing the dotfiles configuration, run as your regular user:

```sh
just bootstrap
# Or select an existing checkout:
just bootstrap-dotfiles /path/to/dotfiles
```

The script clones `pszponder/dotfiles` over HTTPS when needed, validates the origin and Stow layout, and runs `just stow` inside the checkout. It does not pull updates or invoke the repository's application installers. The Stow recipe backs up conflicting files under `~/.dotfiles-backup` before creating symlinks. Bootstrap is intentionally separate from system activation.

See the [host-name ideas](docs/hostnames.md) for future machines.
