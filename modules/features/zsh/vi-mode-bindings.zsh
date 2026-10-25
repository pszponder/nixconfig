_zoxide_interactive_widget() {
  zle -I
  zi < /dev/tty || :
  zle reset-prompt
}

zvm_after_init() {
  zle -N _zoxide_interactive_widget
  bindkey -M viins '\ez' _zoxide_interactive_widget
  bindkey -M emacs '\ez' _zoxide_interactive_widget
  bindkey '^T' fzf-file-widget
  bindkey '\ec' fzf-cd-widget
  if (( $+widgets[_atuin_search_widget] )); then
    bindkey '^R' _atuin_search_widget
  else
    bindkey '^R' history-incremental-search-backward
  fi
}
