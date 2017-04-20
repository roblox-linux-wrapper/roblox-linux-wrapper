#!/usr/bin/env bash

# Change to the handler script's directory
cd "$(dirname "${BASH_SOURCE[0]}")"
if [ -f "rlw-core.sh" ]; then
	printf "Sourcing rlw-core.sh\n"
	source "rlw-core.sh"
else
	zenity \
		--no-wrap \
		--window-icon="$RBXICON" \
		--title="version-unknown" \
		--error \
		--text="Missing rlw-core: try reinstalling rlw using the main script. If this problem presists, please report an issue to our GitHub page.\n" 2&> /dev/null
    exit 1
fi

WINEDLLOVERRIDES="winhttp.dll=b,n;wininet.dll=n,b;msvcp110.dll,msvcr110.dll=n,b;d3d11.dll=" rwine "$WINEPREFIX/drive_c/Program Files/Roblox/Versions/RobloxStudioLauncherBeta.exe" "$1"
