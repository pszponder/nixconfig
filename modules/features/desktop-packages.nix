{
  flake.modules.nixos.desktopPackages =
    { pkgs, ... }:
    {
      programs.firefox.enable = true;
      environment.systemPackages = with pkgs; [
        wl-clipboard
        discord
        ghostty
        google-chrome
        obsidian
        vscode
        zed-editor
      ];
    };
}
