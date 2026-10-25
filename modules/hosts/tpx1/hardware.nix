{ ... }: {
  flake.nixosModules.tpx1Hardware = {
    imports = [ ./_hardware-configuration.nix ];
  };
}
