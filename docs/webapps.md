# Web apps

The `webapps` feature creates GNOME application launchers that open websites in Google Chrome's app mode. Firefox remains the default browser. All apps use the normal Chrome profile, so Google logins can be shared between apps.

The predefined list includes Gmail, Google Docs, Google Photos, YouTube, YouTube Music, ChatGPT, Grok and X. Edit `webapps` in `modules/features/webapps/default.nix` to add or remove entries. Each entry has a `name`, `url`, `iconName` and `iconHash`.

Importing the `webapps` feature installs the list; there are no custom NixOS options. After rebuilding, launch the apps from GNOME's application menu or pin them to the dash. Removing an entry removes its launcher on the next rebuild. Names can be customized without changing the launcher ID.

## GNOME window grouping

Launchers explicitly use Chrome's shared `Default` profile. Each desktop filename matches Chrome's native Wayland app ID (`chrome-<host>_<sanitized-path>-Default`), and `StartupWMClass` matches the corresponding X11 window identity. This lets GNOME show each web app with its own icon in Alt-Tab while keeping shared logins. These identities follow [Chromium's window-class implementation](https://chromium.googlesource.com/chromium/src/+/HEAD/chrome/browser/ui/views/frame/browser_native_widget_aura_linux.cc).

After updating from the old `webapp-<hash>` launchers, rebuild, close existing web app windows, and reopen them from the application menu. Remove old dash pins and pin the updated launchers. If GNOME still displays cached entries, log out and back in.

## Icons

All icons come from [Dashboard Icons](https://github.com/homarr-labs/dashboard-icons), the collection recommended by [Omarchy's web app documentation](https://github.com/omacom/omarchy/blob/quattro/manual/25-web-apps.md). The shared `iconBaseUrl` pins a Git revision and selects its `png` directory. Each app's `iconName` is the filename without `.png`, such as `google-docs`.

Nix downloads and verifies each PNG against its `iconHash` when building the launcher, and stores it in the Nix store. Icons are available immediately after activation, including offline. There is no background downloader or user icon cache to maintain.

Replace `<revision>` with the revision from `iconBaseUrl` and `<iconName>` with the icon filename without `.png`. Run the command to get its hash.

```sh
nix store prefetch-file --json 'https://raw.githubusercontent.com/homarr-labs/dashboard-icons/<revision>/png/<iconName>.png'
```

Set `iconName` and copy the returned `hash` into `iconHash`. To update the collection, change the revision in `iconBaseUrl`, review all eight icons, and refresh their hashes. Cached icons do not need to be downloaded again for each rebuild.
