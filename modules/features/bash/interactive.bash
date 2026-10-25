set -o vi

# bind -x runs in the current shell; preserve the pending command and cursor.
_zoxide_interactive_widget() {
	local saved_line=$READLINE_LINE saved_point=$READLINE_POINT
	zi || :
	READLINE_LINE=$saved_line
	READLINE_POINT=$saved_point
}
bind -m vi-insert -x '"\ez":_zoxide_interactive_widget'
bind -m emacs-standard -x '"\ez":_zoxide_interactive_widget'

HISTTIMEFORMAT='%F %T '
PROMPT_COMMAND='history -a; printf "\e]0;%s@%s: %s\a" "$USER" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'
