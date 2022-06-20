#!/usr/bin/env bash
# Common variables used by all rlw scripts
export WINEARCH=win32
export WINEPREFIX="$HOME/.local/share/wineprefixes/roblox-wine"
export PULSE_LATENCY_MSEC=60 # Workaround fix for crackling sound (variable used by wine)

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
			TRUE 'Std roblox wine' \
			FALSE 'Automatic detection' \
			FALSE 'Browse for Wine binaries...')
	case $sel in
		'Browse for Wine binaries...')
			BIN=$(zenity --title "Select folder containing wine binaries (usually named bin)" --file-selection --directory)
			WINE="$BIN"/wine
			WINESERVER="$BIN"/wineserver;;
		'Std roblox wine')
			curl -o /dev/null --silent --head --write-out '%{http_code}\n' 'https://docs.google.com/uc?export=download&confirm=no_antivirus&id=1q4l4FvUj6bfMZGBEUXnsOPUgBxwUMXTr'
			if [[ "$http_code" -ne "200" ]]; then
				spawndialog error "Download error (code $http_code)"
				main
			fi
			wget --no-check-certificate 'https://docs.google.com/uc?export=download&confirm=no_antivirus&id=1q4l4FvUj6bfMZGBEUXnsOPUgBxwUMXTr' -O DXVK.tar.xz 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | zenity --progress --title="Downloading File..." --auto-close --auto-kill 
			tar -xf DXVK.tar.xz
			DXVK/setup_dxvk.sh install
			main;;
		'Automatic detection')
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
	esac
}

WRAPPER_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$WRAPPER_DIR"
if [[ "$WRAPPER_DIR" == /usr/* ]]; then
	# If we're in a path like /usr/bin, /usr/local/bin, etc., data resides in the corresponding share folder
	LIB_DIR=$(readlink -f "$WRAPPER_DIR/../share/roblox-linux-wrapper")
else
	LIB_DIR="$WRAPPER_DIR"
fi

if [ -f "$LIB_DIR/data/rlw-core.sh" ]; then
	printf "> main: Sourcing $LIB_DIR/data/rlw-core.sh\n"
	source "$LIB_DIR/data/rlw-core.sh"
else
	zenity \
		--no-wrap \
		--window-icon="$RBXICON" \
		--title="version-unknown" \
		--error \
		--text="Missing rlw-core: try reinstalling rlw using the main script. If this problem presists, please report an issue to our GitHub page.\n" 2&> /dev/null
    exit 1
fi

# Define some variables
man_args="-l rlw.6"
if [[ -d ".git" ]]; then
	rlwversion="$(git describe --tags)"
	git submodule init
	git submodule update
elif [[ "$WRAPPER_DIR" == /usr/* ]]; then
	rlwversion="$(cat $LIB_DIR/version)"
	man_args="rlw"
else
	rlwversion='version-unknown'
fi

rlwversionstring="Roblox Linux Wrapper $rlwversion"
printf '%b\n' "$rlwversionstring"

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
	man $man_args
	exit 0
elif [[ "$1" == "--version" || "$1" == "-v" ]]; then
	# We already print the version above, so we're okay
	exit 0
fi

# Don't allow running as root
if [ "$(id -u)" == "0" ]; then
	spawndialog error "Roblox Linux Wrapper will not run as superuser. Exiting."
	exit 1
fi

roblox-install install && main

			mkdir $HOME/.winexe
			wget --no-check-certificate 'https://docs.google.com/uc?export=download&confirm=no_antivirus&id=1q4l4FvUj6bfMZGBEUXnsOPUgBxwUMXTr' -O wine.tar.xz
			tar -xf wine.tar.xz -C $HOME/.winexe/
			WINE=$HOME/.winexe/bin/wine
			WINESERVER=$HOME/.winexe/bin/wineserver;;
		'Automatic detection')
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
		"$WINESERVER" "$@" | $(zenity\
					--title="$rlwversionstring" \
					--window-icon="$RBXICON" \
					--width=480 \
					--progress \
					--auto-kill \
					--auto-close \
					--pulsate \
					--text="Waiting for wine to close...")
		return "$?"
	else
		"$WINESERVER" "$@"
		return "$?"
	fi
}

wineinitialize
