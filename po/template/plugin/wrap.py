#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

import re
import textwrap

from template.plugin import Plugin


"""
template.plugin.wrap - Plugin interface to Text::Wrap


SYNOPSIS

    [% USE wrap %]

    # call wrap subroutine
    [% wrap(mytext, width, initial_tab,  subsequent_tab) %]

    # or use wrap FILTER
    [% mytext FILTER wrap(width, initital_tab, subsequent_tab) %]


DESCRIPTION

This plugin provides an interface to the textwrap module which
provides simple paragraph formatting.

It defines a 'wrap' subroutine which can be called, passing the input
text and further optional parameters to specify the page width (default:
72), and tab characters for the first and subsequent lines (no defaults).

    [% USE wrap %]

    [% text = BLOCK %]
    First, attach the transmutex multiplier to the cross-wired
    quantum homogeniser.
    [% END %]

    [% wrap(text, 40, '* ', '  ') %]

Output:

    * First, attach the transmutex
      multiplier to the cross-wired quantum
      homogeniser.

It also registers a 'wrap' filter which accepts the same three
optional arguments but takes the input text directly via the filter
input.

    [% FILTER bullet = wrap(40, '* ', '  ') -%]
    First, attach the transmutex multiplier to the cross-wired quantum
    homogeniser.
    [%- END %]

    [% FILTER bullet -%]
    Then remodulate the shield to match the harmonic frequency, taking
    care to correct the phase difference.
    [% END %]

Output:

    * First, attach the transmutex
      multiplier to the cross-wired quantum
      homogeniser.

    * Then remodulate the shield to match
      the harmonic frequency, taking
      care to correct the phase difference.

"""


class Wrap(Plugin):
  """Plugin for wrapping text via the textwrap module."""
  @classmethod
  def load(cls, context=None):
    return cls.factory

  @classmethod
  def factory(cls, context):
    context.define_filter('wrap', wrap_filter_factory, True)
    return tt_wrap


def tt_wrap(text, width=72, itab="", ntab=""):
  return textwrap.fill(
    text, width, initial_indent=itab, subsequent_indent=ntab,
    replace_whitespace=True)


def wrap_filter_factory(context, *args):
  def wrap_filter(text):
    return tt_wrap(text, *args)
  return wrap_filter
