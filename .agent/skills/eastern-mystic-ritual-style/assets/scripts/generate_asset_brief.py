#\!/usr/bin/env python3
"""Generate a compact art brief and prompt scaffold for the eastern mystic ritual UI style system."""

from __future__ import annotations

import argparse
from textwrap import dedent


ASSET_PRESETS = {
    "vertical-main-screen": {
        "purpose": "first playable ritual interaction screen",
        "canvas": "9:16, 1024x1792 or 1080x1920",
        "composition": "centered [device], Shanhai ink depth, lower third reserved for controls",
    },
    "ritual-device": {
        "purpose": "reusable central interactive apparatus",
        "canvas": "square or transparent isolated PNG",
        "composition": "front-facing jade/brass device with simple maskable silhouette",
    },
    "result-card": {
        "purpose": "post-interaction result card background and frame",
        "canvas": "vertical card or transparent frame",
        "composition": "jade panel, brass rim, empty title areas, restrained glow",
    },
    "ritual-button": {
        "purpose": "tappable control set",
        "canvas": "512x512 or atlas-friendly transparent PNG",
        "composition": "round jade button states with simple glyph icons",
    },
    "astrolabe-ui": {
        "purpose": "rotating rings, scan overlays, star dial components",
        "canvas": "square transparent PNG",
        "composition": "concentric rings, compass ticks, constellation nodes, talisman glyph circle",
    },
    "energy-effect": {
        "purpose": "elemental VFX source",
        "canvas": "transparent PNG or dark preview sheet",
        "composition": "disciplined spiritual glow, particles, ink or energy motion",
    },
    "ink-shanhai-background": {
        "purpose": "background plate",
        "canvas": "9:16 or wider parallax plate",
        "composition": "mist mountains, cloud sea, ritual terrace, open center and lower UI space",
    },
    "scan-overlay": {
        "purpose": "translucent scanning/reading overlay",
        "canvas": "transparent PNG",
        "composition": "ethereal translucent subject, internal structure lines, energy points",
    },
}


def build_prompt(asset_type: str, focus: str) -> str:
    preset = ASSET_PRESETS[asset_type]
    return dedent(
        f"""
        ART BRIEF
        Asset type: {asset_type}
        Purpose: {preset["purpose"]}
        Canvas: {preset["canvas"]}
        Composition: {preset["composition"]}
        Focus: {focus}

        GENERATION PROMPT
        {asset_type}, {preset["purpose"]}, eastern fantasy modern ritual mobile game UI asset,
        jade and aged brass material language, Shanhai ink atmosphere,
        luminous teal talisman glyphs, fine gold measurement lines, calm mysterious immortal mood,
        {preset["composition"]}, layered game asset, readable phone-scale shapes, no baked text

        NEGATIVE DIRECTION
        avoid ordinary questionnaire UI, avoid red gold webgame style, avoid generic tarot,
        avoid medical sci-fi scanner, avoid character poster composition, avoid tiny unreadable text,
        avoid cluttered lower touch zone, avoid neon cyberpunk, avoid explosive VFX
        """
    ).strip()


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate an eastern mystic ritual UI asset brief.")
    parser.add_argument("asset_type", choices=sorted(ASSET_PRESETS))
    parser.add_argument("--focus", default="production-ready visual direction")
    args = parser.parse_args()
    print(build_prompt(args.asset_type, args.focus))


if __name__ == "__main__":
    main()
