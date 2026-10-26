{
  inputs,
  pkgs,
  lib,
  ...
}:

let
  llm = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  bashFiles = "\\.(sh|bash)$|^scripts/bootstrap-dotfiles$";
in
{
  packages = with pkgs; [
    betterleaks
    bubblewrap
    deadnix
    git
    just
    nixfmt
    prettier
    shfmt
    shellcheck
    statix
    taplo
    llm.codex
  ];

  git-hooks.excludes = [ "^modules/hosts/tpx1/_hardware-configuration\\.nix$" ];
  git-hooks.hooks = {
    nixfmt.enable = true;
    statix = {
      enable = true;
      args = [
        "--ignore"
        "modules/hosts/tpx1/_hardware-configuration.nix"
      ];
    };
    deadnix.enable = true;
    prettier = {
      enable = true;
      files = "\\.(md|json|ya?ml)$";
    };
    taplo.enable = true;
    shfmt = {
      enable = true;
      files = bashFiles;
      types = lib.mkForce [ "file" ];
      args = [
        "-ln"
        "bash"
      ];
    };
    shellcheck = {
      enable = true;
      files = bashFiles;
      types = lib.mkForce [ "file" ];
      args = [ "--shell=bash" ];
    };
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
