# -*- coding: utf-8 -*-
#!/usr/bin/python
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
import errno
import subprocess
from which import which
from Errors import NoWine, Unsupported, DownloadError

import requests

WINE = which("wine")
WINESERVER = which("wineserver")
# Uncomment these lines to use Wine Compholio
# WINE = "/opt/wine-compholio/bin/wine"
# WINESERVERBIN = "/opt/wine-compholio/wineserver"

RLWVERSION = __version__
RLWCHANNEL = "PRERELEASE"
WINEPREFIX = os.getenv("HOME") + "/.local/share/wineprefixes/Roblox"
WINEARCH = "win32"
WINETRICKSDEV = "/tmp/winetricks"
WINEDLLOVERRIDES = "winebrowser.exe,winemenubuilder.exe="


def srm(filename):
    """
    Silently Remove a file

    :param filename: File to remove
    """
    try:
        os.remove(filename)
    except OSError as e:
        if e.errno != errno.ENOENT:
            raise


def wget(file, out):
    """
    Download a file

    :param file: File to download
    :param out: Output Location
    """
    r = requests.get(file, stream=True)

    if not r.ok:
        raise DownloadError

    size = int(r.headers['Content-Length'].strip())

    with open(out, 'wb') as fd:
        for chunk in r.iter_content(1024):
            fd.write(chunk)


def checkDeps():
    """
    Check Dependencies

    """
    if not WINE:
        raise NoWine
    if not WINESERVER:
        raise NoWine
    os.environ["WINEPREFIX"] = WINEPREFIX
    os.environ["WINEARCH"] = WINEARCH
    os.environ["WINEDLLOVERRIDES"] = WINEDLLOVERRIDES
    import platform

    if platform.system() == "Windows":
        raise Unsupported
    srm(WINETRICKSDEV)
    wget("http://winetricks.googlecode.com/svn/trunk/src/winetricks", out = "/tmp/winetricks")
    os.chmod('/tmp/winetricks', os.stat('/tmp/winetricks').st_mode | 0o0111)

    srm("/tmp/RobloxPlayerLauncher.exe")
    wget("http://roblox.com/install/setup.ashx", out = "/tmp/RobloxPlayerLauncher.exe")

    srm("/tmp/Firefox-Setup-esr.exe")
    wget(
        "http://ftp.mozilla.org/pub/mozilla.org/firefox/releases/31.1.1esr/win32/en-US/Firefox%20Setup%2031.1.1esr.exe",
        out = "/tmp/Firefox-Setup-esr.exe")


def Install():
    """
    Install RLW

    """
    global WINEPREFIX
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

    rootdir = WINEPREFIX  # rootdir = os.getenv("HOME") + "/.wine/drive_c/users/ian/"
    for dirName, subdirList, fileList in os.walk(rootdir):
        if "RobloxProxy.dll" in fileList:
            ROBLOXPROXY = dirName + "/RobloxProxy.dll"

    subprocess.call([WINE, "regsvr32",
                     "/i",
                     ROBLOXPROXY
    ])

    subprocess.call([WINE, "/tmp/Firefox-Setup-esr.exe",
                     "/SD"
    ])

    subprocess.call([WINE, WINEPREFIX + "/RobloxPlayerBeta.exe",
                     "--id 10393493"])


def main():
    """
    Main Program for RLW

    """
    print('Roblox Linux Wrapper v' + RLWVERSION + '-' + RLWCHANNEL)
    print(
        "Required dependencies are going to be installed. \n\nDepending on your internet connection, this may take a few minutes.\n")
    checkDeps()
    Install()
