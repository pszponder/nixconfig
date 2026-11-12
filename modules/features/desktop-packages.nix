{
  flake.modules.nixos.desktopPackages =
    { pkgs, ... }:
    {
      programs.firefox.enable = true;
      environment.systemPackages = with pkgs; [
        discord
        ghostty
        google-chrome
        libreoffice
        obsidian
        vscode
        wl-clipboard
        zed-editor
      ];
    };
}
