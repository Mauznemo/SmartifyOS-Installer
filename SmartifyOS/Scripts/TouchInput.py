#!/usr/bin/env python3
import subprocess
import re
import syslog
import random

def get_touchscreen_id():
    xinput_output = subprocess.check_output(["xinput", "list"]).decode("utf-8")
    for line in xinput_output.split('\n'):
        if "touchscreen" in line.lower():
            match = re.search(r'id=(\d+)', line)
            if match:
                return match.group(1)
    raise Exception("Touchscreen device not found")

TOUCHSCREEN_ID = get_touchscreen_id()
MOUSE_BUTTON = 1  # Left mouse button

patternPress = r'a\[\d\]=(\d+)'
patternMotion = r'=\s*(\d+)'

# Function to simulate mouse click and drag
def simulate_mouse_action(action):
    if action == "press":
        subprocess.run(["xdotool", "mousedown", str(MOUSE_BUTTON)])
    elif action == "release":
        subprocess.run(["xdotool", "mouseup", str(MOUSE_BUTTON)])

def log_message(message):
    syslog.syslog(syslog.LOG_INFO, message)


# Get screen resolution
xdpyinfo_output = subprocess.check_output(["xdpyinfo"]).decode("utf-8")
for line in xdpyinfo_output.split('\n'):
    if "dimensions" in line:
        SCREEN_WIDTH, SCREEN_HEIGHT = map(int, line.strip().split()[1].split('x'))
        break

# Listen for touch events and simulate mouse actions
xinput_process = subprocess.Popen(["xinput", "test", TOUCHSCREEN_ID], stdout=subprocess.PIPE)
for line in iter(xinput_process.stdout.readline, b''):
    line = line.decode("utf-8").strip()
    if "button press" in line:

        matches = re.findall(patternPress, line)

        if len(matches) >= 2:
            X = int(matches[0])
            Y = int(matches[1])
            SCALED_X = X / 64500 * SCREEN_WIDTH
            SCALED_Y = Y / 64500 * SCREEN_HEIGHT
            subprocess.run(["xdotool", "mousemove", str(int(SCALED_X)), str(int(SCALED_Y))])
            simulate_mouse_action("press")
            log_message("press " + str(random.randint(0, 100)))
        else:
            print("Could not find two numbers after '='")

    elif "button release" in line:
        simulate_mouse_action("release")
        log_message("release " + str(random.randint(0, 100)))