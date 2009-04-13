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
template.plugin.filter - Base class for plugin filters


SYNOPSIS

    class MyFilter(template.plugin.filter.Filter):
      def __init__(self, *args):
        template.plugin.filter.Filter.__init__(self, *args)

      def filter(self, text):
        # ...mungify text...
        return text

    # now load it...
    [% USE MyFilter %]

    # ...and use the returned object as a filter
    [% FILTER $MyFilter %]
      ...
    [% END %]


DESCRIPTION

This module implements a base class for plugin filters.  It hides
the underlying complexity involved in creating and using filters
that get defined and made available by loading a plugin.

To use the module, simply create your own plugin module that is
inherited from the template.plugin.filter.Filter class.

    class MyFilter(template.plugin.filter.Filter):
      def __init__(self, *args):
        template.plugin.filter.Filter.__init__(self, *args)

Then simply define your filter() method.  When called, you get
passed the text to be filtered.

      def filter(self, text):
        # ...mungify text...
        return text

To use your custom plugin, you have to make sure that the Template
Toolkit knows about your plugin namespace.

    tt2 = template.Template({
	'PLUGIN_BASE': 'myorg.template.plugin',
    })

Or for individual plugins you can do it like this:

    tt2 = template.Template({
	'PLUGINS': {
	    'MyFilter': myorg.template.plugin.myfilter.MyFilter,
	},
    })

Then you USE your plugin in the normal way.

    [% USE MyFilter %]

The object returned is stored in the variable of the same name,
'MyFilter'.  When you come to use it as a FILTER, you should add a
dollar prefix.  This indicates that you want to use the filter stored
in the variable 'MyFilter' rather than the filter named 'MyFilter',
which is an entirely different thing (see later for information on
defining filters by name).

    [% FILTER $MyFilter %]
       ...text to be filtered...
    [% END %]

You can, of course, assign it to a different variable.

    [% USE blat = MyFilter %]

    [% FILTER $blat %]
       ...text to be filtered...
    [% END %]

Any configuration parameters passed to the plugin constructor from the
USE directive are stored internally in the object for inspection by
the filter() method (or indeed any other method).  Positional
arguments are stored as a tuple in the _args attribute while named
configuration parameters are stored as a dictionary in the _config
attribute.

For example, loading a plugin as shown here:

    [% USE blat = MyFilter 'foo' 'bar' baz = 'blam' %]

would allow the filter() method to do something like this:

    def filter(self, text):
      args = self._args    # ('foo', 'bar')
      conf = self._config  # { 'baz': 'blam' }
      # ...munge $text...
      return text

By default, plugins derived from this module will create static
filters.  A static filter is created once when the plugin gets loaded
via the USE directive and re-used for all subsequent FILTER
operations.  That means that any argument specified with the FILTER
directive are ignored.

Dynamic filters, on the other hand, are re-created each time they are
used by a FILTER directive.  This allows them to act on any parameters
passed from the FILTER directive and modify their behaviour
accordingly.

There are two ways to create a dynamic filter.  The first is to
define a DYNAMIC class attribute set to a true value.

    class MyFilter(template.plugin.filter.Filter):
      DYNAMIC = True

The other way is to set the internal _dynamic attribute within
__init__:

      def __init__(self, *args):
        template.plugin.filter.Filter.__init__(self, *args)
        self._dynamic = True

When this is set to a true value, the plugin will automatically create
a dynamic filter.  The outcome is that the filter() method will now
also get passed a tuple of postional arguments and a dictionary of
named parameters.

So, using a plugin filter like this:

    [% FILTER $blat 'foo' 'bar' baz = 'blam' %]

would allow the filter() method to work like this:

      def filter(self, text, args, conf):
        # args = ('foo', 'bar')
        # conf = {'baz': 'blam'}

In this case can pass parameters to both the USE and FILTER
directives, so your filter() method should probably take that into
account.

    [% USE MyFilter 'foo' wiz => 'waz' %]

    [% FILTER $MyFilter 'bar' biz => 'baz' %]
       ...
    [% END %]

You can use the _merge_args() and _merge_config() methods to do a
quick and easy job of merging the local (e.g. FILTER) parameters with
the internal (e.g. USE) values and returning new sets of conglomerated
data.

     def filter(self, text, args, conf):
       args = self._merge_args(args)
       conf = self._merge_config(conf)
       # args = ('foo', 'bar')
       # conf = {'wiz': 'waz', 'biz': 'baz'}

You can also have your plugin install itself as a named filter by
calling the _install_filter() method from the init() method.  You
should provide a name for the filter, something that you might like to
make a configuration option.

      def __init__(self, *args):
        template.plugin.filter.Filter.__init__(self, *args)
        name = self._config.get('name', 'myfilter')
        self._install_filter(name)

This allows the plugin filter to be used as follows:

    [% USE MyFilter %]

    [% FILTER myfilter %]
       ...
    [% END %]

or

    [% USE MyFilter name = 'swipe' %]

    [% FILTER swipe %]
       ...
    [% END %]

Alternately, you can allow a filter name to be specified as the first
positional argument.

      def __init__(self, *args):
        template.plugin.filter.Filter.__init__(self, *args)
        if self._args:
          name = self._args[0]
        else:
          name = 'myfilter'
        self._install_filter(name)

    [% USE MyFilter 'swipe' %]

    [% FILTER swipe %]
       ...
    [% END %]


EXAMPLE

Here's a complete example of a plugin filter module.

    import re

    class Change(template.plugin.filter.Filter):
      def __init__(self, *args):
        template.plugin.filter.Filter.__init__(self, *args)
        self._dynamic = True
        self._install_filter(self._args and self._args[0] or 'change')

      def filter(self, text, args, config):
        config = self._merge_config(config)
        regex = '|'.join(config.keys())
        return re.sub(regex, lambda match: config.get(match.group(), ''), text)

"""


class Filter(Plugin):
  """Template Toolkit module implementing a base class plugin object
  which acts like a filter and can be used with the FILTER directive.
  """

  DYNAMIC = False  # Create static filters by default.

  def __init__(self, context, *args):
    Plugin.__init__(self)
    self._args, self._config = self._split_arguments(args)
    self._dynamic = self.DYNAMIC
    self._context = context
    self._cached_filter = None

  def factory(self):
    if not self._cached_filter:
      if self._dynamic:
        def dynamic(context, *args):
          args, config = self._split_arguments(args)
          def filter(text):
            return self.filter(text, args, config)
          return filter
        dynamic.dynamic_filter = True
        self._cached_filter = dynamic
      else:
        def filter(text):
          return self.filter(text)
        self._cached_filter = filter
    return self._cached_filter

  def filter(self, text, args=None, config=None):
    return text

  def _merge_config(self, newcfg):
    owncfg = self._config
    if not newcfg:
      return owncfg
    copy = owncfg.copy()
    copy.update(newcfg)
    return copy

  def _merge_args(self, newargs):
    ownargs = self._args
    if not newargs:
      return ownargs
    return ownargs + newargs

  def _install_filter(self, name):
    self._context.define_filter(name, self.factory())
    return self


