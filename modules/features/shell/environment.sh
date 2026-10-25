export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export TERMINAL=ghostty BROWSER=firefox
export PAGER=less MANROFFOPT=-c
export MANPAGER="sh -c 'col -bx | bat --language=man --plain --paging=always'"
for dir in "$HOME/scripts" "$HOME/bin" "$HOME/.local/bin"; do
	case ":$PATH:" in *":$dir:"*) ;; *) PATH="$dir:$PATH" ;; esac
done
export PATH
