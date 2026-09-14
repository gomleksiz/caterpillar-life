#!/usr/bin/env bash
# Copy the device/ files onto the board's filesystem and restart it.
#
#   ./upload.sh              auto-detect the port
#   ./upload.sh /dev/ttyUSB0 use a specific port
#
# main.py runs automatically on boot, so the demo starts as soon as this finishes.

set -uo pipefail
cd "$(dirname "$0")"

PORT="${1:-}"
VENV="./.esp-venv"
say() { printf '\n\033[1m== %s\033[0m\n' "$1"; }

if [ ! -d "$VENV" ]; then
  echo "Run ./detect.sh first to create the toolchain venv."
  exit 1
fi

if [ ! -x "$VENV/bin/mpremote" ]; then
  say "Installing mpremote"
  "$VENV/bin/pip" install --quiet --timeout 120 --retries 3 mpremote || {
    echo "mpremote install failed -- check your network."; exit 1; }
fi

MPR=("$VENV/bin/mpremote")
[ -n "$PORT" ] && MPR+=(connect "$PORT")

say "Copying files"
for f in ssd1306.py i2cscan.py main.py; do
  echo "  device/$f -> :$f"
  "${MPR[@]}" fs cp "device/$f" ":$f" || {
    echo
    echo "Copy failed. Close any serial monitor holding the port and try again."
    exit 1; }
done

say "Resetting board"
"${MPR[@]}" reset

say "Done"
cat <<MSG
The demo is running on the display now.

Useful follow-ups:
  $VENV/bin/mpremote                  open a live REPL (Ctrl-] to exit)
  $VENV/bin/mpremote run device/i2cscan.py   re-scan the I2C bus
  $VENV/bin/mpremote fs ls            list files on the board

If the screen stayed dark, the REPL prints the reason -- connect and press
Ctrl-D to see the traceback.
MSG
