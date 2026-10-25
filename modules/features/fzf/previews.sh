# Shared completion previews loaded by the fzf shell integrations.
_fzf_comprun() {
	local command=$1
	shift
	case "$command" in
	cd | z) fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
	export | unset) fzf --preview "eval 'echo \${}'" "$@" ;;
	ssh) fzf --preview 'dig {}' "$@" ;;
	*) fzf --preview 'bat --color=always --style=plain,numbers --line-range=:500 {}' "$@" ;;
	esac
}
