{ inputs, self, ... }:
{
  flake.modules.nixos.common =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ self.modules.nixos.commonPackages ];

      _module.args.pkgsStable = import inputs.nixpkgs-stable {
        system = pkgs.stdenv.hostPlatform.system;
        config = config.nixpkgs.config;
      };

      i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

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
