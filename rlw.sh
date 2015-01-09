#!/usr/bin/env bash
#
#  Copyright 2015 Jonathan Alfonso <alfonsojon1997@gmail.com>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#
#

# Uncomment these lines to use stock Wine (default)
#export WINE=`which wine`
#export WINESERVERBIN=`which wineserver`

# Uncomment these lines to use Wine Compholio
export WINE=/opt/wine-compholio/bin/wine
export WINESERVERBIN=/opt/wine-compholio/bin/wineserver

###
# Don't touch stuff below this point!!!
###

export RLWVERSION=20150109
export RLWCHANNEL=RELEASE
export WINEPREFIX=$HOME/.local/share/wineprefixes/Roblox
export WINEARCH=win32

echo 'Roblox Linux Wrapper v'$RLWVERSION'-'$RLWCHANNEL

spawndialog () {
	zenity \
		--window-icon=$RBXICON \
		--title='Roblox Linux Wrapper v'$RLWVERSION'-'$RLWCHANNEL \
		--$1 \
		--no-wrap \
		--text="$2"
}

download () {
	wget $1 -O $2 2>&1 | \
	sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | \
	zenity \
		--progress \
		--window-icon=$RBXICON \
		--title='Downloading' \
		--auto-close \
		--no-cancel \
		--width=450 \
		--height=120
}

if [[ -e $HOME/.local/share/icons/hicolor/512x512/apps/roblox.png ]]; then
	export RBXICON=$HOME/.local/share/icons/hicolor/512x512/apps/roblox.png
else
	download http://img1.wikia.nocookie.net/__cb20130302012343/robloxhelp/images/f/fb/ROBLOX_Circle_Logo.png $HOME/.local/share/icons/hicolor/512x512/apps/roblox.png
	export RBXICON=$HOME/.local/share/icons/hicolor/512x512/apps/roblox.png
fi

roblox-install () {
	if command -v $1 >/dev/null 2>&1; then
		echo "$1 installed, continuing"
	else
		echo "Please install $1."
		if [[ $1 != "zenity" ]]; then
			spawndialog error "Please install $1"
		fi
		if [[ "$WINE" == "/opt/wine-compholio/bin/wine" ]]; then
			xdg-open "https://github.com/wine-compholio/wine-staging/wiki/Installation" &
		fi
		exit 127
	fi
	if [[ ! -e $WINEPREFIX ]]; then
		spawndialog question 'Roblox is not installed on your computer.\n Would you like to install Roblox?'
		if [[ $? == "0" ]]; then
			spawndialog info 'Required software will be installed. \n\nDepending upon your internet connection, this may take a few minutes.'
			download http://roblox.com/install/setup.ashx /tmp/RobloxPlayerLauncher.exe
			winetricks ddr=gdi
			WINEDLLOVERRIDES="winebrowser.exe,winemenubuilder.exe=" $WINE /tmp/RobloxPlayerLauncher.exe
			cd $WINEPREFIX
			ROBLOXPROXY=`find . -iname 'RobloxProxy.dll' | sed "s/.\/drive_c/C:/" | tr '/' '\\'`
			$WINE regsvr32 /i "$ROBLOXPROXY"
			download http://ftp.mozilla.org/pub/mozilla.org/firefox/releases/31.3.0esr/win32/en-US/Firefox%20Setup%2031.3.0esr.exe /tmp/Firefox-Setup-esr.exe
			$WINE /tmp/Firefox-Setup-esr.exe /SD | zenity \
				--window-icon=$RBXICON \
				--title='Installing Mozilla Firefox' \
				--text='Installing Mozilla Firefox ESR ...' \
				--progress \
				--pulsate \
				--no-cancel \
				--auto-close
			cat <<-EOF > $HOME/.local/share/applications/Roblox.desktop
			[Desktop Entry]
			Comment=Play Roblox
			Name=Roblox Linux Wrapper
			Exec=$HOME/.rlw/rlw-stub.sh
			Actions=RFAGroup;ROLWiki;
			GenericName=Building Game
			Icon=roblox
			Categories=Game;
			Type=Application

			[Desktop Action ROLWiki]
			Name='Roblox on Linux Wiki'
			Exec=xdg-open 'http://roblox.wikia.com/wiki/Roblox_On_Linux'

			[Desktop Action RFAGroup]
			Name='Roblox for All'
			Exec=xdg-open 'http://www.roblox.com/Groups/group.aspx?gid=292611'
			EOF
			mkdir $HOME/.rlw
			download https://raw.githubusercontent.com/alfonsojon/roblox-linux-wrapper/master/rlw.sh $HOME/.rlw/rlw.sh
			download https://raw.githubusercontent.com/alfonsojon/roblox-linux-wrapper/master/rlw-stub.sh $HOME/.rlw/rlw-stub.sh
			download http://img1.wikia.nocookie.net/__cb20130302012343/robloxhelp/images/f/fb/ROBLOX_Circle_Logo.png $HOME/.local/share/icons/roblox.png
			chmod +x $HOME/.rlw/rlw.sh
			chmod +x $HOME/.rlw/rlw-stub.sh
			chmod +x $HOME/.local/share/applications/Roblox.desktop
			xdg-desktop-menu install --novendor $HOME/.local/share/applications/Roblox.desktop
			xdg-desktop-menu forceupdate
			if [[ -f $HOME/.rlw/rlw-stub.sh && -f $HOME/.rlw/rlw.sh && -f $HOME/.local/share/icons/roblox.png && -f $HOME/.local/share/applications/Roblox.desktop ]]; then
				spawndialog info 'Installation has completed. You can now launch Roblox \nvia your system program launcher.'
			else
				spawndialog error 'Roblox Linux Wrapper did not install successfully.'
			fi
			exit
		else
			exit
		fi
	fi
}

