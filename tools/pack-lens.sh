#!/usr/bin/env bash
# Packs the Snap Web Lens zip: Squnchies-lens.zip
#
# Snapchat unpacks the zip and serves index.html from its ROOT, so the zip must
# contain the files themselves, never a folder holding them. Building it from a
# staging directory and zipping "." from inside guarantees that, and `zip` on
# macOS/Linux writes forward-slash entries, which the ZIP spec requires.
# (Do NOT use PowerShell's Compress-Archive: it writes backslashes and every
# relative path breaks when Snapchat unpacks it.)
set -euo pipefail
cd "$(dirname "$0")/.."
OUT="Squnchies-lens.zip"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

cp index.html "$STAGE/"
cp -R vendor assets "$STAGE/"
find "$STAGE" -name '.DS_Store' -delete

rm -f "$OUT"
( cd "$STAGE" && zip -rqX "$OLDPWD/$OUT" . )

echo "built $OUT"
echo "  zip:        $(du -h "$OUT" | cut -f1)  (limit 8 MB)"
echo "  index.html: $(du -h index.html | cut -f1)  (limit 1 MB)"
