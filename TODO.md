# dotfiles TODO

Improvement backlog. `.chezmoiignore` keeps this file out of `$HOME`.

## Done

- [x] **Stop deploying repo housekeeping files to `$HOME`** — `README.md`,
      `TODO.md`, `LICENSE`, `.github` added to `.chezmoiignore`
      (`chezmoi managed` was listing `~/README.md` as a target).
- [x] **fzf shell integration** — `.zshrc` now runs `source <(fzf --zsh)`
      (Ctrl-R history, Ctrl-T file picker, Alt-C cd).
- [x] **Drop dead p10k segments** — removed the language version-manager
      segments (`asdf`, `goenv`, `nodenv`, `nodeenv`, `rvm`, `fvm`, `luaenv`,
      `jenv`, `plenv`, `perlbrew`, `phpenv`, `scalaenv`, `haskell_stack`),
      `anaconda`, and `direnv` from `RIGHT_PROMPT_ELEMENTS`. `virtualenv`
      kept (uv `.venv`s). mise is the only version manager now.
- [x] **No more empty `~/Library/.../Code` tree on Linux** (and `~/.config/Code`
      on macOS) — `.chezmoiignore` now ignores the whole non-applicable tree,
      not just the leaf JSON files.

## Next (recommended)

- [ ] **Custom p10k `mise` prompt fragment** — p10k has no native mise segment.
      Write a `prompt_mise` segment (or a `POWERLEVEL9K_CUSTOM_*` command)
      that shows active tool versions from `mise current` and add it back to
      `RIGHT_PROMPT_ELEMENTS` in `dot_p10k.zsh` where the removed block was.
- [ ] **`.chezmoiexternal.toml`** — manage antidote + TPM as chezmoi externals
      with `refreshPeriod` instead of one-shot `git clone` in the bootstrap
      script. Reproducible + auto-updating.
- [ ] **`dot_config/mise/config.toml`** — check in a global mise config with
      default tools (node, python, …) and settings.
- [ ] **Secrets handling** — set up age encryption (`chezmoi add --encrypt`)
      or a password-manager template for: SSH config/keys, git signing key,
      `~/.netrc`, cloud tokens. Currently nothing.

## Backlog

- [ ] `.chezmoi.toml.tmpl`: `promptChoiceOnce` machine type (personal / work /
      headless); gate GUI config (Ghostty, VS Code, fonts) and sudo package
      installs behind it so the repo works on a server.
- [ ] `.chezmoiversion` — require a minimum chezmoi version.
- [ ] git config: `[includeIf "gitdir:~/work/"]` for a second identity /
      signing key; `delta` as diff pager; `rerere.enabled`, `fetch.prune`;
      promote `rebase.autostash` from the `up` alias to a global setting.
- [ ] macOS `defaults` script (`run_onchange_darwin-*.sh.tmpl`) — Dock,
      Finder, key-repeat, screenshot location.
- [ ] Linux GNOME `dconf` / `gsettings` script (or document the manual steps).
- [ ] Modern CLI tools + config: `zoxide` (`eval "$(zoxide init zsh)"`),
      `eza`, `bat` (`dot_config/bat/config`), `fd`, `ripgrep` config.
      Install via mise / zypper.
- [ ] VS Code extensions — checked-in list installed by a `run_onchange_`
      script (`code --install-extension`).
- [ ] CI — GitHub Actions running `chezmoi apply` + `chezmoi verify` in a
      container and `shellcheck` on the scripts.
- [ ] `zcompile` the `dot_config/zsh/*.zsh` files / cache the compinit dump
      for faster shell startup.
- [ ] Small niceties: `dot_hushlogin`, `dot_editorconfig`.
- [ ] chezmoi self-management: `[git] autoCommit` / `autoPush`, or a
      `chezmoi update` systemd timer / launchd job.
