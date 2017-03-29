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

WINEDLLOVERRIDES="winhttp.dll=b,n;wininet.dll=n,b;msvcp110.dll,msvcr110.dll=n,b;d3d11.dll=" rwine "$WINEPREFIX/drive_c/Program Files/Roblox/Versions/RobloxStudioLauncherBeta.exe" "$1"