playerwrapper () {
	if [[ $1 = legacy ]]; then
		export GAMEURL=`\
		zenity \
			--title='Roblox Linux Wrapper v'$RLWVERSION'-'$RLWCHANNEL \
			--window-icon=$RBXICON \
			--entry \
			--text='Paste the URL for the game here.' \
			--ok-label='Play' \
			--width=450 \
			--height=122`
			GAMEID=`echo $GAMEURL | cut -d "=" -f 2`
		if [[ -n "$GAMEID" ]]; then
			$WINE "`find $WINEPREFIX -name RobloxPlayerBeta.exe`" --id $GAMEID | \
			zenity \
				--window-icon=$WINEPREFIX/ROBLOX-Circle-Logo1.png \
				--title='ROBLOX' \
				--text='Starting ROBLOX Player...' \
				--progress \
				--pulsate \
				--auto-close \
				--no-cancel \
				--width=362 \
				--height=122
		else
			return
		fi
	else
		$WINE 'C:\Program Files\Mozilla Firefox\firefox.exe' http://www.roblox.com/Games.aspx
	fi
}

main () {
	if [[ -e $HOME/Desktop/ROBLOX\ Player.desktop ]] || [[ -e $HOME/Desktop/ROBLOX\ Player.lnk ]]; then
		rm -rf $HOME/Desktop/ROBLOX\ Player.desktop
		rm -rf $HOME/Desktop/ROBLOX\ Player.lnk
	fi
	if [[ -e $HOME/Desktop/ROBLOX\ Studio.desktop ]] || [[ -e $HOME/Desktop/ROBLOX\ Studio.lnk ]]; then
		rm -rf $HOME/Desktop/ROBLOX\ Studio.desktop
		rm -rf $HOME/Desktop/ROBLOX\ Studio.lnk
	fi
	if [[ -e $HOME/.local/share/applications/wine/Programs/Roblox ]]; then
		rm -rf $HOME/.local/share/applications/wine/Programs/Roblox
	fi
	sel=`zenity \
		--title='Roblox Linux Wrapper v'$RLWVERSION'-'$RLWCHANNEL' by alfonsojon' \
		--window-icon=$RBXICON \
		--width=480 \
		--height=240 \
		--cancel-label='Quit' \
		--list \
		--text 'Select a choice.' \
		--radiolist \
		--column '' \
		--column 'Options' \
		TRUE 'Play Roblox' \
		FALSE 'Play Roblox (Legacy Mode)' \
		FALSE 'Roblox Studio' \
		FALSE 'Reset Roblox to defaults' \
		FALSE 'Uninstall Roblox' `
	case $sel in
	'Play Roblox')
		playerwrapper; main;;
	'Play Roblox (Legacy Mode)')
		playerwrapper legacy; main;;
	'Roblox Studio')
		if [[ `find $WINEPREFIX/drive_c/users/$USER/Local\ Settings/Application\ Data/RobloxVersions/version-* -name RobloxStudioLauncherBeta.exe` == '' ]]; then
			$WINE $WINEPREFIX/drive_c/users/$USER/Local\ Settings/Application\ Data/RobloxVersions/RobloxStudioLauncherBeta.exe -ide
			$WINESERVERBIN -k
		fi
		WINEDLLOVERRIDES="msvcp110.dll,msvcr110.dll=n,b" $WINE $WINEPREFIX/drive_c/users/$USER/Local\ Settings/Application\ Data/RobloxVersions/version-*/RobloxStudioBeta.exe
		main;;
	'Reset Roblox to defaults')
		rm -rf $WINEPREFIX;
		roblox-install; main;;
	'Uninstall Roblox')
		spawndialog question 'Are you sure you would like to uninstall?'
		if [[ $? == "0" ]]; then
			xdg-desktop-menu uninstall $HOME/.local/share/applications/Roblox.desktop
			rm -rf $HOME/.rlw
			if [[ -e $HOME/.local/share/icons/roblox.png ]]; then
				rm -rf $HOME/.local/share/icons/roblox.png
			fi
			rm -rf $HOME/.local/share/icons/hicolor/512x512/apps/roblox.png
			xdg-desktop-menu forceupdate
			wineserver -k
			rm -rf $WINEPREFIX
			if [[ -d $HOME/.rlw ]] || [[ -e $HOME/.local/share/icons/hicolor/512x512/apps/roblox.png ]] || [[ -d $WINEPREFIX ]]; then
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

# Run dependency check & launch main function
roblox-install zenity; roblox-install wget; roblox-install shasum; roblox-install cabextract; roblox-install $WINE
main
