{ inputs, moduleWithSystem, ... }:
{
  perSystem =
    { pkgs, self', ... }:
    let
      environment = {
        FZF_DEFAULT_COMMAND = "fd --type f --hidden --strip-cwd-prefix";
        FZF_CTRL_T_COMMAND = "fd --type f --hidden --strip-cwd-prefix";
        FZF_ALT_C_COMMAND = "fd --type d --hidden --strip-cwd-prefix";
        FZF_CTRL_T_OPTS = "--preview 'bat --color=always --style=plain,numbers --line-range=:500 {}'";
        FZF_ALT_C_OPTS = "--preview 'eza --tree --color=always {} | head -200'";
        FZF_DEFAULT_OPTS = builtins.readFile ./options;
      };
    in
    {
      packages = {
        configured-fzf = inputs.wrappers.lib.wrapPackage {
          inherit pkgs;
          package = pkgs.fzf;
          runtimePkgs = [
            pkgs.fd
            pkgs.eza
            pkgs.dnsutils
            self'.packages.configured-bat
          ];
          envDefault = environment;
        };
        configured-fzf-environment = pkgs.writeText "fzf-environment.sh" (
          pkgs.lib.concatStringsSep "\n" (
            pkgs.lib.mapAttrsToList (name: value: "export ${name}=${pkgs.lib.escapeShellArg value}") environment
          )
        );
        configured-fzf-bash-integration = pkgs.replaceVars ./bash-integration.bash {
          environment = self'.packages.configured-fzf-environment;
          fzf = self'.packages.configured-fzf;
          previews = ./previews.sh;
        };
        configured-fzf-zsh-integration = pkgs.replaceVars ./zsh-integration.zsh {
          environment = self'.packages.configured-fzf-environment;
          fzf = self'.packages.configured-fzf;
          previews = ./previews.sh;
        };
      };
    };
  flake.nixosModules.fzf = moduleWithSystem (
    { self', ... }: {
      environment.systemPackages = [ self'.packages.configured-fzf ];
    }
  );
}
