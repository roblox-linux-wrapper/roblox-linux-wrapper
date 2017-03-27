#!/bin/bash
export WINEPREFIX="$HOME/.local/share/wineprefixes/roblox-wine"
export WINEDLLOVERRIDES="winhttp.dll=b,n;wininet.dll=n,b;d3d11.dll="

rwine () {
    /usr/bin/wine "$@" && /usr/bin/wineserver --wait
}

DLL="$(find "$WINEPREFIX" -iname 'RobloxProxy.dll' -printf "%T+\t%p\n" | sort -nr | cut -f 2 | head -n 1)"
rwine regsvr32 /i "$DLL"

rwine "$(find "$HOME/.local/share/wineprefixes/roblox-wine" -name RobloxPlayerLauncher.exe)" "$1"
