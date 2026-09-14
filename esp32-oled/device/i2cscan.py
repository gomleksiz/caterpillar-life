# Find the OLED on the I2C bus.
#
# Run it when the display stays dark: it tries the usual pin pairs and reports
# every address that answers, so you can tell a wiring fault (nothing answers
# anywhere) from a wrong address (something answers, but not at 0x3C).

from machine import Pin, SoftI2C

# (SCL, SDA) pairs, commonest first. Classic ESP32 devkits use 22/21; the
# C3/S3 boards renumber their pins, hence the alternatives.
CANDIDATES = ((22, 21), (9, 8), (5, 4), (7, 6), (18, 19))


def scan(scl, sda):
    try:
        bus = SoftI2C(scl=Pin(scl), sda=Pin(sda))
    except (ValueError, OSError) as err:
        # That GPIO does not exist on this chip -- expected while probing.
        return None, err
    try:
        return bus.scan(), None
    except OSError as err:
        return None, err


def main():
    print("Scanning I2C buses...\n")
    found = False
    for scl, sda in CANDIDATES:
        addrs, err = scan(scl, sda)
        label = "SCL=%-3d SDA=%-3d" % (scl, sda)
        if addrs is None:
            print("%s  unavailable (%s)" % (label, err))
        elif addrs:
            found = True
            print("%s  devices: %s" % (label, ", ".join(hex(a) for a in addrs)))
            for a in addrs:
                if a in (0x3C, 0x3D):
                    print("      ^ that is an SSD1306 OLED at %s" % hex(a))
        else:
            print("%s  nothing responded" % label)

    print()
    if not found:
        print("No I2C device answered on any pin pair. Check that:")
        print("  * VCC and GND are not swapped (a reversed module stays dark)")
        print("  * SCL and SDA are not swapped")
        print("  * the module is getting 3.3V")
    else:
        print("Put the working pins into main.py as SCL_PIN / SDA_PIN.")


main()
