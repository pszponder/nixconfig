#!/usr/bin/env bash
set -euo pipefail

host=${1:?Usage: bootstrap-hardware.sh HOST}
destination="modules/hosts/$host/_hardware-configuration.nix"
temporary=$(mktemp "${destination}.XXXXXX")
trap 'rm -f -- "$temporary"' EXIT

# The temporary file belongs to the invoking user; only generation needs root.
# shellcheck disable=SC2024
sudo nixos-generate-config --show-hardware-config --no-filesystems >"$temporary"
chmod 644 "$temporary"
mv -- "$temporary" "$destination"
git diff -- "$destination"
