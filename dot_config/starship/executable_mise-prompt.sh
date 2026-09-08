#!/usr/bin/env bash
# Prints capped "name version" pairs for the *language runtimes* the
# nearest project-local mise config above $PWD pins. Companion to the
# removed p10k `prompt_mise` segment (dot_p10k.zsh) — same upward search,
# ported here for starship's `custom.mise` module (dot_config/starship.toml).
#
# `--check` and the real run must agree on relevance, or starship's
# when+command combo shows a bare $symbol: `when` passing while `command`
# then finds nothing to report still renders the module (icon, no text).
# So both share the same "does the config actually mention a runtime we
# care about" grep before `--check` exits, and before the real run bothers
# calling `mise ls` — a comment merely mentioning a runtime name could still
# produce that mismatch, but an actual mise.toml/.tool-versions won't.
#
# Capped at $max runtimes so a polyglot project doesn't take over the
# prompt line; the rest collapse into a "+N" suffix.
#
# `--extra` narrows the runtime list to the ones the catppuccin-powerline
# preset's own language modules (c/rust/golang/nodejs/bun/php/java/kotlin/
# haskell/python) don't already show — otherwise a project pinning node
# would show its version twice, once from starship's native $nodejs and
# once from this segment.
set -euo pipefail

max=3

# mise's core plugins — actual language runtimes, as opposed to the CLI
# tools (terraform, awscli, uv, …) mise also happens to manage. Static
# rather than shelling out to `mise plugins ls --core` every prompt; check
# that list if a new runtime doesn't show up here.
runtimes=(bun deno dotnet elixir erlang go java node python ruby rust swift zig)

check_only=false
for arg in "$@"; do
  case $arg in
    --check) check_only=true ;;
    --extra)
      # bun/rust/go/node/java/python overlap with the preset's own modules;
      # everything else in mise's core list doesn't have a starship module.
      runtimes=(deno dotnet elixir erlang ruby swift zig)
      ;;
  esac
done

is_runtime() {
  local t
  for t in "${runtimes[@]}"; do
    [[ $t == "$1" ]] && return 0
  done
  return 1
}

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

command -v mise > /dev/null 2>&1 || exit 1
cfg=$(find_config) || exit 1

# Cheap textual pre-check: does the config mention one of our runtimes at
# all? Skips `mise` entirely for the common case of a project only pinning
# tools we don't care about — and in --check mode, this IS the whole check.
pattern=$(IFS='|'; echo "${runtimes[*]}")
grep -qE "(^|[^[:alnum:]_-])($pattern)([^[:alnum:]_-]|\$)" "$cfg" || exit 1

$check_only && exit 0

# MISE_OFFLINE keeps this from ever blocking the prompt on a network call to
# resolve "latest"; --no-header for older mise safety.
pairs=()
while IFS= read -r line; do
  read -ra fields <<< "$line"
  (( ${#fields[@]} >= 2 )) || continue
  [[ ${fields[0]} == Tool && ${fields[1]} == Version ]] && continue
  name=${fields[0]##*:}
  is_runtime "$name" || continue
  pairs+=("$name ${fields[1]}")
done < <(MISE_OFFLINE=1 command mise ls --local --no-header 2>/dev/null)

(( ${#pairs[@]} )) || exit 1

if (( ${#pairs[@]} > max )); then
  shown=("${pairs[@]:0:max}")
  printf '%s +%d\n' "${shown[*]}" "$(( ${#pairs[@]} - max ))"
else
  printf '%s\n' "${pairs[*]}"
fi
