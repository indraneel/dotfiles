# dotfiles

Personal shell, vim, and git config. Files live here as the canonical
copies; `make config` symlinks them into `$HOME`.

## Install

```sh
git clone <this repo> ~/Code/dotfiles
cd ~/Code/dotfiles
make clean && make config
```

`make clean` removes any existing `~/.bashrc`, `~/.vimrc`, etc. so the
symlinks can be created fresh. `make config` then links everything in.

## What's in here

| File / dir              | Symlinked to                | Notes                                  |
| ----------------------- | --------------------------- | -------------------------------------- |
| `bash_profile`          | `~/.bash_profile`           | login shells                           |
| `bashrc`                | `~/.bashrc`                 | non-login shells; sources `bash_aliases` |
| `bash_aliases`          | `~/.bash_aliases`           | aliases                                |
| `zshrc`                 | `~/.zshrc`                  | interactive zsh (not yet in Makefile)  |
| `zshenv`                | `~/.zshenv`                 | always-sourced zsh env (not yet in Makefile) |
| `gitconfig`             | `~/.gitconfig`              |                                        |
| `vimrc`                 | `~/.vimrc`                  |                                        |
| `vim/`                  | `~/.vim`                    | plugins under `bundle/`                |
| `Bash-Scripts/`         | (on `$PATH` via `bashrc`)   | small one-off scripts                  |
| `config/zsh/`           | `~/.config/zsh/`            | LLM helper scripts (see below)         |

> The Makefile currently only symlinks the bash configs. Zsh files and
> `config/zsh/` are tracked here but you'll need to symlink them by hand
> (or extend the Makefile) until the migration lands.

## Shell helpers

A few small functions defined in both `bashrc` and `zshrc`:

- `up N` — `cd` up N directories (`up 3` == `cd ../../..`)
- `cdls DIR` — `cd` and `ls` in one go
- `tabname NAME` — set the current terminal tab title
- `git-jira-tix [REF]` — extract Jira-style ticket IDs from `git log`

## LLM helpers (`config/zsh/`)

`zshrc` sources `~/.config/zsh/llm.sh` if present. That script wires up
local-LLM control functions:

- **qwen** (`qwen-start`, `qwen-stop`, `qwen-warm`, `qwen-bench`,
  `qwen-status`, `qwen-mem`, `qwen-logs`) — controls an
  `mlx_lm.server` instance and an optional `claude-code-proxy` in front.
- **gpt-oss** (`gpt-start`, `gpt-stop`, `gpt-warm`, `gpt-bench`,
  `gpt-status`, `gpt-mem`, `gpt-logs`) — controls an Ollama-loaded
  model. The Ollama daemon itself is managed externally (e.g. menubar app).
- `pic` — runs `pi` against the local qwen instance, autostarting if needed.
- `qwen-idle-reaper.sh` — meant to be called from `cron`/`launchd`;
  shuts down qwen if it's been idle past `QWEN_IDLE_MIN` minutes.

### Per-machine setup

Model paths and ports are NOT hardcoded in the committed scripts. Set
them in `~/.config/zsh/llm.local.sh` (gitignored):

```sh
cp config/zsh/llm.local.sh.example ~/.config/zsh/llm.local.sh
$EDITOR ~/.config/zsh/llm.local.sh   # set QWEN_MODEL_PATH, GPT_MODEL, etc.
```

`llm.sh` sources `llm.local.sh` *before* `qwen.sh` and `gpt-oss.sh`, so
its exports become the values those scripts use.

## What's gitignored

- `vim/backup/*` — vim's `backupdir`. CAN contain secrets (it has copies
  of any file you've ever edited in vim, including `.env`, `.netrc`,
  `credentials`, etc.). Treat the directory as private.
- `config/zsh/llm.local.sh` — per-machine model selections.
- `.DS_Store`, `.claude/settings.local.json`.

If you've previously committed any of the above, scrub them from history
with `git filter-repo` before pushing publicly.
