#!/usr/bin/env bash
#
#    Copyright 2015 Jonathan Alfonso <alfonsojon1997@gmail.com>
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

spawndialog () {
	[[ -x "$(which zenity)" ]] || {
		printf '%b\n' "Missing dependency! Please install \"zenity\", then try again."
		exit 1
	}
	zenity \
		--no-wrap \
		--window-icon="$RBXICON" \
		--title='Roblox Linux Wrapper v'"$rlwversion"'-'"$branch" \
		--"$1" \
		--text="$2"
}

rwine () {
	printf '%b\n' " > begin rwine ()\n---"
	if [[ "$1" = "--silent" ]]; then
		$winebin "${@:2}" && rwineserver --wait
	else
		$winebin "$@" && rwineserver --wait; [[ "$?" = "0" ]] || {
			spawndialog error "wine closed unsuccessfully.\nSee terminal for details. (exit code $?)"
			exit $?
	}
	fi
	printf '%b\n' " > end rwine ()\n---"
}
rwineboot () {
	printf '%b\n' " > begin rwineboot ()\n---"
	$winebootbin; [[ "$?" = "0" ]] || {
		spawndialog error "wineboot closed unsuccessfully.\nSee terminal for details. (exit code $?)"
		exit $?
	}
	printf '%b\n' " > end rwineboot ()\n---"
}
rwineserver () {
	printf '%b\n' " > begin rwineserver ()\n---"
	$wineserverbin "$@"; [[ "$?" = "0" ]] || {
		spawndialog error "wineserver closed unsuccessfully.\nSee terminal for details. (exit code $?)"
		exit $?
	}
	printf '%b\n' " > end rwineserver ()\n---"
}
rwget () {
	printf '%b\n' " > begin rwget ()\n---"
	[[ -x "$(which wget)" ]] || {
		spawndialog error "Missing dependency! Please install wget, then try again."
	}
	wget "$@" 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | \
		zenity \
			--progress \
			--window-icon="$RBXICON" \
			--title='Downloading' \
			--auto-close \
			--no-cancel \
			--width=450 \
			--height=120
	[[ "$?" = "0" ]] || {
		spawndialog error "wget download failed. \nSee terminal for details. (exit code $?)"
		exit $?
	}
	printf '%b\n' " > end rwget ()\n---"
}
rwinetricks () {
	printf '%b\n' " > begin rwinetricks ()\n---"
	winetricksbin="$(which winetricks)"
	[[ -x "$(which winetricks)" ]] || {
		rwget "http://winetricks.org/winetricks" -O "$HOME/.rlw/winetricks"
		chmod +x "$HOME/.rlw/winetricks"
		winetricksbin="$HOME/.rlw/winetricks"
	}
	$winetricksbin "$@"
	[[ "$?" = "0" ]] || {
		spawndialog error "winetricks failed. \nSee terminal for details. (exit code $?"
		exit $?
	}
	printf '%b\n' " > end rwinetricks ()\n---"
}

