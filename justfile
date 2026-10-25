set shell := ["bash", "-eu", "-o", "pipefail", "-c"]
set positional-arguments

# Git pathspecs shared by formatting and checking (includes untracked files).
nix_files := "'*.nix' ':(exclude)modules/hosts/tpx1/_hardware-configuration.nix'"
prettier_files := "'*.md' '*.json' '*.yaml' '*.yml'"
bash_files := "'*.sh' '*.bash' 'modules/features/bash/bashrc' 'modules/features/shell/aliases' 'modules/features/shell/bash_profile' 'scripts/bootstrap-home' 'scripts/bootstrap-ssh'"

# List available recipes
default:
    @just --list

# Set up home directories and generate missing per-machine SSH keys
bootstrap: bootstrap-home bootstrap-ssh

# Create the default home directory structure; preserve existing contents
bootstrap-home:
    bash scripts/bootstrap-home

# Generate missing SSH key pairs interactively; preserve existing pairs
bootstrap-ssh:
    bash scripts/bootstrap-ssh

# Format supported tracked and new files, excluding generated files
fmt:
    git ls-files --cached --others --exclude-standard -z -- {{ nix_files }} | xargs -0 -r nixfmt
    git ls-files --cached --others --exclude-standard -z -- {{ prettier_files }} | xargs -0 -r prettier --write
    git ls-files --cached --others --exclude-standard -z -- '*.toml' | xargs -0 -r taplo format
    git ls-files --cached --others --exclude-standard -z -- {{ bash_files }} | xargs -0 -r shfmt -ln bash -s -w

# Check formatting without changing files
fmt-check:
    git ls-files --cached --others --exclude-standard -z -- {{ nix_files }} | xargs -0 -r nixfmt --check
    git ls-files --cached --others --exclude-standard -z -- {{ prettier_files }} | xargs -0 -r prettier --check
    git ls-files --cached --others --exclude-standard -z -- '*.toml' | xargs -0 -r taplo format --check
    git ls-files --cached --others --exclude-standard -z -- {{ bash_files }} | xargs -0 -r shfmt -ln bash -s -d

# Lint Nix and Bash files, excluding generated files and Zsh scripts
lint:
    statix check . --ignore modules/hosts/tpx1/_hardware-configuration.nix
    git ls-files --cached --others --exclude-standard -z -- {{ nix_files }} | xargs -0 -r deadnix --fail
    git ls-files --cached --others --exclude-standard -z -- {{ bash_files }} | xargs -0 -r shellcheck --shell=bash

# Validate flake outputs
check:
    nix flake check

# Run formatting, linting, and flake checks
validate: fmt-check lint check

# Fix formatting, then run all validation checks
ok: fmt validate

# Build a host without activating it; creates ./result
build host=`hostname`:
    nix build -L {{ quote(".#nixosConfigurations." + host + ".config.system.build.toplevel") }}

# Build, activate, and make the host configuration the boot default
switch host=`hostname`:
    sudo nixos-rebuild switch --flake {{ quote(".#" + host) }}

# Update flake.lock; optionally name specific inputs
update *inputs:
    nix flake update "$@"
