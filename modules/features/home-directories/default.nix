_: {
  flake.nixosModules.homeDirectories = { lib, ... }: {
    # A leading colon preserves permissions on directories that already exist.
    systemd.user.tmpfiles.users.piotr.rules = map (
      path: "d ${lib.escapeShellArg "%h/${path}"} :0755 - - -"
    ) (lib.filter (path: path != "") (lib.splitString "\n" (builtins.readFile ./directories)));
  };
}
