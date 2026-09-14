#!/usr/bin/env bash
# Identify an ESP32 board connected over USB.
#
# Installs esptool into a local venv (./.esp-venv) and interrogates the chip.
# Nothing is written to the board -- this only reads.
#
#   ./detect.sh              auto-detect the port
#   ./detect.sh /dev/ttyUSB0 use a specific port

set -uo pipefail
cd "$(dirname "$0")"

PORT="${1:-}"
VENV="./.esp-venv"

say() { printf '\n\033[1m== %s\033[0m\n' "$1"; }

say "Serial ports"
# macOS uses /dev/cu.*, Linux uses /dev/ttyUSB* (CP210x/FTDI) or /dev/ttyACM* (native USB).
PORTS=$(ls /dev/cu.usbserial* /dev/cu.usbmodem* /dev/cu.wchusbserial* /dev/cu.SLAB_USBtoUART* \
           /dev/ttyUSB* /dev/ttyACM* 2>/dev/null)
if [ -z "$PORTS" ]; then
  echo "No USB serial ports found."
  echo
  echo "  * Is the board plugged in? Try a different cable -- many USB cables are"
  echo "    charge-only and carry no data lines."
  echo "  * Linux: you may need to be in the 'dialout' group:"
  echo "        sudo usermod -aG dialout \$USER   # then log out and back in"
  echo "  * macOS: a CH340-based clone may need the WCH driver."
  exit 1
fi
echo "$PORTS"

say "Installing esptool"
if [ ! -x "$VENV/bin/esptool" ]; then
  python3 -m venv "$VENV" || { echo "Could not create venv. Install python3-venv."; exit 1; }
  "$VENV/bin/pip" install --quiet --timeout 120 --retries 3 esptool || {
    echo "esptool install failed -- check your network."; exit 1; }
fi
"$VENV/bin/esptool" version | head -1

# esptool v5 renamed subcommands to hyphens (flash-id); v4 used underscores (flash_id).
MAJOR=$("$VENV/bin/esptool" version 2>/dev/null | tail -1 | cut -d. -f1)
if [ "${MAJOR:-5}" -ge 5 ] 2>/dev/null; then
  FLASH_ID="flash-id"; READ_MAC="read-mac"
else
  FLASH_ID="flash_id"; READ_MAC="read_mac"
fi

ARGS=()
[ -n "$PORT" ] && ARGS=(--port "$PORT")

say "Chip identity"
# flash-id reports the chip type, crystal, MAC and the attached flash chip in one pass.
"$VENV/bin/esptool" "${ARGS[@]}" "$FLASH_ID" || {
  echo
  echo "Could not talk to the chip. If it just sits at 'Connecting...':"
  echo "  * Hold the BOOT (or IO0) button, tap EN/RST, release BOOT, and rerun."
  echo "  * Close any serial monitor holding the port (Arduino IDE, screen, minicom)."
  exit 1
}

say "MAC address"
"$VENV/bin/esptool" "${ARGS[@]}" "$READ_MAC"

say "Done"
echo "Report the 'Detecting chip type' and 'Features' lines above to size up the board."
