#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

from template.util import split_arguments


"""
template.plugin.Plugin  - Base class for Template Toolkit plugins


SYNOPSIS

    class MyPlugin(template.plugin.Plugin):
      def __init__(self, context=None):
        ...


DESCRIPTION

A 'plugin' for the Template Toolkit is simply a Python class which
conforms to a regular standard, allowing it to be loaded and used
automatically.

The template.plugin module defines a base class, Plugin, from which
other plugin modules can be derived.  A plugin does not have to be
derived from template.plugin.Plugin but should at least conform to its
object-oriented interface.

Use the PLUGIN_BASE option to specify the namespace that you use.  e.g.

    import template
    template = template.Template({
	'PLUGIN_BASE': 'myorg.template.plugin',
    })


PLUGIN API

The following methods form the basic interface between the Template
Toolkit and plugin modules.

load(cls, context=None)

This method is called by the Template Toolkit when the plugin module
is first loaded.  It is called as a class method and thus implicitly
receives the class object as the first parameter.  A reference to the
template.context.Context object loading the plugin may also be passed.
The default behaviour for the load() method is to simply return the
class object.  The calling context then uses this class object to
instantiate a plugin object.

__init__(context, @params)

This method is called to instantiate a new plugin object for the USE
directive.  It is typically invoked via the class object returned by
load().  A reference to the template.context.Context object creating
the plugin is passed, along with any additional parameters specified
in the USE directive.

    def __init__(self, context, *args):
      self._context = context


DEEPER MAGIC

The Context object that handles the loading and use of plugins
instantiates plugin objects by calling the object returned by the
load() method as a function.  In pseudo-code terms, it might look
something like this:

    cls = MyPlugin.load(context)  # returns MyPlugin

    obj = cls(context, *params)

The load() method may return any callable object, even a member of the
plugin class itself:

    class YourPlugin:
      @classmethod
      def load(cls, context):
        return cls(context)

      def __init__(self, context):
        self._context = context

      def __call__(self):
        return self


In this example, we have implemented a 'Singleton' plugin.  One object
gets created when load() is called and this simply returns itself when
called like a function.

Another implementation might require individual objects to be created
for every call to new(), but with each object sharing a reference to
some other object to maintain cached data, database handles, etc.
This pseudo-code example demonstrates the principle.

    class MyServer:
      @classmethod
      def load(cls, context):
        return cls(context)

      def __init__(self, context):
        self._context = context
        self._cache = {}

      def __call__(self, *params):
        return MyClient(self, *params)

      def add_to_cache(self):
        ...

      def get_from_cache(self):
        ...

    class MyClient:
      def __init__(self, server, blah):
        self._server = server
        self._blah = blah

      def get(self, *args):
        return self._server.get_from_cache(*args)

      def put(self, *args):
        return self._server.add_to_cache(*args)

When the plugin is loaded, a MyServer instance is created.  When
called like a function (via __call__), it instantiates and returns a
MyClient object, primed to communicate with the creating MyServer.

"""

class Plugin:
  """Base class for a plugin object which can be loaded and
  instantiated via the USE directive.
  """
  def __init__(self, *args):
    pass

  @classmethod
  def load(cls, context=None):
    """Class method called when the plugin module is first loaded.

    It returns the class object or some other callable which will be
    used to instantiate new objects.
    """
    return cls

  _split_arguments = staticmethod(split_arguments)
