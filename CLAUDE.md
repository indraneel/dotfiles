# CLAUDE.md

Agent guidance for working in this repo.

## What this repo is

Personal dotfiles. Files live here as the canonical copies; `make config`
symlinks them into `$HOME` (see `Makefile`).

Tracked: `bashrc`, `bash_profile`, `bash_aliases`, `zshrc`, `zshenv`,
`gitconfig`, `vimrc`, `vim/`, `config/zsh/*` (helper scripts).

Not tracked (see `.gitignore`):
- `vim/backup/*` — vim swap/backup files. CAN contain secrets if a
  `.env` / `.netrc` / `credentials` file has ever been opened in vim
  with this as `backupdir`. Never `git add` these.
- `config/zsh/llm.local.sh` — per-machine LLM model paths. The committed
  `config/zsh/llm.sh` sources it if present.
- `.DS_Store`, `.claude/settings.local.json`.

## Layout conventions

- Bash configs at the repo root (no leading dot): `bashrc`, `bash_profile`, etc.
  The Makefile symlinks `bashrc` → `~/.bashrc`.
- Zsh follows the same pattern: `zshrc`, `zshenv` → `~/.zshrc`, `~/.zshenv`.
- Per-XDG-config helpers live in `config/zsh/` and are sourced by `zshrc`.

## LLM helper scripts (`config/zsh/`)

`zshrc` sources `~/.config/zsh/llm.sh` if it exists. `llm.sh` then sources,
in order:

1. `llm.local.sh` — per-machine model selection (NOT committed). Exports
   `QWEN_MODEL_PATH`, `GPT_MODEL`, ports, etc.
2. `qwen.sh` — qwen-via-mlx_lm.server functions (`qwen-start`, `qwen-stop`,
   `qwen-warm`, `qwen-bench`, ...).
3. `gpt-oss.sh` — gpt-oss-via-Ollama functions (`gpt-start`, `gpt-stop`, ...).

All model paths/ports/hosts in `qwen.sh`, `gpt-oss.sh`, `qwen-idle-reaper.sh`
use `${VAR:-default}` so they're overridable from `llm.local.sh`. When
adding a new hardcoded path or port to one of these scripts, parameterize
it the same way.

`llm.local.sh.example` is the template. To set up a new machine:

```sh
cp config/zsh/llm.local.sh.example ~/.config/zsh/llm.local.sh
$EDITOR ~/.config/zsh/llm.local.sh
```

## Things to avoid

- Don't put machine-specific paths or model names in committed files. Add a
  `${VAR:-default}` and document the override in `llm.local.sh.example`.
- Don't commit anything from `vim/backup/`. Verify `git status` before staging.
- The Makefile currently only symlinks bash configs. Updating it to also
  symlink `zshrc`/`zshenv`/`config/zsh/*` is a deliberate migration —
  confirm with the user first since it clobbers existing real files.
