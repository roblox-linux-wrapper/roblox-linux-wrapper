# -*- coding: utf-8 -*-
# !/usr/bin/python
"""
Project: roblox-linux-wrapper
File: RLW
Author: Ian
Creation Date: 11/27/2014
"""
from __future__ import print_function
import os
import errno
import subprocess
import sys
import time
import platform
import shutil

import requests

from which import which
from Errors import NoWine, Unsupported, DownloadError, FatalError, OutdatedPython


if platform.system() == "Windows":
    raise Unsupported

if sys.version_info < (3, 0):
    # noinspection PyShadowingBuiltins
    raw_input = input

if not (sys.version_info >= (2, 7)):
    raise OutdatedPython

if (2, 7) <= sys.version_info <= (3, 0):
    pass

__author__ = 'Ian'
__version__ = "20141127b"

WINE = which("wine")
WINESERVER = which("wineserver")
# Uncomment these lines to use Wine Compholio
# WINE = "/opt/wine-compholio/bin/wine"
# WINESERVER = "/opt/wine-compholio/wineserver"

RLWVERSION = __version__
RLWCHANNEL = "PRERELEASE"
WINEPREFIX = os.getenv("HOME") + "/.local/share/wineprefixes/Roblox"
WINEARCH = "win32"
WINETRICKSDEV = "/tmp/winetricks"
WINEDLLOVERRIDES = "winebrowser.exe,winemenubuilder.exe="


def callWine(*args):
    """
    Simplify Calling Wine

    :param args: Arguments
    """
    arg = [WINE]
    for a in args:
        arg.append(a)
    with open(os.devnull, "w") as fnull:
        subprocess.call(arg, stdout = fnull, stderr = fnull)


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


