{
  description = "Nix Config";

  inputs = {
    # Latest stable nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    # Unstable nixpkgs
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Flake parts utils
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    # Nix Wrapper Modules
    wrappers.url = "github:nix-community/nix-wrapper-modules";
  };

  # Default import-tree output (imports /modules automatically)
  outputs = inputs:
  # Pass all inputs to outputs
    inputs.flake-parts.lib.mkFlake {
      # Call mkFlake from flake-parts module
      inherit inputs; # Inherit inputs (required to get correct arch for self')
    } (inputs.import-tree ./modules); # Pass in all modules using import-tree
}

