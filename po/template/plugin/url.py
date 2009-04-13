#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

import re

from template.plugin import Plugin
from template import util

"""
template.plugin.url - Plugin to construct complex URLs


SYNOPSIS

    [% USE url('/cgi-bin/foo.pl') %]

    [% url(debug = 1, id = 123) %]
       # ==> /cgi/bin/foo.pl?debug=1&amp;id=123


    [% USE mycgi = url('/cgi-bin/bar.pl', mode='browse', debug=1) %]

    [% mycgi %]
       # ==> /cgi/bin/bar.pl?mode=browse&amp;debug=1

    [% mycgi(mode='submit') %]
       # ==> /cgi/bin/bar.pl?mode=submit&amp;debug=1

    [% mycgi(debug='d2 p0', id='D4-2k[4]') %]
       # ==> /cgi-bin/bar.pl?mode=browse&amp;debug=d2%20p0&amp;id=D4-2k%5B4%5D


DESCRIPTION

The URL plugin can be used to construct complex URLs from a base stem
and a dictionary of additional query parameters.

The constructor should be passed a base URL and optionally, a
dictionary of default parameters and values.  Used from with a
Template Documents, this would look something like the following:

    [% USE url('http://www.somewhere.com/cgi-bin/foo.pl') %]
    [% USE url('/cgi-bin/bar.pl', mode='browse') %]
    [% USE url('/cgi-bin/baz.pl', mode='browse', debug=1) %]

When the plugin is then called without any arguments, the default base
and parameters are returned as a formatted query string.

    [% url %]

For the above three examples, these will produce the following outputs:

    http://www.somewhere.com/cgi-bin/foo.pl
    /cgi-bin/bar.pl?mode=browse
    /cgi-bin/baz.pl?mode=browse&amp;debug=1

Note that additional parameters are seperated by '&amp;' rather than
simply '&'.  This is the correct behaviour for HTML pages but is,
unfortunately, incorrect when creating URLs that do not need to be
encoded safely for HTML.  This is likely to be corrected in a future
version of the plugin (most probably with TT3).  In the mean time, you
can set the module global variable JOINT to '&' to get the correct
behaviour.

Additional parameters may be also be specified to the URL:

    [% url(mode='submit', id='wiz') %]

Which, for the same three examples, produces:

    http://www.somewhere.com/cgi-bin/foo.pl?mode=submit&amp;id=wiz
    /cgi-bin/bar.pl?mode=browse&amp;id=wiz
    /cgi-bin/baz.pl?mode=browse&amp;debug=1&amp;id=wiz

A new base URL may also be specified as the first option:

    [% url('/cgi-bin/waz.pl', test=1) %]

producing

    /cgi-bin/waz.pl?test=1
    /cgi-bin/waz.pl?mode=browse&amp;test=1
    /cgi-bin/waz.pl?mode=browse&amp;debug=1&amp;test=1

The ordering of the parameters is non-deterministic due to fact that
Python's dictionaries themselves are unordered.  This isn't a problem
as the ordering of CGI parameters is insignificant (to the best of my
knowledge).  All values will be properly escaped.

    [% USE url('/cgi-bin/woz.pl') %]
    [% url(name="Elrich von Benjy d'Weiro") %]

Here the spaces and "'" character are escaped in the output:

    /cgi-bin/woz.pl?name=Elrich%20von%20Benjy%20d%27Weiro

An alternate name may be provided for the plugin at construction time
as per regular Template Toolkit syntax.

    [% USE mycgi = url('cgi-bin/min.pl') %]

    [% mycgi(debug=1) %]

"""


JOINT = "&amp;"


class Url(Plugin):
  """Template Toolkit Plugin for constructing URL's from a base stem
  and adaptable parameters.
  """
  @classmethod
  def load(cls, context=None):
    return cls.factory

  @classmethod
  def factory(cls, context, base=None, args=None):
    def url(newbase=None, newargs=None):
      if isinstance(newbase, dict):
        newbase, newargs = None, newbase
      combo = (args or {}).copy()
      combo.update(newargs or {})
      urlargs = JOINT.join([var for key, value in combo.items()
                                for var in Args(key, value)
                                if value is not None and len(str(value)) > 0])
      query = newbase or base or ""
      if query and urlargs:
        query += "?"
      if urlargs:
        query += urlargs
      return query
    return url


def Args(key, val):
  key = escape(key)
  if not util.is_seq(val):
    val = [val]
  return ["%s=%s" % (key, escape(v)) for v in val]


def escape(toencode):
  """URL-encode data."""
  if toencode is None:
    return None
  return re.sub(r"[^a-zA-Z0-9_.-]", lambda m: "%%%02x" % ord(m.group()),
                str(toencode))


