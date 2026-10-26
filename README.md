# Nix Config

A minimal dendritic NixOS configuration for `tpx1`, inspired by
[Renato Garcia's simple dendritic config](https://renatogarcia.blog.br/posts/a-simple-nix-dendritic-config.html).

`import-tree` discovers Flake Parts modules under `modules/`. Reusable NixOS
aspects live under `flake.modules.nixos`; the host explicitly selects its aspects.

- `modules/parts.nix`: module registration and supported systems.
- `modules/base/`: baseline NixOS settings and CLI packages.
- `modules/hosts/tpx1/`: host composition, machine settings, and generated hardware configuration.
- `modules/users/piotr/default.nix`: user account.
- `modules/features/`: GNOME, desktop packages, Docker, and Kanata.

Nix installs applications and manages system configuration. Application dotfiles
belong in [pszponder/dotfiles](https://github.com/pszponder/dotfiles).
macOS and Ubuntu configuration are deferred.

## Clean install on `tpx1`

1. Back up personal files, SSH keys, and any uncommitted changes. Commit and push
   the configuration you want to install before wiping the machine.
2. Boot a NixOS installer USB in **UEFI mode** and connect to the internet. Follow
   the [manual installation guide](https://nixos.org/manual/nixos/stable/#sec-installation-manual)
   to partition and format the target disk (**this erases its contents**). Mount
   the root filesystem at `/mnt`, the EFI partition at `/mnt/boot`, and enable
   swap if used. This repo does not automate disk setup.
3. Open a root shell with `sudo -i`, then run:

   ```sh
   nix-shell -p git
   git clone https://github.com/pszponder/nixconfig.git /mnt/etc/nixos
   cd /mnt/etc/nixos
   # Check out the branch or commit you want to install before continuing.
   nixos-generate-config --root /mnt --show-hardware-config > modules/hosts/tpx1/_hardware-configuration.nix
   nixos-install --option extra-experimental-features 'nix-command flakes' --flake .#tpx1
   nixos-enter --root /mnt --command 'passwd piotr'
   reboot
   ```

   Regenerate the hardware file even on the same machine: formatting changes
   filesystem UUIDs. Keep `system.stateVersion` unchanged. The installer prompts
   for a root password; the separate `passwd piotr` command enables Piotr's login.

4. Log in as `piotr`, then run `cd /etc/nixos && just bootstrap`.
   Restore private keys separately and save the regenerated hardware file back
   to this repository before subsequent rebuilds.

## After a graphical installation

Install in UEFI mode, create the user `piotr`, and reboot into the installed
system. Log in as `piotr`, connect to the internet, then run:

```sh
nix-shell -p git just
mkdir -p ~/repos/github/pszponder
git clone https://github.com/pszponder/nixconfig.git ~/repos/github/pszponder/nixconfig
cd ~/repos/github/pszponder/nixconfig
# Check out the branch or commit you want to apply.
just bootstrap-hardware tpx1
```

`bootstrap-hardware` requires an explicit existing host, generates its hardware
configuration with `sudo nixos-generate-config --show-hardware-config`, and shows
the Git diff. Run it after booting into the installed system and review the diff
before rebuilding. From a live installer, use `--root /mnt` as shown above.
`just bootstrap` only sets up dotfiles.

Before rebuilding, compare `/etc/nixos/configuration.nix` with this repo. Preserve
any required installer settings, such as encrypted-disk configuration, and use
the installed system's `system.stateVersion` in `modules/hosts/tpx1/default.nix`.
The installer-created password for `piotr` is retained.

```sh
sudo nixos-rebuild switch --option extra-experimental-features 'nix-command flakes' --flake .#tpx1
just bootstrap
sudo reboot
```

This applies the repo to the existing installation without repartitioning. Save
the updated hardware file and any installation-specific changes back to Git.
See the [NixOS configuration documentation](https://nixos.org/manual/nixos/stable/#sec-changing-config)
for rebuilding and rollback.

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

New Nix files must be added to Git before Git-backed flake commands can see them.
Review and stage the refactor before running these commands. For an unstaged
working-tree check, use `nix flake check path:.` and
`nix build path:.#nixosConfigurations.tpx1.config.system.build.toplevel`.

After reviewing the build, activate with `just switch tpx1`.
The hardware file and `system.stateVersion` retain their existing values.

## Dotfiles bootstrap

The Stow checkout defaults to `~/repos/github/pszponder/dotfiles`. After resolving old managed links
and reviewing the dotfiles configuration, run as your regular user:

```sh
just bootstrap
# Or select an existing checkout:
just bootstrap-dotfiles /path/to/dotfiles
```

The script clones `pszponder/dotfiles` over HTTPS when needed, validates the origin
and Stow layout, and runs `just stow` inside the checkout. It does not pull updates
or invoke the repository's application installers. The Stow recipe backs up
conflicting files under `~/.dotfiles-backup` before creating symlinks. Bootstrap
is intentionally separate from system activation.
