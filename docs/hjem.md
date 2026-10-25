# Home configuration with Hjem

The `hjem` NixOS feature enables home-file management for `piotr`. Features
declare their own files using `hjem.users.piotr.files` or
`hjem.users.piotr.xdg.config.files`. Packages and application wrappers remain
managed by their existing features.

The shell feature manages `.bashrc`, `.bash_profile`, and `.profile`. The VS Code
feature manages `Code/User/settings.json` and `Code/User/keybindings.json` under
the user's XDG configuration directory. These files link to read-only store
contents; edit the repository sources to change them.

Hjem applies files during system activation. Unmanaged files are not overwritten.
Before the first activation, move any conflicting personal files aside. If the
previous `home-files.nix` helper was activated, its links into
`/etc/nixconfig/piotr/` also need to be moved aside so Hjem can take ownership.
The old helper's declarations have been removed; no existing home files are
changed by this repository migration itself.
