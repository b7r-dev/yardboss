# yardboss

Yardboss is a tiny Bash process manager for local development. It starts, stops,
restarts, checks, and tails logs for the handful of dev servers that usually end
up scattered across terminal tabs.

It is intentionally boring. It uses a Bash config file, PID files, and plain
logs. You can clone it, read it, change it, and keep working.

Yardboss is not a production process manager. It is not a daemon. It is not a
container orchestrator. It is not trying to replace Docker Compose, systemd,
Overmind, Foreman, or tmux. It is for local dev workflows where a few commands
need to run together without turning your terminal into a crime scene.

## What Yardboss Is

- A single Bash script you can read and modify.
- A repo-local config file written in Bash.
- A way to start and stop named services in order.
- A way to check which services are running.
- A way to tail logs without learning a new UI.

## What Yardboss Is Not

- A daemon or background service.
- A TUI or curses interface.
- A replacement for Docker Compose, systemd, or Kubernetes.
- A tool for production deployments.
- A plugin platform.
- YAML or JSON config based.

## Installation

### Per-repo (recommended)

Copy the script into your project:

```bash
curl -L -o yardboss https://github.com/yourname/yardboss/raw/main/yardboss
chmod +x yardboss
./yardboss init         # Generates a starter yardboss.conf
```

Or clone it:

```bash
git clone https://github.com/yourname/yardboss.git
cd yardboss
chmod +x yardboss
./yardboss init         # Generates a starter yardboss.conf
```

### Global install

Install to `/usr/local`:

```bash
make install
```

Install to a custom prefix:

```bash
make PREFIX=$HOME/.local install
```

Then copy the example config into your project:

```bash
cp /usr/local/share/yardboss/yardboss.conf.example ./yardboss.conf
```

To remove:

```bash
make uninstall
```

Yardboss has no runtime dependencies beyond common POSIX-ish userland tools:
`bash`, `mkdir`, `rm`, `kill`, `tail`, `lsof` (optional), and `curl` (optional).

## Quickstart

1. Edit `yardboss.conf` to define your services:

```bash
PROJECT_NAME="myapp"

services=(api web)

api_cmd="cd apps/api && npm run dev"
api_port=3001

web_cmd="cd apps/web && npm run dev"
web_port=3000
```

2. Start everything:

```bash
./yardboss start
```

3. Check status:

```bash
./yardboss status
```

4. Tail logs:

```bash
./yardboss logs
```

5. Stop everything:

```bash
./yardboss stop
```

## Command Reference

| Command | Description |
|---------|-------------|
| `yardboss init [--force]` | Generate a starter config for this project |
| `yardboss start [service]` | Start a service or all services |
| `yardboss stop [service]` | Stop a service or all services |
| `yardboss restart [service]` | Restart a service or all services |
| `yardboss status` | Show status table for all services |
| `yardboss logs [service]` | Tail logs for a service or all services |
| `yardboss clean` | Remove stale PID files |
| `yardboss doctor` | Check configuration and environment |
| `yardboss help` | Show usage |

A `[service]` argument targets a single service from the config. Without it, the
command applies to all services. Start uses the listed order; stop uses reverse
order.

## Config File

The config file is Bash. It is sourced by yardboss. You can use shell features,
but keep it simple.

Required:

- `services=(...)` - Array of service names.
- `<service>_cmd="..."` - Command to run for each service.

Optional:

- `PROJECT_NAME="..."`
- `YARDBOSS_STATE_DIR="..."` (default: `.yardboss`)
- `<service>_port=...` - For port status checks.
- `<service>_health="..."` - For future health check support.

See `yardboss.conf.example` and `docs/configuration.md` for more examples.

## Runtime Files

Yardboss creates a state directory (default: `.yardboss`) next to the config:

```
.yardboss/
  pids/
    api.pid
    web.pid
  logs/
    api.log
    web.log
```

- PID files track processes yardboss started.
- Logs capture stdout and stderr.
- The directory is safe to delete when nothing is running.

## macOS and Ubuntu Notes

Yardboss targets Bash 3.2+ to support the ancient Bash shipped with macOS. It
avoids Bash 4+ features like associative arrays.

On macOS, `lsof` is typically available for port checks. On Ubuntu, install it
with `apt-get install lsof` if needed.

## Safety Model

Yardboss only manages processes it started, as tracked by PID files. It will not
kill random processes based on port numbers. If a port is in use by something
else, yardboss will report it but will not take action.

## Troubleshooting

See `docs/troubleshooting.md` for common issues and fixes.

## Development

See `AGENTS.md` for contributor and agent-oriented documentation.

## License

MIT. See `LICENSE`.
