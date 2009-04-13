#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

import cStringIO
import re

from template.constants import ERROR_VIEW
from template.util import can, is_seq


"""
template.view - customised view of a template processing context

SYNOPSIS

    # define a view
    [% VIEW view
            # some standard args
            prefix        => 'my_',
	    suffix        => '.tt2',
	    notfound      => 'no_such_file'
            ...

            # any other data
            title         => 'My View title'
            other_item    => 'Joe Random Data'
            ...
    %]
       # add new data definitions, via 'my' self reference
       [% my.author = "$abw.name <$abw.email>" %]
       [% my.copy   = "&copy; Copyright 2000 $my.author" %]

       # define a local block
       [% BLOCK header %]
       This is the header block, title: [% title or my.title %]
       [% END %]

    [% END %]

    # access data items for view
    [% view.title %]
    [% view.other_item %]

    # access blocks directly ('include_naked' option, set by default)
    [% view.header %]
    [% view.header(title => 'New Title') %]

    # non-local templates have prefix/suffix attached
    [% view.footer %]		# => [% INCLUDE my_footer.tt2 %]

    # more verbose form of block access
    [% view.include( 'header', title => 'The Header Title' ) %]
    [% view.include_header( title => 'The Header Title' ) %]

    # very short form of above ('include_naked' option, set by default)
    [% view.header( title => 'The Header Title' ) %]

    # non-local templates have prefix/suffix attached
    [% view.footer %]		# => [% INCLUDE my_footer.tt2 %]

    # fallback on the 'notfound' template ('my_no_such_file.tt2')
    # if template not found
    [% view.include('missing') %]
    [% view.include_missing %]
    [% view.missing %]

    # print() includes a template relevant to argument type
    [% view.print("some text") %]     # type=TEXT, template='text'

    [% BLOCK my_text.tt2 %]	      # 'text' with prefix/suffix
       Text: [% item %]
    [% END %]

    # now print() a hash ref, mapped to 'hash' template
    [% view.print(some_hash_ref) %]   # type=HASH, template='hash'

    [% BLOCK my_hash.tt2 %]	      # 'hash' with prefix/suffix
       hash keys: [% item.keys.sort.join(', ')
    [% END %]

    # now print() a list ref, mapped to 'list' template
    [% view.print(my_list_ref) %]     # type=ARRAY, template='list'

    [% BLOCK my_list.tt2 %]	      # 'list' with prefix/suffix
       list: [% item.join(', ') %]
    [% END %]

    # print() maps 'My::Object' to 'My_Object'
    [% view.print(myobj) %]

    [% BLOCK my_My_Object.tt2 %]
       [% item.this %], [% item.that %]
    [% END %]

    # update mapping table
    [% view.map.ARRAY = 'my_list_template' %]
    [% view.map.TEXT  = 'my_text_block'    %]


    # change prefix, suffix, item name, etc.
    [% view.prefix = 'your_' %]
    [% view.default = 'anyobj' %]
    ...

DESCRIPTION

TODO

METHODS

__init__(context, config=None)

Initializes a template.view.View presenting a custom view of the
specified context object.

A dictionary of configuration options may be passed as the second
argument.

* prefix

Prefix added to all template names.

    [% USE view(prefix => 'my_') %]
    [% view.view('foo', a => 20) %]	# => my_foo

* suffix

Suffix added to all template names.

    [% USE view(suffix => '.tt2') %]
    [% view.view('foo', a => 20) %]	# => foo.tt2

* map

Dictionary mapping type names to template names.  The print()
method uses this to determine which template to use to present any
particular item.  The TEXT, HASH and ARRAY items default to 'test',
'hash' and 'list' appropriately.

Python note: For compatibility with the Perl version of the Template
Toolkit, Python's list and tuple types correspond to"ARRAY", its dict
type corresponds to "HASH", and any other object that is not an
instance of a class corresponds to "TEXT".  Class instances map to the
name of the class.  Module names are not currently considered, so
there is no way to distinguish two classes with the same name that
live in different modules.

    [% USE view(map => { 'ARRAY': 'my_list',
			 'HASH': 'your_hash',
		         'MyFoo': 'my_foo', } ) %]

    [% view.print(some_text) %]		# => text
    [% view.print(a_list) %]		# => my_list
    [% view.print(a_hash) %]		# => your_hash
    [% view.print(a_foo) %]		# => my_foo

    [% BLOCK text %]
       Text: [% item %]
    [% END %]

    [% BLOCK my_list %]
       list: [% item.join(', ') %]
    [% END %]

    [% BLOCK your_hash %]
       hash keys: [% item.keys.sort.join(', ')
    [% END %]

    [% BLOCK my_foo %]
       Foo: [% item.this %], [% item.that %]
    [% END %]

* method

Name of a method which objects passed to print() may provide for
presenting themselves to the view.  If a specific map entry can't be
found for an object reference and it supports the method (default:
'present') then the method will be called, passing the view as an
argument.  The object can then make callbacks against the view to
present itself.

    class Foo:
      def present(self, view):
        return 'a regular view of a Foo\n'
      def debug(self, view):
        return 'a debug view of a Foo\n'

In a template:

    [% USE view %]
    [% view.print(my_foo_object) %]	# a regular view of a Foo

    [% USE view(method => 'debug') %]
    [% view.print(my_foo_object) %]	# a debug view of a Foo

* default

Default template to use if no specific map entry is found for an item.

    [% USE view(default => 'my_object') %]

    [% view.print(objref) %]		# => my_object

Any current prefix and suffix will be added to both the default
template name and the object class name.

* notfound

Fallback template to use if any other isn't found.

* item

Name of the template variable to which the print_() method assigns the
current item.  Defaults to'item'.

    [% USE view %]
    [% BLOCK list %]
       [% item.join(', ') %]
    [% END %]
    [% view.print(a_list) %]

    [% USE view(item => 'thing') %]
    [% BLOCK list %]
       [% thing.join(', ') %]
    [% END %]
    [% view.print(a_list) %]

* view_prefix

Prefix of methods which should be mapped to view() by __getattr__.
Defaults to'view_'.

    [% USE view %]
    [% view.view_header() %]			# => view('header')

    [% USE view(view_prefix => 'show_me_the_' %]
    [% view.show_me_the_header() %]		# => view('header')

* view_naked

Flag to indcate if any attempt should be made to map method names to
template names where they don't match the view_prefix.  Defaults to
False.

    [% USE view(view_naked => 1) %]

    [% view.header() %]			# => view('header')


print_( obj1, obj2, ... config)

TODO


view( template, vars, config )

TODO

"""


