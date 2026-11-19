{
  description = "Nix Config";

  inputs = {
    # Unstable nixpkgs is the default for NixOS and packages.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Stable packages are available separately when needed.
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    # Keep upstream's tested nixpkgs pin for compatibility and binary cache hits.
    llm-agents.url = "github:numtide/llm-agents.nix";

    pflakes = {
      url = "github:pszponder/pflakes";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake parts utils
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
