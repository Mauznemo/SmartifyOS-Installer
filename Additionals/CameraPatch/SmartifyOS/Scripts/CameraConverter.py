#!/usr/bin/env python3
import os
import subprocess
import time

input_path = "/dev/video0"
output_path = "/dev/video2"

def start_ffmpeg():
    # Command to start ffmpeg
    command = [
        "ffmpeg", "-f", "v4l2", "-i", input_path, "-pix_fmt",
        "yuyv422", "-f", "v4l2", output_path
    ]
    # Start ffmpeg process
    return subprocess.Popen(command)

def watch_file(file_path, ffmpeg_process):
    last_modified = os.path.getmtime(file_path)
    converting = True
    
    while True:
        current_modified = os.path.getmtime(file_path)
        if current_modified > last_modified:
            last_modified = current_modified
            with open(file_path, 'r') as file:
                signal = file.read().strip()
                if signal == "true" and not converting:
                    print("Starting converting")
                    ffmpeg_process = start_ffmpeg()
                    converting = True
                elif signal == "false" and converting:
                    print("Stopping converting")
                    ffmpeg_process.terminate()
                    converting = False
        time.sleep(1)

if __name__ == "__main__":
    file_path = "~/SmartifyOS/Events/SetReverseCam"
    ffmpeg_process = None
    try:
        ffmpeg_process = start_ffmpeg()
        watch_file(file_path, ffmpeg_process)
    except KeyboardInterrupt:
        if ffmpeg_process:
            ffmpeg_process.terminate()