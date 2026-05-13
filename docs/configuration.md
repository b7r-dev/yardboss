# Configuration Reference

The yardboss config file is a Bash script named `yardboss.conf` by default. It
is sourced by the main `yardboss` script.

## Required Fields

### `services=(...)`

A bash array defining the names of services in startup order.

```bash
services=(api web worker)
```

### `<service>_cmd="..."`

The command to run for each service. The command is executed via `bash -lc`.

```bash
api_cmd="cd apps/api && npm run dev"
web_cmd="cd apps/web && npm run dev"
worker_cmd="cd apps/worker && npm run dev"
```

## Optional Fields

### `PROJECT_NAME="..."`

A project name for display or future use. Currently informational.

### `YARDBOSS_STATE_DIR="..."`

Directory for PID files and logs. Default: `.yardboss`.

### `<service>_port=...`

Port number for status checks. If set, `yardboss status` shows whether the port
is listening.

```bash
api_port=3001
web_port=3000
```

### `<service>_health="..."`

Health check URL for future use. Parsed but not actively polled in v0.

```bash
api_health="http://localhost:3001/health"
```

## Examples

### Node.js / npm

```bash
PROJECT_NAME="my-node-app"
services=(api web)

api_cmd="cd apps/api && npm run dev"
api_port=3001

web_cmd="cd apps/web && npm run dev"
web_port=3000
```

### Python

```bash
PROJECT_NAME="my-python-app"
services=(api worker)

api_cmd="cd api && python -m uvicorn main:app --reload --port 8000"
api_port=8000

worker_cmd="cd worker && celery -A tasks worker -l info"
```

### Rails

```bash
PROJECT_NAME="my-rails-app"
services=(web worker)

web_cmd="bin/rails server -p 3000"
web_port=3000

worker_cmd="bin/bundle exec sidekiq"
```

### Docker Compose Wrapper

```bash
PROJECT_NAME="my-docker-app"
services=(db app)

db_cmd="docker compose up db"
db_port=5432

app_cmd="docker compose up app"
app_port=3000
```

### Generic Shell Commands

```bash
PROJECT_NAME="my-shell-app"
services=(server watcher)

server_cmd="python -m http.server 8080"
server_port=8080

watcher_cmd="find . -name '*.go' | entr -r go run ./..."
```

## Quoting and Shell Expansion

- Use double quotes around commands that contain variables or special characters.
- Commands are passed to `bash -lc`, so tilde expansion, command substitution,
  and variables work.
- Avoid single quotes if the command contains single quotes; escape or restructure.
- Keep commands simple. Complex logic belongs in a script that the config calls.
