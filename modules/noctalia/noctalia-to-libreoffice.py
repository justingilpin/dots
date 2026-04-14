#!/usr/bin/env python3
# noctalia-to-libreoffice.py
#
# Reads ~/.config/noctalia/colors.json and writes a LibreOffice color scheme
# to ~/.config/libreoffice/4/user/registrymodifications.xcu.
#
# LibreOffice reads this XML registry file for UI color overrides.
# The file is merged with LibreOffice's defaults — only the keys listed here
# are overridden, everything else stays as-is.
#
# Run automatically via Noctalia's colorGeneration hook.

import json
import os

COLORS_FILE = os.path.expanduser("~/.config/noctalia/colors.json")
LO_DIR      = os.path.expanduser("~/.config/libreoffice/4/user")
LO_FILE     = os.path.join(LO_DIR, "registrymodifications.xcu")

with open(COLORS_FILE) as f:
    c = json.load(f)

def hex_to_long(h):
    """Convert #rrggbb to a decimal integer LibreOffice uses in its registry."""
    return int(h.lstrip('#'), 16)

# Map Noctalia tokens to LibreOffice color roles
surface         = hex_to_long(c['mSurface'])         # main background
surface_variant = hex_to_long(c['mSurfaceVariant'])  # sidebars, inactive areas
on_surface      = hex_to_long(c['mOnSurface'])        # primary text
on_surface_var  = hex_to_long(c['mOnSurfaceVariant'])# secondary text
primary         = hex_to_long(c['mPrimary'])           # accent / selection
shadow          = hex_to_long(c['mShadow'])            # shadows

def entry(path, name, value):
    """Render a single registry key entry."""
    return f"""  <item oor:path="{path}">
    <prop oor:name="{name}" oor:op="fuse">
      <value>{value}</value>
    </prop>
  </item>"""

entries = "\n".join([
    # Application background (the grey area around documents)
    entry("/org.openoffice.Office.UI/ColorScheme/ColorSchemes/org.openoffice.Office.UI:ColorScheme['LibreOffice']",
          "DocColor", surface),
    # Base window background
    entry("/org.openoffice.Office.UI/ColorScheme/ColorSchemes/org.openoffice.Office.UI:ColorScheme['LibreOffice']",
          "AppBackColor", surface_variant),
    # Font color
    entry("/org.openoffice.Office.UI/ColorScheme/ColorSchemes/org.openoffice.Office.UI:ColorScheme['LibreOffice']",
          "FontColor", on_surface),
    # Spell-check / field shading
    entry("/org.openoffice.Office.UI/ColorScheme/ColorSchemes/org.openoffice.Office.UI:ColorScheme['LibreOffice']",
          "FieldShadingsColor", surface_variant),
    # Note: toolbar/menubar colors are controlled by the GTK theme (synced via
    # Noctalia's syncGsettings). Only document-area colors are set here.
])

xcu = f"""<?xml version="1.0" encoding="UTF-8"?>
<!-- Noctalia LibreOffice color scheme — auto-generated, do not edit.
     Re-generated on every Noctalia color scheme change via colorGeneration hook.
     Source: modules/noctalia/noctalia-to-libreoffice.py -->
<oor:items xmlns:oor="http://openoffice.org/2001/registry"
           xmlns:xs="http://www.w3.org/2001/XMLSchema"
           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
{entries}
</oor:items>
"""

os.makedirs(LO_DIR, exist_ok=True)
with open(LO_FILE, "w") as f:
    f.write(xcu)

print(f"Written: {LO_FILE}")
