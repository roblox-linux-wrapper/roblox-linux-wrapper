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
        return "Wine needs to be installed to run this program"


raise NoWine
