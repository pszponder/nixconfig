{ inputs, pkgs, ... }:

let
  llm = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  packages = with pkgs; [
    betterleaks
    bubblewrap
    deadnix
    git
    just
    nixfmt
    statix
    llm.codex
  ];

  git-hooks.hooks = {
    betterleaks-commit = {
      enable = true;
      name = "Betterleaks staged secrets";
      entry = "${pkgs.betterleaks}/bin/betterleaks git --pre-commit --staged --redact --no-banner .";
      stages = [ "pre-commit" ];
      pass_filenames = false;
      always_run = true;
    };
    betterleaks-push = {
      enable = true;
      name = "Betterleaks pushed history";
      entry = "${pkgs.writeShellScript "check-pushed-secrets" ''
        exec ${pkgs.betterleaks}/bin/betterleaks git --redact --no-banner --log-opts="''${PRE_COMMIT_TO_REF:?Missing pushed commit}" .
      ''}";
      stages = [ "pre-push" ];
      pass_filenames = false;
      always_run = true;
    };
  };

  enterShell = ''
    echo "NixOS configuration development environment"
    echo "Codex is available as 'codex'."
  '';
}
