config_path="$HOME/.codex/config.toml"
if [ -L "$config_path" ] || [ ! -f "$config_path" ] || [ ! -w "$config_path" ]; then
	echo "Codex needs a writable regular $config_path; move any old managed link aside and create a writable file." >&2
	exit 1
fi
chmod 0600 "$config_path"
