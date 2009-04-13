#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

import locale as Locale
import re
import time as Time

from template.plugin import Plugin
from template.util import TemplateException

"""

template.plugin.date - Plugin to generate formatted date strings


SYNOPSIS

    [% USE date %]

    # use current time and default format
    [% date.format %]

    # specify time as seconds since epoch or 'h:m:s d-m-y' string
    [% date.format(960973980) %]
    [% date.format('4:20:36 21/12/2000') %]

    # specify format
    [% date.format(mytime, '%H:%M:%S') %]

    # specify locale
    [% date.format(date.now, '%a %d %b %y', 'en_GB') %]

    # named parameters
    [% date.format(mytime, format = '%H:%M:%S') %]
    [% date.format(locale = 'en_GB') %]
    [% date.format(time   = date.now,
		   format = '%H:%M:%S',
                   locale = 'en_GB) %]

    # specify default format to plugin
    [% USE date(format = '%H:%M:%S', locale = 'de_DE') %]

    [% date.format %]
    ...


DESCRIPTION

The Date plugin provides an easy way to generate formatted time and
date strings by delegating to the POSIX strftime() routine.

The plugin can be loaded via the familiar USE directive.

    [% USE date %]

This creates a plugin object with the default name of 'date'.  An alternate
name can be specified as such:

    [% USE myname = date %]

The plugin provides the format() method which accepts a time value, a
format string and a locale name.  All of these parameters are optional
with the current system time, default format ('%H:%M:%S %d-%b-%Y') and
current locale being used respectively, if undefined.  Default values
for the time, format and/or locale may be specified as named
parameters in the USE directive.

    [% USE date(format = '%a %d-%b-%Y', locale = 'fr_FR') %]

When called without any parameters, the format() method returns a
string representing the current system time, formatted by strftime()
according to the default format and for the default locale (which may
not be the current one, if locale is set in the USE directive).

    [% date.format %]

The plugin allows a time/date to be specified as seconds since the epoch,
as is returned by time().

    File last modified: [% date.format(filemod_time) %]

The time/date can also be specified as a string of the form 'h:m:s d/m/y'.
Any of the characters : / - or space may be used to delimit fields.

    [% USE day = date(format => '%A', locale => 'en_GB') %]
    [% day.format('4:20:00 9-13-2000') %]

Output:

    Tuesday

A format string can also be passed to the format() method, and a locale
specification may follow that.

    [% date.format(filemod, '%d-%b-%Y') %]
    [% date.format(filemod, '%d-%b-%Y', 'en_GB') %]

A fourth parameter allows you to force output in GMT, in the case of
seconds-since-the-epoch input:

    [% date.format(filemod, '%d-%b-%Y', 'en_GB', 1) %]

Note that in this case, if the local time is not GMT, then also
specifying '%Z' (time zone) in the format parameter will lead to an
extremely misleading result.

Any or all of these parameters may be named.  Positional parameters
should always be in the order ($time, $format, $locale).

    [% date.format(format => '%H:%M:%S') %]
    [% date.format(time => filemod, format => '%H:%M:%S') %]
    [% date.format(mytime, format => '%H:%M:%S') %]
    [% date.format(mytime, format => '%H:%M:%S', locale => 'fr_FR') %]
    [% date.format(mytime, format => '%H:%M:%S', gmt => 1) %]
    ...etc...

The now() method returns the current system time in seconds since the
epoch.

    [% date.format(date.now, '%A') %]

"""


# Default strftime() format:
FORMAT = "%H:%M:%S %d-%b-%Y"

LOCALE_SUFFIX = (".ISO8859-1", ".ISO_8859-15", ".US-ASCII", ".UTF-8");

GMTIME = { True: Time.gmtime,
           False: Time.localtime }


class Date(Plugin):
  """Plugin to generate formatted date strings."""
  def __init__(self, context, params=None):
    self.params = params or {}

  def now(self):
    return int(Time.time())

  def format(self, *args):
    """Returns a formatted time/date string for the specified time (or
    the current system time if unspecified) using the format, locale,
    and gmt values specified as arguments or internal values set
    defined at construction time.

    Specifying a true value for gmt will override the local time zone
    and force the output to be for GMT.  Any or all of the arguments
    may be specified as named parameters which get passed as a
    dictionary as the final argument.
    """
    args, params = self._split_arguments(args)
    args = list(args)
    def get(name):
      if args:
        return args.pop(0)
      else:
        return params.get(name) or self.params.get(name)
    time = get("time") or self.now()
    format = get("format") or FORMAT
    locale = get("locale")
    gmt = get("gmt")

    try:
      # If time is numeric, we assume it's seconds since the epoch:
      time = int(time)
    except StandardError:
      # Otherwise, we try to parse it as a 'H:M:S D:M:Y' string:
      date = re.split(r"[-/ :]", str(time))
      if len(date) < 6:
        raise TemplateException(
          "date", "bad time/date string:  expects 'h:m:s d:m:y'  got: '%s'"
          % time)
      date = [str(int(x)) for x in date[:6]]
      date = Time.strptime(" ".join(date), "%H %M %S %d %m %Y")
    else:
      date = GMTIME[bool(gmt)](time)

    if locale is not None:
      old_locale = Locale.setlocale(Locale.LC_ALL)
      try:
        for suffix in ("",) + LOCALE_SUFFIX:
          try_locale = "%s%s" % (locale, suffix)
          try:
            setlocale = Locale.setlocale(Locale.LC_ALL, try_locale)
          except Locale.Error:
            continue
          else:
            if try_locale == setlocale:
              locale = try_locale
              break
        datestr = Time.strftime(format, date)
      finally:
        Locale.setlocale(Locale.LC_ALL, old_locale)
    else:
      datestr = Time.strftime(format, date)

    return datestr

  def calc(self):
    self.throw("Failed to load date calculation module")

  def manip(self):
    self.throw("Failed to load date manipulation module")

  def throw(self, *args):
    raise TemplateException("date", ", ".join(str(x) for x in args))

