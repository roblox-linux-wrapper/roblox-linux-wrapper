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

# Some internal functions to make wine more useful to the wrapper.
# This allows the wrapper to know what went wrong and where, without excessive code.
# Note: functions prefixed with "r" indicate wrappers that extend system functionality.
spawndialog () {
	[[ -x "$(which zenity)" ]] || {
		printf '%b\n' "Missing dependency! Please install \"zenity\", then try again."
		exit 1
	}
	zenity \
		--no-wrap \
		--window-icon="$RBXICON" \
		--title='Roblox Linux Wrapper '"$rlwversion"'-'"$branch" \
		--"$1" \
		--text="$2" 2&> /dev/null
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
			--height=120 2&>/dev/null
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
		# Winetricks was not found, so we'll download our own copy.
		rwget "http://winetricks.org/winetricks" -O "/tmp/winetricks"
		chmod +x "/tmp/winetricks"
		winetricksbin="/tmp/winetricks"
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
			mkdir -p "$HOME/.local/share/wineprefixes"
			rwineboot
			rwinetricks ddr=gdi		# Causes graphical problems in mutter/gala (GNOME Shell/Elementary OS)
			[[ "$?" = 0 ]] || {
				spawndialog error "Wine prefix not generated successfully.\nSee terminal for more details. (exit code $?)"
				exit $?
			}
			wget -N -r --no-parent -Aexe http://download.cdn.mozilla.net/pub/mozilla.org/firefox/releases/latest-esr/win32/en-US/ -nd -P /tmp/Firefox-Setup/
			WINEDLLOVERRIDES="winebrowser.exe,winemenubuilder.exe=" rwine /tmp/Firefox-Setup/*.exe /SD | zenity \
				--window-icon="$RBXICON" \
				--title='Installing Mozilla Firefox' \
				--text='Installing Mozilla Firefox Browser ...' \
				--progress \
				--pulsate \
				--no-cancel \
				--auto-close 2&>/dev/null
			rwget http://roblox.com/install/setup.ashx -O /tmp/RobloxPlayerLauncher.exe
			WINEDLLOVERRIDES="winemenubuilder.exe=" rwine /tmp/RobloxPlayerLauncher.exe
			rwine regsvr32 /i "$(find "$WINEPREFIX" -iname 'RobloxProxy.dll')"
		else
			exit 1
		fi
	fi
	printf '%b\n' " > end roblox-install ()\n---"
}

playerwrapper () {
	printf '%b\n' " > begin playerwrapper ()\n---"
	rwine regsvr32 /i "$(find "$WINEPREFIX" -iname 'RobloxProxy.dll')"
	if [[ "$1" = legacy ]]; then
		GAMEURL=$(zenity \
				--title='Roblox Linux Wrapper '"$rlwversion"'-'"$branch" \
				--window-icon="$RBXICON" \
				--entry \
				--text='Paste the URL for the game here.' \
				--ok-label='Play' \
				--width=450 \
				--height=122)
			GAMEID=$(cut -f 5 -d '/' <<< "$GAMEURL")
		if [[ -n "$GAMEID" ]]; then
			rwine "$(find "$WINEPREFIX" -name RobloxPlayerBeta.exe)" --id "$GAMEID"
		else
			spawndialog warning "Invalid game URL."
			return
		fi
	else
		rwine "$WINEPREFIX/drive_c/Program Files/Mozilla Firefox/firefox.exe" "http://www.roblox.com/Games.aspx"
	fi
	printf '%b\n' " > end playerwrapper ()\n---"
}

main () {
	printf '%b\n' " > begin main ()\n---"
	rm -f $HOME/Desktop/ROBLOX*.lnk
	rm -rf "$HOME/.local/share/applications/wine/Programs/Roblox"
	sel=$(zenity \
		--title='Roblox Linux Wrapper '"$rlwversion"'-'"$branch"'' \
		--window-icon="$RBXICON" \
		--width=480 \
		--height=300 \
		--cancel-label='Exit' \
		--list \
		--text 'What option would you like?' \
		--radiolist \
		--column '' \
		--column 'Options' \
		TRUE 'Play Roblox' \
		FALSE 'Play Roblox (Legacy Mode)' \
		FALSE 'Roblox Studio' \
		FALSE 'Reinstall Roblox' \
		FALSE 'Uninstall Roblox'  \
		FALSE 'Visit the GitHub page' 2>/dev/null )
	case $sel in
	'Play Roblox')
		playerwrapper; main;;
	'Play Roblox (Legacy Mode)')
		playerwrapper legacy; main;;
	'Roblox Studio')
		rwine "$WINEPREFIX/drive_c/users/$USER/Local Settings/Application Data/RobloxVersions/RobloxStudioLauncherBeta.exe" -ide
		main ;;
	'Reinstall Roblox')
		spawndialog question 'Are you sure you would like to reinstall?'
		if [[ "$?" = "0" ]]; then
			rm -rf "$HOME/.rlw"
			rm -rf "$WINEPREFIX"
			roblox-install; main
		else
			main
		fi;;
	'Uninstall Roblox')
		spawndialog question 'Are you sure you would like to uninstall?'
		if [[ "$?" = "0" ]]; then
			xdg-desktop-menu uninstall "roblox.desktop"
			rm -rf "$HOME/.rlw"
			rm -rf "$HOME/.local/share/icons/roblox.png"
			rm -rf "$HOME/.local/share/icons/hicolor/512x512/apps/roblox.png"
			rm -rf "$WINEPREFIX"
			spawndialog info 'Roblox has been uninstalled successfully.'
			exit
		else
			main
		fi;;
		'Visit the GitHub page')
			xdg-open https://github.com/alfonsojon/roblox-linux-wrapper
			main  # Reopen the menu. Not sure if this should be kept or not. 
		esac
	printf '%b\n' " > end main ()\n---"
}


WRAPPER_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$WRAPPER_DIR"

# Define some variables
rlw_epoch=1 # This is used to track upgrades between .desktop file versions
export rlwversion=$(git describe --tags)
export branch=$(git symbolic-ref --short -q HEAD)
export WINEARCH=win32
export winebin="$(which wine)"
export winebootbin="$(which wineboot)"
export wineserverbin="$(which wineserver)"
export WINEPREFIX="$HOME/.local/share/wineprefixes/roblox-wine"

printf '%b\n' 'Roblox Linux Wrapper '"$rlwversion"'-'"$branch"

[[ -d ".git" ]] || {
	spawndialog error 'Roblox Linux Wrapper does not support running outside of its Git repository.\nPlease clone a copy via the command: git clone https://github.com/alfonsojon/roblox-linux-wrapper'
	exit 1
}

# Don't allow running as root
if [ "$(id -u)" == "0" ]; then
   spawndialog error "Roblox Linux Wrapper should not be ran with root permissions."
   exit 1
fi

# Check that everything is here
[[ -x "$winebin" && -x "$winebootbin" && -x "$wineserverbin" ]] || {
	spawndialog error "Missing dependencies! Please install wine and try again."
	exit 1
}

[[ "$(wine --version | sed 's/.*-//')" > "1.7.27" ]] || {
	spawndialog error "Your copy of Wine is too old. Please install version 1.7.28 or greater.\n(expected 1.7.28, got $(wine --version | sed 's/.*-//'))"
	exit 1
}

# Note: git is used for automatic updating, and is recommended.
[[ -x "$(which git)" ]] || {
	spawndialog error "git is not installed, or was not found. Please install git\nto enable automatic updates."
}
# Run dependency check & launch main function
[[ -x "gen-desktop.sh" ]] && {
	./gen-desktop.sh
	if [[ $(cat .rlw_epoch) -eq "$rlw_epoch" ]]; then
		printf '%b\n' "Not automatically overwriting the .desktop file; the epoch version seems up to date (rlw_epoch=$rlw_epoch)."
	else
		spawndialog question "Would you like to install the Roblox menu item on your system?"
		[[ "$?" = "0" ]] && {
			xdg-desktop-menu install --novendor --mode user "$WRAPPER_DIR/roblox.desktop"
			echo "$rlw_epoch" > .rlw_epoch
		}
	fi
}
printf '%b\n' "Checking for updates... You will need to restart the script afterwards for updates to apply, if there are any."
git pull
roblox-install && main
