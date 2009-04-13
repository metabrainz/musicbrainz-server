#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

import types

from template.constants import *
from template.util import TemplateException, get_class, listify


"""
template.plugins - Plugin provider module


SYNOPSIS

    import template.plugins

    plugin_provider = template.plugins.Plugins(options)

    plugin = plugin_provider.fetch(name, args)


DESCRIPTION

The template.plugins module defines a provider class which can be used
to load and instantiate Template Toolkit plugin modules.


METHODS

__init__(params)

Constructor which initializaes a template.plugins.Plugins object.  A
dictionary of configuration items may be passed as a parameter.  These
are described below.

Note that the template front-end module creates a Plugins provider,
passing all configuration items.  Thus, the examples shown below in
the form:

    plugprov = template.plugins.Plugins({
	'PLUGIN_BASE': 'mytemplate.plugin',
        'LOAD_PYTHON': 1,
	...
    })

can also be used via the template module as:

    tengine = template.Template({
	'PLUGIN_BASE': 'mytemplate.plugin',
        'LOAD_PYTHON': 1,
	...
    })

as well as the more explicit form of:

    plugprov = template.plugins.Plugins({
	'PLUGIN_BASE': 'mytemplate.plugin',
        'LOAD_PYTHON': 1,
	...
    })

    ttengine = template.Template({
	'LOAD_PLUGINS': [ plugprov ],
    })

fetch(name, args)

Called to request that a plugin of a given name be provided.  The
relevant module is first loaded (if necessary) and the load() class
method called to return the factory object (usually the class itself).
The factory object is then called like a function to instantiate the
provider, passing all remaining parameters.

Returns a new plugin object or None to decline to service the request.
Raises a TemplateException on error, unless TOLERANT is set, in which
case None is returned.


CONFIGURATION OPTIONS

The following list details the configuration options that can be provided
to the Plugins constructor.

* PLUGINS

The PLUGINS options can be used to provide a dictionary that maps
plugin names to Python classes.  The values of this dictionary
may be one of three kinds.

  1.  The plugin class object itself.

  2.  A two-element tuple.  The first item names the module; the
      second item names the class within the module.

  3.  A string, which is interpreted as a module name.  The class
      name is derived from it by taking only the trailing non-period
      characters and capitalizing the first.

The third form is potentially ambiguous, and exists primarily as a nod
to the semantics of the original Perl implemetation.  It should be
avoided.

A number of standard plugins are defined (e.g. 'table', 'cgi', 'dbi',
etc.) which map to their corresponding template.plugin.* counterparts.
These can be redefined by values in the PLUGINS hash.

    plugins = template.plugins.Plugins({
        'PLUGINS': {
            'foo':   myorg.template.plugin.foo.Foo,       # Style 1
            'cgi': ('myorg.template.plugin.cgi', 'CGI'),  # Style 2
            'bar':  'myorg.template.plugin.bar',          # Style 3
        },
    })

The recommended convention is to specify these plugin names in lower
case.  The Template Toolkit first looks for an exact case-sensitive
match and then tries the lower case conversion of the name specified.

    [% USE Foo %]      # look for 'Foo' then 'foo'

If you define all your PLUGINS with lower case names then they will be
located regardless of how the user specifies the name in the USE
directive.  If, on the other hand, you define your PLUGINS with upper
or mixed case names then the name specified in the USE directive must
match the case exactly.

The USE directive is used to create plugin objects and does so by
calling the plugin() method on the current template.context.Context
object.  If the plugin name is defined in the PLUGINS dictionary then
the corresponding Python module is imported.  The context then calls
the load() class method which should return a factory object that can
instantiate individual plugin objects.  Typically this factory object
will be the plugin class object itself; the base
template.plugin.Plugin class provides a load() class method that does
exactly this.

If the plugin name is not defined in the PLUGINS dictionary then the
PLUGIN_BASE and/or LOAD_PYTHON options come into effect.

* PLUGIN_BASE

If a plugin is not defined in the PLUGINS dictionary then the
PLUGIN_BASE is used to attempt to construct a correct Python module
name which can be successfully loaded.

The PLUGIN_BASE can be specified as a list of module namespaces, or as
a single value which is automatically converted to a list.  The
default PLUGIN_BASE value ('template.plugin') is then added to the
end of this list.

The supplied plugin name is interpreted as above to derive a module
and class name; then each value in PLUGIN_BASE in turn is prepended to
the module name to construct a full path.

example 1:

    plugins = template.plugins.Plugins({
        'PLUGIN_BASE': 'myorg.template.plugin',
    })

    [% USE Foo %]    # => Module myorg.template.plugin.Foo, class Foo
                       or Module       template.plugin.Foo, class Foo

example 2:

    plugins = template.plugins.Plugins({
        'PLUGIN_BASE': [   'myorg.template.plugin',
                           'yourorg.template.plugin'  ],
    })

    [% USE Foo %]    # => Module   myorg.template.plugin.Foo, class Foo
                       or Module yourorg.template.plugin.Foo, class Foo
                       or Module         template.plugin.Foo, class Foo

If you don't want the default template.plugin.Plugin namespace added
to the end of the PLUGIN_BASE, then set the class variable PLUGIN_BASE
to a false value before instantiating the Plugins object.  This is
shown in the example below where the 'Foo' is located as
'my.plugin.Foo' or 'your.plugin.foo' but not as 'template.plugin.Foo'.

example 3:

    import template.plugins
    template.plugins.Plugins.PLUGIN_BASE = ""

    plugins = template.plugins.Plugins({
        'PLUGIN_BASE': [   'my.plugin',
                           'your.plugin'  ],
    });

    [% USE Foo %]    # =>   Module my.plugin.Foo, class Foo
                       or Module your.plugin.Foo, class Foo


* LOAD_PYTHON

If a plugin cannot be loaded using the PLUGINS or PLUGIN_BASE
approaches then the provider can make a final attempt to load the
module without prepending any prefix to the module path.  This allows
regular Python modules (i.e. those that don't reside in the
template.plugin or some other such namespace) to be loaded and used
as plugins.

By default, the LOAD_PYTHON option is set to 0 and no attempt will be
made to load any Python modules that aren't named explicitly in the
PLUGINS dictionary or reside in a module as named by one of the
PLUGIN_BASE components.

Plugins loaded using the PLUGINS or PLUGIN_BASE receive a reference to
the current context object as the first argument to __init__.  Modules
loaded using LOAD_PYTHON are assumed to not conform to the plugin
interface.  They must be callable for instantiating objects, but they
will not receive a reference to the context as the first argument.
Plugin modules should provide a load() class method (or inherit the
default one from the template.plugin.Plugin base class) which is
called the first time the plugin is loaded.  Regular Python modules
need not.  In all other respects, regular Python objects and Template
Toolkit plugins are identical.

* TOLERANT

The TOLERANT flag is used by the various Template Toolkit provider
modules (template.provider, template.plugins, template.filters) to
control their behaviour when errors are encountered.  By default, any
errors are reported as such, with a TemplateException being raised.
When the TOLERANT flag is set to any true value, errors will be
silently ignored and the provider will instead return None.  This
allows a subsequent provider to take responsibility for providing the
resource, rather than failing the request outright.  If all providers
decline to service the request, either through tolerated failure or a
genuine disinclination to comply, then a '<resource> not found'
exception is raised.

* DEBUG

The DEBUG option can be used to enable debugging messages from the
template.plugins module by setting it to include the DEBUG_PLUGINS
value.

    from template.constants import *

    tt = template.Template({
	'DEBUG': DEBUG_FILTERS | DEBUG_PLUGINS,
    })


TEMPLATE TOOLKIT PLUGINS

The following plugin modules are distributed with the Template
Toolkit.


Datafile
--------

Provides an interface to data stored in a plain text file in a simple
delimited format.  The first line in the file specifies field names
which should be delimiter by any non-word character sequence.
Subsequent lines define data using the same delimiter as in the first
line.  Blank lines and comments (lines starting '#') are ignored.  See
template.plugin.datafile for further details.

/tmp/mydata:

    # define names for each field
    id : email : name : tel
    # here's the data
    fred : fred@here.com : Fred Smith : 555-1234
    bill : bill@here.com : Bill White : 555-5678

example:

    [% USE userlist = datafile('/tmp/mydata') %]

    [% FOREACH user = userlist %]
       [% user.name %] ([% user.id %])
    [% END %]


Date
----

The Date plugin provides an easy way to generate formatted time and
date strings by delegating to the POSIX strftime() routine.  See
template.plugin.date for further details.

    [% USE date %]
    [% date.format %]		# current time/date

    File last modified: [% date.format(template.modtime) %]


Directory
---------

The Directory plugin provides a simple interface to a directory and
the files within it.  See template.plugin.directory for further
details.

    [% USE dir = Directory('/tmp') %]
    [% FOREACH file = dir.files %]
        # all the plain files in the directory
    [% END %]
    [% FOREACH file = dir.dirs %]
        # all the sub-directories
    [% END %]


File
----

The File plugin provides a general abstraction for files and can be
used to fetch information about specific files within a filesystem.
See template.plugin.file for further details.

    [% USE File('/tmp/foo.html') %]
    [% File.name %]     # foo.html
    [% File.dir %]      # /tmp
    [% File.mtime %]    # modification time


Filter
------

This module implements a base class plugin which can be subclassed
to easily create your own modules that define and install new filters.

    class MyFilter(template.plugin.filter.Filter):

      def filter(self, text):
        # ...mungify text...
        return text


    # now load it...
    [% USE MyFilter %]

    # ...and use the returned object as a filter
    [% FILTER MyFilter %]
      ...
    [% END %]

See template.plugin.filter for further details.


Format
------

The Format plugin provides a simple way to format text using Python's
string-formatting operator, %.  See template.plugin.format for further
details.

    [% USE bold = format('<b>%s</b>') %]
    [% bold('Hello') %]


HTML
----

The HTML plugin is very basic, implementing a few useful methods for
generating HTML.  It is likely to be extended in the future or
integrated with a larger project to generate HTML elements in a
generic way.

    [% USE HTML %]
    [% HTML.escape("if (a < b && c > d) ..." %]
    [% HTML.attributes(border => 1, cellpadding => 2) %]
    [% HTML.element(table => { border => 1, cellpadding => 2 }) %]

See template.plugin.html for further details.


Iterator
--------

The Iterator plugin provides a way to create a
template.iterator.Iterator object to iterate over a data set.  An
iterator is created automatically by the FOREACH directive and is
aliased to the 'loop' variable.  This plugin allows an iterator to
be explicitly created with a given name, or the default plugin name,
'iterator'.  See template.plugin.iterator for further details.

    [% USE iterator(list, args) %]

    [% FOREACH item = iterator %]
       [% '<ul>' IF iterator.first %]
       <li>[% item %]
       [% '</ul>' IF iterator.last %]
    [% END %]


String
------

The String plugin implements an object-oriented interface for
manipulating strings.  See template.plugin.string for further details.

    [% USE String 'Hello' %]
    [% String.append(' World') %]

    [% msg = String.new('Another string') %]
    [% msg.replace('string', 'text') %]

    The string "[% msg %]" is [% msg.length %] characters long.


Table
-----

The Table plugin allows you to format a list of data items into a
virtual table by specifying a fixed number of rows or columns, with an
optional overlap.  See template.plugin.table for further details.

    [% USE table(list, rows=10, overlap=1) %]

    [% FOREACH item = table.col(3) %]
       [% item %]
    [% END %]


URL
---

The URL plugin provides a simple way of contructing URLs from a base
part and a variable set of parameters.  See template.plugin.url for
further details.

    [% USE mycgi = url('/cgi-bin/bar.pl', debug=1) %]

    [% mycgi %]
       # ==> /cgi/bin/bar.pl?debug=1

    [% mycgi(mode='submit') %]
       # ==> /cgi/bin/bar.pl?mode=submit&debug=1


Wrap
----

The Wrap plugin uses the standard textwrap module to provide simple
paragraph formatting.  See template.plugin.wrap for further details.

    [% USE wrap %]
    [% wrap(mytext, 40, '* ', '  ') %]	# use wrap sub
    [% mytext FILTER wrap(40) -%]	# or wrap FILTER

Note that Python's textwrap module does not always wrap text in precisely
the same way that Perl's Text::Wrap module does.

"""


