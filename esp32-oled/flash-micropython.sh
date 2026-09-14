#!/usr/bin/env bash
# Flash a MicroPython firmware image onto the connected ESP32.
#
#   ./flash-micropython.sh                    tell me which firmware to download
#   ./flash-micropython.sh ESP32_GENERIC.bin  erase the chip and flash that image
#
# The flash offset differs between ESP32 families -- get it wrong and the board
# boot-loops -- so the offset is chosen from the detected chip, not guessed.

set -uo pipefail
cd "$(dirname "$0")"

FIRMWARE="${1:-}"
VENV="./.esp-venv"
say() { printf '\n\033[1m== %s\033[0m\n' "$1"; }

if [ ! -x "$VENV/bin/esptool" ]; then
  echo "esptool not installed yet. Run ./detect.sh first."
  exit 1
fi

say "Detecting chip"
CHIP_LINE=$("$VENV/bin/esptool" flash-id 2>&1 | grep -m1 "Chip is")
if [ -z "$CHIP_LINE" ]; then
  echo "Could not identify the chip. Run ./detect.sh to troubleshoot the connection."
  exit 1
fi
echo "$CHIP_LINE"

# Order matters: match the specific families before bare ESP32.
case "$CHIP_LINE" in
  *ESP32-S3*) BOARD=ESP32_GENERIC_S3; OFFSET=0x0    ;;
  *ESP32-C3*) BOARD=ESP32_GENERIC_C3; OFFSET=0x0    ;;
  *ESP32-C6*) BOARD=ESP32_GENERIC_C6; OFFSET=0x0    ;;
  *ESP32-H2*) BOARD=ESP32_GENERIC_H2; OFFSET=0x0    ;;
  *ESP32-C2*) BOARD=ESP32_GENERIC_C2; OFFSET=0x0    ;;
  *ESP32-S2*) BOARD=ESP32_GENERIC_S2; OFFSET=0x1000 ;;
  *ESP32*)    BOARD=ESP32_GENERIC;    OFFSET=0x1000 ;;
  *) echo "Unrecognised chip: $CHIP_LINE"; exit 1 ;;
esac

echo "Board variant: $BOARD    flash offset: $OFFSET"

if [ -z "$FIRMWARE" ]; then
  say "Download the firmware"
  cat <<MSG
Grab the latest stable .bin for your chip from:

    https://micropython.org/download/$BOARD/

Pick the newest entry under "Firmware" (the .bin without 'IDF3'/'preview'),
then rerun this script with the file:

    ./flash-micropython.sh ~/Downloads/$BOARD-<version>.bin
MSG
  exit 0
fi

if [ ! -f "$FIRMWARE" ]; then
  echo "No such file: $FIRMWARE"
  exit 1
fi

say "Erasing flash"
# A clean erase avoids stale filesystem blocks from whatever shipped on the board.
"$VENV/bin/esptool" erase-flash || { echo "Erase failed."; exit 1; }

say "Writing $FIRMWARE at $OFFSET"
"$VENV/bin/esptool" --baud 460800 write-flash "$OFFSET" "$FIRMWARE" || {
  echo "Flash failed. Retry at a slower speed if the cable is long or noisy."; exit 1; }

say "Done"
echo "MicroPython is on the board. Next: ./upload.sh"
