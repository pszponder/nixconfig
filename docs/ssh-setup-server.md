# SSH server setup

Use this guide to let other computers connect to a machine over SSH. It covers the receiving side: the SSH service, login accounts, authorized public keys, network access, and authentication policy. A workstation needs this setup too if you want to connect to it remotely.

Generate and keep your client private keys on the connecting computer using [SSH client setup](ssh-setup.md). For Git hosting authentication, use the [Git guide](git-ssh-setup.md); you do not need to run your own SSH server to use GitHub or Bitbucket.

The examples use a remote account named `deploy` and port `2222`, matching the client guide. Replace these with your actual account and port. OpenSSH's standard port is `22`.

## 1. Enable the service and network access

Keep console or provider recovery access available while setting this up. If already connected over SSH, keep that session open until a second connection succeeds.

### NixOS

Add the following to a NixOS module imported by the target host:

```nix
{
  services.openssh = {
    enable = true;
    ports = [ 2222 ];
    openFirewall = true;
    settings.PubkeyAuthentication = true;
  };
}
```

`openFirewall` opens the configured SSH ports in the NixOS firewall. Cloud security groups, upstream firewalls, and router port forwarding are separate: allow the same TCP port there if needed, preferably only from your intended network or VPN.

This repository uses host-selected NixOS modules. Place the service settings in a feature or host module selected by the receiving host; user keys belong with the relevant NixOS user declaration. These examples are documentation, and do not enable incoming SSH on existing hosts.

Add the account and public key from the next section before applying the configuration through your normal host rebuild workflow. If changing the port of an existing SSH service, temporarily keep both ports in `ports` until you have verified the new one.

See the [NixOS OpenSSH options](https://search.nixos.org/options?channel=unstable&query=services.openssh) for service configuration.

### Other Linux distributions

Install your distribution's OpenSSH server package and enable its service. Package and service names vary, commonly `openssh-server` and `ssh` or `sshd`. Use your distribution's instructions for these commands and its firewall.

Configure the service through `/etc/ssh/sshd_config` or a supported included file. For example:

```text
Port 2222
PubkeyAuthentication yes
```

Check existing settings, `Include` files, and `Match` blocks rather than appending conflicting directives. Validate with `sudo sshd -t` before reloading the service using your distribution's service manager. On NixOS, use NixOS options instead of editing generated files.

## 2. Authorize client public keys

An authorized key grants access to a particular remote user. Create or choose that account first; it needs an appropriate home directory and login shell. Administrative privileges are a separate decision and are not required for SSH access.

### NixOS: declare authorized keys

For a new example account:

```nix
{
  users.users.deploy = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "PASTE_YOUR_ENTIRE_PUBLIC_KEY_LINE_HERE"
    ];
  };
}
```

Replace the placeholder with the complete line from your client's `.pub` file before rebuilding. For an existing account, add only its `openssh.authorizedKeys.keys` setting to the existing declaration. For example, this repository declares `piotr` in [modules/users/piotr/account.nix](../modules/users/piotr/account.nix); use the actual intended account instead of creating `deploy` unnecessarily.

Public keys may be stored in configuration; private keys must never be embedded in Nix expressions or copied into the Nix store. NixOS supplies declared keys through system-managed authorized-key files. See the [authorized key option](https://search.nixos.org/options?channel=unstable&query=users.users.%3Cname%3E.openssh.authorizedKeys.keys).

### Manual authorization on the remote account

For accounts that use `~/.ssh/authorized_keys`, log into the target account using existing access or a console and run these commands **on the server**:

```sh
mkdir -p ~/.ssh
chmod 700 ~/.ssh
cat >> ~/.ssh/authorized_keys <<'PUBLIC_KEY'
PASTE_YOUR_ENTIRE_PUBLIC_KEY_LINE_HERE
PUBLIC_KEY
chmod 600 ~/.ssh/authorized_keys
```

Replace the placeholder before running the command. This appends a public key without replacing existing entries. Run it as the intended login user so the files belong to that user; their home directory must not be writable by other users.

Alternatively, run [`ssh-copy-id` from the client](ssh-setup.md#4-install-the-public-key-on-a-server) if an existing login method permits it.

On NixOS, prefer declared keys for managed accounts. Manual keys and `ssh-copy-id` work only when the server allows home-directory authorized keys through `services.openssh.authorizedKeysInHomedir`. To revoke access, remove the key from every active authorization source, including both declarative settings and manually maintained files.

## 3. Test access before restricting authentication

On the server, obtain its public host key fingerprint through your console or existing trusted access:

```sh
sudo ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

If the server uses different host key paths or algorithms, inspect the corresponding public host key. Share this fingerprint with the connecting user through a trusted channel. Server host keys identify the server; authorized client keys identify users. Keep server host private keys on the server.

From a second terminal **on the client**, test public key authentication without falling back to a password or keyboard-interactive prompt:

```sh
ssh -i ~/.ssh/servers/app-prod \
    -o IdentitiesOnly=yes \
    -o PreferredAuthentications=publickey \
    -p 2222 deploy@203.0.113.10
```

Compare the host key fingerprint before accepting it. A prompt for the local private key's passphrase is expected unless an agent has already unlocked it. Confirm you reach the intended account, and test `sudo` separately if this account requires administration rights.

After that succeeds, you can require key-based login. For NixOS:

```nix
{
  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PermitRootLogin = "no";
  };
}
```

This policy disables password and keyboard-interactive SSH authentication and direct root login. Use it when all intended users have working public keys and you have a non-root administration path. If you use keyboard-interactive MFA, preserve its required authentication policy instead.

For other OpenSSH servers, the corresponding `sshd_config` settings are:

```text
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
```

Validate and apply through the appropriate mechanism, then open another fresh client connection before closing your original session. The [OpenSSH server configuration manual](https://man.openbsd.org/sshd_config) describes these settings and their interaction with other policies.

## 4. Troubleshoot and maintain access

On NixOS, inspect the service and recent logs:

```sh
sudo systemctl status sshd
sudo journalctl -u sshd -b --no-pager -n 100
```

On other distributions, substitute the actual SSH service name. To inspect listening TCP sockets on Linux, use `sudo ss -ltnp`.

- For connection timeouts or refusals, check the service, listening address and port, host firewall, and upstream network rules.
- For `Permission denied (publickey)`, check the account, installed public key, ownership, permissions, and effective authentication policy. Check any user or group allow/deny rules too.
- If access breaks after a change, use the session you kept open or recovery console to correct or revert it.

For client diagnostics, aliases, and replacement keys, see [SSH client troubleshooting](ssh-setup.md#6-troubleshoot-and-maintain-keys). When retiring a client device, remove its public keys from the server's authorization sources and apply the change. Existing sessions may remain active after key removal.