## Getting Issues Fixed
As you probably know, Roblox was never intended to run on Linux; it is a Windows-based game. Through the Wine project and the Roblox Linux Wrapper script, the game works on a limited basis, given that many issues come and go. Often, issues can be fixed via workarounds or using a different version of wine, so if you are saavy enough, try to play with it a bit. if you can somehow find a workaround, post it! 

Note: if the fix is available through winetricks, try to find the actual workaround applied by winetricks. I am trying to remove winetricks as a dependency, so this is a necessary evil.

#### Duplicate bugs
Currently, the game is experiencing issues. As a result, we have been getting bug reports along the lines of "help game is not working!!!11!" and "Here is a detailed hex dump of the game crashing", without many realizing that the issue has already been reported. If you are having an issue, please check the issue list to see if the issue has already been reported. If it has, do not reply "me too" or "fix please", as that does not help us fix it. If you are willing to test or aid in development, feel free to chime in. Any help is welcomed!

### Information needed in a bug report

In order to even have a chance of fixing issues, we need to know what's causing the problem. **Please include the following in any issues you open, it will be closed as lacking information!**

#### Wine Version

Wine is very dynamic, volatile code - hefty changes are made almost every version. Roblox Linux Wrapper currently requires the 1.7 (development) branch of Wine, as the stable (1.6) branch is simply too old for the game to run. When posting issues on the issue tracker, please tell us what Wine version you are using. You can often find the latest version for your distro here: https://www.winehq.org/download

#### OS Version
Same with the above. Knowing the OS distro + version can help us eliminate system-specific bugs and give the best possible support.

#### Graphics card model and driver used
Roblox requires 3D graphics to run. Implementations vary between different graphics card models, and can be the deciding point for whether your game runs or not.

#### Posting Error Logs
As for posting error logs - if you have a very large error log you wish to post, please submit the error log in a pastebin such as GitHub's [Gist](https://gist.github.com/), and paste a link to it in your issue. This prevents long logs from clogging up the issue tracker comments.

### Issue Hijacking
If you are having a problem, please do not comment on another thread unless you are fairly confident that the issue you are having is the issue mentioned in the original bug report. While we do understand mistakes may be made, it helps us greatly to have issues maintained in separate issue threads, so that we can manage each individual issue easily. For example, if an issue states "Game crashes five seconds into game", do not comment saying "My computer restarts when I play Roblox!!!", as this does not help us fix it. Additionally, old issues that are closed can be reopened in the event that it resurfaces. If you find that an issue is closed, please do not post to it unless the issue you are having is identical to the reported issue. Help us help you by making our jobs easier! :)

Thank you for your cooperation!
