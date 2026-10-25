set shell := ["bash", "-eu", "-o", "pipefail", "-c"]
set positional-arguments

# List available recipes
default:
    @just --list

# Format tracked and new, non-ignored Nix files
fmt:
    git ls-files --cached --others --exclude-standard -z -- '*.nix' | xargs -0 -r nixfmt

# Check formatting without changing files
fmt-check:
    git ls-files --cached --others --exclude-standard -z -- '*.nix' | xargs -0 -r nixfmt --check

# Check for Nix anti-patterns and unused code
lint:
    statix check .
    deadnix --fail .

# Validate flake outputs
check:
    nix flake check

# Run formatting, linting, and flake checks
validate: fmt-check lint check

# Fix formatting, then run all validation checks
ok: fmt validate

# Build a host without activating it; creates ./result
build host=`hostname`:
    nix build -L {{quote(".#nixosConfigurations." + host + ".config.system.build.toplevel")}}

# Build, activate, and make the host configuration the boot default
switch host=`hostname`:
    sudo nixos-rebuild switch --flake {{quote(".#" + host)}}

# Update flake.lock; optionally name specific inputs
update *inputs:
    nix flake update "$@"
