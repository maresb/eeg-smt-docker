import argparse
import socket
from datetime import datetime
from pathlib import Path
from time import sleep

import cv2
import numpy as np

DEFAULT_HOST = "127.0.0.1"
DEFAULT_PORT = 8336

thickness = 2
isClosed = False

bg_color = (255, 255, 255)
line_color = [(128, 0, 0), (0, 0, 128)]

parser = argparse.ArgumentParser(description="Plot the output of the EEG-SMT.")
parser.add_argument(
    "-s",
    "--save-to",
    dest="images_dir",
    type=Path,
    help="if given, then save the output to the specified directory",
)
parser.add_argument(
    "-H",
    "--host",
    type=str,
    dest="host",
    default=DEFAULT_HOST,
    help="host of the NSD server",
)
parser.add_argument(
    "-p", "--port", type=int, default=DEFAULT_PORT, help="port of the NSD server"
)
args = parser.parse_args()
images_dir = args.images_dir
if images_dir is not None:
    images_dir.mkdir(exist_ok=True)

image_width, image_height = 2048, 1024
image = np.full((2 * image_height, image_width, 3), bg_color, dtype=np.uint8)
print("Opening window...")
cv2.imshow("image", image)
print("Window opened.", flush=True)

# Wait to make sure modeegdriver is fully initialized
sleep(0.5)

print(f"Connecting to {args.host}:{args.port}...")
with socket.create_connection((args.host, args.port)) as sock:
    print("Connected.")
    sock.sendall(b"display\n" + b"watch 0\n")
    scanx = 0
    oldvals = [0, 0]
    quit_ = False
    while not quit_:
        print(f"{scanx=}")
        last_cnt = None
        data = sock.recv(1024)
        for line in data.splitlines():
            if quit_:
                break
            if line.startswith(b"! "):
                try:
                    dev_raw, cnt_raw, num_channels_raw, *vals_raw = line[2:].split(b" ")
                    dev, cnt, num_channels = (
                        int(dev_raw),
                        int(cnt_raw),
                        int(num_channels_raw),
                    )
                except ValueError:
                    print(f"Error parsing line:\n{line}\n")
                    continue
                try:
                    vals = [int(v) for v in vals_raw]
                except ValueError:
                    print(f"Error parsing values:\n{vals_raw}\n")
                    continue
                if last_cnt is not None:
                    if (last_cnt + 1) % 256 != cnt:
                        print(f"{last_cnt} -> {cnt}")
                last_cnt = cnt
                if not (len(vals) == num_channels == 2):
                    print(f"{len(vals)=} {num_channels=}")
                    continue
                for channel in range(num_channels):
                    # print(channel, vals[channel])
                    cv2.line(
                        image,
                        (scanx, oldvals[channel] + image_height * channel),
                        (scanx + thickness, vals[channel] + image_height * channel),
                        line_color[channel],
                        thickness,
                    )

                if image_width - scanx <= thickness and images_dir is not None:
                    filename = images_dir / (
                        datetime.today().strftime("%Y-%m-%d_%H-%M-%S") + ".png"
                    )
                    cv2.imwrite(str(filename), image)

                scanx = (scanx + thickness) % image_width
                clearx = (scanx + 3 * thickness) % image_width
                oldvals = vals
                cv2.line(
                    image,
                    (clearx, 0),
                    (clearx, image_height * num_channels),
                    bg_color,
                    thickness,
                )
                cv2.imshow("image", image)

        key = cv2.waitKey(2)
        if ord("q") == key:
            quit_ = True
        if cv2.getWindowProperty("image", cv2.WND_PROP_VISIBLE) < 1:
            quit_ = True

cv2.destroyAllWindows()
