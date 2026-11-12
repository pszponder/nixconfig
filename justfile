set shell := ["bash", "-eu", "-o", "pipefail", "-c"]
set positional-arguments

# Git pathspecs shared by formatting and checking (includes untracked files).
nix_files := "'*.nix' ':(exclude)modules/hosts/tpx1/_hardware-configuration.nix'"
prettier_files := "'*.md' '*.json' '*.yaml' '*.yml'"
bash_files := "'*.sh' '*.bash' 'scripts/bootstrap-dotfiles'"

# Match scheduled nh cleanup: retain recent generations and development roots.
nh_clean_args := "--keep-since 30d --keep 3 --no-gcroots"

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
    nh os build . -H {{ quote(host) }} --out-link ./result

# Build, review changes, confirm, and activate as the boot default
switch host=`hostname`:
    nh os switch . -H {{ quote(host) }} --ask

# Update all flake inputs, build, and confirm before activation
up host=`hostname`:
    nh os switch . -H {{ quote(host) }} --update --ask

# Update flake.lock; optionally name specific inputs
update *inputs:
    nix flake update "$@"

# Preview generation pruning and garbage collection with the scheduled retention policy
gc-preview:
    sudo nh clean all --dry {{ nh_clean_args }}

# Confirm pruning old generations and collecting garbage; retain 30 days and at least 3 generations
gc:
    sudo nh clean all --ask {{ nh_clean_args }}
