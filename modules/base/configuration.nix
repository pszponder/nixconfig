{
  flake.modules.nixos.baseConfiguration = { pkgs, ... }: {
    fonts.packages = with pkgs.nerd-fonts; [
      caskaydia-cove
      caskaydia-mono
      jetbrains-mono
      symbols-only
    ];

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      extra-substituters = [ "https://cache.numtide.com" ];
      extra-trusted-public-keys = [
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };
    nixpkgs.config.allowUnfree = true;
  };
}
