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

## Clone the repository

```sh
mkdir -p ~/repos/github/pszponder
git clone https://github.com/pszponder/nixconfig.git ~/repos/github/pszponder/nixconfig
cd ~/repos/github/pszponder/nixconfig
```

## Install a host

Follow the [installation guide](docs/install.md) to install or reinstall a configured host from a NixOS USB or over SSH.

- [Install a persistent VM](docs/new-host.md#install-a-persistent-vm)
- [Add a physical host](docs/new-host.md) or [configure a cloud guest](docs/new-host.md#creating-a-cloud-host)
- [Update an installed host over SSH](docs/maintenance.md#update-an-existing-nixos-host-over-ssh)

## Applying the flake to an existing installation

On the original unencrypted ThinkPad, the declared partition GUIDs match the existing filesystems. Run `just switch tpx1-unencrypted` to activate the renamed configuration without running the disk installer. On a ThinkPad previously configured as `tpx1-encrypted`, run `just switch tpx1` to activate its new hostname.

For a different graphical or manual installation, first compare `lsblk -o NAME,PARTUUID,FSTYPE,MOUNTPOINTS` and the installed boot configuration with the host's disk module. Adapt the host's disk, filesystem and boot declarations to the installed layout before switching. Preserve its `system.stateVersion`. Run `just bootstrap-hardware HOST` with the matching host name from the installed system to refresh driver detection. It uses `--no-filesystems` because disko supplies mounts and swap. Review the diff before activating. The existing user's password is retained.

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
