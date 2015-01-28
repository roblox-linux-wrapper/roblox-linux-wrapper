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

# Check that everything is here
if [[ ! -e `which zenity` ]]; then
	echo "Missing dependencies! Make sure zenity, wget, wine, and wine-staging are installed."
	exit 1
elif [[ ! -e `which wget` && `which wine` ]]; then
	echo "Missing dependencies! Make sure zenity, wget, wine, and wine-staging are installed."
	spawndialog error "Missing dependencies! Make sure zenity, \nwget, wine, and wine-staging are installed."
	exit 1
fi

# Define some variables and the spawndialog function
export RLWVERSION=20150127b-staging
export RLWCHANNEL=RELEASE
export WINEARCH=win32
if [[ -e $HOME/.local/share/icons/hicolor/512x512/apps/roblox.png ]]; then
	export RBXICON=$HOME/.local/share/icons/hicolor/512x512/apps/roblox.png
fi
echo 'Roblox Linux Wrapper v'$RLWVERSION'-'$RLWCHANNEL

spawndialog () {
	zenity \
		--window-icon=$RBXICON \
		--title='Roblox Linux Wrapper v'$RLWVERSION'-'$RLWCHANNEL \
		--$1 \
		--no-wrap \
		--text="$2"
}

# Uncomment these lines to use stock Wine (default)
#export WINE=`which wine`
#export WINESERVERBIN=`which wineserver`
#export WINEPREFIX=$HOME/.local/share/wineprefixes/Roblox-wine

# Uncomment these lines to use wine-staging (formerly wine-compholio)
if [[ -f /opt/wine-compholio/bin/wine ]]; then
	export WINE=/opt/wine-compholio/bin/wine
	export WINESERVERBIN=/opt/wine-compholio/bin/wineserver
	export WINEPREFIX=$HOME/.local/share/wineprefixes/Roblox-wine-compholio
elif [[ -f /opt/wine-staging/bin/wine ]]; then
	export WINE=/opt/wine-staging/bin/wine
	export WINESERVERBIN=/opt/wine-staging/bin/wineserver
	export WINEPREFIX=$HOME/.local/share/wineprefixes/Roblox-wine-staging
else
	echo "Missing dependencies! Make sure zenity, wget, wine, and wine-staging are installed."
	spawndialog error "Missing dependencies! Make sure wine-staging is installed."
	spawndialog question "Would you like to open the wine-staging installation instructions?"
	if [[ $? == "0" ]]; then
		xdg-open "https://github.com/wine-compholio/wine-staging/wiki/Installation"
	fi
	exit 1
fi

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

roblox-install () {
	if [[ ! -e $WINEPREFIX ]]; then
		spawndialog question 'A working Roblox wineprefix was not found. Would you like to install one?'
		if [[ $? == "0" ]]; then
			download http://roblox.com/install/setup.ashx /tmp/RobloxPlayerLauncher.exe
			winetricks ddr=gdi
			WINEDLLOVERRIDES="winebrowser.exe,winemenubuilder.exe=" $WINE /tmp/RobloxPlayerLauncher.exe
			cd $WINEPREFIX
			ROBLOXPROXY=`find . -iname 'RobloxProxy.dll' | sed "s/.\/drive_c/C:/" | tr '/' '\\'`
			$WINE regsvr32 /i "$ROBLOXPROXY"
			download http://ftp.mozilla.org/pub/mozilla.org/firefox/releases/31.4.0esr/win32/en-US/Firefox%20Setup%2031.4.0esr.exe /tmp/Firefox-Setup-esr.exe
			WINEDLLOVERRIDES="winebrowser.exe,winemenubuilder.exe=" $WINE /tmp/Firefox-Setup-esr.exe /SD | zenity \
				--window-icon=$RBXICON \
				--title='Installing Mozilla Firefox' \
				--text='Installing Mozilla Firefox ESR ...' \
				--progress \
				--pulsate \
				--no-cancel \
				--auto-close
		else
			exit 1
		fi
	fi
}

wrapper-install () {
	if [[ ! -d $HOME/.rlw && -f $HOME/.local/share/applications/Roblox.desktop ]]; then
		spawndialog question 'Roblox Linux Wrapper is not installed. This is necessary to launch games properly.\nWould you like to install it?'
		if [[ $? == "0" ]]; then
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
			download http://img1.wikia.nocookie.net/__cb20130302012343/robloxhelp/images/f/fb/ROBLOX_Circle_Logo.png $HOME/.local/share/icons/ro$
			chmod +x $HOME/.rlw/rlw.sh
			chmod +x $HOME/.rlw/rlw-stub.sh
			chmod +x $HOME/.local/share/applications/Roblox.desktop
			xdg-desktop-menu install --novendor $HOME/.local/share/applications/Roblox.desktop
			xdg-desktop-menu forceupdate
			if [[ -f $HOME/.rlw/rlw-stub.sh && -f $HOME/.rlw/rlw.sh && -f $HOME/.local/share/icons/roblox.png && -f $HOME/.local/share/applications/Roblox.desktop ]]; then
				echo "wrapper installed properly, continuing"
			else
				spawndialog error 'Roblox Linux Wrapper did not install successfully.'
				exit 1
			fi
		fi
	fi
}

playerwrapper () {
	ROBLOXPROXY=`find . -iname 'RobloxProxy.dll' | sed "s/.\/drive_c/C:/" | tr '/' '\\'`
	$WINE regsvr32 /i "$ROBLOXPROXY"
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
	if [[ ! -f $HOME/.local/share/icons/hicolor/512x512/apps/roblox.png ]]; then
		download http://img1.wikia.nocookie.net/__cb20130302012343/robloxhelp/images/f/fb/ROBLOX_Circle_Logo.png $HOME/.local/share/icons/hicolor/512x512/apps/roblox.png
		export RBXICON=$HOME/.local/share/icons/hicolor/512x512/apps/roblox.png
	fi
	rm -rf $HOME/Desktop/ROBLOX*desktop $HOME/Desktop/ROBLOX*.lnk
	rm -rf $HOME/.local/share/applications/wine/Programs/Roblox
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
			$WINESERVER -k
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
wrapper-install && roblox-install && main
