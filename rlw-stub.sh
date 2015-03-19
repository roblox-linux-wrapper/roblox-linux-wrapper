#!/usr/bin/env bash
#
#    Copyright 2015 Jonathan Alfonso <alfonsojon1997@gmail.com>
#
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


rwget () {
	wget "$@" 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | zenity \
		--progress \
		--window-icon="$RBXICON" \
		--title='Downloading' \
		--auto-close \
		--no-cancel \
		--width=450 \
		--height=120
	[ "$?" = "0" ] || { spawndialog error "wget download failed. \nSee terminal for details. (exit code $?)"; exit $?; }
}
spawndialog () {
	zenity \
		--window-icon="$RBXICON" \
		--title='Roblox Linux Wrapper v'"$RLWVERSION"'-'"$RLWCHANNEL" \
		--"$1" \
		--text="$2"
}
[ -e "$(which zenity)" -a "$(which shasum)" -a "$(which wget)"  ] || { spawndialog error "Missing dependencies! Make sure zenity, wget, wine, and wine-staging are installed."; exit 1; }
if [ ! -e "$HOME/.rlw/rlw.sh" ]; then
	download https://raw.githubusercontent.com/alfonsojon/roblox-linux-wrapper/master/rlw.sh "$HOME/.rlw/rlw.sh"
	cp "$HOME/.rlw/rlw.sh" "$HOME/.rlw/rlw.sh.update"
fi
rwget https://raw.githubusercontent.com/alfonsojon/roblox-linux-wrapper/master/rlw.sh -O "$HOME/.rlw/rlw.sh.update"
if [ "$(shasum "$HOME/.rlw/rlw.sh.update" | cut -d' ' -f1)" != "$(cut -d' ' -f1 < cat "$HOME/.rlw/update.ignored")" ]
then
	rm -rf "$HOME/.rlw/update.ignored"
fi
if [ "$(cut -d' ' -f1 < shasum "$HOME/.rlw/rlw.sh.update")" != "$(shasum "$HOME/.rlw/rlw.sh.update" | cut -d' ' -f1)" ]
then
	if [ ! -e "$HOME/.rlw/update.ignored" ]
	then
		if [ "$(cut -d' ' -f1 < "$HOME/.rlw/update.ignored")" != "$(shasum "$HOME/.rlw/rlw.sh.update")" ]
		then
			spawndialog question "An update to Roblox Linux Wrapper is available.\nWould you like to update?"
			if [[ $? != "0" ]]
			then
				shasum "$HOME/.rlw/rlw.sh.update" > "$HOME/.rlw/update.ignored"
			else
				rm -rf "$HOME/.rlw/rlw.sh"
				cp	"$HOME/.rlw/rlw.sh.update $HOME/.rlw/rlw.sh"
			fi
		fi
	fi
fi

printf "Loading rlw.sh ... \n"
chmod +x "$HOME/.rlw/rlw.sh"
bash "$HOME/.rlw/rlw.sh"
