_: {
  flake.nixosModules.nerdFonts = { pkgs, ... }: {
    fonts.packages = with pkgs.nerd-fonts; [
      caskaydia-cove
      caskaydia-mono
      jetbrains-mono
      symbols-only
    ];
  };
}
