#!/usr/bin/env python3
# noctalia-to-obsidian.py
#
# Reads ~/.config/noctalia/colors.json and writes an Obsidian CSS snippet
# that maps Noctalia's color tokens to Obsidian CSS variables.
#
# Run automatically via Noctalia's colorGeneration hook.

import json
import os

COLORS_FILE = os.path.expanduser("~/.config/noctalia/colors.json")
SNIPPET_FILE = os.path.expanduser("~/.obsidian/.obsidian/snippets/noctalia.css")

with open(COLORS_FILE) as f:
    c = json.load(f)

css = f"""/* Noctalia dynamic color scheme — auto-generated, do not edit.
 * Re-generated on every Noctalia color scheme change via colorGeneration hook.
 */
.theme-dark, .theme-light {{
  --color-accent:           {c['mPrimary']};
  --color-accent-1:         {c['mSecondary']};
  --color-accent-2:         {c['mTertiary']};

  --background-primary:     {c['mSurface']};
  --background-primary-alt: {c['mSurfaceVariant']};
  --background-secondary:   {c['mSurfaceVariant']};
  --background-modifier-border: {c['mOutline']};
  --background-modifier-hover:  {c['mHover']};

  --text-normal:            {c['mOnSurface']};
  --text-muted:             {c['mOnSurfaceVariant']};
  --text-faint:             {c['mOutline']};
  --text-accent:            {c['mPrimary']};
  --text-accent-hover:      {c['mSecondary']};
  --text-on-accent:         {c['mOnPrimary']};
  --text-error:             {c['mError']};

  --interactive-accent:         {c['mPrimary']};
  --interactive-accent-hover:   {c['mSecondary']};

  --tag-color:              {c['mPrimary']};
  --tag-background:         {c['mSurfaceVariant']};
  --link-color:             {c['mSecondary']};
  --link-color-hover:       {c['mTertiary']};
  --link-external-color:    {c['mTertiary']};

  --color-base-00:  {c['mSurface']};
  --color-base-10:  {c['mSurfaceVariant']};
  --color-base-20:  {c['mSurfaceVariant']};
  --color-base-25:  {c['mSurfaceVariant']};
  --color-base-30:  {c['mOutline']};
  --color-base-35:  {c['mOutline']};
  --color-base-40:  {c['mOutline']};
  --color-base-50:  {c['mOnSurfaceVariant']};
  --color-base-60:  {c['mOnSurfaceVariant']};
  --color-base-70:  {c['mOnSurface']};
  --color-base-100: {c['mOnSurface']};
}}
"""

os.makedirs(os.path.dirname(SNIPPET_FILE), exist_ok=True)
with open(SNIPPET_FILE, "w") as f:
    f.write(css)

print(f"Written: {SNIPPET_FILE}")
