# Nix maintenance

[Back to the README](../README.md#working-on-the-configuration).

## Using nh

`nh` is enabled system-wide. On `tpx1`, its default flake is the checkout at
`/home/piotr/repos/github/pszponder/nixconfig`, so these commands work from any
directory:

```sh
nh os build
nh os test
nh os switch --ask
```

`build` builds without activating, `test` activates without changing the boot
default, and `switch --ask` asks for confirmation before persistent activation.
Run nh as your regular user; it requests elevated privileges when needed.
For another checkout, pass its path explicitly, for example `nh os build . -H tpx1`.
`just build` and `just switch` use nh and explicitly target this checkout.
`just build` keeps its output at `./result`; `just switch` asks for confirmation
before activation. The development shell also supplies nh.

`just switch` builds from the existing lockfile without requesting newer input
revisions. To update all flake inputs and switch in one command, run:

```sh
just up
# Or select a host explicitly:
just up tpx1
```

This updates `flake.lock`, builds, shows the package changes, and asks for
confirmation before activation. Lockfile changes remain even if the build fails
or you decline activation; review and commit them with Git. It updates the system
flake's inputs, not the separate `devenv.lock`.

For a selective update with validation before activation, run `just update nixpkgs`,
review `git diff -- flake.lock`, run `just validate`, then run `just switch tpx1`.

Scheduled nh cleanup runs weekly, retaining generations from the last 30 days
and at least three generations per profile. It preserves build and devenv GC
roots. Preview cleanup with the same retention settings:

```sh
just gc-preview
```

Run `just gc` to perform that cleanup with confirmation. It prunes old profile
generations as well as collecting unreachable store paths, while preserving the
same retention policy and development roots as scheduled cleanup.

Automatic upgrades run Sundays at 18:00 with up to 45 minutes of random delay.
They update the `nixpkgs` flake input, rebuild, and activate without automatic
reboot. Other inputs remain pinned. The job writes `flake.lock` in the configured
checkout without committing or pushing it; review and commit that diff afterward.
If the build fails, the lockfile may still contain the updated pin.
Cleanup is handled separately by nh.

## First switch and shell reloads

If `just switch` reports `nh: command not found`, load the updated development
environment explicitly for the first switch:

```sh
devenv shell -- just switch tpx1
```

This supplies nh before it is installed system-wide. An already running shell
may need to be re-entered after changing `devenv.nix`.
