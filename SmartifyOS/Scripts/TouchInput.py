import evdev
import subprocess
from evdev import InputDevice, categorize, ecodes, list_devices
from pynput.mouse import Button, Controller
import yaml

with open('TouchConfig.yml', 'r') as file:
    config = yaml.safe_load(file)

def find_touchscreen():
    search_terms = config.get('search_terms', [])
    devices = [InputDevice(path) for path in list_devices()]
    for device in devices:
        if any(search_term in device.name.lower() for search_term in search_terms):
            return device
    raise Exception("No touchscreen device found")

event_file = config.get('event_file')
if event_file == 'auto':
    device = find_touchscreen() #InputDevice('/dev/input/event3')
else:
    device = InputDevice(event_file)


def find_xinput_touch_devices():
    xinput_search_terms = config.get('xinput_search_terms', [])
    xinput_list_result = subprocess.run(['xinput', 'list'], capture_output=True, text=True)
    xinput_list = xinput_list_result.stdout

    device_ids = []
    for line in xinput_list.splitlines():
        for term in xinput_search_terms:
            if term in line:
                parts = line.split()
                for part in parts:
                    if part.startswith("id="):
                        device_id = part.split('=')[1]
                        device_ids.append(device_id)

    return device_ids

xinput_device = config.get('xinput_device')
if xinput_device == 'auto':
    device_ids = find_xinput_touch_devices()
    for device_id in device_ids:
        subprocess.run(['xinput', 'disable', device_id])
else:
    subprocess.run(['xinput', 'disable', xinput_device])


mouse = Controller()

# Get screen resolution
xdpyinfo_output = subprocess.check_output(["xdpyinfo"]).decode("utf-8")
for line in xdpyinfo_output.split('\n'):
    if "dimensions" in line:
        screen_width, screen_height = map(int, line.strip().split()[1].split('x'))
        break

# Get touch device resolution
abs_info = device.capabilities(absinfo=True)[ecodes.EV_ABS]
touch_x_min = abs_info[0][1].min
touch_x_max = abs_info[0][1].max
touch_y_min = abs_info[1][1].min
touch_y_max = abs_info[1][1].max

# Variables to keep track of the touch state
touching = False
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

        #screen_x = screen_width - screen_x
        #screen_y = screen_height - screen_y

        # Move the mouse cursor to the touch point
        mouse.position = (screen_x, screen_y)

    # Track touch down and up events
    elif event.type == ecodes.EV_KEY and event.code == ecodes.BTN_TOUCH:
        if event.value == 1:  # Touch down
            mouse.press(Button.left)
            touching = True
        elif event.value == 0:  # Touch up
            mouse.release(Button.left)
            touching = False