#!/bin/bash

BASEDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
if [ -f "$BASEDIR/vars.sh" ]; then
  printf "Sourcing vars.sh ..."
  source "$BASEDIR/vars.sh"
else
  zenity \
		--no-wrap \
		--window-icon="$RBXICON" \
		--title="version-unknown" \
		--error \
		--text="Critical error when launching the game, please reinstall Roblox using rlw, if the problem presists after that please report the issue on github page\n" 2&> /dev/null
    exit 1
fi

DLL="$(find "$WINEPREFIX" -iname 'RobloxProxy.dll' -printf "%T+\t%p\n" | sort -nr | cut -f 2 | head -n 1)"
rwine regsvr32 /i "$DLL"

WINEDLLOVERRIDES="winhttp.dll=b,n;wininet.dll=n,b;d3d11.dll=" rwine "$(find "$HOME/.local/share/wineprefixes/roblox-wine" -name RobloxPlayerLauncher.exe)" "$1"
