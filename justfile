set shell := ["bash", "-eu", "-o", "pipefail", "-c"]
set positional-arguments

# Git pathspecs shared by formatting and checking (includes untracked files).
nix_files := "'*.nix' ':(exclude)modules/hosts/tpx1/_hardware-configuration.nix'"
prettier_files := "'*.md' '*.json' '*.yaml' '*.yml'"
bash_files := "'*.sh' '*.bash' 'scripts/bootstrap-dotfiles'"

# Match scheduled Nix garbage collection: retain 30 days of generations.
gc_args := "--delete-older-than 30d"

# List available recipes
default:
    @just --list

# Use SSH authentication for this repository's origin
remote-ssh:
    git remote set-url origin git@github.com:pszponder/nixconfig.git

# Set up dotfiles after activating the system configuration
bootstrap: bootstrap-dotfiles

# Generate hardware configuration from the installed system before the first rebuild
bootstrap-hardware host:
    bash scripts/bootstrap-hardware.sh "$1"

# Apply dotfiles from an existing checkout or clone the default repository
bootstrap-dotfiles *args:
    bash scripts/bootstrap-dotfiles "$@"

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
    nix build .#nixosConfigurations.{{ quote(host) }}.config.system.build.toplevel --out-link ./result

# Build and compare packages with the currently running local system
diff host=`hostname`: (build host)
    nix store diff-closures /run/current-system ./result

# Build and preview activation changes without applying them
preview host=`hostname`:
    sudo nixos-rebuild dry-activate --flake .#{{ quote(host) }}

# Activate temporarily, preserving the current boot default
[confirm("Build and temporarily activate the system configuration?")]
test host=`hostname`:
    sudo nixos-rebuild test --flake .#{{ quote(host) }}

# Confirm, build, and activate as the boot default
[confirm("Build and activate the system configuration?")]
switch host=`hostname`:
    sudo nixos-rebuild switch --flake .#{{ quote(host) }}

# Deploy over SSH: host target [switch|test|boot|dry-activate] [build-host]
[confirm("Build and deploy to the specified SSH target?")]
deploy host target action="switch" build_host="":
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ -z "$1" || -z "$2" ]]; then
        echo "A configuration name and nonempty SSH target are required." >&2
        exit 1
    fi
    case "$3" in
        switch|test|boot|dry-activate) ;;
        *) echo "Action must be switch, test, boot, or dry-activate." >&2; exit 1 ;;
    esac
    args=("$3" --flake ".#$1" --target-host "$2" --elevate sudo --ask-elevate-password)
    if [[ -n "$4" ]]; then
        args+=(--build-host "$4")
    fi
    nixos-rebuild "${args[@]}"

# Update all flake inputs, build, and activate without confirmation
up host=`hostname`:
    nix flake update
    sudo nixos-rebuild switch --flake .#{{ quote(host) }}

# Update flake.lock; optionally name specific inputs
update *inputs:
    nix flake update "$@"

# Show system profile generations
history:
    nix profile history --profile /nix/var/nix/profiles/system

# Explore this checkout's flake outputs interactively
repl:
    nix repl .

# List automatic garbage collection roots
gc-roots:
    ls -l /nix/var/nix/gcroots/auto/

# Preview cleanup without deleting generations or store paths
gc-preview:
    sudo nix-collect-garbage --dry-run {{ gc_args }}

# Confirm pruning generations older than 30 days and collecting garbage
[confirm("Prune generations older than 30 days and collect garbage?")]
gc:
    sudo nix-collect-garbage {{ gc_args }}
