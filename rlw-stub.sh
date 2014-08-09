#!/bin/bash
download () {
	wget $1 -O $2 2>&1 | \
	sed -u 's/.* \([[0-9]]\+%\)\ \+\([[0-9.]]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | \
	zenity \
		--progress \
		--window-icon=$RBXICON \
		--title='Downloading' \
		--auto-close \
		--no-cancel \
		--width=362 \
		--height=122
}
spawndialog () {
	zenity \
		--window-icon=$RBXICON \
		--title='Roblox Linux Wrapper' \
		--$1 \
		--no-wrap \
		--text="$2" \
		--width=362 \
		--height=122
}
depcheck () {
	if command -v zenity >/dev/null 2>&1; then
		echo 'zenity installed, continuing'
	else
		echo "Please install zenity via your system's package manager."
		exit 127
	fi
	if command -v shasum >/dev/null 2>&1; then
		echo 'shasum installed, continuing'
	else
		echo "Please install shasum via your system's package manager."
		spawndialog error "Please install shasum via your system's package manager"
		exit 127
	fi
	if command -v wget >/dev/null 2>&1; then
		echo 'wget installed, continuing'
	else
		echo "Please install wget via your system's package manager."
		spawndialog error "Please install wget via your system's package manager."
		exit 127
	fi
}

depcheck

if [[ -e $HOME/.local/share/icons/hicolor/512x512/apps/roblox.png ]]; then
	export RBXICON=$HOME/.local/share/icons/hicolor/512x512/apps/roblox.png
else
	download http://img1.wikia.nocookie.net/__cb20130302012343/robloxhelp/images/f/fb/ROBLOX_Circle_Logo.png $HOME/.local/share/icons/hicolor/512x512/apps/roblox.png
	export RBXICON=$HOME/.local/share/icons/hicolor/512x512/apps/roblox.png
fi

if [[ ! -e $HOME/.rlw/rlw.sh ]]; then
	download https://raw.githubusercontent.com/alfonsojon/roblox-linux-wrapper/master/rlw.sh $HOME/.rlw/rlw.sh
	cp $HOME/.rlw/rlw.sh $HOME/.rlw/rlw.sh.update
fi

download https://raw.githubusercontent.com/alfonsojon/roblox-linux-wrapper/master/rlw.sh $HOME/.rlw/rlw.sh.update

if [[ `shasum $HOME/.rlw/rlw.sh.update | cut -d' ' -f1` != `cat $HOME/.rlw/update.ignored | cut -d' ' -f1` ]]; then
	rm -rf $HOME/.rlw/update.ignored
fi

if [[ `shasum $HOME/.rlw/rlw.sh | cut -d' ' -f1` != `shasum $HOME/.rlw/rlw.sh.update | cut -d' ' -f1` ]]; then
	if [[ ! -e $HOME/.rlw/update.ignored ]]; then
		if [[ `cat $HOME/.rlw/update.ignored | cut -d' ' -f1` != `shasum $HOME/.rlw/rlw.sh.update` ]]; then
			spawndialog question "An update to Roblox Linux Wrapper is available.\nWould you like to update?"
			if [[ $? != "0" ]]; then
				shasum $HOME/.rlw/rlw.sh.update > $HOME/.rlw/update.ignored
			else
				rm -rf $HOME/.rlw/rlw.sh
				cp	$HOME/.rlw/rlw.sh.update $HOME/.rlw/rlw.sh
			fi
		fi
	fi
fi

echo 'Loading rlw.sh ...'
echo ''
chmod +x $HOME/.rlw/rlw.sh
$HOME/.rlw/rlw.sh
