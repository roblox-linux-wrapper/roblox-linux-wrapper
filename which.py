# -*- coding: utf-8 -*-
"""
Project: roblox-linux-wrapper
File: which
Author: Ian
Creation Date: 11/29/2014
"""
from __future__ import print_function

__author__ = 'Ian'

import os


def which(program):
    """
    Functions similar to the which command on linux

    :param program: path or file name
    """

    def is_exe(ffpath):
        """
        Checks if exe?

        :param ffpath: path
        """
        return os.path.isfile(ffpath) and os.access(ffpath, os.X_OK)

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