class View:
  """A custom view of a template processing context.  Can be used to
  implement custom "skins".
  """

  MAP = { "HASH": "hash",
          "ARRAY": "list",
          "TEXT": "text",
          "default": "" }

  CONFIG = dict((item, None) for item in (
    "data", "default", "map", "blocks", "method", "sealed", "base", "prefix",
    "suffix", "notfound", "silent", "item", "include_prefix", "include_naked",
    "view_prefix", "view_naked"))

  def __init__(self, context, config=None):
    config = config or {}
    self._context = context
    if isinstance(config, View):
      # Clone an existing View.
      self._map = config._map
      self._blocks = config._blocks
      self._method = config._method
      self._sealed = config._sealed
      self._base = config._base
      self._prefix = config._prefix
      self._suffix = config._suffix
      self._notfound = config._notfound
      self._silent = config._silent
      self._item = config._item
      self._include_prefix = config._include_prefix
      self._include_naked = config._include_naked
      self._view_prefix = config._view_prefix
      self._view_naked = config._view_naked
      self._data = config._data
      self._sealed = config._sealed
    else:
      map = config.get("map") or {}
      map.setdefault("default", config.get("default"))
      self._map = self.MAP.copy()
      self._map.update(map)
      self._blocks = config.get("blocks") or {}
      self._method = config.get("method") or "present"
      self._sealed = bool(config.get("sealed", True))
      self._base = config.get("base") or ""
      self._prefix = config.get("prefix") or ""
      self._suffix = config.get("suffix") or ""
      self._notfound = config.get("notfound") or ""
      self._silent = config.get("silent") or ""
      self._item = config.get("item") or "item"
      self._include_prefix = config.get("include_prefix") or "include_"
      self._include_naked = bool(config.get("include_naked", True))
      self._view_prefix = config.get("view_prefix") or "view_"
      self._view_naked = config.get("view_naked") or 0
      for item in self.CONFIG:
        try:
          del config[item]
        except KeyError:
          pass
      if self._base:
        data = self._base._data.copy()
        data.update(config)
        config = data
      self._data = config
      self._SEALED = False

  def __getattr__(self, attr):
    """Returns/updates public internal data items (i.e. not prefixed
    '_' or '.') or presents a view if the method matches the
    view_prefix item, e.g. view_foo(...) => view('foo', ...).

    Similarly, the include_prefix is used, if defined, to map
    include_foo(...) to include('foo', ...).  If that fails then the
    entire method name will be used as the name of a template to
    include iff the include_named parameter is set (default: True).
    Last attempt is to match the entire method name to a view() call,
    iff view_naked is set.  Otherwise, a 'view' exception is raised
    reporting the error 'no such view member: <method>'.
    """
    if attr == "print":
      return self.print_
    if attr.startswith("__") and attr.endswith("__"):
      raise AttributeError
    if re.match(r"[._]", attr):
      self._context.throw(ERROR_VIEW, "attempt to view private member: %s" %
                          attr)
    if attr in self.CONFIG:
      def accessor(*args):
        if args:
          if self._SEALED:
            self._context.throw(ERROR_VIEW, ("cannot update config item "
                                             "in sealed view: %s" % attr))
          setattr(self, "_%s" % attr, args[0])
          return args[0]
        else:
          return getattr(self, "_%s" % attr)
    elif attr in self._data:
      def accessor(*args):
        if args and self._SEALED:
          if not self._silent:
            self._context.throw(ERROR_VIEW, ("cannot update item "
                                             "in sealed view: %s" % attr))
          args = ()
        if args:
          self._data[attr] = args[0]
          return args[0]
        else:
          return self._data.get(attr)
    else:
      def accessor(*args):
        if args and not self._SEALED:
          self._data[attr] = args[0]
          return args[0]
        match = re.match(self._view_prefix, attr)
        if match:
          return self.view(attr[match.end():], *args)
        match = re.match(self._include_prefix, attr)
        if match:
          return self.include(attr[match.end():], *args)
        if self._include_naked:
          return self.include(attr, *args)
        if self._view_naked:
          return self.view(attr, *args)
        self._context.throw(ERROR_VIEW, "no such view member: %s" % attr)
    return accessor

  def seal(self):
    """Seal the view to prevent new data items from being
    automatically created by the __getattr__ method.
    """
    self._SEALED = self._sealed

  def unseal(self):
    """Unseal the view to allow new data items from being
    automatically created by the __getattr__ method.
    """
    self._SEALED = False

  def clone(self, config):
    """Cloning method which takes a copy of 'self' and then applies to
    it any modifications specified in the config dictionary passed as an
    argument.

    Returns the cloned View object.
    """
    clone = View(self._context, self)
    # Merge maps:
    clone._map = self._map.copy()
    clone._map.update(config.get("map", {}))
    if config.get("default") is not None:
      clone._map["default"] = config["default"]
    for arg in ("base", "prefix", "suffix", "notfound", "item", "method",
                "include_prefix", "include_naked", "view_prefix",
                "view_naked"):
      if arg in config:
        value = config[arg]
        if value is not None:
          setattr(clone, "_%s" % arg, value)
        del config[arg]
    if "default" in config:
      del config["default"]
    if "map" in config:
      del config["map"]
    data = clone._data = self._data.copy()
    data.update(config)

    return clone

  def print_(self, *args):
    """Prints @items in turn by mapping each to an approriate template
    using the internal 'map' dictionary.

    If an entry isn't found and the item is an object that implements
    the method named in the internal 'method' item, (default:
    'present'), then the method will be called passing a reference to
    'self', against which the presenter method may make callbacks
    (e.g.  to view_item()).  If the presenter method isn't
    implemented, then the 'default' map entry is consulted and used if
    defined.  The final argument may be a dictionary providing local
    overrides to the internal defaults for various items (prefix,
    suffix, etc).  In the presence of this parameter, a clone of the
    current object is first made, applying any configuration updates,
    and control is then delegated to it.
    """
    args = list(args)
    if len(args) > 1 and isinstance(args[-1], dict):
      cfg = args.pop()
      clone = self.clone(cfg)
      return clone.print_(*args)
    output = cStringIO.StringIO()
    for item in args:
      if isinstance(item, (tuple, list)):
        type = "ARRAY"
      elif isinstance(item, dict):
        type = "HASH"
      elif isinstance(item, (basestring, int, long)):
        type = "TEXT"
      else:
        type = item.__class__.__name__
      template = self._map.get(type)
      if template is None:
        # No specific map entry for object, maybe it implements a
        # 'present' (or other) method?
        # Hack: Have to explicitly disallow View objects, since
        # our promiscuous __getattr__ method will dynamically create
        # a getter/setter subroutine for most any method name.
        # Perl's UNIVERSAL::can method ignores AUTOLOAD, but
        # Python's getattr() does not ignore __getattr__.
        if not isinstance(item, View) and can(item, self._method):
          output.write(str(getattr(item, self._method)(self)))
          continue
        done = False
        newtype = None
        if isinstance(item, dict):
          newtype = item.get(self._method)
          if newtype is not None:
            template = self._map.get("%s=>%s" % (self._method, newtype))
            done = template is not None
        if not done and newtype is not None:
          template = self._map.get("%s=>*" % (self._method,))
          if template is not None:
            template = template.replace("*", newtype)
            done = True
        if not done:
          template = self._map.get("default") or type
      if template:
        output.write(str(self.view(template, item)))

    return output.getvalue()

  def view(self, template, item=None, vars=None):
    """Wrapper around include() which expects a template name,
    'template', followed by a data item, 'item', and optionally, a
    further dictionary of template variables.

    The 'item' is added as an entry to the 'vars' dictionary (which is
    created empty if not passed as an argument) under the name
    specified by the internal 'item' member, which is appropriately
    'item' by default.  Thus an external object present() method can
    callback against this object method, simply passing a data item to
    be displayed.  The external object doesn't have to know what the
    view expects the item to be called in the 'vars' dictionary.
    """
    vars = vars or {}
    if item is not None:
      vars[self._item] = item
    return self.include(template, vars)

  def include(self, template, vars=None):
    """INCLUDE a template, 'template', mapped according to the current
    prefix, suffix, default, etc., where 'vars' is an optional
    dictionary containing template variable definitions.

    If the template isn't found then the method will default to any
    'notfound' template, if defined as an internal item.
    """
    template = self.template(template)
    if not isinstance(vars, dict):
      vars = {}
    vars.setdefault("view", self)
    return self._context.include(template, vars)

  def template(self, name):
    """Returns a compiled template for the specified template name,
    according to the current configuration parameters.
    """
    if not name:
      self._context.throw(ERROR_VIEW, "no view template specified")
    block = self._blocks.get(name)
    if block:
      return block
    template = self.template_name(name)
    e = None
    try:
      template = self._context.template(template)
    except Exception, e:
      pass
    if e and self._base:
      try:
        template = self._base.template(name)
        e = None
      except Exception, e:
        pass
    if e and self._notfound:
      template = self._blocks.get(self._notfound)
      if not template:
        notfound = self.template_name(self._notfound)
        try:
          template = self._context.template(notfound)
        except Exception, e:
          self._context.throw(ERROR_VIEW, e)
    elif e:
      self._context.throw(ERROR_VIEW, e)
    return template

  def template_name(self, template):
    """Returns the name of the specified template with any appropriate
    prefix and/or suffix added.
    """
    if template:
      template = "%s%s%s" % (self._prefix, template, self._suffix)
    return template

  def default(self, *args):
    """Special case accessor to retrieve/update 'default' as an alias for
    map['default'].
    """
    if args:
      self._map["default"] = args[0]
    return self._map["default"]
