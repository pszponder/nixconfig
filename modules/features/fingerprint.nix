{
  flake.modules.nixos.fingerprint = {
    services.fprintd = {
      enable = true;
      # Desktop and locker modules select their own fingerprint authentication.
      # GDM supplies its fingerprint PAM stack when fprintd is enabled.
      enablePam = false;
    };
  };
}
