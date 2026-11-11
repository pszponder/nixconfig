#!/usr/bin/env bash
set -euo pipefail

destination="modules/hosts/${1:?Usage: bootstrap-hardware.sh HOST}/_hardware-configuration.nix"
temporary=$(mktemp "${destination}.XXXXXX")
trap 'rm -f -- "$temporary"' EXIT

# The temporary file belongs to the invoking user; only generation needs root.
# shellcheck disable=SC2024
sudo nixos-generate-config --show-hardware-config >"$temporary"
chmod 644 "$temporary"
mv -- "$temporary" "$destination"
git diff -- "$destination"
