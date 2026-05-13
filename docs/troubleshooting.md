# Troubleshooting

## I Don't Have a Config Yet

**Symptom:** `yardboss` exits with `missing config file: yardboss.conf`.

**Fix:** Run `yardboss init` to generate a starter config. Yardboss detects the
project type and writes a commented config with sensible defaults. Review it,
then run `yardboss doctor` before starting services.

## Stale PID Files

**Symptom:** `yardboss status` shows a service as "stopped (stale PID)".

**Cause:** The service crashed or was killed outside of yardboss. The PID file
was not cleaned up.

**Fix:** Run `./yardboss clean` to remove stale PID files. Or remove them
manually from `.yardboss/pids/`.

## Port Already in Use

**Symptom:** A service fails to bind to its port, or `yardboss doctor` warns
that a port is listening but not owned by yardboss.

**Cause:** Another process is using the port. Yardboss only manages processes it
started and will not kill processes based on port alone.

**Fix:** Stop the other process manually, or change the port in your config.

## Service Starts Then Exits

**Symptom:** `yardboss start` reports "failed to start (process exited
immediately)".

**Cause:** The command has a syntax error, missing dependency, or exits quickly
by design.

**Fix:** Check the service log in `.yardboss/logs/<service>.log`. Run the
command manually in a terminal to see the error.

## Missing `lsof`

**Symptom:** `yardboss status` shows `unknown` for all port statuses.

**Cause:** `lsof` is not installed or not in PATH.

**Fix:** Install `lsof`. On Ubuntu: `sudo apt-get install lsof`. On macOS, it
is usually preinstalled.

## Logs Are Empty

**Symptom:** `yardboss logs <service>` shows nothing.

**Cause:** The service has not been started yet, or the command does not
produce output.

**Fix:** Start the service with `./yardboss start <service>`. Check if the log
file exists: `ls .yardboss/logs/`.

## Commands Work Manually but Fail Under Yardboss

**Symptom:** Running the command directly in a terminal works, but fails when
started by yardboss.

**Cause:** The command relies on environment variables, shell aliases, or
interactive features (like `read`) that are not available in a non-interactive
shell.

**Fix:** Yardboss runs commands with `bash -lc`, which loads the user's profile
and rc files. Make sure environment variables are set in `.bashrc` or
`.bash_profile`, not just in the current interactive session. Avoid interactive
commands in service definitions.

## macOS Bash Gotchas

**Symptom:** Strange errors about associative arrays or `declare -A`.

**Cause:** macOS ships Bash 3.2, which does not support Bash 4+ features.

**Fix:** Yardboss avoids Bash 4+ features. If you modify the script, avoid
associative arrays, `mapfile`, `readarray`, and `local -n`.

If you want a newer Bash on macOS, install it via Homebrew:
`brew install bash`. Yardboss does not require this, but it may help with your
own scripts.
