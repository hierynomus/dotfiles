# Key bindings. Ported from the old dotmac zplug/bindkeys.zsh.
# History-substring-search bindings need the zsh-users/zsh-history-substring-search
# plugin from .zsh_plugins.txt, which is where these widgets come from.

bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

for keymap in 'emacs' 'viins'; do
  bindkey -M "$keymap" "${key_info[Up]}" history-substring-search-up
  bindkey -M "$keymap" "${key_info[Down]}" history-substring-search-down
done
