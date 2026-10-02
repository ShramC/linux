#!/usr/bin/env python3
import os
import sys
import time
import json
import math
import subprocess

PAPIRUS_COLORS = {
    "red": (211, 47, 47),
    "carmine": (165, 42, 42),
    "pink": (233, 30, 99),
    "magenta": (156, 39, 176),
    "violet": (123, 31, 162),
    "indigo": (63, 81, 181),
    "blue": (33, 150, 243),
    "nordic": (94, 129, 172),
    "cyan": (0, 188, 212),
    "darkcyan": (0, 150, 136),
    "teal": (0, 121, 107),
    "green": (76, 175, 80),
    "yellow": (255, 235, 59),
    "orange": (255, 152, 0),
    "deeporange": (255, 87, 34),
    "paleorange": (245, 166, 120),
    "brown": (121, 85, 72),
    "palebrown": (160, 120, 100),
    "grey": (158, 158, 158),
    "black": (33, 33, 33),
}

def hex_to_rgb(hex_str):
    hex_str = str(hex_str).lstrip('#')
    if len(hex_str) == 6:
        try:
            return tuple(int(hex_str[i:i+2], 16) for i in (0, 2, 4))
        except ValueError:
            pass
    return (128, 128, 128)

def color_distance(c1, c2):
    r1, g1, b1 = c1
    r2, g2, b2 = c2
    return math.sqrt((r1 - r2)**2 + (g1 - g2)**2 + (b1 - b2)**2)

def get_accent_hex():
    matugen_file = os.path.expanduser("~/.local/state/serpantinum/qs_matugen_colors.json")
    if os.path.exists(matugen_file):
        try:
            with open(matugen_file, "r") as f:
                data = json.load(f)
                colors = data.get("colors", data)
                for key in ["primary", "blue", "mauve", "peach", "red", "teal"]:
                    if key in colors and colors[key]:
                        return colors[key]
        except Exception:
            pass

    kitty_colors = os.path.expanduser("~/.config/kitty/colors.conf")
    if os.path.exists(kitty_colors):
        try:
            with open(kitty_colors, "r") as f:
                for line in f:
                    if line.strip().startswith("active_tab_background") or line.strip().startswith("selection_background"):
                        parts = line.strip().split()
                        if len(parts) >= 2 and parts[1].startswith("#"):
                            return parts[1]
        except Exception:
            pass

    return "#71361b"

last_applied_color = None

def update_folder_colors():
    global last_applied_color
    hex_color = get_accent_hex()
    rgb = hex_to_rgb(hex_color)
    target_color = min(PAPIRUS_COLORS.keys(), key=lambda c: color_distance(rgb, PAPIRUS_COLORS[c]))

    if target_color == last_applied_color:
        return

    script_path = os.path.expanduser("~/.local/bin/papirus-folders")
    if not os.path.exists(script_path):
        return

    for theme in ["Papirus-Dark", "Papirus"]:
        subprocess.run([script_path, "-C", target_color, "-t", theme, "-u"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    
    last_applied_color = target_color

def watch_loop():
    watch_files = [
        os.path.expanduser("~/.local/state/serpantinum/qs_matugen_colors.json"),
        os.path.expanduser("~/.local/state/serpantinum/qs_colors.json"),
        os.path.expanduser("~/.config/kitty/colors.conf")
    ]
    mtimes = {}
    
    update_folder_colors()
    
    while True:
        time.sleep(2)
        changed = False
        for fpath in watch_files:
            if os.path.exists(fpath):
                current_mtime = os.path.getmtime(fpath)
                if mtimes.get(fpath) != current_mtime:
                    mtimes[fpath] = current_mtime
                    changed = True
        if changed:
            update_folder_colors()

def main():
    if "--watch" in sys.argv:
        watch_loop()
    elif len(sys.argv) > 1 and not sys.argv[1].startswith("-"):
        target_color = sys.argv[1]
        script_path = os.path.expanduser("~/.local/bin/papirus-folders")
        if os.path.exists(script_path):
            for theme in ["Papirus-Dark", "Papirus"]:
                subprocess.run([script_path, "-C", target_color, "-t", theme, "-u"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    else:
        update_folder_colors()

if __name__ == "__main__":
    main()