# noinspection PyUnresolvedReferences,PyShadowingBuiltins
def wget(file, out):
    """
    Download a file

    :param file: File to download
    :param out: Output Location
    """
    r = requests.get(file, stream = True)

    if not r.ok:
        raise DownloadError

    with open(out, 'wb') as fd:
        start = time.clock()
        total_length = int(r.headers.get('content-length'))
        dl = 0
        if total_length is None:
            fd.write(r.content)
        else:
            for chunk in r.iter_content(1024):
                dl += len(chunk)
                fd.write(chunk)
                done = int((50 * dl) / total_length)
                sys.stdout.write(
                    "\r[%s%s] %s / %s" % ('=' * done, ' ' * (50 - done), (dl // 1024), (total_length // 1024)))
                sys.stdout.flush()
    print("\n")
    print(time.clock() - start)


def checkDeps(Force = False):
    """
    Check Dependencies

    :param Force: Whether to force Dependency download
    """
    print(
        "Required dependencies are going to be installed. \n\nDepending on your internet connection, this may take a few minutes.\n")
    if not WINE:
        raise NoWine
    if not WINESERVER:
        raise NoWine
    os.environ["WINEPREFIX"] = WINEPREFIX
    os.environ["WINEARCH"] = WINEARCH
    os.environ["WINEDLLOVERRIDES"] = WINEDLLOVERRIDES
    os.environ["WINE"] = WINE
    os.environ["WINESERVERBIN"] = WINESERVER
    os.environ["WINETRICKSDEV"] = WINETRICKSDEV

    if os.path.isfile(WINETRICKSDEV) and os.path.isfile("/tmp/RobloxPlayerLauncher.exe") and \
            os.path.isfile("/tmp/Firefox-Setup-esr.exe") and not Force:
        return

    srm(WINETRICKSDEV)
    wget("http://winetricks.googlecode.com/svn/trunk/src/winetricks", out = "/tmp/winetricks")
    os.chmod('/tmp/winetricks', os.stat('/tmp/winetricks').st_mode | 0o0111)

    srm("/tmp/RobloxPlayerLauncher.exe")
    wget("http://roblox.com/install/setup.ashx", out = "/tmp/RobloxPlayerLauncher.exe")

    srm("/tmp/Firefox-Setup-esr.exe")
    wget(
        "http://ftp.mozilla.org/pub/mozilla.org/firefox/releases/31.1.1esr/win32/en-US/Firefox%20Setup%2031.1.1esr.exe",
        out = "/tmp/Firefox-Setup-esr.exe")

    Install()


def Install():
    """
    Install RLW

    """
    with open(os.devnull, "w") as fnull:
        subprocess.call(["/tmp/winetricks",
                         "-q",
                         "ddr=gdi",
                         "vcrun2008",
                         # "mshtml",
                         # "mshttp",
                         "vcrun2012",
                         "vcrun2013",
                         "winhttp",
                         "wininet",
                         "wmp9",
                        ], stdout = fnull, stderr = fnull)

        callWine("/tmp/RobloxPlayerLauncher.exe")

        ROBLOXPROXY = None

        rootdir = WINEPREFIX
        for dirName, subdirList, fileList in os.walk(rootdir):
            if "RobloxProxy.dll" in fileList:
                ROBLOXPROXY = dirName + "/RobloxProxy.dll"

        if ROBLOXPROXY is None:
            raise FatalError

        callWine("regsvr32", "/i", ROBLOXPROXY)

        callWine("/tmp/Firefox-Setup-esr.exe", "/SD")


def main():
    """
    Main Program for RLW

    """
    print('Roblox Linux Wrapper v' + RLWVERSION + '-' + RLWCHANNEL)
    installed = os.path.isdir(os.getenv("HOME") + "/.rlw")
    # choice = getnum(choices=7)
    print("""
          1. Play Roblox
          2. Play Roblox (Legacy)
          3. Roblox Studio
          4. {0}
          5. Reset Roblox to defaults
          6. Uninstall Roblox
          7. Exit""".format(installed and "Uninstall Roblox Linux Wrapper" or "Install Roblox Linux Wrapper (Recommended)")
    )
    choice = raw_input("> ")
    if choice == 1:
        callWine("C:\Program Files\Mozilla Firefox\\firefox.exe", "http://www.roblox.com/Games.aspx")
    if choice == 2:
        PLAYER = None
        for dirName, subdirList, fileList in os.walk(WINEPREFIX):
            if "RobloxPlayerBeta.exe" in fileList:
                PLAYER = dirName + "/RobloxPlayerBeta.exe"
        x = raw_input("GameID: ")
        callWine(PLAYER, "--id", str(x))
    if choice == 3:
        for dirName, subdirList, fileList in os.walk(WINEPREFIX):
            if "RobloxStudioLauncherBeta.exe" in fileList:
                callWine(dirName + "/RobloxStudioLauncherBeta.exe", "-ide")
                subprocess.call([WINESERVER, "-k"])
        for dirName, subdirList, fileList in os.walk(WINEPREFIX):
            if "RobloxStudioBeta.exe" in fileList:
                callWine(dirName + "/RobloxStudioBeta.exe")
    if choice == 4 and not installed:
        di = os.getenv("HOME") + "/.local/share/applications/"
        with open(di + "Roblox.desktop", "w") as f:
            f.write("""
            [Desktop Entry]
            Comment=Play Roblox
            Name=Roblox Linux Wrapper
            Exec=$HOME/.rlw/RLW.py
            Actions=RFAGroup;ROLWiki;
            GenericName=Building Game
            Icon=roblox
            Categories=Game;
            Type=Application

            [Desktop Action ROLWiki]
            Name='Roblox on Linux Wiki'
            Exec=xdg-open 'http://roblox.wikia.com/wiki/Roblox_On_Linux'

            [Desktop Action RFAGroup]
            Name='Roblox for All'
            Exec=xdg-open 'http://www.roblox.com/Groups/group.aspx?gid=292611'""")
            f.close()
        try:
            os.mkdir(os.getenv("HOME") + "/.rlw")
        except OSError as e:
            if e.errno == 17:
                pass
        # TODO: Download link to latest version of this python script, once uploaded.
        wget("http://img1.wikia.nocookie.net/__cb20130302012343/robloxhelp/images/f/fb/ROBLOX_Circle_Logo.png",
             out = os.getenv("HOME") + "/.local/share/icons/roblox.png")
        os.chmod(os.getenv("HOME") + "/.rlw", os.stat(os.getenv("HOME") + "/.rlw").st_mode | 0o0111)
        os.chmod(os.getenv("HOME") + "/.local/share/applications/Roblox.desktop",
                 os.stat(os.getenv("HOME") + "/.local/share/applications/Roblox.desktop").st_mode | 0o0111)
        subprocess.call(["xdg-desktop-menu",
                         "install",
                         "--novendor",
                         os.getenv("HOME") + "/.local/share/applications/Roblox.desktop"
        ])
        subprocess.call(["xdg-desktop-menu", "forceupdate"])
    if choice == 4 and installed:
        subprocess.call(["xdg-desktop-menu",
                         "uninstall",
                         os.getenv("HOME") + "/.local/share/applications/Roblox.desktop"
                         ])
        shutil.rmtree(os.getenv("HOME") + "/.rlw")
        os.remove(os.getenv("HOME") + "/.local/share/icons/roblox.png")
        subprocess.call(["xdg-desktop-menu", "forceupdate"])
    if choice == 5:
        shutil.rmtree(WINEPREFIX)
        checkDeps(Force=True)
        main()
    if choice == 6:
        subprocess.call([WINESERVER, "-k"])
        shutil.rmtree(WINEPREFIX)
    if choice == 7:
        sys.exit()


checkDeps()
main()
