#!/usr/bin/env python3
# noctalia-to-kdeglobals.py
#
# Reads ~/.config/noctalia/colors.json and writes ~/.config/kdeglobals,
# which is the KDE color scheme file that Dolphin and other Qt/KDE apps read.
#
# Run automatically via Noctalia's colorGeneration hook (and once at startup),
# so Dolphin's colors update whenever you switch palettes in Noctalia.
#
# Requires QT_QPA_PLATFORMTHEME=kde (set via environment.sessionVariables in Nix)
# and plasma-integration installed so Qt apps know to read kdeglobals.

import json
import os

COLORS_FILE    = os.path.expanduser("~/.config/noctalia/colors.json")
KDEGLOBALS_FILE = os.path.expanduser("~/.config/kdeglobals")

def hex_to_rgb(h):
    """Convert #rrggbb to the R,G,B format kdeglobals expects."""
    h = h.lstrip('#')
    return ','.join(str(int(h[i:i+2], 16)) for i in (0, 2, 4))

with open(COLORS_FILE) as f:
    c = json.load(f)

# Map Noctalia semantic tokens → kdeglobals color roles.
# Each group (View, Window, Button, etc.) controls a different part of the UI.
bg      = hex_to_rgb(c['mSurface'])          # main window/panel background
bg_alt  = hex_to_rgb(c['mSurfaceVariant'])   # alternate rows, button faces
fg      = hex_to_rgb(c['mOnSurface'])         # primary text
fg_in   = hex_to_rgb(c['mOnSurfaceVariant']) # inactive/dimmed text
accent  = hex_to_rgb(c['mPrimary'])           # selection highlight, focus rings
on_acc  = hex_to_rgb(c['mOnPrimary'])         # text drawn on top of the accent color
link    = hex_to_rgb(c['mSecondary'])          # hyperlinks
visited = hex_to_rgb(c['mTertiary'])           # visited links / hover accent
error   = hex_to_rgb(c['mError'])             # error text
hover   = hex_to_rgb(c['mHover'])             # hover decoration

kdeglobals = f"""# Noctalia KDE color scheme — auto-generated, do not edit.
# Re-generated on every Noctalia color scheme change via the colorGeneration hook.
# Source: modules/noctalia/noctalia-to-kdeglobals.py

[ColorEffects:Disabled]
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

# Button — toolbar buttons, dialog buttons
[Colors:Button]
BackgroundAlternate={bg_alt}
BackgroundNormal={bg_alt}
DecorationFocus={accent}
DecorationHover={hover}
ForegroundActive={accent}
ForegroundInactive={fg_in}
ForegroundLink={link}
ForegroundNegative={error}
ForegroundNormal={fg}
ForegroundPositive={accent}
ForegroundVisited={visited}

# Header — toolbar/menubar background (Dolphin's top bar)
[Colors:Header]
BackgroundAlternate={bg_alt}
BackgroundNormal={bg}
DecorationFocus={accent}
DecorationHover={hover}
ForegroundActive={accent}
ForegroundInactive={fg_in}
ForegroundLink={link}
ForegroundNegative={error}
ForegroundNormal={fg}
ForegroundPositive={accent}
ForegroundVisited={visited}

# Selection — highlighted/selected items (selected files in Dolphin)
[Colors:Selection]
BackgroundAlternate={accent}
BackgroundNormal={accent}
DecorationFocus={accent}
DecorationHover={hover}
ForegroundActive={on_acc}
ForegroundInactive={on_acc}
ForegroundLink={on_acc}
ForegroundNegative={error}
ForegroundNormal={on_acc}
ForegroundPositive={on_acc}
ForegroundVisited={on_acc}

# Tooltip — hover tooltips
[Colors:Tooltip]
BackgroundAlternate={bg_alt}
BackgroundNormal={bg_alt}
DecorationFocus={accent}
DecorationHover={hover}
ForegroundActive={accent}
ForegroundInactive={fg_in}
ForegroundLink={link}
ForegroundNegative={error}
ForegroundNormal={fg}
ForegroundPositive={accent}
ForegroundVisited={visited}

# View — the file/folder list area (Dolphin's main content pane)
[Colors:View]
BackgroundAlternate={bg_alt}
BackgroundNormal={bg}
DecorationFocus={accent}
DecorationHover={hover}
ForegroundActive={accent}
ForegroundInactive={fg_in}
ForegroundLink={link}
ForegroundNegative={error}
ForegroundNormal={fg}
ForegroundPositive={accent}
ForegroundVisited={visited}

# Window — outer window chrome, sidebar, status bar
[Colors:Window]
BackgroundAlternate={bg_alt}
BackgroundNormal={bg}
DecorationFocus={accent}
DecorationHover={hover}
ForegroundActive={accent}
ForegroundInactive={fg_in}
ForegroundLink={link}
ForegroundNegative={error}
ForegroundNormal={fg}
ForegroundPositive={accent}
ForegroundVisited={visited}

[General]
ColorScheme=Noctalia
Name=Noctalia
shadeSortColumn=true

[KDE]
contrast=4

# WM — window title bar colors (used by some compositors)
[WM]
activeBackground={bg_alt}
activeBlend={accent}
activeForeground={fg}
inactiveBackground={bg}
inactiveBlend={bg_alt}
inactiveForeground={fg_in}
"""

with open(KDEGLOBALS_FILE, "w") as f:
    f.write(kdeglobals)

print(f"Written: {KDEGLOBALS_FILE}")
