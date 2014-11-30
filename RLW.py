# -*- coding: utf-8 -*-
"""
Project: roblox-linux-wrapper
File: RLW
Author: Ian
Creation Date: 11/27/2014
"""
from __future__ import print_function
__author__ = 'Ian'
import os
import subprocess

import wget

def which(program):
    """
    Functions similar to the which command on linux

    :param program: path or file name
    """
    def is_exe(fpath):
        """
        Checks if exe?

        :param fpath: path
        """
        return os.path.isfile(fpath) and os.access(fpath, os.X_OK)

    fpath, fname = os.path.split(program)
    if fpath:
        if is_exe(program):
            return program
    else:
        for path in os.environ["PATH"].split(os.pathsep):
            path = path.strip('"')
            exe_file = os.path.join(path, program)
            if is_exe(exe_file):
                return exe_file

    return None

WINE = which("wine")
WINESERVER = which("wineserver")

print(WINE, '\n', WINESERVER)

# Uncomment these lines to use Wine Compholio
# WINE = "/opt/wine-compholio/bin/wine"
# WINESERVERBIN = "/opt/wine-compholio/wineserver"


RLWVERSION = "20141127b"
RLWCHANNEL = "PRERELEASE"
WINEPREFIX = os.getenv("HOME") + "/.local/share/wineprefixes/Roblox"

WINEARCH = "win32"

WINETRICKSDEV = "/tmp/winetricks"
WINEARCH = "win32"
WINEDLLOVERRIDES = "winebrowser.exe,winemenubuilder.exe="

print('Roblox Linux Wrapper v' + RLWVERSION + '-' + RLWCHANNEL)
print("Required dependencies are going to be installed. \n\nDepending on your internet connection, this may take a few minutes.\n")

try:
    wget.download("http://roblox.com/install/setup.ashx", out="/tmp/RobloxPlayerLauncher.exe")
    print("\n")
except ValueError:
    pass
try:
    wget.download("http://winetricks.googlecode.com/svn/trunk/src/winetricks", out="/tmp/winetricks")
    print("\n")
except ValueError:
    pass

os.chmod('/tmp/winetricks', os.stat('/tmp/winetricks').st_mode | 0o0111)

p = subprocess.call(["/tmp/winetricks",
                     "-q",
                     "ddr=gdi",
                     "vcrun2012",
                     "vcrun2013",
                     "winhttp",
                     "wininet",
                     ])

q = subprocess.call([WINE, "/tmp/RobloxPlayerLauncher.exe"])

rootdir = os.getenv("HOME") + "/.wine/drive_c/users/ian/"

for dirName, subdirList, fileList in os.walk(rootdir):
    if "RobloxProxy.dll" in fileList:
        ROBLOXPROXY = dirName + "/RobloxProxy.dll"
        WINEPREFIX = dirName

q = subprocess.call([WINE, "regsvr32",
                    "/i",
                    ROBLOXPROXY
                    ])

try:
    wget.download("http://ftp.mozilla.org/pub/mozilla.org/firefox/releases/31.1.1esr/win32/en-US/Firefox%20Setup%2031.1.1esr.exe", out = "/tmp/Firefox-Setup-esr.exe")
    print("\n")
except ValueError:
    pass

subprocess.call([WINE, "/tmp/Firefox-Setup-esr.exe",
                "/SD"
               ])

subprocess.call([WINE, WINEPREFIX + "/RobloxPlayerBeta.exe",
                "--id 10393493"])








