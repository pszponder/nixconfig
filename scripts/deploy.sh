#!/usr/bin/env bash
set -euo pipefail

host="${1:-}"
target="${2:-}"
action="${3:-switch}"
build_host="${4:-}"

if [[ -z $host || -z $target ]]; then
	echo "A configuration name and nonempty SSH target are required." >&2
	exit 1
fi
case "$action" in
switch | test | boot | dry-activate) ;;
*)
	echo "Action must be switch, test, boot, or dry-activate." >&2
	exit 1
	;;
esac

args=("$action" --flake ".#$host" --target-host "$target" --elevate sudo --ask-elevate-password)
if [[ -n $build_host ]]; then
	args+=(--build-host "$build_host")
fi
nixos-rebuild "${args[@]}"
