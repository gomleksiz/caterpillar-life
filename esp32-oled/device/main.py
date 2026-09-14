# Caterpillar Life, on a 128x64 SSD1306.
#
# MicroPython runs main.py automatically at boot, so this starts as soon as the
# board powers up. Ctrl-C in the REPL stops it and drops you to a prompt.

import math
import time

from machine import Pin, SoftI2C

import ssd1306

# --- wiring ---------------------------------------------------------------
# Defaults are the classic ESP32 devkit pins. ESP32-C3/S3 boards number their
# GPIOs differently -- run i2cscan.py and put the working pair here.
SCL_PIN = 22
SDA_PIN = 21
ADDR = 0x3C

WIDTH = 128
HEIGHT = 64

SEGMENTS = 7  # head plus six body segments
SPACING = 9  # pixels between segment centres
HEAD_X = 90  # the caterpillar undulates in place; the ground scrolls past it
GROUND = HEIGHT - 4


def connect():
    """Bring up the display, or explain what is wrong and re-raise."""
    bus = SoftI2C(scl=Pin(SCL_PIN), sda=Pin(SDA_PIN))
    devices = bus.scan()
    if ADDR not in devices:
        print("No SSD1306 at %s on SCL=%d SDA=%d." % (hex(ADDR), SCL_PIN, SDA_PIN))
        if devices:
            print("Something is on the bus though: %s" % ", ".join(hex(d) for d in devices))
            print("Try setting ADDR to one of those.")
        else:
            print("Nothing answered at all -- run i2cscan.py to find the right pins.")
        raise OSError("SSD1306 not found")
    return ssd1306.SSD1306_I2C(WIDTH, HEIGHT, bus, addr=ADDR)


def disc(fb, cx, cy, r, col):
    """Filled circle. framebuf.ellipse() is absent on older builds, so span it."""
    for dy in range(-r, r + 1):
        dx = int(math.sqrt(r * r - dy * dy))
        fb.hline(cx - dx, cy + dy, 2 * dx + 1, col)


def draw(oled, tick):
    oled.fill(0)

    # Title bar. The 8x8 font fits exactly 16 characters across 128px.
    oled.text("Caterpillar Life", 0, 0, 1)
    oled.hline(0, 10, WIDTH, 1)

    phase = tick * 0.35

    # Draw tail first so the head overlaps it rather than the other way round.
    for i in range(SEGMENTS - 1, -1, -1):
        x = HEAD_X - i * SPACING
        # Each segment lags the one ahead, which makes the body ripple.
        y = GROUND - 9 + int(3 * math.sin(phase - i * 0.7))
        r = 5 if i == 0 else 4
        disc(oled, x, y, r, 1)
        disc(oled, x, y, r - 2, 0)  # hollow, so segments stay distinct

        if i == 0:
            oled.pixel(x + 2, y - 2, 1)  # eye
            oled.pixel(x + 4, y - 4, 1)  # antenna
            oled.pixel(x + 5, y - 6, 1)

    # Ground scrolls right to left, which is what sells the forward motion --
    # the caterpillar itself stays put so it is never off-screen.
    oled.hline(0, GROUND + 3, WIDTH, 1)
    for x in range(-(tick * 2 % 8), WIDTH, 8):
        oled.pixel(x, GROUND + 1, 1)

    oled.show()


def main():
    oled = connect()

    # Splash, so you can see the display works before the animation starts.
    oled.fill(0)
    oled.text("Caterpillar Life", 0, 24, 1)
    oled.text("128x64 SSD1306", 8, 36, 1)
    oled.show()
    time.sleep(2)

    tick = 0
    while True:
        draw(oled, tick)
        tick += 1
        time.sleep_ms(40)


main()
