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

The local recipes target this checkout and default to the current hostname:

```sh
just build tpx1    # Build without activating; keep ./result
just diff tpx1     # Build and compare packages with the running local system
just preview tpx1  # Build and show activation changes without applying them
just test tpx1     # Confirm and activate without changing the boot default
just switch tpx1   # Confirm and activate as the boot default
```

`diff` always compares against the local `/run/current-system`; use it for the local host. `preview` runs `nixos-rebuild dry-activate`, whose service-change report may be incomplete. `test` and `switch` ask for confirmation **before building**, then run `sudo nixos-rebuild`. A temporary activation does not automatically roll back if access is lost; rebooting restores the boot default. It does not test booting a new kernel.

Confirmation prompts for `test`, `switch`, `up`, `deploy`, and `gc` show `[y/N]`: enter `y` or `yes` to proceed, or press Enter to cancel.

`just switch` uses the existing lockfile without requesting newer input revisions. To update all flake inputs and switch in one command, run:

```sh
just up
# Or select a host explicitly:
just up tpx1
```

This asks for confirmation before updating all inputs with `nix flake update` as your regular user, then builds and activates with `sudo nixos-rebuild switch`. The update writes `flake.lock`; it does not rewrite input declarations in `flake.nix` or update the separate `devenv.lock`. Sudo may prompt for your password. Lockfile changes remain if activation fails; review and commit them with Git. An update failure stops the recipe before switching.

For a selective update with validation before activation, run `just update nixpkgs`, review `git diff -- flake.lock`, run `just validate`, then run `just switch tpx1`.

Inspect system generations with `just history`, explore this checkout's flake outputs with `just repl`, and list automatic GC roots with `just gc-roots`.

## Fingerprint setup on `tpx1`

The host enables `fprintd` for its Synaptics `06cb:00bd` reader. GDM provides fingerprint authentication for GNOME login and screen unlock. General PAM integration is disabled with `services.fprintd.enablePam = false`, so this does not enable fingerprints for `sudo` or other PAM services.

The reusable `fingerprint` aspect lives in `modules/features/fingerprint.nix`; hosts opt in through their imports. It enables the reader service independently of the desktop. For Niri or Hyprland, retain this feature and configure fingerprint authentication in the chosen display manager and screen locker. Enrollment stays local and can be reused after changing desktops.

Activate the configuration, then enroll as your regular user **without sudo**:

```sh
just switch tpx1
just fingerprint-setup
# Optionally enroll another finger:
just fingerprint-setup left-index-finger
```

The helper checks that the tools are installed, prints scanning instructions, starts interactive enrollment, and then verifies the selected finger. The GNOME password dialog only authorizes enrollment; return to the terminal afterward. Repeatedly touch and lift the same finger, varying its position slightly. Each `enroll-stage-passed` means one scan succeeded, so keep going until `enroll-completed`. Then touch the reader again for verification and look for `verify-match`. Physical scans cannot be automated. Running it again for the same finger replaces that finger's enrollment; ordinary rebuilds never run enrollment. GNOME Settings → Users → Fingerprint Login provides a graphical alternative.

Enrollment data stays local under `/var/lib/fprint/` and, depending on the reader, in device storage. It is never imported into Nix or copied into this checkout. Rebuilds and reboots preserve it; after a clean installation, enroll again. If the host later uses an ephemeral root filesystem, persist `/var/lib/fprint/` separately.

Keep your account password: fingerprint login cannot unlock the GNOME login keyring using your password, so the keyring may prompt separately. It also does not replace a boot-time disk encryption password.

To inspect enrollment or troubleshoot a reader that is unavailable:

```sh
fprintd-list "$(id -un)"
fprintd-verify
journalctl -u fprintd.service -b
```

`fprintd` starts on demand over D-Bus; being inactive when idle is normal. See the [fprintd manual](https://man.archlinux.org/man/fprintd.1.en) and [NixOS GDM integration](https://github.com/NixOS/nixpkgs/blob/d5cc6833999746cffdfe0598f7bc801a57b887a9/nixos/modules/services/display-managers/gdm.nix).

## Update an existing NixOS host over SSH

Use this recipe to rebuild an installed NixOS host using its existing filesystems. For a fresh disk layout, follow the [clean installation guide](encrypted-install.md). The deployment command is `just deploy HOST TARGET [ACTION] [BUILD_HOST]`. `HOST` selects `nixosConfigurations.HOST`; `TARGET` is a required SSH destination, such as `piotr@server1` or an SSH configuration alias. The default action is `switch` and the default build location is the local machine. All actions ask for confirmation.

After declaring a real host, use commands like these, replacing the example names:

```sh
# Build locally and preview changes on the target
just deploy server1 piotr@server1 dry-activate

# Activate temporarily, then reconnect and check the services
just deploy server1 piotr@server1 test

# Activate and make the configuration the boot default
just deploy server1 piotr@server1

# Build on the target instead, useful for another architecture
just deploy server1 piotr@server1 switch piotr@server1

# Build on a separate compatible builder
just deploy server1 piotr@server1 switch piotr@builder

# Make the new configuration the boot default without activating it now
just deploy server1 piotr@server1 boot
```

The recipe runs as your regular local user so SSH can use your keys, agent, and aliases. It uses `--elevate sudo --ask-elevate-password` for remote activation, prompting locally for the target user's sudo password. These flags are supported by the installed `nixos-rebuild`; older versions may use `--sudo --ask-sudo-password`. The article's `--use-remote-sudo` flag is deprecated. For passwordless automation, use the underlying command with the elevation and authentication settings appropriate to the deployment account.

Before the first deployment:

- Add a host composition with its own hardware configuration, platform, boot settings, and `system.stateVersion`. Select server features explicitly.
- Enable `services.openssh`, declare the deployment user's `openssh.authorizedKeys.keys`, and provide sudo access. Verify the SSH host key and test login first.
- Ensure the build machine can build the target platform. `--target-host` alone does not configure cross-compilation. A remote builder needs SSH access and working Nix builds; store transfers may also require configured signing trust or an appropriately trusted Nix user.
- Stage newly created Nix files so Git-backed flakes can see them. Review and commit the lockfile used for deployment. The recipe does not update inputs or synchronize a checkout on the target.
- For centrally managed servers, keep automatic GC but configure upgrades separately: importing the current `nixMaintenance` module enables both. Prefer centrally deploying a reviewed lockfile over each server independently updating `nixpkgs`.

Remote `test` preserves the old boot default but cannot restore SSH automatically. Consider [deploy-rs](https://github.com/serokell/deploy-rs) when deployments need connectivity confirmation and automatic rollback. Keep a console or other recovery path available for boot and network changes.

For a fresh installation, follow the [tpx1 disko and nixos-anywhere procedure](../README.md#clean-install-on-tpx1). The install recipe erases the target disk. Use the deployment recipe above for routine updates.

See the upstream [nixos-rebuild command reference](https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/ni/nixos-rebuild-ng/nixos-rebuild.8.scd) for build-host, target-host, and elevation options.

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
