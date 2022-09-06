## Information
This script is neither created nor officially supported by Roblox. It is unofficial and may be unstable. Use at your own risk. To install wine, please [see the official WineHQ documentation](https://www.winehq.org/download/) on how to install the appropriate version of Wine for your system. This program does not install Wine for you.


## Reporting Issues
If you plan on reporting issues, please read [CONTRIBUTING.md](https://github.com/roblox-linux-wrapper/roblox-linux-wrapper/blob/master/CONTRIBUTING.md) before doing so. Thanks!

## Installation

### Prerequisites

You should have Wine installed already. Install the appropriate version of `wine` from [this page](https://wiki.winehq.org/Download). I recommend wine-staging as it has the latest fixes and highest probability of working. Also make sure to install `git` for ease of installation.

### source (via `git clone`)

To install Roblox on your Linux computer from Git source, run the following commands in a terminal:
```shell
git clone https://github.com/roblox-linux-wrapper/roblox-linux-wrapper.git
roblox-linux-wrapper/rlw
```

If you are saavy enough, you can also clone to a custom directory of your choice.

## Updates

Roblox Linux Wrapper is very volatile, and updates are released very often, so please check for updates frequently.

### from Git source
* Open a terminal, change to the directory you installed.
* Run `git pull` inside the terminal while in that directory.

## Diagnosing the game
Often times, a Roblox update breaks compatibility with the Roblox Linux Wrapper. Many of these changes will require an update to wine, which may come out months after the issue is introduced. In order to circumvent this issue, the wrapper now allows you to choose either wine or wine-staging, to allow you to use the release of wine that works best for you. It will ask you upon launching, and there is also an option labelled "Select Wine Release" in the launcher.
* If wine works fine, keep using wine.
* If wine-staging works, keep using it. Do note that wine-staging is pre-release software - you may encounter issues.

## Questions and Answers

* Q: How do I install this?
  * A: See the Installation section.

* Q: It tells me there is a syntax error, or I'm having another problem.
  * A: Download the script again and retry. If the same thing occurs, [open a new issue here](https://github.com/roblox-linux-wrapper/roblox-linux-wrapper/issues).

* Q: Roblox isn't behaving like it should.
  * A: Select the "Reinstall Roblox" option and press "Ok". If you continue having problems, [file a bug report here](https://github.com/roblox-linux-wrapper/roblox-linux-wrapper/issues).

* Q: What is the "Play Roblox (Legacy Mode)" option?
  * A: This is the old method used to launch games. Paste the game link in and click "Play" to launch the game.

* Q: It keeps telling me "Missing Dependencies"!
  * A: Then install it! If it tells you "Please install wine", then install Wine. It does not install these dependencies automatically. To install the latest version of Wine, visit https://www.winehq.org/download/.


## Required Dependencies

* git
* wget
* wine or wine-staging (whichever works best for you)
* zenity

## Licensing and copyright
Roblox Linux Wrapper is licensed under thE GPL v3 license. Please see LICENSE for details.


#### Affiliation Disclaimer
The red Roblox "R" symbol is property and copyright of 2006-2015 Roblox Corporation. We do not claim any ownership, nor affiliation with Roblox, nor its staff or software. No changes to the core Roblox software are made in this program. No proprietary files are bundled in this software.

## Spare change?
If you like my work, you can show your support with donations :)

[![PayPal - The safer, easier way to pay online!](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=4LPXB3QJWVFQ6)
