# Web apps

The `webapps` feature creates GNOME application launchers that open websites in Google Chrome's app mode. Firefox remains the default browser. All apps use the normal Chrome profile, so Google logins can be shared between apps.

The predefined list includes Gmail, Google Docs, Google Photos, YouTube, YouTube Music, ChatGPT, Grok and X. Edit `webapps` in `modules/features/webapps/default.nix` to add or remove entries. Each entry has a `name`, `url`, `iconUrl` and `iconHash`.

Importing the `webapps` feature installs the list; there are no custom NixOS options. After rebuilding, launch the apps from GNOME's application menu or pin them to the dash. Removing an entry removes its launcher on the next rebuild. Names can be customized without changing the launcher ID.

## Icons

Each app has a fixed, direct icon URL and a SHA-256 hash. Nix downloads and verifies the icon when building the launcher, and stores it in the Nix store. Icons are available immediately after activation, including offline. ICO sources are converted to PNG during the build; PNG and SVG are used directly. There is no background downloader or user icon cache to maintain.

When adding or updating an icon, get its hash with:

```sh
nix store prefetch-file --json 'https://example.com/icon.png'
```

Copy the URL into `iconUrl` and the returned `hash` into `iconHash`. If the upstream file changes, the hash check fails until you review the new icon and update its hash. Cached icons do not need to be downloaded again for each rebuild.
