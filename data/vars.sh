#!/usr/bin/env bash

 # Since rlw script can be cloned anywhere we don't want to assume where the script is so I just copied and pasted the wineinitialize function.

 	# Evaluate the Wine path selection, and base the wineboot/wineserver
 	# paths off that.
 	source "$HOME/.rlw/wine_choice"
  BASEDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
 	if [[ "$WINE" == *"-development" ]]; then
 		# Debian uses different paths for their packaging of Wine 1.7 (namely, the binaries have a -development suffix)...
 		winebin_suffix="-development"
 	fi
 	winebootbin="$(dirname "$WINE")/wineboot${winebin_suffix}"
 	WINESERVER="$(dirname "$WINE")/wineserver${winebin_suffix}"
 	if [[ ! -x "$WINESERVER" && "$(lsb_release -is)" == "Debian" ]]; then
 		# Debian also sticks wineserver in /usr/lib, not /usr/bin or anywhere remote accessible via $PATH, ugh...
 		# I really don't like hardcoding the architecture here, but it's the best we can do for now.
 		WINESERVER="/usr/lib/i386-linux-gnu/wine${winebin_suffix}/wineserver"
 	fi
 	for x in "$WINE" "$winebootbin" "$WINESERVER"; do
 		if [[ -x "$x" ]]; then
 			printf "%b\n" "$(basename "$x") path set to $x"
 		else
 			spawndialog error "Could not find $(basename "$x") at $x. Are you sure a copy is installed there?"
 			winechooser
 			break
 		fi
 	done
 	export WINE
 	export WINESERVER
 	[[ "$($WINE --version | cut -f 1 -d ' ' | sed 's/.*?-//')" > "1.7.27" ]] || {
 		spawndialog error "Your copy of Wine is too old. Please install version 1.7.28 or greater.\n(expected 1.7.28, got $(wine --version | cut -f 1 -d ' ' | sed 's/.*-//'))"
 		exit 1
  }
  export WINEPREFIX="$HOME/.local/share/wineprefixes/roblox-wine"

# Functions (Yep, they are copied from rlw script)
spawndialog () {
	[[ -x "$(which zenity)" ]] || {
		printf '%b\n' "Missing dependency! Please install \"zenity\", then try again."
		exit 1
	}
	zenity \
		--no-wrap \
		--window-icon="$RBXICON" \
		--title="$rlwversionstring" \
		--"$1" \
		--text="$2" 2&> /dev/null
}

rwine () {
  printf '%b\n' "> rwine: calling wine with arguments \"$(printf "%s " "$@")\""
  if [[ "$1" = "--silent" ]]; then
  	$WINE "${@:2}" && rwineserver --wait
  else
  	$WINE "$@" && rwineserver --wait; [[ "$?" = "0" ]] || {
  		spawndialog error "wine closed unsuccessfully.\nSee terminal for details. (exit code $?)"
  		exit $?
  	}
  fi
}

rwineserver () {
  printf '%b\n' "> rwineserver: calling wineserver with arguments \"$(printf "%s " "$@")\""
  $WINESERVER "$@"; [[ "$?" = "0" ]] || {
  	spawndialog error "wineserver closed unsuccessfully.\nSee terminal for details. (exit code $?)"
  	exit $?
  }
}
