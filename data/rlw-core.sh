#!/usr/bin/env bash
# Common variables used by all rlw scripts
export WINEARCH=win32
export WINEPREFIX="$HOME/.local/share/wineprefixes/roblox-wine"
export PULSE_LATENCY_MSEC=60 # Workaround fix for crackling sound (variable used by wine)

wineinitialize () {
	# Evaluate the Wine path selection, and base the wineboot/wineserver
	# paths off that.
	source "$HOME/.rlw/wine_choice"
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
}

winechooser () {
	sel=$(zenity \
			--title "Wine Release Selection" \
			--width=480 \
			--height=250 \
			--cancel-label='Exit' \
			--list \
			--text 'Select the version of Wine you want to use:' \
			--radiolist \
			--column '' \
			--column 'Options' \
			TRUE 'Automatic detection (via $PATH)' \
			FALSE '/usr/bin/wine' \
			FALSE '/opt/wine-staging/bin/wine' \
			FALSE '/usr/bin/wine-development' \
			FALSE 'Enter custom Wine path...')
	case $sel in
		'Enter custom Wine path...')
			WINE=$(zenity --title "Wine Release Selection" \
					  --text "Enter custom Wine path:" --entry);;
		'Automatic detection (via $PATH)')
			# Here, we will literally save '$(which wine)' as the path
			# so it changes dynamically and isn't immediately evaluated.
			WINE='$(which wine)'
			real_wine="$(eval "echo $WINE")"
			winebootbin="$(dirname "$real_wine")/wineboot"
			WINESERVER="$(dirname "$real_wine")/wineserver"
			for x in "$real_wine" "$winebootbin" "$WINESERVER"; do
				if [[ ! -x "$x" ]]; then
					spawndialog error "Missing dependencies! Please install wine somewhere in "'$PATH'", or select a custom path instead.\nDetails: Could not find $(basename "$x") at $x. Are you sure a copy is installed there?"
					exit 1
				fi
			done;;
		*)
			WINE="$sel"
	esac
	printf "%b\n" "Wine path set to: $WINE"
	if [[ -z "$WINE" ]]; then
		printf "%b\n" "Clearing Wine choice..."
		rm -f "$HOME/.rlw/wine_choice"
		spawndialog error "You must enter a valid path."
		winechooser
	else
		printf "%b\n" "Saving Wine choice to ~/.rlw/wine_choice"
		mkdir -p "$HOME/.rlw/"
		echo "WINE=$WINE" > "$HOME/.rlw/wine_choice"
	fi
	wineinitialize
}

spawndialog () {
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
rwineboot () {
	printf '%b\n' " > Calling wineboot..."
	$winebootbin; [[ "$?" = "0" ]] || {
		spawndialog error "wineboot closed unsuccessfully.\nSee terminal for details. (exit code $?)"
		exit $?
	}
}

rwineserver () {
	printf '%b\n' "> rwineserver: calling wineserver with arguments \"$(printf "%s " "$@")\""
	$WINESERVER "$@"; [[ "$?" = "0" ]] || {
		spawndialog error "wineserver closed unsuccessfully.\nSee terminal for details. (exit code $?)"
		exit $?
	}
}

wineinitialize
