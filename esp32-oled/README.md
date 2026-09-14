# ESP32 + SSD1306 OLED

A MicroPython setup for driving a 128x64 I2C OLED from an ESP32, with scripts to
identify the board, flash MicroPython and push the code.

> **These scripts run on your own computer, not in a Claude session.** A Claude
> Code session on the web runs in a cloud VM with no USB passthrough, so it
> cannot see or flash a board plugged into your machine. Clone the repo locally
> and run them there.

## Quickstart

```sh
cd esp32-oled
./detect.sh                    # what board is this?
./flash-micropython.sh         # prints the firmware URL for your chip
./flash-micropython.sh ~/Downloads/ESP32_GENERIC-<version>.bin
./upload.sh                    # copy the code across and run it
```

## Step 1 — what is this board?

`./detect.sh` installs `esptool` into a local venv (`.esp-venv/`, git-ignored)
and reads the chip's identity. It only reads; nothing is written.

The line that matters is `Chip is ...`. Match it against the table below —
these are the families you are likely to have, and what they can do:

| Chip | Cores | WiFi / BT | Notable | Typical board |
| --- | --- | --- | --- | --- |
| **ESP32** (D0WD) | 2 x 240MHz | WiFi + BT Classic + BLE | 34 GPIO, 2 x ADC, DAC, touch | DevKit v1, WROOM-32 |
| **ESP32-S2** | 1 x 240MHz | WiFi only | native USB, no Bluetooth | Saola, S2 Mini |
| **ESP32-S3** | 2 x 240MHz | WiFi + BLE | native USB, PSRAM, AI ops | S3 DevKitC |
| **ESP32-C3** | 1 x 160MHz RISC-V | WiFi + BLE | cheap, 22 GPIO | C3 Mini, Super Mini |
| **ESP32-C6** | 1 x 160MHz RISC-V | WiFi 6 + BLE + Thread/Zigbee | newest radio stack | C6 DevKitC |

All of them can drive this OLED — I2C is universal across the family. The
differences matter for what you build *next*: BT Classic (audio, serial
profiles) only exists on the original ESP32, and Thread/Zigbee only on the C6.

Every one of these gives you, beyond the display: WiFi (HTTP client/server,
MQTT, NTP), PWM for LEDs and servos, ADC for analogue sensors, hardware I2C and
SPI for more peripherals, interrupts, and deep sleep at a few microamps.

## Step 2 — wiring

Power the module from **3.3V**, not 5V. Most of these modules tolerate 5V, but
the ESP32's GPIO pins do not, and a 5V-powered module can pull the I2C lines
above 3.3V.

| OLED pin | ESP32 pin | Notes |
| --- | --- | --- |
| `VCC` / `VDD` | `3V3` | not `VIN`, not `5V` |
| `GND` | `GND` | |
| `SCL` / `SCK` | `GPIO22` | clock |
| `SDA` | `GPIO21` | data |

GPIO22/21 are the classic ESP32 devkit's I2C pins. **The C3, S3 and C6 number
their pins differently** — if you have one of those, pick any two free GPIOs,
wire them, and set `SCL_PIN` / `SDA_PIN` at the top of `device/main.py`.
`i2cscan.py` will find them for you.

No pull-up resistors needed: essentially every SSD1306 breakout has them on
board already.

## Step 3 — flash MicroPython

`./flash-micropython.sh` with no arguments detects the chip and prints the
download page for the matching firmware. Download the newest stable `.bin`, then
pass it back:

```sh
./flash-micropython.sh ~/Downloads/ESP32_GENERIC-20250809-v1.26.1.bin
```

The script erases the flash and writes the image at the **correct offset for
your chip** — `0x1000` on the original ESP32 and the S2, `0x0` on the S3, C3, C6
and H2. Getting this wrong is the single most common reason a freshly flashed
board boot-loops, which is why the script derives it rather than assuming.

## Step 4 — upload the code

```sh
./upload.sh
```

This installs `mpremote`, copies the three files in `device/` onto the board and
resets it. MicroPython runs `main.py` at boot, so the display lights up
immediately.

| File | Purpose |
| --- | --- |
| `device/ssd1306.py` | the display driver, from `micropython-lib` |
| `device/i2cscan.py` | scans the bus and reports what answers |
| `device/main.py` | the demo: a caterpillar crawling across the screen |

`ssd1306.py` is **not** built into MicroPython. It was frozen into ESP32 builds
up to v1.19 and removed afterwards, so it has to be copied onto the board —
which is what `upload.sh` does.

## Drawing your own

`SSD1306_I2C` subclasses `framebuf.FrameBuffer`, so you get the whole
framebuffer API. Nothing appears until you call `show()`:

```python
from machine import Pin, SoftI2C
import ssd1306

i2c = SoftI2C(scl=Pin(22), sda=Pin(21))
oled = ssd1306.SSD1306_I2C(128, 64, i2c)

oled.fill(0)                      # clear
oled.text("hello", 0, 0, 1)       # 8x8 font, 16 chars x 8 lines
oled.rect(0, 12, 60, 20, 1)       # outline
oled.fill_rect(4, 16, 20, 12, 1)  # solid
oled.line(0, 40, 127, 63, 1)
oled.show()                       # push the buffer to the panel
```

Also available: `pixel`, `hline`, `vline`, `scroll`, `blit`, and on the display
object `contrast(0-255)`, `invert(True/False)`, `rotate(True/False)`,
`poweroff()` and `poweron()`.

## Troubleshooting

**Nothing on screen, no errors.** The contrast may be at zero, or the module is
a 128x32 sold as 128x64. Try `oled.invert(True)` — if the panel flashes white,
wiring and address are fine and the problem is in what you are drawing.

**`OSError: [Errno 19] ENODEV` on startup.** Nothing answered at the I2C address.
Run `mpremote run device/i2cscan.py` to sweep the common pin pairs. If nothing
answers anywhere, it is the wiring — swapped SDA/SCL is the usual culprit, and
swapped VCC/GND leaves the module completely dark.

**Something answers, but not at 0x3C.** A few modules are strapped to `0x3D`.
Set `ADDR` in `main.py`.

**Image is garbled or shifted by 2 pixels.** The controller is an SH1106, not an
SSD1306 — visually identical modules, different driver. Use an SH1106 driver
instead; the rest of this setup is unchanged.

**esptool hangs at `Connecting...`.** Hold `BOOT` (or `IO0`), tap `EN`/`RST`,
release `BOOT`. Some boards need this to enter the bootloader. Also make sure no
serial monitor is holding the port.

**No serial port at all.** Try another cable — charge-only USB cables are
extremely common and carry no data lines. On Linux add yourself to `dialout`
(`sudo usermod -aG dialout $USER`, then log out and in).
