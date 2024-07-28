import evdev
from evdev import InputDevice, categorize, ecodes
import pyautogui

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
screen_width, screen_height = pyautogui.size()

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
        pyautogui.moveTo(screen_x, screen_y)

    # Track touch down and up events
    elif event.type == ecodes.EV_KEY and event.code == ecodes.BTN_TOUCH:
        if event.value == 1:  # Touch down
            pyautogui.mouseDown()
            touching = True
        elif event.value == 0:  # Touch up
            pyautogui.mouseUp()
            touching = False
