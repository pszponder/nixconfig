{ inputs, moduleWithSystem, ... }:
{
  perSystem = { pkgs, ... }: {
    # Keep nixpkgs' provider/plugin packaging, with a portable wrapper as the output.
    packages.configured-neovim = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
        viAlias = true;
        vimAlias = true;
        withPython3 = true;
        plugins = [ pkgs.vimPlugins.catppuccin-nvim ];
        neovimRcContent = builtins.readFile ../vim/common.vim + "\ncolorscheme catppuccin-mocha\n";
      };
      runtimePkgs = with pkgs; [
        bash-language-server
        clang-tools
        cmake-language-server
        nixd
      ];
    };
  };
  flake.nixosModules.neovim = moduleWithSystem (
    { self', ... }: {
      environment.systemPackages = [ self'.packages.configured-neovim ];
      environment.variables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        SUDO_EDITOR = "nvim";
        GH_EDITOR = "nvim";
      };
    }
  );
}
