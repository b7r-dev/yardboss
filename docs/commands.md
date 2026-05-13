# Commands Reference

## `yardboss init [--force]`

Generate a starter `yardboss.conf` for the current project. Yardboss detects the
project type by looking for common files and generates a commented config with
sensible defaults.

### Arguments

- `--force` (optional) - Overwrite an existing config file.

### Examples

```bash
# Generate a new config
./yardboss init

# Overwrite an existing config
./yardboss init --force
```

### Expected Output

```
Detected project type: node
Generating yardboss.conf ...

Created yardboss.conf

Next steps:
  1. Review and edit yardboss.conf
  2. Run 'yardboss doctor' to check your config
  3. Run 'yardboss start' to start your services
```

The generated config is a Bash file with the detected project type in comments.
Always review and edit it before running `start`.

---

## `yardboss start [service]`

Start a service or all services. Services are started in the order defined in
the config array.

### Arguments

- `service` (optional) - Name of a single service to start.

### Examples

```bash
# Start all services
./yardboss start

# Start the api service only
./yardboss start api
```

### Expected Output

```
yardboss: api: started (pid 12345)
yardboss: web: started (pid 12346)
```

If a service is already running:

```
yardboss: api: already running (pid 12345)
```

## `yardboss stop [service]`

Stop a service or all services. Services are stopped in reverse order.

### Arguments

- `service` (optional) - Name of a single service to stop.

### Examples

```bash
# Stop all services
./yardboss stop

# Stop the api service only
./yardboss stop api
```

### Expected Output

```
yardboss: web: stopping (pid 12346)...
yardboss: web: stopped
yardboss: api: stopping (pid 12345)...
yardboss: api: stopped
```

If a service is not running:

```
yardboss: api: not running
```

## `yardboss restart [service]`

Restart a service or all services. Stops in reverse order, then starts in
listed order.

### Arguments

- `service` (optional) - Name of a single service to restart.

### Examples

```bash
# Restart all services
./yardboss restart

# Restart the api service only
./yardboss restart api
```

### Expected Output

```
yardboss: web: stopping (pid 12346)...
yardboss: web: stopped
yardboss: api: stopping (pid 12345)...
yardboss: api: stopped

yardboss: api: started (pid 12347)
yardboss: web: started (pid 12348)
```

## `yardboss status`

Show a table of all services with their status, PID, port, port status, and log
file path.

### Expected Output

```
SERVICE          STATUS       PID       PORT      PORT_STATUS   LOG
api              running      12345     3001      listening     .yardboss/logs/api.log
web              stopped      -         3000      closed        .yardboss/logs/web.log
worker           running      12347     -         -             .yardboss/logs/worker.log
```

If a PID file exists but the process is dead, status shows:

```
api              stopped (stale PID)  -  3001  closed  .yardboss/logs/api.log
```

## `yardboss logs [service]`

Tail logs for a service or all services.

### Arguments

- `service` (optional) - Name of a single service to tail.

### Examples

```bash
# Tail all service logs
./yardboss logs

# Tail the api service log
./yardboss logs api
```

### Behavior

Uses `tail -n 120 -f`. If the log file does not exist yet, it prints a message.
When tailing all logs, each line is prefixed with the log filename by `tail`.

## `yardboss clean`

Remove stale PID files. A PID file is stale if the process it references is no
longer running. Does not kill processes or remove log files.

### Expected Output

```
yardboss: removed stale PID file for api
yardboss: no stale PID files found
```

## `yardboss doctor`

Check the configuration and environment for common problems.

### Checks Performed

- Config file exists.
- Bash is available.
- `lsof` is available (warning only).
- `curl` is available (warning only).
- State directory is writable.
- Services array is defined and non-empty.
- Each service has a command.
- Ports that are listening but not owned by yardboss.

### Expected Output

```
yardboss: doctor

  [OK] config file exists: yardboss.conf
  [OK] bash found: /bin/bash
  [OK] lsof found (port checks enabled)
  [OK] curl found (health checks possible)
  [OK] state directory writable: .yardboss
  [OK] services array defined: api web worker
  [OK]   api: command defined
  [OK]   web: command defined
  [OK]   worker: command defined

yardboss: doctor passed
```

## `yardboss help`

Show usage information.

### Expected Output

```
yardboss 0.1.0

Usage: yardboss <command> [service]

Commands:
  init [--force]     Generate a yardboss.conf for this project
  start [service]    Start a service or all services
  stop [service]     Stop a service or all services
  restart [service]  Restart a service or all services
  status             Show status of all services
  logs [service]     Tail logs for a service or all services
  clean              Remove stale PID files
  doctor             Check configuration and environment
  help               Show this message

Environment:
  YARDBOSS_CONFIG    Path to config file (default: yardboss.conf)
```
