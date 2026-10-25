{ inputs, moduleWithSystem, ... }: {
  perSystem = { system, ... }: {
    packages.configured-codex = inputs.llm-agents.packages.${system}.codex;
  };

  flake.nixosModules.codex = moduleWithSystem (
    { self', ... }: { pkgs, ... }: {
      environment.systemPackages = [ self'.packages.configured-codex ];
      # System defaults stay immutable; Codex can persist changes in its user config.
      environment.etc."codex/config.toml".source = ./config.toml;
      systemd.user.tmpfiles.users.piotr.rules = [
        "d %h/.codex 0700 - - -"
        "C %h/.codex/config.toml 0600 - - - ${pkgs.writeText "codex-user-config.toml" ""}"
      ];
      systemd.user.services.codex-config = {
        description = "Check the writable Codex user configuration";
        unitConfig.ConditionUser = "piotr";
        wantedBy = [ "default.target" ];
        after = [ "systemd-tmpfiles-setup.service" ];
        serviceConfig.Type = "oneshot";
        path = [ pkgs.coreutils ];
        script = builtins.readFile ./check-config.sh;
      };
    }
  );
}
