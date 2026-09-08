#!/usr/bin/env bash
# Prints capped "name version" pairs for the nearest project-local mise
# config above $PWD. Companion to the removed p10k `prompt_mise` segment
# (dot_p10k.zsh) — same upward search, ported here for starship's
# `custom.mise` module (dot_config/starship.toml).
#
# `--check` is the cheap half (just the directory walk, no `mise`
# invocation) — used as starship's `when` so the expensive half below only
# runs when there's actually something to show. Capped at $max tools so a
# project pinning half a dozen of them doesn't take over the prompt line;
# the rest collapse into a "+N" suffix.
set -euo pipefail

max=3

find_config() {
  local global_cfg="${XDG_CONFIG_HOME:-$HOME/.config}/mise/config.toml"
  local dir="$PWD" f
  while [[ -n $dir && $dir != "$HOME" && $dir != "/" ]]; do
    for f in mise.toml mise.local.toml .mise.toml .mise.local.toml .tool-versions; do
      if [[ "$dir/$f" != "$global_cfg" && -e "$dir/$f" ]]; then
        printf '%s\n' "$dir/$f"
        return 0
      fi
    done
    dir="${dir%/*}"
    [[ -z $dir ]] && dir=/
  done
  return 1
}

if [[ "${1-}" == --check ]]; then
  command -v mise > /dev/null 2>&1 && find_config > /dev/null
  exit $?
fi

command -v mise > /dev/null 2>&1 || exit 1
find_config > /dev/null || exit 1

# MISE_OFFLINE keeps this from ever blocking the prompt on a network call to
# resolve "latest"; --no-header for older mise safety.
pairs=()
while IFS= read -r line; do
  read -ra fields <<< "$line"
  (( ${#fields[@]} >= 2 )) || continue
  [[ ${fields[0]} == Tool && ${fields[1]} == Version ]] && continue
  pairs+=("${fields[0]##*:} ${fields[1]}")
done < <(MISE_OFFLINE=1 command mise ls --local --no-header 2>/dev/null)

(( ${#pairs[@]} )) || exit 1

if (( ${#pairs[@]} > max )); then
  shown=("${pairs[@]:0:max}")
  printf '%s +%d\n' "${shown[*]}" "$(( ${#pairs[@]} - max ))"
else
  printf '%s\n' "${pairs[*]}"
fi
