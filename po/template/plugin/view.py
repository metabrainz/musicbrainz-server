#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

from template.plugin import Plugin
from template.view import View as ViewClass


"""
template.plugin.view - Plugin to create views (template.view)

SYNOPSIS

    [% USE view
	    prefix = 'splash/'		# template prefix/suffix
	    suffix = '.tt2'
	    bgcol  = '#ffffff'		# and any other variables you
	    style  = 'Fancy HTML'       # care to define as view metadata,
	    items  = [ foo, bar.baz ]	# including complex data and
	    foo    = bar ? baz : x.y.z  # expressions
    %]

    [% view.title %]			# access view metadata

    [% view.header(title = 'Foo!') %]	# view "methods" process blocks or
    [% view.footer %]			# templates with prefix/suffix added

DESCRIPTION

This plugin module creates template.view.View objects.  Views are an
experimental feature and are subject to change in the near future.  In
the mean time, please consult template.view for further info.
"""


class View(Plugin):
  """A user-definable view based on templates.  Similar to the concept of
  a "Skin".
  """
  @classmethod
  def load(cls, context=None):
    return cls.factory

  @classmethod
  def factory(cls, context, *args):
    view = ViewClass(context, *args)
    view.seal()
    return view
