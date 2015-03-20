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

cd "$HOME"

# Define some variables and the spawndialog function
export rlwversion=20150319
export rlwchannel=stable
export WINEARCH=win32

printf '%b\n' 'Roblox Linux Wrapper v'"$rlwversion"'-'"$rlwchannel"

# Uncomment these lines to use stock Wine (default)
export winebin="$(which wine)"
export winebootbin="$(which wineboot)"
export wineserverbin="$(which wineserver)"
export WINEPREFIX="$HOME/.rlw/roblox-wine"

# Uncomment these lines to use wine-staging (formerly wine-compholio)
#[[ -x /opt/wine-staging/bin/wine ]] && {
#	export winebin="/opt/wine-staging/bin/wine"
#	export winebootbin="/opt/wine-staging/bin/wineboot"
#	export wineserverbin="/opt/wine-staging/bin/wineserver"
#	export WINEPREFIX="$HOME/.rlw/roblox-wine-staging"
#}

# Some internal functions to make wine more useful to the wrapper.
# This allows the wrapper to know what went wrong and where, without excessive code.
# Note: the "r" prefix indicates a function that extends system functionality.

spawndialog () {
	[[ -x "$(which zenity)" ]] || {
		printf '%b\n' "Missing dependency! Please install \"zenity\", then try again."
		exit 1
	}
	zenity \
		--window-icon="$RBXICON" \
		--title='Roblox Linux Wrapper v'"$rlwversion"'-'"$rlwchannel" \
		--"$1" \
		--text="$2"
}

rwine () {
	if [[ "$1" = "--silent" ]]; then
		$winebin "${@:2}"
	else
		$winebin "$@"; [[ "$?" = "0" ]] || {
			spawndialog error "wine closed unsuccessfully.\nSee terminal for details. (exit code $?)"
			exit $?
	}
	fi
}
rwineboot () {
	$winebootbin; [[ "$?" = "0" ]] || {
		spawndialog error "wineboot closed unsuccessfully.\nSee terminal for details. (exit code $?)"
		exit $?
	}
}
rwineserver () {
	$wineserverbin "$@"; [[ "$?" = "0" ]] || {
		spawndialog error "wineserver closed unsuccessfully.\nSee terminal for details. (exit code $?)"
		exit $?
	}
}
rwget () {
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
}
rwinetricks () {
	winetricksbin="$(which winetricks)"
	[[ -x "$(which winetricks)" ]] || {
		rwget "http://winetricks.org/winetricks" -O "$HOME/.rlw/winetricks"
		chmod +x "$HOME/.rlw/winetricks"
		winetricksbin="$HOME/.rlw/winetricks"
	}
	$winetricksbin "$@"
}

roblox-install () {
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
			rwineserver --wait
			cd "$WINEPREFIX"
			[[ "$?" = 0 ]]  || {
				spawndialog error "Wine prefix not generated successfully.\nSee terminal for more details. (exit code $?)"
				exit $?
			}
			rwget http://roblox.com/install/setup.ashx -O /tmp/RobloxPlayerLauncher.exe
			WINEDLLOVERRIDES="winebrowser.exe,winemenubuilder.exe=" rwine /tmp/RobloxPlayerLauncher.exe
			cd "$WINEPREFIX"
			ROBLOXPROXY="$(find . -iname 'RobloxProxy.dll' | sed "s/.\/drive_c/C:/" | tr '/' '\\')"
			rwineserver --wait
			[[ ! -f "$WINEPREFIX/Program Files/Mozilla Firefox/firefox.exe" ]] && {
				# Don't ask to install only one browser
				#
				#ans=$(zenity \
				#	--title='Roblox Linux Wrapper v'$rlwversion'-'$rlwchannel' by alfonsojon' \
				#	--window-icon="$RBXICON" \
				#	--width=480 \
				#	--height=240 \
				#	--cancel-label='Quit' \
				#	--list \
				#	--text 'Which browser do you want?' \
				#	--radiolist \
				#	--column '' \
				#	--column 'Options' \
				#	TRUE 'Firefox')
				ans="Firefox"
				case $ans in
				'Firefox')
					rwget http://ftp.mozilla.org/pub/mozilla.org/firefox/releases/31.4.0esr/win32/en-US/Firefox%20Setup%2031.4.0esr.exe -O /tmp/Firefox-Setup-esr.exe
					WINEDLLOVERRIDES="winebrowser.exe,winemenubuilder.exe=" rwine /tmp/Firefox-Setup-esr.exe /SD | zenity \
						--window-icon="$RBXICON" \
						--title='Installing Mozilla Firefox' \
						--text='Installing Mozilla Firefox Browser ...' \
						--progress \
						--pulsate \
						--no-cancel \
						--auto-close
					rwineserver --wait
				esac
			}
		else
			exit 1
		fi
	fi

}

