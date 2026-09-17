# Key bindings. Ported from the old dotmac zplug/bindkeys.zsh.
# History-substring-search bindings need the zsh-users/zsh-history-substring-search
# plugin from .zsh_plugins.txt, which is where these widgets come from.

bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward

# Up/Down arrows -> history-substring-search, in both keymaps and for both
# the normal (^[[A) and application-cursor-key (^[OA) escape sequences
# terminals send. (dotmac bound these via prezto's $key_info array, which
# doesn't exist without prezto — hence the explicit sequences here.)
for keymap in emacs viins; do
  bindkey -M "$keymap" '^[[A' history-substring-search-up
  bindkey -M "$keymap" '^[OA' history-substring-search-up
  bindkey -M "$keymap" '^[[B' history-substring-search-down
  bindkey -M "$keymap" '^[OB' history-substring-search-down
done

# `...` -> `../..`, `....` -> `../../..`, and so on — ported from prezto's
# editor module (the dot-expansion zstyle), which is where this actually
# lived, not the directory module. Bound to the literal `.` key: if the
# buffer already ends in `..`, each further dot appends another `/..`
# instead of a third literal dot, so it keeps extending for as many dots
# as you type rather than stopping at some fixed depth.
function expand-dot-to-parent-directory-path {
  if [[ $LBUFFER = *.. ]]; then
    LBUFFER+='/..'
  else
    LBUFFER+='.'
  fi
}
zle -N expand-dot-to-parent-directory-path
for keymap in emacs viins; do
  bindkey -M "$keymap" '.' expand-dot-to-parent-directory-path
done
# ...but not during incremental search (^R) — a literal `.` in a search
# query shouldn't turn into a path.
bindkey -M isearch '.' self-insert