roblox-install () {
	printf '%b\n' " > begin roblox-install ()\n---"
	if [[ ! -d "$WINEPREFIX/drive_c" ]]; then
		spawndialog question 'A working Roblox wineprefix was not found.\nWould you like to install one?'
		if [[ $? = "0" ]]; then
			rm -rf "$WINEPREFIX"
			# Make sure our directories really exist
			[[ -d "$HOME/.rlw" ]] || {
				mkdir -p "$HOME/.rlw"
			}
			rwineboot
			rwinetricks ddr=gdi		# Causes graphical problems in mutter/gala (GNOME Shell/Elementary OS)
			[[ "$?" = 0 ]] || {
				spawndialog error "Wine prefix not generated successfully.\nSee terminal for more details. (exit code $?)"
				exit $?
			}
			wget -r --no-parent -Aexe http://download.cdn.mozilla.net/pub/mozilla.org/firefox/releases/latest-esr/win32/en-US/ -nd -P /tmp/Firefox-Setup/
			WINEDLLOVERRIDES="winebrowser.exe,winemenubuilder.exe=" rwine /tmp/Firefox-Setup/*.exe /SD | zenity \
				--window-icon="$RBXICON" \
				--title='Installing Mozilla Firefox' \
				--text='Installing Mozilla Firefox Browser ...' \
				--progress \
				--pulsate \
				--no-cancel \
				--auto-close
			rwget http://roblox.com/install/setup.ashx -O /tmp/RobloxPlayerLauncher.exe
			WINEDLLOVERRIDES="winebrowser.exe,winemenubuilder.exe=" rwine /tmp/RobloxPlayerLauncher.exe
			rwine regsvr32 /i "$(find "$WINEPREFIX" -iname 'RobloxProxy.dll')"
		else
			exit 1
		fi
	fi
	printf '%b\n' " > end roblox-install ()\n---"
}

wrapper-install () {
	[[ -d "$HOME/.rlw/.git" ]] && {
		cd "$HOME/.rlw"
		git checkout "$branch"
		git pull
	}
	printf '%b\n' "> begin wrapper-install ()\n---"
	[[ -d "$HOME/.rlw" ]] || [[ -f "$HOME/.rlw/roblox.desktop" ]] || {
		spawndialog question 'Roblox Linux Wrapper is not installed. This is necessary to launch games properly.\nWould you like to install it?'
		if [[ "$?" = 0 ]]; then
			# If we're in the rlw source repository, install that copy!
			if [[ -x "$HOME/.rlw/rlw.sh" && -f "$HOME/.rlw/roblox.desktop" && -f "$HOME/.rlw/roblox.png" && -d "$HOME/.rlw/.git" ]]; then
				cp -R $SOURCE_DIR "$HOME/.rlw"
			else
				git clone "https://github.com/alfonsojon/roblox-linux-wrapper.git" "$HOME/.rlw"
			fi
			cd "$HOME/.rlw"
			git checkout "$branch"
			chmod +x "$HOME/.rlw/rlw.sh"
			xdg-desktop-menu install --novendor "$HOME/.rlw/roblox.desktop"
			xdg-desktop-menu forceupdate
			[[ -x "$HOME/.rlw/rlw.sh" && -f "$HOME/.rlw/roblox.desktop" && -f "$HOME/.rlw/roblox.png" && -d "$HOME/.rlw/.git" ]] || {
				spawndialog error 'Roblox Linux Wrapper did not install successfully.'
				exit 1
			}
		else
			exit 1
		fi
	}
}

playerwrapper () {
	printf '%b\n' " > begin playerwrapper ()\n---"
	rwine regsvr32 /i "$(find "$WINEPREFIX" -iname 'RobloxProxy.dll')"
	if [[ "$1" = legacy ]]; then
		export GAMEURL=$(\
			zenity \
				--title='Roblox Linux Wrapper v'"$rlwversion"'-'"$branch" \
				--window-icon="$RBXICON" \
				--entry \
				--text='Paste the URL for the game here.' \
				--ok-label='Play' \
				--width=450 \
				--height=122)
			GAMEID=$(printf '%s' "$GAMEURL" | cut -d "=" -f 2)
		if [[ -n "$GAMEID" ]]; then
			rwine "$(find "$WINEPREFIX" -name RobloxPlayerBeta.exe)" --id "$GAMEID"
		else
			spawndialog warning "Invalid game URL or ID."
			return
		fi
	else
		rwine "$WINEPREFIX/drive_c/Program Files/Mozilla Firefox/firefox.exe" "http://www.roblox.com/Games.aspx"
	fi
	printf '%b\n' " > end playerwrapper ()\n---"
}

main () {
	printf '%b\n' " > begin main ()\n---"
	cd "$HOME"
	rm -rf "$HOME/Desktop/ROBLOX*desktop $HOME/Desktop/ROBLOX*.lnk"
	rm -rf "$HOME/.local/share/applications/wine/Programs/Roblox"
	rm -rf "$HOME/.local/share/wineprefixes/roblox*" "$HOME/.local/share/wineprefixes/Roblox*"
	sel=$(zenity \
		--title='Roblox Linux Wrapper v'"$rlwversion"'-'"$branch"' by alfonsojon' \
		--window-icon="$RBXICON" \
		--width=480 \
		--height=240 \
		--cancel-label='Quit' \
		--list \
		--text 'What option would you like?' \
		--radiolist \
		--column '' \
		--column 'Options' \
		TRUE 'Play Roblox' \
		FALSE 'Play Roblox (Legacy Mode)' \
		FALSE 'Roblox Studio' \
		FALSE 'Reinstall Roblox' \
		FALSE 'Uninstall Roblox')
	case $sel in
	'Play Roblox')
		playerwrapper; main;;
	'Play Roblox (Legacy Mode)')
		playerwrapper legacy; main;;
	'Roblox Studio')
		WINEDLLOVERRIDES="msvcp110.dll,msvcr110.dll=n,b" rwine "$WINEPREFIX/drive_c/users/$USER/Local Settings/Application Data/RobloxVersions/RobloxStudioLauncherBeta.exe" -ide
		main ;;
	'Reinstall Roblox')
		spawndialog question 'Are you sure you would like to reinstall?'
		if [[ "$?" = "0" ]]; then
			rm -rf "$WINEPREFIX";
			roblox-install; main
		else
			main
		fi;;
	'Uninstall Roblox')
		spawndialog question 'Are you sure you would like to uninstall?'
		if [[ "$?" = "0" ]]; then
			xdg-desktop-menu uninstall "$HOME/.rlw/roblox.desktop"
			[[ ! -f "$HOME/.local/share/icons/roblox.png" ]] || {
				rm -rf "$HOME/.local/share/icons/roblox.png"
			}
			[[ ! -f "$HOME/.local/share/icons/hicolor/512x512/apps/roblox.png" ]] || {
				rm -rf "$HOME/.local/share/icons/hicolor/512x512/apps/roblox.png"
			}
			xdg-desktop-menu forceupdate
			rm -rf "$HOME/.rlw"
			if [[ -d "$HOME/.rlw" ]]; then
				spawndialog error 'Roblox is still installed. Please try uninstalling again.'
			else
				spawndialog info 'Roblox has been uninstalled successfully.'
			fi
			exit
		else
			main
		fi;;
	esac
	printf '%b\n' " > end main ()\n---"
}

SOURCE_DIR=$(pwd)
cd "$HOME"

# Define some variables
export rlwversion=20150405
export branch=$(git symbolic-ref --short -q HEAD)
export WINEARCH=win32

printf '%b\n' 'Roblox Linux Wrapper v'"$rlwversion"'-'"$branch"

# Uncomment these lines to use stock Wine (default)
export winebin="$(which wine-development)" || "$(which wine)"
export winebootbin="$(which wineboot-development)" || "$(which wineboot)"
export wineserverbin="$(which wineserver-development)" || "$(which wineserver)"
export WINEPREFIX="$HOME/.rlw/roblox-wine"

# Uncomment these lines to use wine-staging (formerly wine-compholio)
#[[ -x /opt/wine-staging/bin/wine ]] && {
#	export winebin="/opt/wine-staging/bin/wine"
#	export winebootbin="/opt/wine-staging/bin/wineboot"
#	export wineserverbin="/opt/wine-staging/bin/wineserver"
#	export WINEPREFIX="$HOME/.rlw/roblox-wine-staging"
#	WINEPREFIX="$HOME/.wine-staging" "/opt/wine-staging/bin/wineboot"
#}

# Some internal functions to make wine more useful to the wrapper.
# This allows the wrapper to know what went wrong and where, without excessive code.
# Note: the "r" prefix indicates a function that extends system functionality.

# Check that everything is here
[[ -x "$winebin" && -x "$winebootbin" && -x "$wineserverbin"  ]] || {
	spawndialog error "Missing dependencies! Please install wine and/or wine-staging."
	exit 1
}

[[ "$(wine --version | sed 's/.*-//')" > "1.7.27" ]] || {
	spawndialog error "Your copy of Wine is too old. Please install version 1.7.28 or greater.\n(expected 1.7.28, got $(wine --version | sed 's/.*-//'))"
	exit 1
}

# Note: git is used for automatic updating, and is recommended.
[[ -x "$(which git)" ]] || {
	spawndialog error "Missing dependencies! Please install git."
	exit 1
}
# Run dependency check & launch main function
wrapper-install && roblox-install && main
