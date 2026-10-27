{ inputs, ... }:
{
  flake.modules.nixos.desktopPackages =
    { pkgs, ... }:
    let
      unstable = import inputs.nixpkgs-unstable {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    in
    {
      programs.firefox.enable = true;
      environment.systemPackages = [
        pkgs.wl-clipboard
      ]
      ++ (with unstable; [
        brave
        discord
        ghostty
        google-chrome
        obsidian
        vscode
        zed-editor
      ]);
    };
}
