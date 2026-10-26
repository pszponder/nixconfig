{
  flake.modules.nixos.tpx1Hardware = {
    imports = [ ./_hardware-configuration.nix ];
  };
}
