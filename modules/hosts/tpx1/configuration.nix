{ self, ... }: {
  # Extend the original NixOS configuration with repository features.
  flake.nixosModules.tpx1Configuration = {
    imports = [
      ./_configuration.nix
      self.nixosModules.atuin
      self.nixosModules.bash
      self.nixosModules.bat
      self.nixosModules.common
      self.nixosModules.codex
      self.nixosModules.devenv
      self.nixosModules.direnv
      self.nixosModules.fzf
      self.nixosModules.ghostty
      self.nixosModules.git
      self.nixosModules.gnome
      self.nixosModules.hjem
      self.nixosModules.homeDirectories
      self.nixosModules.jujutsu
      self.nixosModules.kanata
      self.nixosModules.neovim
      self.nixosModules.nerdFonts
      self.nixosModules.shell
      self.nixosModules.ssh
      self.nixosModules.starship
      self.nixosModules.vscode
      self.nixosModules.zoxide
      self.nixosModules.zsh
    ];
  };
}
