{
  inputs,
  self,
  moduleWithSystem,
  ...
}:
{
  flake.wrappers.vscode = { pkgs, wlib, ... }: {
    imports = [ wlib.modules.default ];
    package = import ./_package.nix {
      pkgs = import inputs.nixpkgs-unstable {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    };
  };

  perSystem =
    {
      pkgs,
      self',
      system,
      ...
    }:
    {
      # The outer wrapper retains VS Code's unfree license metadata.
      wrappers.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfreePredicate =
          pkg:
          builtins.elem (inputs.nixpkgs.lib.getName pkg) [
            "vscode"
            "vscode-with-extensions"
          ];
      };
      packages.configured-vscode-settings = pkgs.writeText "vscode-settings.json" (
        builtins.toJSON (
          (builtins.fromJSON (builtins.readFile ./settings.json))
          // {
            "terminal.integrated.profiles.linux" = {
              bash = {
                path = "${self'.packages.bash}/bin/bash";
                icon = "terminal-bash";
              };
              zsh = {
                path = "${self'.packages.zsh}/bin/zsh";
                icon = "terminal-bash";
              };
            };
            "vim.shell" = "${self'.packages.zsh}/bin/zsh";
          }
        )
      );
    };

  flake.nixosModules.vscode = moduleWithSystem (
    { self', ... }: {
      imports = [
        self.wrappers.vscode.install
      ];
      wrappers.vscode.enable = true;
      hjem.users.piotr.xdg.config.files = {
        "Code/User/settings.json".source = self'.packages.configured-vscode-settings;
        "Code/User/keybindings.json".source = ./keybindings.json;
      };
    }
  );
}
