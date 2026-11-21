{ inputs, ... }:
{
  flake.modules.nixos.desktopPackages =
    { pkgs, ... }:
    {
      imports = [
        inputs.pflakes.nixosModules.helium
        inputs.pflakes.nixosModules.zen-browser
      ];

      programs = {
        firefox.enable = true;
        helium.enable = true;
        zen-browser.enable = true;
      };

      environment.systemPackages = with pkgs; [
        discord
        flameshot
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
