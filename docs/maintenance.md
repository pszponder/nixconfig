# Nix maintenance

[Back to the README](../README.md#working-on-the-configuration).

## Building and switching

Run these standard Nix commands from this checkout, selecting a host explicitly:

```sh
nix build .#nixosConfigurations.tpx1.config.system.build.toplevel
sudo nixos-rebuild test --flake .#tpx1
sudo nixos-rebuild switch --flake .#tpx1
```

`build` builds without activating and keeps the output at `./result`. `test` activates without changing the boot default; `switch` also makes the configuration persistent across reboots. Use an absolute flake path to run from another directory.

`just build` and `just switch` target this checkout and default to the current hostname. `just switch` asks for confirmation **before building**, then runs `sudo nixos-rebuild switch`. To inspect changes before switching, run `sudo nixos-rebuild dry-activate --flake .#tpx1` separately.

`just switch` uses the existing lockfile without requesting newer input revisions. To update all flake inputs and switch in one command, run:

```sh
just up
# Or select a host explicitly:
just up tpx1
```

This runs without confirmation, updates all inputs with `nix flake update` as your regular user, then builds and activates with `sudo nixos-rebuild switch`. The update writes `flake.lock`; it does not rewrite input declarations in `flake.nix` or update the separate `devenv.lock`. Sudo may prompt for your password. Lockfile changes remain if activation fails; review and commit them with Git. An update failure stops the recipe before switching.

For a selective update with validation before activation, run `just update nixpkgs`, review `git diff -- flake.lock`, run `just validate`, then run `just switch tpx1`.

Inspect system generations with `just history`, explore this checkout's flake outputs with `just repl`, and list automatic GC roots with `just gc-roots`.

## Cleanup

The standard NixOS `nix.gc` service runs weekly with `--delete-older-than 30d`. It prunes old profile generations, then collects unreachable store paths. Current generations and live build and development GC roots remain protected. This age-based policy does not guarantee a minimum of three generations; a rarely updated profile may retain fewer rollback options.

Preview cleanup without deleting generations or store paths:

```sh
just gc-preview
# Equivalent command:
sudo nix-collect-garbage --dry-run --delete-older-than 30d
```

The dry run does not remove profile roots, so the store paths it reports may omit paths that become collectible after actual generation pruning. Run `just gc` to confirm and perform cleanup, or run the underlying command directly:

```sh
sudo nix-collect-garbage --delete-older-than 30d
```

Inspect the scheduled cleanup with `systemctl status nix-gc.timer` and `journalctl -u nix-gc.service`.

## Automatic upgrades

The standard NixOS `system.autoUpgrade` service runs Sundays at 18:00 with up to 45 minutes of random delay. It updates the `nixpkgs` flake input, rebuilds, and activates without automatic reboot. Other inputs remain pinned. The job writes `flake.lock` in the configured checkout without committing or pushing it; review and commit that diff afterward. If the build fails, the lockfile may still contain the updated pin. Cleanup runs separately through `nix-gc.service`.

Inspect upgrades with `systemctl status nixos-upgrade.timer` and `journalctl -u nixos-upgrade.service`.

## Resources / References

- [ryan4yin's Justfile](https://github.com/ryan4yin/nix-config/blob/main/Justfile)
