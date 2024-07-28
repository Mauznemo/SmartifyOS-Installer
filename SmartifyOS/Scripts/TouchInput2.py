import evdev
from evdev import InputDevice, categorize, ecodes, list_devices
import os

#sudo apt install python3-evdev

def find_touchscreen():
    keywords = ["touchscreen", "some other", "yet another"]  # Add other relevant keywords here
    devices = [InputDevice(path) for path in list_devices()]
    for device in devices:
        if any(keyword in device.name.lower() for keyword in keywords):
            return device
    raise Exception("No touchscreen device found")

# Replace '/dev/input/eventX' with the actual event file for your touch screen.
device = find_touchscreen() #InputDevice('/dev/input/event3')

# Get screen resolution
xdpyinfo_output = subprocess.check_output(["xdpyinfo"]).decode("utf-8")
for line in xdpyinfo_output.split('\n'):
    if "dimensions" in line:
        SCREEN_WIDTH, SCREEN_HEIGHT = map(int, line.strip().split()[1].split('x'))
        break

# Get touch device resolution
abs_info = device.capabilities(absinfo=True)[ecodes.EV_ABS]
touch_x_min = abs_info[0][1].min
touch_x_max = abs_info[0][1].max
touch_y_min = abs_info[1][1].min
touch_y_max = abs_info[1][1].max

# Variables to keep track of the touch state
touching = False
pyautogui.PAUSE = 0
x, y = 0, 0

def move_mouse(x, y):
    subprocess.run(['xdotool', 'mousemove', str(x), str(y)])

for event in device.read_loop():
    if event.type == ecodes.EV_ABS:
        absevent = categorize(event)

        # Track X and Y coordinates
        if absevent.event.code == ecodes.ABS_MT_POSITION_X:
            x = absevent.event.value
        if absevent.event.code == ecodes.ABS_MT_POSITION_Y:
            y = absevent.event.value

        # Scale coordinates to screen resolution
        screen_x = (x - touch_x_min) * screen_width / (touch_x_max - touch_x_min)
        screen_y = (y - touch_y_min) * screen_height / (touch_y_max - touch_y_min)

        screen_x = screen_width - screen_x
        screen_y = screen_height - screen_y

        # Move the mouse cursor to the touch point
        move_mouse(screen_x, screen_y)

    # Track touch down and up events
    elif event.type == ecodes.EV_KEY and event.code == ecodes.BTN_TOUCH:
        if event.value == 1:  # Touch down
            subprocess.run(['xdotool', 'mousedown', '1'])
            touching = True
        elif event.value == 0:  # Touch up
            subprocess.run(['xdotool', 'mouseup', '1'])
            touching = False
