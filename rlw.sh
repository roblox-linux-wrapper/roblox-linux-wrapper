#!/bin/bash
#
#  Copyright 2014 Jonathan Alfonso <alfonsojon1997@gmail.com>
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
export RWLVERSION=2.0
export WINEPREFIX=$HOME/.local/share/wineprefixes/Roblox
export WINETRICKSDEV=/tmp/winetricks
export WINEARCH=win32
export WINEDLLOVERRIDES=winebrowser.exe,winemenubuilder.exe=
if [ -e $HOME/.local/share/icons/hicolor/512x512/apps/roblox.png ]; then
	export RBXICON=$HOME/.local/share/icons/hicolor/512x512/apps/roblox.png
else
	download http://img1.wikia.nocookie.net/__cb20130302012343/robloxhelp/images/f/fb/ROBLOX_Circle_Logo.png $HOME/.local/share/icons/hicolor/512x512/apps/roblox.png
	export RBXICON=$HOME/.local/share/icons/hicolor/512x512/apps/roblox.png
fi
echo 'Roblox Linux Wrapper v'$RWLVERSION

spawndialog () {
	zenity \
		--window-icon=$RBXICON \
		--title='Roblox Linux Wrapper v'$RWLVERSION \
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
		--title="Downloading" \
		--auto-close \
		--no-cancel \
		--width=450 \
		--height=120
}

depcheck () {
	if command -v zenity >/dev/null 2>&1; then
		echo 'Zenity installed, continuing'
	else
		echo 'Please install zenity via your system'\''s package manager.'
		exit 127
	fi
	if command -v wget >/dev/null 2>&1; then
		echo 'wget installed, continuing'
	else
		echo 'Please install wget via your system'\''s package manager.'
		exit 127
	fi
	if command -v wine >/dev/null 2>&1; then
		echo 'Wine installed, continuing'
	else
		spawndialog error 'Please install Wine from www.winehq.org/download'
		xdg-open 'http://www.winehq.org/download'
		exit 127
	fi
	if [ ! -e $WINEPREFIX ]; then
		spawndialog info 'Required dependencies are going to be installed. \n\nDepending on your internet connection, this may take a few minutes.'
		download http://roblox.com/install/setup.ashx /tmp/RobloxPlayerLauncher.exe
		download http://winetricks.googlecode.com/svn/trunk/src/winetricks /tmp/winetricks
		chmod +x /tmp/winetricks
		/tmp/winetricks -q vcrun2008 vcrun2012 winhttp wininet | zenity \
			--window-icon=$RBXICON \
			--title='Running winetricks' \
			--text='Running winetricks...' \
			--progress \
			--pulsate \
			--no-cancel \
			--auto-close
		wine /tmp/RobloxPlayerLauncher.exe | zenity \
			--window-icon=$RBXICON \
			--title='Installing Roblox' \
			--text='Installing Roblox...' \
			--progress \
			--pulsate \
			--no-cancel \
			--auto-close
		cd $WINEPREFIX
		ROBLOXPROXY=`find . -iname 'RobloxProxy.dll'| sed "s/.\/drive_c/C:/" | tr '/' '\\'`
		wine regsvr32 "$ROBLOXPROXY"
		download ftp://ftp.mozilla.org/pub/firefox/releases/31.0esr/win32/en-US/Firefox%20Setup%2031.0esr.exe /tmp/Firefox-Setup-31.0esr.exe
		wine /tmp/Firefox-Setup-31.0esr.exe /SD | zenity \
			--window-icon=$RBXICON \
			--title='Installing Mozilla Firefox' \
			--text='Installing Mozilla Firefox 31.0 ESR...' \
			--progress \
			--pulsate \
			--no-cancel \
			--auto-close
	fi
	if [ -e ~/.local/share/applications/wine/Programs/Roblox ]; then
		rm -rf ~/.local/share/applications/wine/Programs/Roblox
	fi
}

