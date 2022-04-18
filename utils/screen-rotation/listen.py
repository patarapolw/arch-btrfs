#!/usr/bin/env python

from os import getenv
import sys
from time import sleep
from subprocess import Popen, check_output
from typing import Optional
from threading import Thread


class OnscreenKeyboard:
    is_shown = False
    process: Optional[Popen] = None

    def __init__(self):
        pass

    def _hide(self):
        if self.process:
            self.process.kill()
            self.process = None

    def _show(self):
        if not self.process:
            self.process = Popen(["onboard"])

    def toggle(self, show: bool):
        if self.is_shown != show:
            self.is_shown = show
        if show:
            Thread(target=lambda: (self._show()), daemon=True).start()
        else:
            self._hide()


kbd = OnscreenKeyboard()
mode = None

while True:
    screen = check_output(["xrandr", "--current"], encoding="utf-8").splitlines()[1]
    new_mode = screen[: screen.index("(")].split(" ")[-2]
    if not new_mode:
        sys.exit(1)

    if mode != new_mode:
        mode = new_mode
        kbd.toggle(not mode[:3].isdecimal())
        Popen(["./.workspace-changed"], cwd=getenv("HOME"))

    sleep(2)
