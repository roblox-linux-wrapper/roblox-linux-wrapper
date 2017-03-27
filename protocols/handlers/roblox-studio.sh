#!/bin/bash
export WINEPREFIX="$HOME/.local/share/wineprefixes/roblox-wine"
export WINEDLLOVERRIDES="winhttp.dll=b,n;wininet.dll=n,b;msvcp110.dll,msvcr110.dll=n,b;d3d11.dll="

rwine () {
    /usr/bin/wine "$@" && /usr/bin/wineserver --wait
}

rwine "$WINEPREFIX/drive_c/Program Files/Roblox/Versions/RobloxStudioLauncherBeta.exe" "$1"
