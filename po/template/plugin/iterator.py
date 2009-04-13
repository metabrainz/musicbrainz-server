#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

from template.iterator import Iterator as WrappedIterator
from template.plugin import Plugin

"""
template.plugin.iterator - Plugin to create iterators
(template.iterator.Iterator)


SYNOPSIS

    [% USE iterator(list, args) %]

    [% FOREACH item = iterator %]
       [% '<ul>' IF iterator.first %]
       <li>[% item %]
       [% '</ul>' IF iterator.last %]
    [% END %]


DESCRIPTION

The iterator plugin provides a way to create a
template.iterator.Iterator object to iterate over a data set.  An
iterator is implicitly automatically by the FOREACH directive.  This
plugin allows the iterator to be explicitly created with a given name.

"""

class Iterator(Plugin):
  """Plugin to create a template.iterator.Iterator from a list of
  items and optional configuration parameters.
  """
  @classmethod
  def load(cls, context=None):
    return cls.factory

  @classmethod
  def factory(cls, context, *args):
    return WrappedIterator(*args)
