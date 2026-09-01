#!/usr/bin/env bash
# Copy stdin to the system clipboard. Referenced by ~/.tmux.conf's copy-mode
# bindings (was referenced but never checked into the original dotmac repo).
#
# Tries, in order: macOS pbcopy, Wayland wl-copy, X11 xclip/xsel, and
# finally an OSC52 escape sequence (works over SSH in terminals that
# support it, tmux included, with no local clipboard tool required).

set -euo pipefail

if command -v pbcopy > /dev/null 2>&1; then
  exec pbcopy
elif [ -n "${WAYLAND_DISPLAY:-}" ] && command -v wl-copy > /dev/null 2>&1; then
  exec wl-copy
elif command -v xclip > /dev/null 2>&1; then
  exec xclip -selection clipboard
elif command -v xsel > /dev/null 2>&1; then
  exec xsel --clipboard --input
else
  # OSC52 fallback: base64-encode stdin and wrap it in the escape sequence
  # that asks the terminal to set the clipboard itself.
  buf=$(cat | base64 | tr -d '\n')
  printf '\033]52;c;%s\a' "$buf" > /dev/tty
fi
