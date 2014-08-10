# Roblox Linux Wrapper

## Information
This script is not created nor supported officially by Roblox. It is unofficial and may be unstable. Use at your own risk.

#### Usage
To install Roblox on your Linux computer, download rlw.sh, mark it as executable, and run it. The script will automatically generate a wine prefix with Roblox installed, along with the Microsoft Windows build of Mozilla Firefox for launching games. If you would like to install the Roblox Linux Wrapper to your system, select the install option and it will place the launcher in your system's application menu. Once installed, the launcher will automatically update whenever an update is available, so this is a highly recommended option.

#### Questions and Answers
Q: How does it work?
A: Roblox Linux Wrapper is a shell script which installs the Microsoft Windows versions of Roblox and Mozilla Firefox within a folder that Wine generated. (see winehq.org for more info). After Roblox has been set up, it allows you to play Roblox by loading Mozilla Firefox in Wine, then launching the Windows version of Roblox.

Diagram: Roblox Linux Wrapper > Wine > Firefox.exe > RobloxPlayer.exe

Q: How can I install this?
A: See the usage section.

Q: It opens in a text editor, what do I do?
A: Run it in a terminal by dragging it in and hit enter.

Q: It says "permission denied", what do I do?
A: Make sure to mark it as executable (open terminal, type "chmod +x ", drag in rlw.sh, hit enter

Q: It tells me there is a syntax error.
A: Download it again and retry. If the same thing occurs again, [open a new issue here][1].

Q: Roblox isn't behaving like it should.
A: Select the "Reset Roblox to defaults" option and press Ok.

Q: What is the "Play Roblox (Legacy Mode)" option?
A: This is the old method used to launch games. Paste the game link in and click "Play" to launch the game.


## Dependencies
	rlw.sh: shasum wget wine zenity
	rlw-stub.sh: wget shasum zenity
    
  [1]: https://github.com/alfonsojon/roblox-linux-wrapper/issues

### Spare change?
If you like my work, feel free to buy me a coffee.
[![PayPal - The safer, easier way to pay online!](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=4LPXB3QJWVFQ6)
