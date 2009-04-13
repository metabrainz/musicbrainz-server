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
from template.util import Sequence

"""

template.plugin.datafile - Plugin to construct records from a simple data file


SYNOPSIS

    [% USE mydata = datafile('/path/to/datafile') %]
    [% USE mydata = datafile('/path/to/datafile', delim = '|') %]

    [% FOREACH record = mydata %]
       [% record.this %]  [% record.that %]
    [% END %]


DESCRIPTION

This plugin provides a simple facility to construct a list of
dictionaries, each of which represents a data record of known
structure, from a data file.

    [% USE datafile(filename) %]

A absolute filename must be specified (for this initial implementation
at least - in a future version it might also use the INCLUDE_PATH).
An optional 'delim' parameter may also be provided to specify an
alternate delimiter character.

    [% USE userlist = datafile('/path/to/file/users')     %]
    [% USE things   = datafile('items', delim = '|') %]

The format of the file is intentionally simple.  The first line
defines the field names, delimited by colons with optional surrounding
whitespace.  Subsequent lines then defines records containing data
items, also delimited by colons.  e.g.

    id : name : email : tel
    abw : Andy Wardley : abw@cre.canon.co.uk : 555-1234
    neilb : Neil Bowers : neilb@cre.canon.co.uk : 555-9876

Each line is read, split into composite fields, and then used to
initialise a dictionary containing the field names as relevant keys.
The plugin returns an object that encapsulates the dictionaries in the
order as defined in the file.

    [% FOREACH user = userlist %]
       [% user.id %]: [% user.name %]
    [% END %]

The first line of the file MUST contain the field definitions.  After
the first line, blank lines will be ignored, along with comment line
which start with a '#'.


BUGS

Should handle file names relative to INCLUDE_PATH.
Doesn't permit use of ':' in a field.  Some escaping mechanism is required.

"""


class Datafile(Plugin, Sequence):
  """Template Toolkit Plugin which reads a datafile and constructs a
  list object containing hashes representing records in the file.
  """
  def __init__(self, context, filename, params=None):
    Plugin.__init__(self)
    params = params or {}
    delim = params.get("delim") or ":"
    items = []
    line = None
    names = None
    splitter = re.compile(r'\s*%s\s*' % re.escape(delim))

    try:
      f = open(filename)
    except IOError, e:
      return self.fail("%s: %s" % (filename, e))

    for line in f:
      line = line.rstrip("\n\r")
      if not line or line.startswith("#") or line.isspace():
        continue
      fields = splitter.split(line)
      if names is None:
        names = fields
      else:
        fields.extend([None] * (len(names) - len(fields)))
        items.append(dict(zip(names, fields)))

    f.close()
    self.items = items

  def __iter__(self):
    return iter(self.items)

  def as_list(self):
    return self.items
