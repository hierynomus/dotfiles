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
