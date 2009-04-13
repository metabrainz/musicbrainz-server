#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

from template.plugin import Plugin

"""
template.plugin.format - Plugin to create formatting functions


SYNOPSIS

    [% USE format %]
    [% commented = format('# %s') %]
    [% commented('The cat sat on the mat') %]

    [% USE bold = format('<b>%s</b>') %]
    [% bold('Hello') %]


DESCRIPTION

The format plugin constructs sub-routines which format text according to
a printf()-like format string.

"""


class Format(Plugin):
  """Simple Template Toolkit Plugin which creates formatting functions."""
  @classmethod
  def load(cls, context=None):
    return cls.factory

  @classmethod
  def factory(cls, context, format=None):
    if format is not None:
      return make_formatter(format)
    else:
      return make_formatter


def make_formatter(format="%s"):
  def formatter(*args):
    # This is a pretty hacky way to simulate Perl's permissive string
    # formatting, which doesn't insist on having exactly the number of
    # specified arguments available.  It should work all right as long
    # as only strings are to be formatted.
    while True:
      try:
        return format % args
      except TypeError, e:
        if e.args[0].startswith("not enough arguments"):
          args += ("",)
        elif e.args[0].startswith("not all arguments converted"):
          args = args[:-1]
        else:
          raise
  return formatter
