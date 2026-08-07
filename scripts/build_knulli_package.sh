#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STAGE="$ROOT/build/portmaster-package"
ZIPFILE="$ROOT/build/jemima_vs_the_fish.zip"

rm -rf "$STAGE"
mkdir -p "$STAGE/jemima_vs_the_fish/lovegame"
mkdir -p "$ROOT/build"

cp "$ROOT/main.lua" "$STAGE/jemima_vs_the_fish/lovegame/main.lua"
cp "$ROOT/conf.lua" "$STAGE/jemima_vs_the_fish/lovegame/conf.lua"
cp "$ROOT/portmaster/port.json" "$STAGE/jemima_vs_the_fish/port.json"
cp "$ROOT/portmaster/gameinfo.xml" "$STAGE/jemima_vs_the_fish/gameinfo.xml"
cp "$ROOT/portmaster/Jemima vs the Fish.sh" "$STAGE/Jemima vs the Fish.sh"

python3 - "$STAGE" "$ZIPFILE" <<'PY'
import os
import sys
import zipfile

stage, outfile = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(outfile, "w", zipfile.ZIP_DEFLATED) as zf:
    for root, _, files in os.walk(stage):
        for name in files:
            path = os.path.join(root, name)
            arcname = os.path.relpath(path, stage)
            zf.write(path, arcname)
print(outfile)
PY

echo
printf 'Built PortMaster autoinstall package:\n  %s\n' "$ZIPFILE"
printf '\nFor KNULLI copy the ZIP, without extracting it, to:\n  /userdata/system/.local/share/PortMaster/autoinstall/\n'
printf '\nThen launch PortMaster. It should detect and install the ZIP automatically.\n'
