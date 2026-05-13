# AGENTS.md

This document is for AI coding agents and human contributors who want to modify
yardboss safely and correctly.

## Project Purpose

Yardboss is a repo-local Bash process manager for running multiple development
servers during local software development. It is intentionally simple,
explicit, and boring.

## Non-Goals

- Not a production process manager.
- Not a daemon or background service.
- Not a TUI or GUI.
- Not a replacement for Docker Compose, systemd, Overmind, Foreman, tmux.
- Not a plugin platform.
- Not a secret manager or remote execution tool.
- Not a file watcher or auto-reloader.

## Compatibility Rules

- Target Bash 3.2+ because macOS ships old Bash.
- Must work on macOS and Ubuntu.
- No runtime dependencies beyond common POSIX-ish tools.
- No associative arrays (Bash 4+ feature).
- Avoid arrays indexed by string.
- Use variable indirection (`${!var}`) carefully; verify on Bash 3.2.

## Bash Version Constraints

- Use `set -euo pipefail` but be careful with optional variables and arrays.
- Prefer `printf '%s' "${!var:-}"` for variable indirection.
- Avoid `mapfile`, `readarray`, associative arrays, and `declare -A`.
- Avoid `local -n` (namerefs) unless verified on target Bash.

## Style Rules

- Use functions for each command.
- Use small helpers for PID files, log files, service validation, variable lookup.
- Use clear names and defensive quoting.
- No huge clever one-liners.
- No generated code.
- No unreadable regex acrobatics.
- Prefer explicit error messages over cryptic Bash errors.
- Avoid silent `|| true` unless explicitly justified.

Example error helper:

```bash
die() {
  echo "yardboss: $*" >&2
  exit 1
}
```

## How to Add a Command

1. Add a function: `<command>_service` or `<command>_all` or `<command>`.
2. Add the command to the `case` statement in `main()`.
3. Update `usage()` to include the new command.
4. Update `docs/commands.md`.
5. Update `README.md` command reference.
6. Add a smoke test in `test/smoke.sh` if applicable.
7. Run `./scripts/lint.sh`.

## How to Modify Config Behavior Safely

- The config file is sourced via `source`.
- Validate required variables exist after sourcing.
- Do not assume optional variables are set; use `${var:-}` defaults.
- If adding new optional fields, document them in `docs/configuration.md`.
- Keep the example config in sync.

## Testing Expectations

- Run `bash -n yardboss` before committing.
- Run `./scripts/lint.sh` if shellcheck is available.
- Run `./test/smoke.sh` before committing.
- Tests should not require Node, npm, or external services.

## Documentation Expectations

- Keep `README.md` concise and practical.
- Update `docs/*.md` for detailed reference.
- Update `AGENTS.md` if conventions change.
- Update `Makefile` if install targets change.
- Do not turn the README into marketing copy.

## Important Warning

Do not add dependencies, daemons, YAML config, JSON config, Node tooling,
Python helpers, or a TUI without strong justification and discussion. Yardboss
is intentionally minimal. If a feature adds complexity, it probably does not
belong here.
