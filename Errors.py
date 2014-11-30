# -*- coding: utf-8 -*-
"""
Project: roblox-linux-wrapper
File: Errors
Author: Ian
Creation Date: 11/29/2014
"""

__author__ = 'Ian'


class RLW_Error(BaseException):
    """
    Base Exception for RLW

    """
    pass


class NoWine(RLW_Error):
    """
    No Wine Exception.

    """
    def __str__(self):
        return "Wine needs to be installed to run this program."


class Unsupported(RLW_Error):
    """
    Unsupported Operating System

    """
    def __str__(self):
        return "Unsupported Operating System."


class DownloadError(RLW_Error):
    """
    Error Downloading Required File

    """
    def __str__(self):
        return "Error Downloading Required File."


class FatalError(RLW_Error):
    """
    Fatal Error

    """
    def __str__(self):
        return "Fatal Error"


class OutdatedPython(RLW_Error):
    """
    The version of python in use is outdated

    """
    def __str__(self):
        return "Your version of python is outdated and can not be used"