wrapper-install () {
	if [[ ! -d "$HOME/.rlw" ]] || [[ ! -x "$HOME/.local/share/applications/Roblox.desktop" ]]; then
		spawndialog question 'Roblox Linux Wrapper is not installed. This is necessary to launch games properly.\nWould you like to install it?'
		if [[ "$?" = 0 ]]; then
			mkdir -p "$HOME/.rlw"
			git clone "https://github.com/alfonsojon/roblox-linux-wrapper.git" "$HOME/.rlw"
			[[ -e "$HOME/.local/share/applications/Roblox.desktop" ]] && {
				rm -rf "$HOME/.local/share/applications/Roblox.desktop"
			}
			ln -s "$HOME/.rlw/Roblox.desktop" "$HOME/.local/share/applications/Roblox.desktop"
			chmod +x "$HOME/.rlw/rlw.sh"
			chmod +x "$HOME/.local/share/applications/Roblox.desktop"
			xdg-desktop-menu install --novendor "$HOME/.local/share/applications/Roblox.desktop"
			xdg-desktop-menu forceupdate
			[[ -x "$HOME/.rlw/rlw-stub.sh" && -x "$HOME/.rlw/rlw.sh && -f $HOME/.local/share/icons/roblox.png && -f $HOME/.local/share/applications/Roblox.desktop" ]] || {
				spawndialog error 'Roblox Linux Wrapper did not install successfully.'
				exit 1
			}
		else
			exit 1
		fi
	fi
	cd "$HOME/.rlw" && git pull
}

playerwrapper () {
	ROBLOXPROXY=$(find . -iname 'RobloxProxy.dll' | sed "s/.\/drive_c/C:/" | tr '/' '\\')
	rwine --silent regsvr32 /i "$ROBLOXPROXY"
	if [[ "$1" = legacy ]]; then
		export GAMEURL=$(\
			zenity \
				--title='Roblox Linux Wrapper v'$rlwversion'-'$rlwchannel \
				--window-icon="$RBXICON" \
				--entry \
				--text='Paste the URL for the game here.' \
				--ok-label='Play' \
				--width=450 \
				--height=122)
			GAMEID=$(printf '%s' "$GAMEURL" | cut -d "=" -f 2)
		if [[ -n "$GAMEID" ]]; then
			rwine "$(find "$WINEPREFIX" -name RobloxPlayerBeta.exe)" --id "$GAMEID"
			rwineserver --wait
		else
			spawndialog warning "Invalid game URL or ID."
			return
		fi
	else
		rwine "$WINEPREFIX/drive_c/Program Files/Mozilla Firefox/firefox.exe" "http://www.roblox.com/Games.aspx"
	fi
}

main () {
	cd "$HOME"
	rm -rf "$HOME/Desktop/ROBLOX*desktop $HOME/Desktop/ROBLOX*.lnk"
	rm -rf "$HOME/.local/share/applications/wine/Programs/Roblox"
	rm -rf "$HOME/.local/share/wineprefixes/roblox*" "$HOME/.local/share/wineprefixes/Roblox*"
	sel=$(zenity \
		--title='Roblox Linux Wrapper v'$rlwversion'-'$rlwchannel' by alfonsojon' \
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
		rwineserver --wait
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
			xdg-desktop-menu uninstall "$HOME/.local/share/applications/Roblox.desktop"
			[[ ! -f "$HOME/.local/share/icons/roblox.png" ]] || {
				rm -rf "$HOME/.local/share/icons/roblox.png"
			}
			[[ ! -f "$HOME/.local/share/icons/hicolor/512x512/apps/roblox.png" ]] || {
				rm -rf "$HOME/.local/share/icons/hicolor/512x512/apps/roblox.png"
			}
			xdg-desktop-menu forceupdate
			$wineserverbin --kill
			rm -rf "$WINEPREFIX"
			rm -rf "$HOME/.rlw"
			if [[ -d "$HOME/.rlw" ]] || [[ -f "$HOME/.rlw/roblox.png" ]] || [[ -d "$WINEPREFIX/drive_c" ]]; then
				spawndialog error 'Roblox is still installed. Please try uninstalling again.'
			else
				spawndialog info 'Roblox has been uninstalled successfully.'
			fi
			exit
		else
			main
		fi;;
	esac
}
# Check that everything is here
[[ -x "$winebin" && -x "$winebootbin" && -x "$wineserverbin"  ]] || {
	spawndialog error "Missing dependencies! Please install wine and wine-staging."
	exit 1
}

# Note: git is used for automatic updating, and is recommended.
[[ -x "$(which git)" ]] || {
	spawndialog error "Missing dependencies! Please install git."
	exit 1
}
# Run dependency check & launch main function
wrapper-install && roblox-install && browser-install && main
