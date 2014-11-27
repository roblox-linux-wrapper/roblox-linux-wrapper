# -*- coding: utf-8 -*-
"""
Project: roblox-linux-wrapper
File: RLW
Author: Ian
Creation Date: 11/27/2014
"""
__author__ = 'Ian'
import os
import subprocess

import wget


"""
winePath = None
for directory in os.get_exec_path():
    testWinePath = os.path.join(directory, "wine")
    if os.path.exists(testWinePath) and os.access(testWinePath, os.R_OK | os.X_OK):
        winePath = testWinePath
        break

print(winePath)
"""


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
WINEPREFIX = "$HOME/.local/share/wineprefixes/Roblox"
WINETRICKSDEV = "/tmp/winetricks"
WINEARCH = "win32"
WINEDLLOVERRIDES = "winebrowser.exe,winemenubuilder.exe="

print('Roblox Linux Wrapper v' + RLWVERSION + '-' + RLWCHANNEL)
print("Required dependencies are going to be installed. \n\nDepending on your internet connection, this may take a few minutes.")

wget.download("http://roblox.com/install/setup.ashx", out="/tmp/RobloxPlayerLauncher.exe")
wget.download("http://winetricks.googlecode.com/svn/trunk/src/winetricks", out="/tmp/winetricks")

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

# from glob import glob
# paths = glob('set01/*/*.png')

# ROBLOXPROXY = subprocess.call(["find", ])
