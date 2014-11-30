# -*- coding: utf-8 -*-
"""
Project: roblox-linux-wrapper
File: RLW
Author: Ian
Creation Date: 11/27/2014
"""
from __future__ import print_function

__author__ = 'Ian'
__version__ = "20141127b"
import os
import subprocess
from which import which
from Errors import NoWine

import wget


def checkDep():
    """
    Check Dependencies

    """
    WINE = which("wine")
    WINESERVER = which("wineserver")
    # Uncomment these lines to use Wine Compholio
    # WINE = "/opt/wine-compholio/bin/wine"
    # WINESERVERBIN = "/opt/wine-compholio/wineserver"
    if not WINE:
        raise NoWine
    RLWVERSION = __version__
    RLWCHANNEL = "PRERELEASE"
    WINEPREFIX = os.getenv("HOME") + "/.local/share/wineprefixes/Roblox"
    WINEARCH = "win32"
    WINETRICKSDEV = "/tmp/winetricks"
    WINEDLLOVERRIDES = "winebrowser.exe,winemenubuilder.exe="


def main():
    print('Roblox Linux Wrapper v' + RLWVERSION + '-' + RLWCHANNEL)
    print(
        "Required dependencies are going to be installed. \n\nDepending on your internet connection, this may take a few minutes.\n")

try:
    wget.download("http://roblox.com/install/setup.ashx", out = "/tmp/RobloxPlayerLauncher.exe")
    print("\n")
except ValueError:
    pass
try:
    wget.download("http://winetricks.googlecode.com/svn/trunk/src/winetricks", out = "/tmp/winetricks")
    print("\n")
except ValueError:
    pass

os.chmod('/tmp/winetricks', os.stat('/tmp/winetricks').st_mode | 0o0111)

subprocess.call(["/tmp/winetricks",
                 "-q",
                 "ddr=gdi",
                 "vcrun2008",
                 "mshtml",
                 "mshttp",
                 "vcrun2012",
                 "vcrun2013",
                 "winhttp",
                 "wininet",
])

subprocess.call([WINE, "/tmp/RobloxPlayerLauncher.exe"])

rootdir = os.getenv("HOME") + "/.wine/drive_c/users/ian/"

for dirName, subdirList, fileList in os.walk(rootdir):
    if "RobloxProxy.dll" in fileList:
        ROBLOXPROXY = dirName + "/RobloxProxy.dll"
        WINEPREFIX = dirName

subprocess.call([WINE, "regsvr32",
                 "/i",
                 ROBLOXPROXY
])

try:
    wget.download(
        "http://ftp.mozilla.org/pub/mozilla.org/firefox/releases/31.1.1esr/win32/en-US/Firefox%20Setup%2031.1.1esr.exe",
        out = "/tmp/Firefox-Setup-esr.exe")
    print("\n")
except ValueError:
    pass

subprocess.call([WINE, "/tmp/Firefox-Setup-esr.exe",
                 "/SD"
])

subprocess.call([WINE, WINEPREFIX + "/RobloxPlayerBeta.exe",
                 "--id 10393493"])
