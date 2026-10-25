zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --color=always $realpath'
autoload -Uz add-zsh-hook
_terminal_title() { print -Pn '\e]0;%n@%m: %~\a'; }
add-zsh-hook precmd _terminal_title
