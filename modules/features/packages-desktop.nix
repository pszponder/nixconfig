{ inputs, ... }:
{
  flake.modules.nixos.desktopPackages =
    { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      llmAgents = inputs.llm-agents.packages.${system};
    in
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
        llmAgents.herdr-app
        inputs.hex.packages.${system}.default
        libreoffice
        obsidian
        llmAgents.opencode2-desktop
        # t3code
        vscode
        wl-clipboard
        zed-editor
      ];
    };
}
