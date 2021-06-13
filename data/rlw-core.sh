#!/usr/bin/env bash
# Common variables used by all rlw scripts
export WINEARCH=win32
export WINEPREFIX="$HOME/.local/share/wineprefixes/roblox-wine"
export PULSE_LATENCY_MSEC=60 # Workaround fix for crackling sound (variable used by wine)
RBXICON="roblox"

wineinitialize () {
	# Evaluate the Wine path selection, and base the wineserver
	# paths off that.
	printf "%b\n" "> wineinitialize: sourcing $HOME/.rlw/wine_choice"
	[[ -e "$HOME"/.rlw/wine_choice ]] && source "$HOME/.rlw/wine_choice" &&	printf "%b\n" "> wineinitialize: source complete" || printf "%b\n" "> wineinitialize: source failed"
	for x in "$WINE" "$WINESERVER"; do
		if [[ -x "$x" ]]; then
			printf "%b\n" "> wineinitialize: $(basename "$x") path set to $x"
		else
			if [[ ! -z "$x" ]]; then
				spawndialog error "Could not find $(basename "$x") at $x. Are you sure a copy is installed there?"
			fi
			winechooser
			break
		fi
	done
	export WINE
	export WINESERVER
	printf "%b\n" "> wineinitialize: Wine version $("$WINE" --version) is installed"
}

winechooser () {
	if command -v zenity >/dev/null 2>&1 ; then
	sel=$(zenity \
			--title "Wine Release Selection" \
			--width=480 \
			--height=300 \
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
			FALSE '/opt/cxoffice/bin/wine' \
			FALSE 'Browse for Wine binaries...')
	case $sel in
		'Browse for Wine binaries...')

			BIN=$(zenity --title "Please select the folder containing the wine binaries (usually named bin)" --file-selection --directory)
		
			WINE="$BIN"/wine
			WINESERVER="$BIN"/wineserver;;
		'Automatic detection (via $PATH)')
			# Here, we will literally save '$(which wine)' as the path
			# so it changes dynamically and isn't immediately evaluated.
			WINE="$(which wine)"
			WINESERVER="$(which wineserver)"
			for x in "$WINE" "$WINESERVER"; do
				if [[ ! -x "$x" ]]; then
					spawndialog error "Missing dependencies! Please install wine somewhere in \"$PATH\", or select a custom path instead.\nDetails: Could not find $(basename \"$x\") at \"$x\".\nAre you sure a copy is installed there?"
					exit 1
				fi
			done;;
		*)
			WINE="$sel"
	esac
	
	else
	 sel=$(kdialog --icon $RBXICON --title "Wine Release Selection" --menu "Select the version of Wine you want to use:" 1 "Automatic detection (via $PATH)" 2 "/usr/bin/wine"  3 "/opt/wine-staging/bin/wine"  4 "/usr/bin/wine-development" 5 "/opt/cxoffice/bin/wine" 6 "Browse for Wine binaries..." --default "Automatic detection (via $PATH)")
			case "$sel" in
				1)
					# Here, we will literally save '$(which wine)' as the path
					# so it changes dynamically and isn't immediately evaluated.
					WINE="$(which wine)"
					WINESERVER="$(which wineserver)"
					for x in "$WINE" "$WINESERVER"; do
						if [[ ! -x "$x" ]]; then
							spawndialog error "Missing dependencies! Please install wine somewhere in \"$PATH\", or select a custom path instead.\nDetails: Could not find $(basename \"$x\") at \"$x\".\nAre you sure a copy is installed there?"
					exit 1
					fi
					done;;
				2)
					BIN="/usr/bin/wine"
					;;
				3)
					BIN="/opt/wine-staging/bin/wine"
					;;
				4)
					BIN="/usr/bin/wine-development"
					;;
				5)
				    BIN="/opt/cxoffice/bin/win"
					;;
				6)
			     	BIN=$(kdialog  --icon $RBXICON --title "Please select the folder containing the wine binaries (usually named bin)" --getexistingdirectory *)
					;;
				*)
					winechooser;;
			esac;
		
	fi
	
	if [[ ! -x "$WINE" ]]; then
		printf "%b\n" "Clearing Wine choice..."
		rm -f "$HOME/.rlw/wine_choice"
		spawndialog error "You must enter a valid path."
		winechooser
	else
		printf "%b\n" "> winechooser: Wine path set to: $WINE"
		printf "%b\n" "> winechooser: Saving Wine choice to ~/.rlw/wine_choice"
		mkdir -p "$HOME/.rlw/"
		printf "%b\n" "WINE=\"$WINE\"" "WINESERVER=\"$WINESERVER\"" > "$HOME/.rlw/wine_choice"
	fi
	wineinitialize
}


spawndialog () {
	if command -v zenity >/dev/null 2>&1 ; then
		zenity \
			--no-wrap \
			--window-icon="$RBXICON" \
			--title="$rlwversionstring" \
			--"$1" \
			--text="$2" 2&> /dev/null
	else
		 kdialog  --"$1" "$2"  --icon $RBXICON --title "$rlwversionstring" 2&> /dev/null
	fi
}

rwine () {
	printf '%b\n' "> rwine: calling wine with arguments \"$(printf "%s " "$@")\""
	if [[ "$1" = "--silent" ]]; then
		"$WINE" "${@:2}" && rwineserver --silent
	else
		"$WINE" "$@" && rwineserver --wait; [[ "$?" = "0" ]] || {
			spawndialog error "wine closed unsuccessfully.\nSee terminal for details. (exit code $?)"
	}
	fi
}

rwineserver () {
	printf '%b\n' "> rwineserver: calling wineserver with arguments \"$(printf "%s " "$@")\""
	if [[ "$1" = "--wait" ]]; then
	if command -v zenity >/dev/null 2>&1 ; then
		"$WINESERVER" "$@" | $(zenity\
					--title="$rlwversionstring" \
					--window-icon="$RBXICON" \
					--width=480 \
					--progress \
					--auto-kill \
					--auto-close \
					--pulsate \
					--text="Waiting for wine to close...")
	else
 		"$WINESERVER" "$@" | $(kdialog --icon $RBXICON --title "$rlwversionstring" --passivepopup "Waiting for wine to close..." 10)
	fi	
		

		return "$?"
	else
		"$WINESERVER" "$@"
		return "$?"
	fi
}

wineinitialize
