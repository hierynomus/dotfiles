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
- [x] **`.chezmoiexternal.toml`** — antidote (`~/.antidote`) and TPM
      (`~/.tmux/plugins/tpm`) are now chezmoi `git-repo` externals with a
      168h `refreshPeriod`; the hand-rolled `git clone`s are gone from the
      bootstrap script (a fallback antidote clone stays in `.zshrc` for a
      shell opened before the first apply). `chezmoi apply --refresh-externals`
      to force an update.
- [x] **`dot_config/mise/config.toml`** — global mise config checked in
      (node lts, python 3.13, uv, bun, playwright, scmpuff via `github:`;
      `python.uv_venv_auto`, `gpg_verify=false`). `run_onchange_after_20-mise-install.sh`
      runs `mise install` when it changes; the per-tool `mise use -g` calls
      are gone from the bootstrap script.
- [x] **Secrets handling** — age encryption scaffolded: `age` added to the
      package installs, `.chezmoi.toml.tmpl` prompts for the `ageRecipient`
      public key and wires up `encryption`/`[age]` when given, `.gitignore`
      blocks private keys, README has the `age-keygen` setup flow. No
      secrets committed yet — add them with `chezmoi add --encrypt`.
- [x] **Machine-type prompt** — `.chezmoi.toml.tmpl` now asks `machineType`
      (personal / work / headless) and `privileged`. `headless` drops all
      GUI config via `.chezmoiignore` (Ghostty, VS Code, iTerm2, fonts);
      `privileged=false` skips the `sudo` package install and the Ghostty
      cask.
- [x] **`.chezmoiversion`** — pinned to `2.60.0`.
- [x] **Modern CLI tools** — `zoxide`, `eza`, `bat`, `fd`, `ripgrep` added
      to the global mise config. `.zshrc` wires `zoxide`; `aliases.zsh`
      points `ls` at `eza`; `dot_config/{bat,ripgrep}/config` +
      `$RIPGREP_CONFIG_PATH` in `.zshenv`.
- [x] **CI** — `.github/workflows/ci.yml`: renders every template and
      dry-runs `chezmoi apply` on Linux + macOS, `shellcheck`s the
      bootstrap scripts across every machine-type branch.

## Next (recommended)

- [ ] **Custom p10k `mise` prompt fragment** — p10k has no native mise segment.
      Write a `prompt_mise` segment (or a `POWERLEVEL9K_CUSTOM_*` command)
      that shows active tool versions from `mise current` and add it back to
      `RIGHT_PROMPT_ELEMENTS` in `dot_p10k.zsh` where the removed block was.
- [ ] **Move first-run secrets into the repo** — once the age key exists,
      `chezmoi add --encrypt` the SSH config, git signing key, `~/.netrc`,
      cloud tokens.

## Backlog

- [ ] git config: `[includeIf "gitdir:~/work/"]` for a second identity /
      signing key; `delta` as diff pager; `rerere.enabled`, `fetch.prune`;
      promote `rebase.autostash` from the `up` alias to a global setting.
- [ ] macOS `defaults` script (`run_onchange_darwin-*.sh.tmpl`) — Dock,
      Finder, key-repeat, screenshot location.
- [ ] Linux GNOME `dconf` / `gsettings` script (or document the manual steps).
- [ ] VS Code extensions — checked-in list installed by a `run_onchange_`
      script (`code --install-extension`).
- [ ] `zcompile` the `dot_config/zsh/*.zsh` files / cache the compinit dump
      for faster shell startup.
- [ ] Small niceties: `dot_hushlogin`, `dot_editorconfig`.
- [ ] chezmoi self-management: `[git] autoCommit` / `autoPush`, or a
      `chezmoi update` systemd timer / launchd job.
