#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STAGE="$ROOT/build/knulli-package"
ZIPFILE="$ROOT/build/jemima-vs-the-fish-knulli.zip"

rm -rf "$STAGE"
mkdir -p "$STAGE/jemima_vs_the_fish/lovegame"
mkdir -p "$ROOT/build"

cp "$ROOT/main.lua" "$STAGE/jemima_vs_the_fish/lovegame/main.lua"
cp "$ROOT/conf.lua" "$STAGE/jemima_vs_the_fish/lovegame/conf.lua"
cp "$ROOT/portmaster/Jemima vs the Fish.sh" "$STAGE/Jemima vs the Fish.sh"

cat > "$STAGE/INSTALL.txt" <<'EOF'
JEMIMA VS THE FISH - KNULLI TEST PACKAGE

1. Make sure PortMaster is installed on KNULLI.
2. Make sure the PortMaster love_11.5 runtime is installed.
3. Extract this ZIP directly into:
      /userdata/roms/ports/

After extraction you should have:

/userdata/roms/ports/Jemima vs the Fish.sh
/userdata/roms/ports/jemima_vs_the_fish/lovegame/main.lua
/userdata/roms/ports/jemima_vs_the_fish/lovegame/conf.lua

4. Refresh the KNULLI game list / restart EmulationStation.
5. Launch "Jemima vs the Fish" from Ports.

If it fails to launch, inspect:
/userdata/roms/ports/jemima_vs_the_fish/log.txt
EOF

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

echo "Built: $ZIPFILE"
