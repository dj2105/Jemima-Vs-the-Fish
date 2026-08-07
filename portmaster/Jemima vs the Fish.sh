#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

if [ ! -f "$controlfolder/control.txt" ]; then
  echo "PortMaster control.txt not found at: $controlfolder"
  exit 1
fi

source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR=/$directory/ports/jemima_vs_the_fish
CONFDIR="$GAMEDIR/conf/"

mkdir -p "$CONFDIR"
cd "$GAMEDIR" || exit 1

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

LOVE_RUNTIME="$controlfolder/runtimes/love_11.5/love.txt"
if [ ! -f "$LOVE_RUNTIME" ]; then
  echo "Love2D 11.5 PortMaster runtime is not installed."
  echo "Install the love_11.5 runtime (or Full PortMaster) and try again."
  exit 1
fi

source "$LOVE_RUNTIME"

$GPTOKEYB "$LOVE_GPTK" &
pm_platform_helper "$LOVE_BINARY"
$LOVE_RUN "$GAMEDIR/lovegame"

pm_finish
