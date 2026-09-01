#!/usr/bin/env bash
# Bound to prefix+$ in ~/.tmux.conf. Refreshes SSH/X11-related env vars in
# tmux's global environment from the attaching client (useful after you
# reattach an old tmux session over a new SSH connection, so SSH_AUTH_SOCK
# etc. point at the current connection instead of a dead one).
#
# (Was referenced but never checked into the original dotmac repo.)

set -euo pipefail

vars=(DISPLAY SSH_ASKPASS SSH_AUTH_SOCK SSH_AGENT_PID SSH_CONNECTION SSH_TTY WINDOWID XAUTHORITY)

for v in "${vars[@]}"; do
  val=$(tmux show-environment -g "$v" 2>/dev/null | sed -n "s/^${v}=//p") || true
  if [ -n "$val" ]; then
    tmux setenv -g "$v" "$val"
  fi
done

tmux display-message "Environment renewed"
