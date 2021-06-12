#!/usr/bin/env bash

# Change to the handler script's directory
cd "$(dirname "${BASH_SOURCE[0]}")"
if [ -f "rlw-core.sh" ]; then
	printf "Sourcing rlw-core.sh\n"
	source "rlw-core.sh"
else
	if command -v zenity >/dev/null 2>&1 ; then
		zenity \
			--no-wrap \
			--window-icon="$RBXICON" \
			--title="Roblox Linux Wrapper" \
			--error \
			--text="Missing rlw-core: try reinstalling rlw using the main script. If this problem presists, please report an issue to our GitHub page.\n" 2&> /dev/null	
	else
		 kdialog  --error "Missing rlw-core: try reinstalling rlw using the main script. If this problem presists, please report an issue to our GitHub page.\n"  --title "Roblox Linux Wrapper" 2&> /dev/null
	fi
	exit 1
fi

rwine "$(find "$HOME/.local/share/wineprefixes/roblox-wine" -name RobloxPlayerLauncher.exe)" "$1"
