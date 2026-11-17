# Web apps

The `webapps` feature creates GNOME application launchers that open websites in Google Chrome's app mode. Firefox remains the default browser. All apps use the normal Chrome profile, so Google logins can be shared between apps.

The predefined list includes Gmail, Google Docs, Google Photos, YouTube, YouTube Music, ChatGPT, Grok and X. Edit `webapps` in `modules/features/webapps/default.nix` to add or remove entries. Each entry has a `name`, `url`, `iconUrl` and `iconHash`.

Importing the `webapps` feature installs the list; there are no custom NixOS options. After rebuilding, launch the apps from GNOME's application menu or pin them to the dash. Removing an entry removes its launcher on the next rebuild. Names can be customized without changing the launcher ID.

## GNOME window grouping

Launchers explicitly use Chrome's shared `Default` profile. Each desktop filename matches Chrome's native Wayland app ID (`chrome-<host>_<sanitized-path>-Default`), and `StartupWMClass` matches the corresponding X11 window identity. This lets GNOME show each web app with its own icon in Alt-Tab while keeping shared logins. These identities follow [Chromium's window-class implementation](https://chromium.googlesource.com/chromium/src/+/HEAD/chrome/browser/ui/views/frame/browser_native_widget_aura_linux.cc).

After updating from the old `webapp-<hash>` launchers, rebuild, close existing web app windows, and reopen them from the application menu. Remove old dash pins and pin the updated launchers. If GNOME still displays cached entries, log out and back in.

## Icons

Each app has a fixed, direct icon URL and a SHA-256 hash. Nix downloads and verifies the icon when building the launcher, and stores it in the Nix store. Icons are available immediately after activation, including offline. ICO sources are converted to PNG during the build; PNG and SVG are used directly. There is no background downloader or user icon cache to maintain.

When adding or updating an icon, get its hash with:

```sh
nix store prefetch-file --json 'https://example.com/icon.png'
```

Copy the URL into `iconUrl` and the returned `hash` into `iconHash`. If the upstream file changes, the hash check fails until you review the new icon and update its hash. Cached icons do not need to be downloaded again for each rebuild.
