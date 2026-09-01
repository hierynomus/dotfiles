# dotfiles

Managed with [chezmoi](https://www.chezmoi.io/), zsh managed with
[antidote](https://getantidote.github.io/) + [powerlevel10k](https://github.com/romkatv/powerlevel10k).
Works the same on macOS and Linux — OS differences are handled with chezmoi
templates rather than by hand.

Rebuilt from [hierynomus/dotmac](https://github.com/hierynomus/dotmac); see
"What changed from dotmac" below for what moved, what got fixed, and what
was deliberately left behind.

## First-time setup on a new machine

```sh
sh -c "$(curl -fsLS get.chezmoi.io)"
chezmoi init --apply <your-github-username>/<this-repo-name>
```

`chezmoi init` will ask three questions the first time (git name, git email,
`$EDITOR`) and cache the answers per-machine in
`~/.config/chezmoi/chezmoi.toml`. `--apply` runs the package-bootstrap
script (Homebrew on macOS; zypper/apt/dnf on Linux; then mise + uv,
antidote, powerlevel10k font, tmux plugin manager) and then symlinks/writes
everything into place.

After that:

- Open a new shell — antidote will clone itself and compile the plugin
  bundle on first run, powerlevel10k's instant prompt will show for future
  shells.
- If you've never run the p10k wizard on this exact prompt config before
  (you have — `~/.p10k.zsh` is carried over from dotmac already tuned), you
  don't need to do anything. To change it, run `p10k configure`.
- Inside tmux, press `prefix + I` (capital i) once to have TPM fetch the
  tmux plugins.
- On Linux, if Ghostty wasn't available through your package manager, the
  bootstrap script will tell you — grab it from
  <https://ghostty.org/download> and re-run `chezmoi apply`.

To pull down changes you made from another machine, or changes you edit
directly in `~/.local/share/chezmoi`:

```sh
chezmoi update       # git pull + apply
```

To edit a dotfile and have chezmoi track the change:

```sh
chezmoi edit ~/.zshrc     # opens the source file in $EDITOR
chezmoi apply             # or -v to preview the diff first
```

## Layout

- `dot_zshenv.tmpl`, `dot_zprofile.tmpl`, `dot_zshrc.tmpl` — the three zsh
  startup files, in prezto's original load order (zshenv → zprofile →
  zshrc), just without prezto itself.
- `dot_zsh_plugins.txt` — antidote's plugin bundle file. Add a line, open a
  new shell, antidote recompiles automatically.
- `dot_p10k.zsh` — your existing powerlevel10k config, carried over as-is.
- `dot_config/zsh/` — aliases, the kubectl/kubeconfig helpers, bind keys,
  and general-purpose shell functions, split out of `.zshrc` for
  readability and sourced from it automatically.
- `dot_gitconfig.tmpl` — your git identity and aliases (`st`, `lg`, `lg2`,
  `ribbon`, `catchup`, etc.), unchanged except for what's listed below.
- `dot_tmux.conf.tmpl` + `dot_tmux/` — tmux config and the two helper
  scripts (`yank.sh`, `renew_env.sh`) it calls out to.
- `dot_config/ghostty/config.tmpl` — Ghostty terminal config. Same file
  works on both OSes since Ghostty reads `~/.config/ghostty/config`
  everywhere, not just on Linux.
- `dot_config/Code/User/` and `Library/Application Support/Code/User/` —
  the same VS Code settings/keybindings, checked in twice because that's
  where each OS actually looks for them; `.chezmoiignore` hides whichever
  one doesn't match the current machine so only one ever gets applied.
- `dot_config/iterm2/colorschemes/` — your iTerm2 `.itermcolors` files,
  carried over as plain files (iTerm2's own settings are a macOS plist,
  not something worth templating — see the iTerm2/GNOME Terminal note
  below).
- `.chezmoiscripts/run_once_before_00-install-packages.sh.tmpl` — installs
  everything above assumes exists (zsh, git, tmux, fzf, tree, a Nerd Font,
  Ghostty, [mise](https://mise.jdx.dev/), [uv](https://docs.astral.sh/uv/),
  [scmpuff](https://github.com/mroth/scmpuff), TPM). On Linux it uses
  zypper (openSUSE), falling back to apt/dnf; `scmpuff` — which has no
  distro package — is pulled from its GitHub releases via mise's `ubi`
  backend. Runs once per machine; edit the script and it'll run once more
  to pick up the change.

## What changed from dotmac

**Plugin manager**: prezto → antidote. The old `.zshrc` sourced
`~/.zprezto/init.zsh`, but nothing in dotmac actually installed or pinned
prezto (no submodule, no clone step) — it only worked because it happened
to already be on the machine. Antidote's bundle file makes the plugin list
explicit and installs itself on first run, and it starts faster because it
compiles the bundle to a static file instead of resolving plugins on every
new shell.

**Cross-platform paths**: `.zprofile`/`.zshrc` had several absolute paths
baked in (`/Users/ajvanerp/google-cloud-sdk/...`, `/Users/ajvanerp/.rd/bin`,
`/opt/homebrew/bin/brew` unconditionally) that only worked on one specific
Mac. These are now `$HOME`-relative and gated behind `command -v` / file
existence checks, plus explicit Linux branches (`zypper`/`apt`/`dnf`
package names) where the two OSes actually differ.

**Version managers**: pyenv, rbenv, nvm and SDKMAN are gone — replaced by
[mise](https://mise.jdx.dev/) for language/tool versions and
[uv](https://docs.astral.sh/uv/) for Python project environments. `.zshrc`
now just runs `mise activate zsh`; `.zprofile` puts the mise shims dir on
`PATH` so non-interactive shells resolve managed tools too. The
`pyenv`/`rbenv`/`nvm` powerlevel10k prompt segments were dropped to match,
and the unused `pipenv` completion hook went with them. The generic
`venv` helper and `virtualenv` prompt segment stay — `uv` creates plain
`.venv`s those still understand.

**No Linuxbrew**: the Linux bootstrap used to install Homebrew purely to
get `pyenv`/`go`/`scmpuff` at macOS parity. With mise handling those,
Linuxbrew is dropped entirely — Linux packages come from zypper (openSUSE,
the common case here) or apt/dnf, and everything else from mise.

**tmux**: dotmac had two tmux configs (`tmux.conf` and `tmux-new.conf`)
that had clearly drifted apart. This repo keeps only the more complete one
(`tmux-new.conf`'s content, now just `tmux.conf`). It also referenced
`~/.tmux/yank.sh` and `~/.tmux/renew_env.sh` and `~/.tmux/tmux.remote.conf`
that were never actually checked into dotmac — those three now exist for
real (`yank.sh` copies to system clipboard on both OSes, falling back to
OSC52 over SSH; `renew_env.sh` refreshes SSH/X11 env vars after
reattaching; `tmux.remote.conf` just recolors the status bar so a nested
remote session is visually obvious).

**git**: default branch `master` → `main` (and the `ribbon`/`catchup`
aliases updated to match); `core.editor` was `/usr/local/bin/atom -n -w`,
which no longer exists (Atom was discontinued) — now uses the `editor`
value you give `chezmoi init`, same as `$EDITOR`; added `pull.rebase` and
`credential.helper` (osxkeychain on macOS, cache on Linux) since those
weren't set before.

**VS Code**: settings/keybindings otherwise untouched. Only functional
change: `vs-kubernetes`'s tool paths were hardcoded to one Mac's home
directory (and, for the Linux entries, to `/root/...`, which won't be
right unless you're actually running as root) — now templated to whatever
`$HOME` actually is on each machine. `terminal.external.osxExec` updated
from `iTerm.app` to `Ghostty.app` since Ghostty's now your primary Mac
terminal.

**iTerm2 / GNOME Terminal**: not automated. iTerm2 stores its preferences
in a macOS plist (`com.googlecode.iterm2.plist`), not a plain-text file —
the clean way to manage it is pointing iTerm2 at a chezmoi-managed folder
via *Preferences → General → Preferences → "Load preferences from a custom
folder or URL"*, but that needs your actual current plist as a starting
point, which isn't in dotmac, so it's not set up here. GNOME Terminal
profiles live in dconf, not a file, and are even less pleasant to manage —
skipped entirely for now. Ghostty's config is the one that's fully
managed, since it's the terminal you're using on both OSes.

**Left behind on purpose** (still in the old dotmac repo if you want any
of them — `zplug/functions/`): `vpnconnect`/`vpnsetup` (a former
employer's OpenConnect VPN, including a passwordless-sudo grant script —
not something to carry into a fresh bootstrap unreviewed), `nuke-vpc` (raw
AWS EC2 VPC teardown, no safety rails), `gradle`/`clean_idea`/`gstac`
(Gradle wrapper finder, IntelliJ cleanup, and a JIRA "STAC-" ticket commit
helper — all specific to a previous, non-Kubernetes job), `creds`
(wraps a `creds.py` that isn't checked in anywhere). The `intellij/`,
`sbt/`, and `vmnet-shark` folders from dotmac weren't ported either, since
they're not part of what you're using day to day now — say the word if you
want any of it back.

## Adding a new machine-specific value

If you ever need a value that should differ per machine beyond what
`chezmoi init` already asks (name/email/editor), add another
`promptStringOnce` line to `.chezmoi.toml.tmpl` and reference it as
`{{ .whatever }}` in any `.tmpl` file.
