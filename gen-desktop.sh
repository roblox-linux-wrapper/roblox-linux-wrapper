#!/bin/bash

# This script generates a .desktop file based on the current path of the wrapper
WRAPPER_DIR=$(pwd)

printf '[Desktop Entry]
Comment=Play Roblox
Name=Roblox Linux Wrapper
Exec=%s/rlw.sh
Actions=Support;RFAGroup;
GenericName=Building Game
Icon=%s/roblox.png
Categories=Game;
Type=Application

[Desktop Action Support]
Name=GitHub Support Ticket
Exec=xdg-open "https://github.com/alfonsojon/roblox-linux-wrapper/issues/new"

[Desktop Action RFAGroup]
Name=Roblox for All
Exec=xdg-open "http://www.roblox.com/Groups/group.aspx?gid=292611"
' "$WRAPPER_DIR" "$WRAPPER_DIR" | tee roblox.desktop

echo 'Finished. You can now install this desktop file via the command: xdg-desktop-menu install --novendor --mode user roblox.desktop'
