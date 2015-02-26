# Roblox Linux Wrapper

## Information
This script is not created nor supported officially by Roblox. It is unofficial and may be unstable. Use at your own risk.

#### Usage

To install Roblox on your Linux computer, run the command `bash <(wget -q https://raw.githubusercontent.com/alfonsojon/roblox-linux-wrapper/master/rlw.sh -O -)` in a terminal. The script will automatically generate a wine prefix with Roblox installed, along with the Microsoft Windows build of Mozilla Firefox for launching games.

#### Questions and Answers

* Q: How do I install this?
  * A: See the usage section.

* Q: My graphics aren't working, the game is white/black!
  * A: This is a Wine bug with your graphics card. Make sure you have your drivers installed, or try to upgrade your graphics card.

* Q: It tells me there is a syntax error, or I'm having another problem.
  * A: Download it again and retry. If the same thing occurs again, [open a new issue here][1]. If you report a bug, please be as informative as possible.

* Q: Roblox isn't behaving like it should.
  * A: Select the "Reset Roblox to defaults" option and press Ok. If you contuinue having problems, [file a bug report here][1].

* Q: What is the "Play Roblox (Legacy Mode)" option?
  * A: This is the old method used to launch games. Paste the game link in and click "Play" to launch the game.

* Q: Help, it's telling me "Missing dependencies"! What do I do?
  * A: If it says you are missing a dependency, then you need to install it. See the dependency section below and verify you have it all installed.


## Dependencies

    rlw.sh: cabextract git shasum wget wine wine-staging zenity
    rlw-stub.sh: wget shasum zenity
    
  [1]: https://github.com/alfonsojon/roblox-linux-wrapper/issues

### Spare change?
If you like my work, feel free to buy me a coffee.
[![PayPal - The safer, easier way to pay online!](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=4LPXB3QJWVFQ6)

