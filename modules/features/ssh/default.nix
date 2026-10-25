_: {
  flake.nixosModules.ssh = {
    hjem.users.piotr.files.".ssh/config".source = ./config;

    systemd.user.tmpfiles.users.piotr.rules = map (path: ''d "%h/${path}" 0700 - - -'') [
      ".ssh"
      ".ssh/github"
      ".ssh/github/pszponder"
    ];
  };
}
