#!/usr/bin/env bash
# Serves the game with Snapchat's chrome drawn over it, so the Lens layout can
# be checked without waiting for review.
#
# Models the WORST case measured on a real device (Galaxy S22 Ultra): Snapchat
# overlays its close button on the TOP-LEFT while reporting a top inset of
# ~0, and its lens carousel covers the bottom ~23% of the screen. A Fold 7
# letterboxes instead and reports a generous inset, so it is the easy case —
# if the layout survives this one it survives that one.
#
#   ./tools/snap-rehearse.sh        then open the URL on a phone, in portrait
set -euo pipefail
cd "$(dirname "$0")/.."
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
cp index.html "$STAGE/"; cp -R vendor assets "$STAGE/"
python3 - "$STAGE/index.html" <<'PY'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding="utf-8").read()
sim = '''<style id="snapchrome">
  html::before { content: "\\00d7"; position: fixed; z-index: 99999;
    left: 12px; top: 41px; width: 30px; height: 30px; border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    font: 700 22px system-ui; color: #fff; background: rgba(255,0,80,.55);
    outline: 2px dashed #ff4d8d; pointer-events: none; }
  html::after { content: "SNAPCHAT CAROUSEL"; position: fixed; z-index: 99999;
    left: 0; right: 0; bottom: 0; height: 23vh; display: flex;
    align-items: center; justify-content: center; letter-spacing: .12em;
    font: 600 11px system-ui; color: #fff;
    background: repeating-linear-gradient(45deg,#ff004f55 0 12px,#00000088 12px 24px);
    pointer-events: none; }
</style>
</head>'''
io.open(p, "w", encoding="utf-8").write(s.replace("</head>", sim, 1))
PY
IP=$(ipconfig getifaddr en0 2>/dev/null || echo localhost)
echo "rehearsing Snapchat chrome — open on your phone, in portrait:"
echo "    http://$IP:8801/index.html"
cd "$STAGE" && python3 -m http.server 8801 --bind 0.0.0.0
