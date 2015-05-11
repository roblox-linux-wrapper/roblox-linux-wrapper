## Information
This script is neither created nor officially supported by Roblox. It is unofficial and may be unstable. Use at your own risk.

## Reporting Issues
If you plan on reporting issues, please read [reporting-issues.md](https://github.com/alfonsojon/roblox-linux-wrapper/blob/master/reporting-issues.md) before doing so. Thanks!

## Installation

### .deb (Debian/Ubuntu)

We provide `.deb` binaries for Debian / Ubuntu users on the [releases page](https://github.com/alfonsojon/roblox-linux-wrapper/releases).
A personal package archive (PPA) will be available shortly.

### .rpm (Fedora/SUSE)
`.rpm` packages will be available shortly.

### source (via `git clone`)

To install Roblox on your Linux computer from source, run the following commands in a terminal:
```
git clone https://github.com/alfonsojon/roblox-linux-wrapper.git
cd roblox-linux-wrapper
./rlw
```
If you are saavy enough, you can also clone to a custom directory of your choice.

#### Updates

Roblox Linux Wrapper is very volatile, and updates are released very often, so please check for updates frequently.

##### `.deb` & `.rpm`
* Note the version you have installed
* If the version present here is newer, download it and install it via your package manager's GUI.
* If you have enabled an RPM repository or Personal Package Archive (PPA), updates to the wrapper will come with system updates automatically.

##### from source
* Open a terminal, change to the directory you installed
* Run `git pull` inside the terminal while in that directory


## Questions and Answers

* Q: How do I install this?
  * A: See the usage section.

* Q: It tells me there is a syntax error, or I'm having another problem.
  * A: Download it again and retry. If the same thing occurs again, [open a new issue here][1]. If you report a bug, please be as informative as possible.

* Q: Roblox isn't behaving like it should.
  * A: Select the "Reinstall Roblox" option and press "Ok". If you continue having problems, [file a bug report here](https://github.com/alfonsojon/roblox-linux-wrapper/issues).

* Q: What is the "Play Roblox (Legacy Mode)" option?
  * A: This is the old method used to launch games. Paste the game link in and click "Play" to launch the game.

* Q: It keeps telling me "Missing Dependencies"!
  * A: Then install it! If it tells you "Please install wine", then install Wine. It does not install these dependencies automatically. You need to install the dependencies manually. To install the latest version of Wine, visit https://www.winehq.org/download/.


## Required Dependencies

    rlw: git wget wine zenity

## Licensing and copyright

    > GNU GPL v3 Notice
    
    Copyright 2015 Jonathan Alfonso <alfonsojon1997@gmail.com>
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    
    > Copyright Information
    
    The red Roblox "R" symbol is property and copyright of 2006-2015 Roblox
    Corporation. I do not claim any ownership, nor affiliation with Roblox,
    nor its staff or software. No changes to the core Roblox software are
    made in this program. No proprietary files are bundled in this software.

## Spare change?
If you like my work, you can show your support with donations :)

[![PayPal - The safer, easier way to pay online!](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=4LPXB3QJWVFQ6)