addremoverlw () {
	if [ $1 == install ]; then
		cat <<-EOF > $HOME/.local/share/applications/Roblox.desktop
		[Desktop Entry]
		Comment=Play Roblox on Linux
		Name=Roblox Linux Wrapper
		Exec=$HOME/.rlw/rlw.sh
		Actions=ROLWiki;
		GenericName=Building Game
		Icon=roblox.png
		Categories=Game;
		Type=Application

		[Desktop Action ROLWiki]
		Name=Roblox on Linux Wiki
		Exec=xdg-open http://roblox.wikia.com/wiki/Roblox_On_Linux
		EOF
		mkdir $HOME/.rlw
		download https://raw.githubusercontent.com/alfonsojon/roblox-linux-wrapper/master/rlw.sh $HOME/.rlw/rlw.sh
		download http://img1.wikia.nocookie.net/__cb20130302012343/robloxhelp/images/f/fb/ROBLOX_Circle_Logo.png $HOME/.local/share/icons/hicolor/512x512/apps/roblox.png
		chmod +x $HOME/.rlw/rlw.sh
		chmod +x $HOME/.local/share/applications/Roblox.desktop
		xdg-desktop-menu install --novendor $HOME/.local/share/applications/Roblox.desktop
		xdg-desktop-menu forceupdate
		if [ -e $HOME/.rlw/rlw.sh ] && [ -e $HOME/.local/share/icons/hicolor/512x512/apps/roblox.png ] && [ -e $HOME/.local/share/applications/Roblox.desktop ]; then
			spawndialog info 'Roblox Linux Wrapper was installed successfully.'
		else
			spawndialog error 'Roblox Linux Wrapper did not install successfully.\n Please ensure you are connected to the internet and try again.'
		fi
	fi
	if [ $1 == uninstall ]; then
		xdg-desktop-menu uninstall $HOME/.local/share/applications/Roblox.desktop
		rm -rf $HOME/.rlw
		if [ -e rm $HOME/.local/share/icons/roblox.png]; then
			rm -rf $HOME/.local/share/icons/roblox.png
		fi
		rm -rf $HOME/.local/share/icons/hicolor/512x512/apps/roblox.png
		xdg-desktop-menu forceupdate
		if [ -e $HOME/.rlw ] || [ -e $HOME/.local/share/icons/hicolor/512x512/apps/roblox.png ]; then
			spawndialog error 'Roblox Linux Wrapper is still installed. Please try uninstalling again.'
		else
			spawndialog info 'Roblox Linux Wrapper has been uninstalled successfully.'
		fi
	fi
}

playerwrapper () {
	if [ $1 = legacy ]; then
		export GAMEURL=`\
		zenity \
			--title='Roblox Linux Wrapper v'$RWLVERSION \
			--window-icon=$RBXICON \
			--entry \
			--text='Paste the URL for the game here.' \
			--ok-label='Play' \
			--width=450 \
			--height=120`
			GAMEID=`echo $GAMEURL | cut -d "=" -f 2`
		if [ -n "$GAMEID" ]; then
			wine $WINEPREFIX/drive_c/users/`whoami`/Local\ Settings/Application\ Data/RobloxVersions/version-*/RobloxPlayerBeta.exe --id $GAMEID 2>&1 | \
			zenity \
				--window-icon=$WINEPREFIX/ROBLOX-Circle-Logo1.png \
				--title='ROBLOX' \
				--text='Starting Roblox Player...' \
				--no-wrap \
				--progress \
				--pulsate \
				--timeout=5 \
				--no-cancel
		else
			return
		fi
	else
		wine 'C:\Program Files\Mozilla Firefox\firefox.exe' http://www.roblox.com/Games.aspx
	fi
}

studiowrapper () {
	zenity \
		--title='Roblox Linux Wrapper v'$RWLVERSION \
		--window-icon=$WINEPREFIX/ROBLOX-Circle-Logo1.png \
		--info \
		--no-wrap \
		--text='Roblox Studio may take up to 90 seconds to load.'
	wine $WINEPREFIX/drive_c/users/`whoami`/Local\ Settings/Application\ Data/RobloxVersions/RobloxStudioLauncherBeta.exe | \
	zenity \
		--window-icon=$WINEPREFIX/ROBLOX-Circle-Logo1.png \
		--title='ROBLOX' \
		--text='Starting Roblox Studio...' \
		--progress \
		--pulsate \
		--no-cancel
}

main () {
	sel=`zenity \
		--title='Roblox Linux Wrapper v'$RWLVERSION' by alfonsojon' \
		--window-icon=$RBXICON \
		--width=480 \
		--height=236 \
		--cancel-label='Quit' \
		--list \
		--text 'Select a choice.' \
		--radiolist \
		--column '' \
		--column 'Options' \
		TRUE 'Play Roblox' \
		FALSE 'Play Roblox (Legacy Mode)' \
		FALSE 'Roblox Studio' \
		FALSE 'Install Roblox Linux Wrapper (Recommended)' \
		FALSE 'Reset Roblox to defaults'`
	case $sel in
	'Play Roblox')
		playerwrapper; main;;
	'Play Roblox (Legacy Mode)')
		playerwrapper legacy; main;;
	'Roblox Studio')
		studiowrapper; main;;
	'Install Roblox Linux Wrapper (Recommended)')
		if [ -e $HOME/.local/share/applications/Roblox.desktop ]; then
			zenity \
				--window-icon=$WINEPREFIX/ROBLOX-Circle-Logo1.png \
				--no-wrap \
				--title='Roblox Linux Wrapper v'$RWLVERSION \
				--question \
				--text='Roblox Linux Wrapper is already installed.\nWould you like to uninstall it?'
			if [ $? == 0 ]; then
				addremoverlw uninstall; main
			else
				main;
			fi
		else
			addremoverlw install; main
		fi;;
	'Reset Roblox to defaults')
		rm -rf $WINEPREFIX;
		depcheck; main;;
	esac
}

# Run dependency check & launch main function
depcheck; main
