#!/usr/bin/env python

from io import FileIO
from time import sleep
from os import path as op
import sys
from subprocess import check_call, check_output
from glob import glob

# Specific to HP Pavillion x360 laptops
TOUCHSCREENS = ["ELAN2514:00 04F3:23DD"]
TOUCHPADS = []
DISABLE_TOUCHPADS = False
SENSITIVITY = 7.0  # (m^2 / s) sensibility, gravity trigger


def bdopen(fname):
    return open(op.join(basedir, fname))


def read(fname):
    return bdopen(fname).read()


for basedir in glob("/sys/bus/iio/devices/iio:device*"):
    if "accel" in read("name"):
        break
else:
    sys.stderr.write("Can't find an accelerator device!\n")
    sys.exit(1)


devices = check_output(
    ["xinput", "--list", "--name-only"], encoding="utf-8"
).splitlines()

touchscreen_names = ["touchscreen", "wacom"]
TOUCHSCREENS.extend(
    i for i in devices if any(j in i.lower() for j in touchscreen_names)
)

touchpad_names = ["touchpad", "trackpoint", "mouse"]
TOUCHPADS.extend(i for i in devices if any(j in i.lower() for j in touchpad_names))

scale = float(read("in_accel_scale"))

states = [
    {
        "rot": "normal",
        "coord": "1 0 0 0 1 0 0 0 1",
        "touchpad": "enable",
        "check": lambda x, y: y <= -SENSITIVITY,
    },
    {
        "rot": "inverted",
        "coord": "-1 0 1 0 -1 1 0 0 1",
        "touchpad": "disable",
        "check": lambda x, y: y >= SENSITIVITY,
    },
    {
        "rot": "left",
        "coord": "0 -1 1 1 0 0 0 0 1",
        "touchpad": "disable",
        "check": lambda x, y: x >= SENSITIVITY,
    },
    {
        "rot": "right",
        "coord": "0 1 0 -1 0 1 0 0 1",
        "touchpad": "disable",
        "check": lambda x, y: x <= -SENSITIVITY,
    },
]


def rotate(i):
    s = states[i]

    check_call(["xrandr", "-o", s["rot"]])

    for dev in TOUCHSCREENS if DISABLE_TOUCHPADS else (TOUCHSCREENS + TOUCHPADS):
        check_call(
            [
                "xinput",
                "set-prop",
                dev,
                "Coordinate Transformation Matrix",
            ]
            + s["coord"].split()
        )

    if DISABLE_TOUCHPADS:
        for dev in TOUCHPADS:
            check_call(["xinput", s["touchpad"], dev])


def read_accel(fp: FileIO):
    fp.seek(0)
    return float(fp.read()) * scale


if __name__ == "__main__":

    accel_x = bdopen("in_accel_x_raw")
    accel_y = bdopen("in_accel_y_raw")

    current_state = None

    while True:
        x = read_accel(accel_x)
        y = read_accel(accel_y)
        for i in range(4):
            if i == current_state:
                continue
            if states[i]["check"](x, y):
                current_state = i
                rotate(i)
                break
        sleep(1)
