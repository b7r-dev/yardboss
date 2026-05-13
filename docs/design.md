# Design Document

This document explains why yardboss is built the way it is.

## Why Bash Config

Bash config files are explicit, inspectable, and require no parser. A developer
can read the config and know exactly what it does. It supports variables,
command substitution, and comments natively. It avoids the complexity of YAML
typers and JSON validators.

The tradeoff: config errors surface as Bash errors. Yardboss mitigates this by
running `bash -n` before sourcing.

## Why PID Files

PID files are simple, portable, and well understood. They require no background
daemon, no control socket, and no IPC. Each service gets a `.pid` file in the
state directory. Yardboss only manages processes whose PIDs it wrote.

The tradeoff: PID files can become stale if a process dies unexpectedly.
Yardboss detects stale PIDs on status and clean commands.

## Why Repo-Local State

Yardboss stores its state in a `.yardboss/` directory next to the config. This
makes it obvious what files belong to yardboss, keeps the project self-contained,
and avoids cluttering system directories. Deleting `.yardboss/` cleans up
everything.

## Why No Daemon

Daemons add complexity: signal handling, socket files, process trees, restart
policies. Yardboss runs in the foreground and exits. The services it starts run
in the background as normal shell jobs. This is the simplest model that works
for local development.

## Why No YAML/JSON

YAML and JSON config files require parsers. In Bash, that means adding
dependencies (Python, jq, npm) or writing fragile regex-based parsers. A Bash
config needs no parser at all. It also means the config can use shell features
like command substitution and environment variables.

## Process Ownership Model

Yardboss writes a PID file when it starts a service. It only stops processes
for which it has a PID file. It detects ports in use with `lsof`, but it never
kills a process based on port alone. This prevents accidentally killing
unrelated processes.

## Known Limitations

- No automatic restart on crash. Start the service again manually.
- No service dependency graph. Order services in the config array.
- No process group cleanup. Stopping a service sends SIGTERM to the PID. If
  that PID spawned children, those children may remain. A future version could
  explore process group cleanup, but the macOS/Linux tradeoffs must be
  documented.
- No health check polling in v0. `_health` URLs are parsed but not polled.
- Port checks require `lsof`. Without it, port status shows `unknown`.
- Commands that exit immediately are treated as failed.
