# shellcheck disable=SC1090,SC1091
. @environment@
eval "$(@fzf@/bin/fzf --bash)"
source @previews@