class Error(Exception):
  pass


class Plugins:
  """Plugin provider which handles the loading of plugin modules and
  instantiation of plugin objects.
  """

  PLUGIN_BASE = "template.plugin"

  STD_PLUGINS = {
    "datafile":  ("template.plugin.datafile", "Datafile"),
    "date":      ("template.plugin.date", "Date"),
    "directory": ("template.plugin.directory", "Directory"),
    "file":      ("template.plugin.file", "File"),
    "format":    ("template.plugin.format", "Format"),
    "html":      ("template.plugin.html", "Html"),
    "image":     ("template.plugin.image", "Image"),
    "iterator":  ("template.plugin.iterator", "Iterator"),
    "math":      ("template.plugin.math_plugin", "Math"),
    "string":    ("template.plugin.string", "String"),
    "table":     ("template.plugin.table", "Table"),
    "wrap":      ("template.plugin.wrap", "Wrap"),
    "url":       ("template.plugin.url", "Url"),
    "view":      ("template.plugin.view", "View"),
  }

  def __init__(self, params):
    pbase = listify(params.get("PLUGIN_BASE") or [])
    plugins = params.get("PLUGINS") or {}
    factory = params.get("PLUGIN_FACTORY")
    if self.PLUGIN_BASE:
      pbase.append(self.PLUGIN_BASE)
    self.__plugin_base = pbase
    self.__plugins = self.STD_PLUGINS.copy()
    self.__plugins.update(plugins)
    self.__tolerant = bool(params.get("TOLERANT"))
    self.__load_python = bool(params.get("LOAD_PYTHON"))
    self.__factory = factory or {}
    self.__debug = (params.get("DEBUG") or 0) & DEBUG_PLUGINS

  def fetch(self, name, args=None, context=None):
    factory = self.__factory[name] = self._load(name, context)
    if not factory:
      return None
    try:
      if callable(factory):
        args = (context,) + tuple(args or ())
        return factory(*args)
      else:
        raise Error("%s plugin is not callable" % (name,))
    except Exception, e:
      if self.__tolerant:
        return None
      else:
        raise TemplateException.convert(e)

  def _load(self, name, context):
    impl = self.__plugins.get(name) or self.__plugins.get(name.lower())

    if impl:
      return get_class(impl).load(context)

    if name:
      for pbase in self.__plugin_base:
        try:
          return get_class(name, pbase).load(context)
        except ImportError:
          pass

    if not self.__load_python:
      return None

    cls = get_class(name)
    return lambda _, *args: cls(*args)  # Discard first context argument

  def plugin_base(self):
    return self.__plugin_base

  def load_python(self):
    return self.__load_python
