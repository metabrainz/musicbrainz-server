#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

import cStringIO
import operator
import os
import re
import time

from template import util
from template.constants import *
from template.document import Document
from template.filters import Filters
from template.plugins import Plugins
from template.provider import Provider
from template.stash import Stash
from template.util import TemplateException, is_seq, unscalar, unscalar_list


"""

NAME

template.context.Context - Runtime context in which templates are processed

SYNOPSIS

    import template.context

    # constructor
    context = template.context.Context(config)

    # fetch (load and compile) a template
    tt = context.template(template_name)

    # fetch (load and instantiate) a plugin object
    plugin = context.plugin(name, args)

    # fetch (return or create) a filter subroutine
    filter = context.filter(name, args, alias)

    # process/include a template, raising an exception on error
    output = context.process(tt, vars)
    output = context.include(tt, vars)

    # raise an exception
    context.throw(error_type, error_message, output_buffer)

    # catch an exception, clean it up and fix output buffer
    exception = context.catch(exception, $output_buffer)

    # save/restore the stash to effect variable localisation
    new_stash = context.localise(vars)
    old_stash = context.delocalise()

    # add new BLOCK or FILTER definitions
    context.define_block(name, block)
    context.define_filter(name, filtersub, is_dynamic)

    # reset context, clearing any imported BLOCK definitions
    context.reset()

    # methods for accessing internal items
    stash     = context.stash()
    tflag     = context.trim()
    epflag    = context.eval_python()
    providers = context.templates()
    providers = context.plugins()
    providers = context.filters()
    ...


DESCRIPTION

The template.context.Context class defines an object class for
representing a runtime context in which templates are processed.  It
provides an interface to the fundamental operations of the Template
Toolkit processing engine through which compiled templates
(i.e. Python code constructed from the template source) can process
templates, load plugins and filters, raise exceptions and so on.

A default Context object is created by the Template class.  Any
Context options may be passed to the Template constructor and will be
forwarded to the Context constructor.

    import template

    tt = template.Template({
	'TRIM': 1,
	'EVAL_PYTHON': 1,
	'BLOCKS': {
	    'header': 'This is the header',
	    'footer': 'This is the footer',
	},
    })

Similarly, the Context constructor will forward all configuration
parameters onto other default objects (e.g. Provider, Plugins,
Filters, etc.) that it may need to instantiate.

    context = template.context.Context({
	'INCLUDE_PATH': '/home/abw/templates', # provider option
	'TAG_STYLE': 'html',                # parser option
    })

A Context object (or subclass/derivative) can be explicitly
instantiated and passed to the Template constructor as the CONTEXT
item.

    import template
    import template.context

    context = template.context.Context({ 'TRIM': 1 })
    tt      = template.Template({ 'CONTEXT': context })

The Template class uses the Config context() factory method to create
a default context object when required.  The template.config.CONTEXT
global variable may be set to specify an alternate context module.
This will be loaded automatically and its constructor called by the
context() factory method when a default context object is required.

    import template

    template.config.CONTEXT = ('MyOrg.Template.Context', 'Context')

    tt = template.Template({
	'EVAL_PYTHON': 1,
	'EXTRA_MAGIC': 'red hot',  # your extra config items
	...
    })


METHODS

__init__(params)

The constructor is called to instantiate a Context object.

    context = template.context.Context({
	'INCLUDE_PATH': 'header',
	'POST_PROCESS': 'footer',
    })

The following configuration items may be specified.

VARIABLES, PRE_DEFINE
---------------------

The VARIABLES option (or PRE_DEFINE - they're equivalent) can be used
to specify a dict of template variables that should be used to
pre-initialise the stash when it is created.  These items are ignored
if the STASH item is defined.

    context = template.context.Context({
	'VARIABLES': {
	    'title': 'A Demo Page',
	    'author': 'Joe Random Hacker',
	    'version': 3.14,
	},
    })

or

    context = template.context.Context({
	'PRE_DEFINE': {
	    'title': 'A Demo Page',
	    'author': 'Joe Random Hacker',
	    'version': 3.14,
	},
    })

BLOCKS
------

The BLOCKS option can be used to pre-define a default set of template
blocks.  These should be specified as a dictionary mapping template
names to template text, subroutines or template.document.Document
objects.

    context = template.context.Context({
	'BLOCKS': {
	    'header': 'The Header.  [% title %]',
	    'footer': lambda: some_output_text,
	    'another': template.document.Document({ ... }),
	},
    })

TRIM
----

The TRIM option can be set to have any leading and trailing whitespace
automatically removed from the output of all template files and
BLOCKs.

By example, the following BLOCK definition

    [% BLOCK foo %]
    Line 1 of foo
    [% END %]

will be processed is as '\nLine 1 of foo\n'.  When INCLUDEd, the surrounding
newlines will also be introduced.

    before
    [% INCLUDE foo %]
    after

output:
    before

    Line 1 of foo

    after

With the TRIM option set to any true value, the leading and trailing
newlines (which count as whitespace) will be removed from the output
of the BLOCK.

    before
    Line 1 of foo
    after

The TRIM option is disabled (0) by default.


EVAL_PYTHON

This flag is used to indicate if PYTHON and/or RAWPYTHON blocks should
be evaluated.  By default, it is disabled and any PYTHON or RAWPYTHON
blocks encountered will raise exceptions of type 'python' with the
message 'EVAL_PYTHON not set'.  Note however that any RAWPYTHON blocks
should always contain valid Python code, regardless of the EVAL_PYTHON
flag.  The parser will fail to compile templates that contain invalid
Python code in RAWPYTHON blocks and will throw a 'file' exception.

When using compiled templates, the EVAL_PYTHON has an affect when the
template is compiled, and again when the templates is subsequently
processed, possibly in a different context to the one that compiled
it.

If the EVAL_PYTHON is set when a template is compiled, then all PYTHON
and RAWPYTHON blocks will be included in the compiled template.  If
the EVAL_PYTHON option isn't set, then Python code will be generated
which ALWAYS throws a 'python' exception with the message 'EVAL_PYTHON
not set' WHENEVER the compiled template code is run.

Thus, you must have EVAL_PYTHON set if you want your compiled templates
to include PYTHON and RAWPYTHON blocks.

At some point in the future, using a different invocation of the
Template Toolkit, you may come to process such a pre-compiled
template.  Assuming the EVAL_PYTHON option was set at the time the
template was compiled, then the output of any RAWPYTHON blocks will be
included in the compiled template and will get executed when the
template is processed.  This will happen regardless of the runtime
EVAL_PYTHON status.

Regular PYTHON blocks are a little more cautious, however.  If the
EVAL_PYTHON flag isn't set for the current context, that is, the
one which is trying to process it, then it will throw the familiar
'python' exception with the message, 'EVAL_PYTHON not set'.

Thus you can compile templates to include PYTHON blocks, but
optionally disable them when you process them later.

RECURSION
---------

The template processor will raise a file exception if it detects
direct or indirect recursion into a template.  Setting this option to
any true value will allow templates to include each other recursively.

LOAD_TEMPLATES
--------------

The LOAD_TEMPLATE option can be used to provide a sequence of
template.provider.Provider objects or sub-classes thereof which will
take responsibility for loading and compiling templates.

    context = template.context.Context({
	'LOAD_TEMPLATES': [
            myorg.template.provider({ ... }),
            template.provider.Provider({ ... }),
	],
    })

When a PROCESS, INCLUDE or WRAPPER directive is encountered, the named
template may refer to a locally defined BLOCK or a file relative to
the INCLUDE_PATH (or an absolute or relative path if the appropriate
ABSOLUTE or RELATIVE options are set).  If a BLOCK definition can't be
found (see the Context template() method for a discussion of BLOCK
locality) then each of the LOAD_TEMPLATES provider objects is queried
in turn via the fetch() method to see if it can supply the required
template.  Each provider can return a compiled template, an error, or
decline to service the request in which case the responsibility is
passed to the next provider.  If none of the providers can service the
request then a 'not found' error is returned.  The same basic provider
mechanism is also used for the INSERT directive but it bypasses any
BLOCK definitions and doesn't attempt is to parse or process the
contents of the template file.

This is an implementation of the 'Chain of Responsibility' design
pattern as described in 'Design Patterns', Erich Gamma, Richard Helm,
Ralph Johnson, John Vlissides), Addision-Wesley, ISBN 0-201-63361-2,
page 223.

If LOAD_TEMPLATES is undefined, a single default provider will be
instantiated using the current configuration parameters.  For example,
the Provider INCLUDE_PATH option can be specified in the Context
configuration and will be correctly passed to the provider's
constructor method.

    context = template.context.Context({
	'INCLUDE_PATH': '/here:/there',
    })

LOAD_PLUGINS
------------

The LOAD_PLUGINS options can be used to specify a list of provider
objects (i.e. they implement the fetch() method) which are responsible
for loading and instantiating template plugin objects.  The Content
plugin() method queries each provider in turn in a 'Chain of
Responsibility' as per the template() and filter() methods.

    context = template.context.Context({
	'LOAD_PLUGINS': [
            myorg.template.plugins.Plugins({ ... }),
            template.plugins.Plugins({ ... }),
	],
    })

By default, a single template.plugins.Plugins object is created using
the current configuration dictionary.  Configuration items destined
for the Plugins constructor may be added to the Context constructor.

    context = template.context.Context({
	'PLUGIN_BASE': 'myorg.template.plugins',
	'LOAD_PYTHON': 1,
    })

LOAD_FILTERS
------------

The LOAD_FILTERS option can be used to specify a list of provider
objects (i.e. they implement the fetch() method) which are responsible
for returning and/or creating filter subroutines.  The Context
filter() method queries each provider in turn in a 'Chain of
Responsibility' as per the template() and plugin() methods.

    context = template.context.Context({
	'LOAD_FILTERS': [
            mytemplaet.filters.Filters(),
            template.filters.Filters(),
	],
    })

By default, a single template.filters.Filters object is created for
the LOAD_FILTERS list.

STASH
-----

A reference to a template.stash.Stash object or sub-class which will
take responsibility for managing template variables.

    stash = myorg.template.stash.Stash({ ... })
    context = template.context.Context({
	'STASH': stash,
    })

If unspecified, a default stash object is created using the VARIABLES
configuration item to initialise the stash variables.  These may also
be specified as the PRE_DEFINE option for backwards compatibility with
version 1.

    context = template.context.Context({
	'VARIABLES': {
	    'id': 'abw',
	    'name': 'Andy Wardley',
	},
    })

DEBUG
-----

The DEBUG option can be used to enable various debugging features of
the Context module.

    from template.constants import *

    tt = template.Template({
	'DEBUG': DEBUG_CONTEXT | DEBUG_DIRS,
    })

The DEBUG value can include any of the following.  Multiple values
should be combined using the binary OR operator, '|'.

DEBUG_CONTEXT

Enables general debugging messages for the Context class.

DEBUG_DIRS

This option causes the Template Toolkit to generate comments
indicating the source file, line and original text of each directive
in the template.  These comments are embedded in the template output
using the format defined in the DEBUG_FORMAT configuration item, or a
simple default format if unspecified.

For example, the following template fragment:

    Hello World

would generate this output:

    ## input text line 1 :  ##
    Hello
    ## input text line 2 : World ##
    World


template(name)

Returns a compiled template by querying each of the LOAD_TEMPLATES
providers (instances of template.provider.Provider, or sub-class) in
turn.

    tt = context.template('header')

On error, a template.TemplateException object of type 'file' is
raised.

    try:
        tt = context.template('header')
    except TemplateException, e:
        print 'Failed to fetch template:', e


plugin(name, args)

Instantiates a plugin object by querying each of the LOAD_PLUGINS
providers.  The default LOAD_PLUGINS provider is a
template.plugins.Plugins object which attempts to load plugin modules,
according the various configuration items such as PLUGIN_BASE,
LOAD_PYTHON, etc., and then instantiate an object.  A list of
constructor arguments may be passed as the second parameter.  These
are forwarded to the plugin constructor.

Returns a plugin (which is generally an object, but doesn't have to
be).  Errors are thrown as TemplateException objects of type 'plugin'.

    plugin = context.plugin('DBI', 'dbi:msql:mydbname')


filter(name, args, alias)

Instantiates a filter subroutine by querying the LOAD_FILTERS
providers.  The default LOAD_FILTERS providers is a
template.filters.Filters object.  Additional arguments may be passed
along with an optional alias under which the filter will be cached for
subsequent use.  The filter is cached under its own 'name' if 'alias'
is undefined.  Subsequent calls to filter(name) will return the cached
entry, if defined.  Specifying arguments bypasses the caching
mechanism and always creates a new filter.  Errors are raised as
TemplateException objects of typre 'filter'.

    # static filter (no args)
    filter = context.filter('html')

    # dynamic filter (args) aliased to 'padright'
    filter = context.filter('format', '%60s', 'padright')

    # retrieve previous filter via 'padright' alias
    filter = context.filter('padright')


process(template, vars=None)

Processes a template named or referenced by the first parameter and
returns the output generated.  An optional dictionary may be passed as
the second parameter, containing variable definitions which will be
set before the template is processed.  The template is processed in
the current context, with no localisation of variables performed.

    output = context.process('header', { 'title': 'Hello World' })


include(template, vars)

Similar to process() above, but using localised variables.  Changes
made to any variables will only persist until the include() method
completes.

    output = context.include('header', { 'title': 'Hello World' })


throw(error_type, error_message, output)

Raises an exception in the form of a TemplateException object.  This
method may be passed an existing TemplateException object; a single
value containing an error message which is used to instantiate a
TemplateException of type 'None'; or a pair of values representing the
exception type and info from which a TemplateException object is
instantiated.  e.g.

    context.throw(exception)
    context.throw("I'm sorry Dave, I can't do that")
    context.throw('denied', "I'm sorry Dave, I can't do that")

The optional third parameter may be a reference to the current output
buffer, an object of type template.util.StringBuffer.  This is then
stored in the exception object when created, allowing the catcher to
examine and use the output up to the point at which the exception was
raised.

    output.write('blah blah blah')
    output.write('more rhubarb')
    context.throw('yack', 'Too much yacking', output)


catch(exception, output)

Catches an exception thrown, either as a reference to a
TemplateException object or some other value.  In the latter case, the
error string is promoted to a TemplateException object of 'None' type.
This method also accepts a reference to the current output buffer
which is passed to the TemplateException constructor, or is appended
to the output buffer stored in an existing TemplateException object,
if unique (i.e. not the same object).  By this process, the correct
state of the output buffer can be reconstructed for simple or nested
throws.


define_block(name, block)

Adds a new block definition to the internal BLOCKS cache.  The first
argument should contain the name of the block and the second a
template.document.Document object or template sub-routine, or template
text which is automatically compiled into a template sub-routine.
Returns a true value (the sub-routine or Document object) on success
or None on failure.  The relevant error message can be retrieved by
calling the error() method.


define_filter(name, filter, is_dynamic)

Adds a new filter definition by calling the store() method on each of
the LOAD_FILTERS providers until accepted (in the usual case, this is
accepted straight away by the one and only template.filters.Filters
provider).  The first argument should contain the name of the filter
and the second a reference to a filter subroutine.  The optional third
argument can be set to any true value to indicate that the subroutine
is a dynamic filter factory.  Returns a true value or raises a
'filter' exception on error.


localise(vars)

Clones the stash to create a context with localised variables.
Returns the newly cloned stash object which is also stored internally.

    stash = context.localise()


delocalise()

Restore the stash to its state prior to localisation.

    stash = context.delocalise()


visit(blocks)

This method is called by template.document.Document objects
immediately before they process their content.  It is called to
register any local BLOCK definitions with the context object so that
they may be subsequently delivered on request.


leave()

Complement to visit(), above.  Called by template.document.Document
objects immediately after they process their content.


reset()

Clears the local BLOCKS cache of any BLOCK definitions.  Any initial
set of BLOCKS specified as a configuration item to the constructor
will be reinstated.

"""


class Context:
  """Class defining a context in which a template document is processed.
  This is the runtime processing interface through which templates
  can access the functionality of the Template Toolkit.
  """

  DEBUG = None

  def __init__(self, config):
    self.__load_templates = util.listify(
      config.get("LOAD_TEMPLATES") or Provider(config))
    self.__load_plugins = util.listify(
      config.get("LOAD_PLUGINS") or Plugins(config))
    self.__load_filters = util.listify(
      config.get("LOAD_FILTERS") or Filters(config))
    prefix_map = config.get("PREFIX_MAP") or {}
    self.__filter_cache = {}
    self.__prefix_map = {}
    for key, value in prefix_map.items():
      if isinstance(value, str):
        self.__prefix_map[key] = util.slice(
          self.__load_templates, [int(x) for x in re.split(r"\D+", value)])
      else:
        self.__prefix_map[key] = value

    if "STASH" in config:
      self.__stash = config["STASH"]
    else:
      predefs = config.get("VARIABLES") or config.get("PRE_DEFINE") or {}
      predefs.setdefault("_DEBUG",
                         int(bool(config.get("DEBUG", 0) & DEBUG_UNDEF)))
      self.__stash = Stash(predefs)

    # compile any template BLOCKS specified as text
    blocks = config.get("BLOCKS") or {}
    b = {}
    for key, block in blocks.items():
      if isinstance(block, str):
        block = self.template(util.Literal(block))
      b[key] = block
    self.__init_blocks = self.__blocks = b

    self.__recursion = config.get("RECURSION", False)
    self.__eval_python = config.get("EVAL_PYTHON", False)
    self.__trim = config.get("TRIM", False)
    self.__blkstack = []
    self.__config = config
    if config.get("EXPOSE_BLOCKS") is not None:
      self.__expose_blocks = config.get("EXPOSE_BLOCKS")
    else:
      self.__expose_blocks = False
    self.__debug_format = config.get("DEBUG_FORMAT")
    self.__debug_dirs = config.get("DEBUG", 0) & DEBUG_DIRS
    if config.get("DEBUG") is not None:
      self.__debug = config["DEBUG"] & (DEBUG_CONTEXT | DEBUG_FLAGS)
    else:
      self.__debug = self.DEBUG

  def config(self):
    return self.__config

  def insert(self, files):
    """Insert the contents of a file without parsing."""
    # TODO: Clean this up; unify the way "files" is passed to this routine.
    files = unscalar(files)
    if is_seq(files):
      files = unscalar_list(files)
    else:
      files = [unscalar(files)]
    prefix = providers = text = None
    output = cStringIO.StringIO()

    for file in files:
      prefix, name = split_prefix(file)
      if prefix:
        providers = self.__prefix_map.get(prefix)
        if not providers:
          self.throw(ERROR_FILE, "no providers for file prefix '%s'" % prefix)
      else:
        providers = self.__prefix_map.get("default") or self.__load_templates

      for provider in providers:
        try:
          text = provider.load(name, prefix)
        except Exception, e:
          self.throw(ERROR_FILE, str(e))
        if text is not None:
          output.write(text)
          break
      else:
        self.throw(ERROR_FILE, "%s: not found" % file)

    return output.getvalue()

  def throw(self, error, info=None, output=None):
    """Raises a TemplateException.

    This method may be passed an existing TemplateException object; a
    single value containing an error message which is used to instantiate
    a TemplateException of type 'None'; or a pair of values representing
    the exception type and info from which a TemplateException object is
    instantiated.  e.g.

      context.throw(exception)
      context.throw("I'm sorry Dave, I can't do that")
      context.throw('denied', "I'm sorry Dave, I can't do that")

    An optional third parameter can be supplied in the last case which
    is a reference to the current output buffer containing the results
    of processing the template up to the point at which the exception
    was thrown.  The RETURN and STOP directives, for example, use this
    to propagate output back to the user, but it can safely be ignored
    in most cases.
    """
    error = unscalar(error)
    info = unscalar(info)
    if isinstance(error, TemplateException):
      raise error
    elif info is not None:
      raise TemplateException(error, info, output)
    else:
      raise TemplateException("None", error or "", output)

  def catch(self, error, output=None):
    """Called by various directives after catching an exception.

    The first parameter contains the errror which may be a sanitized
    reference to a TemplateException object (such as that raised by the
    throw() method above, a plugin object, and so on) or an error message
    raised from somewhere in user code.  The latter are coerced into
    'None' TemplateException objects.  Like throw() above, the current
    output buffer may be passed as an additional parameter.  As exceptions
    are thrown upwards and outwards from nested blocks, the catch() method
    reconstructs the correct output buffer from these fragments, storing
    it in the exception object for passing further onwards and upwards.  #

    Returns a TemplateException object.
    """
    if isinstance(error, TemplateException):
      if output:
        error.text(output)
      return error
    else:
      return TemplateException("None", error, output)

  def view(self, params=None):
    """Create a new View object bound to this context."""
    from template.view import View
    return View(self, unscalar(params))

  def process(self, template, params=None, localize=False):
    """Processes the template named or referenced by the first parameter.

    The optional second parameter may reference a dictionary of variable
    definitions.  These are set before the template is processed by
    calling update() on the stash.  Note that, unless the third parameter
    is true, the context is not localised and these, and any other
    variables set in the template will retain their new values after this
    method returns.  The third parameter is in place so that this method
    can handle INCLUDE calls: the stash will be localized.  # Returns the
    output of processing the template.  Errors are raised as
    TemplateException objects.
    """
    template = util.listify(unscalar(template))
    params = unscalar(params)
    compileds = []
    for name in template:
      compileds.append(self.template(name))
    if localize:
      self.__stash = self.__stash.clone(params)
    else:
      self.__stash.update(params)

    output = cStringIO.StringIO()

    try:
      # save current component
      try:
        component = self.__stash.get("component")
      except:
        component = None
      for name, compiled in zip(template, compileds):
        if not callable(compiled):
          element = compiled
        else:
          element = { "name": isinstance(name, str) and name or "",
                      "modtime": time.time() }
        if isinstance(component, Document):
          # FIXME: This block is not exercised by any test.
          elt = Accessor(element)
          elt["caller"] = component.name
          elt["callers"] = getattr(component, "callers", [])
          elt["callers"].append(component.name)
        self.__stash.set("component", element)
        if not localize:
          # merge any local blocks defined in the Template::Document
          # info our local BLOCKS cache
          if isinstance(compiled, Document):
            tblocks = compiled.blocks()
            if tblocks:
              self.__blocks.update(tblocks)
        if callable(compiled):
          tmpout = compiled(self)
        elif util.can(compiled, "process"):
          tmpout = compiled.process(self)
        else:
          self.throw("file", "invalid template reference: %s" % compiled)
        if self.__trim:
          tmpout = tmpout.strip()
        output.write(tmpout)
        # pop last item from callers
        if isinstance(component, Document):
          elt["callers"].pop()
      self.__stash.set("component", component)
    finally:
      if localize:
        # ensure stash is delocalised before dying
        self.__stash = self.__stash.declone()

    return output.getvalue()

  def include(self, template, params=None):
    """Similar to process() above but processing the template in a local
    context.

    Any variables passed by dictionary as the second parameter will be set
    before the template is processed and then revert to their original
    values before the method returns.  Similarly, any changes made to
    non-global variables within the template will persist only until the
    template is processed.

    Returns the output of processing the template.  Errors are raised as
    TemplateException objects.
    """
    return self.process(template, params, True)

  def localise(self, *args):
    """The localise() method creates a local copy of the current stash,
    allowing the existing state of variables to be saved and later
    restored via delocalise().

    A dictionary may be passed containing local variable definitions
    which should be added to the cloned namespace.  These values
    persist until delocalisation.
    """
    self.__stash = self.__stash.clone(*args)
    return self.__stash

  def delocalise(self):
    self.__stash = self.__stash.declone()

  def plugin(self, name, args=None):
    """Calls on each of the LOAD_PLUGINS providers in turn to fetch()
    (i.e. load and instantiate) a plugin of the specified name.

    Additional parameters passed are propagated to the plugin's
    constructor.  Returns a reference to a new plugin object or other
    object.  On error, a TemplateException is raiased.
    """
    args = unscalar_list(args)
    for provider in self.__load_plugins:
      plugin = provider.fetch(name, args, self)
      if plugin:
        return plugin
    self.throw(ERROR_PLUGIN, "%s: plugin not found" % name)

  def filter(self, name, args=None, alias=None):
    """Similar to plugin() above, but querying the LOAD_FILTERS providers
    to return filter instances.

    An alias may be provided which is used to save the returned filter
    in a local cache.
    """
    name = unscalar(name)
    args = unscalar_list(args or [])
    filter = None
    if not args and isinstance(name, str):
      filter = self.__filter_cache.get(name)
      if filter:
        return filter
    for provider in self.__load_filters:
      filter = provider.fetch(name, args, self)
      if filter:
        if alias:
          self.__filter_cache[alias] = filter
        return filter
    self.throw("%s: filter not found" % name)

  def reset(self, blocks=None):
    """Reset the state of the internal BLOCKS hash to clear any BLOCK
    definitions imported via the PROCESS directive.  Any original BLOCKS
    definitions passed to the constructor will be restored.
    """
    self.__blkstack = []
    self.__blocks = self.__init_blocks.copy()

  def template(self, name):
    """General purpose method to fetch a template and return it in compiled
    form.

    In the usual case, the name parameter will be a simple string
    containing the name of a template (e.g. 'header').  It may also be
    a template.document.Document object (or sub-class) or a callable
    object.  These are considered to be compiled templates and are
    returned intact.  Finally, it may be a file-like object with a
    read() method.

    Templates may be cached at one of 3 different levels.  The
    internal BLOCKS member is a local cache which holds references to
    all template blocks used or imported via PROCESS since the
    context's reset() method was last called.  This is checked first
    and if the template is not found, the method then walks down the
    BLOCKSTACK list.  This contains references to the block definition
    tables in any enclosing Documents that we're visiting (e.g. we've
    been called via an INCLUDE and we want to access a BLOCK defined
    in the template that INCLUDE'd us).  If nothing is defined, then
    we iterate through the LOAD_TEMPLATES providers list as a 'chain
    of responsibility' (see Design Patterns) asking each object to
    fetch() the template if it can.

    Returns the compiled template, or raises a TemplateException on error.
    """
    if isinstance(name, Document) or callable(name):
      return name
    shortname = name
    prefix = providers = None
    if isinstance(name, str):
      for block in [self.__blocks] + self.__blkstack:
        template = block.get(name)
        if template:
          return template
      prefix, shortname = split_prefix(shortname)
      if prefix:
        providers = self.__prefix_map.get(prefix)
        if not providers:
          self.throw(ERROR_FILE, "no providers for template prefix '%s'" %
                     prefix)
    providers = (providers
                 or self.__prefix_map.get("default")
                 or self.__load_templates)

    blockname = ""
    while shortname:
      for provider in providers:
        try:
          template = provider.fetch(shortname, prefix)
        except Exception, e:
          if isinstance(e, TemplateException) and e.type() == ERROR_FILE:
            self.throw(e)
          else:
            self.throw(ERROR_FILE, str(e))

        if template is None:
          continue

        if blockname:
          template = template.blocks().get(blockname)
          if template:
            return template
        else:
          return template
      if not isinstance(shortname, str) or not self.__expose_blocks:
        break
      match = re.search(r"/([^/]+)$", shortname)
      if not match:
        break
      shortname = shortname[:match.start()] + shortname[match.end():]
      if blockname:
        blockname = "%s/%s" % (match.group(1), blockname)
      else:
        blockname = match.group(1)

    # TODO: This is the error thrown when a template has syntax
    # errors.  Confusing!  Is this what the Perl version does?
    self.throw(ERROR_FILE, "%s: not found" % name)

  def stash(self):
    """Simple accessor for the local stash object."""
    return self.__stash

  def define_vmethod(self, *args):
    """Passes all args on to stash.define_vmethod."""
    self.__stash.define_vmethod(*args)

  def visit(self, document, blocks):
    """Each template.document.Document calls the visit() method on the
    context before processing itself.

    It passes the dictionary of named BLOCKs defined within the document,
    allowing them to be added to the internal BLKSTACK list which is
    subsequently used by template() to resolve templates.  from a
    provider.
    """
    self.__blkstack.insert(0, blocks)

  def leave(self):
    """The leave() method is called when the document has finished processing
    itself.

    This removes the entry from the BLKSTACK list that was added visit()
    above.  For persistence of BLOCK definitions, the process() method
    (i.e. the PROCESS directive) does some extra magic to copy BLOCKs into
    a shared hash.
    """
    self.__blkstack.pop(0)

  def define_block(self, name, block):
    """Adds a new BLOCK definition to the local BLOCKS cache.

    block may be specified as a callable or template.document.Document
    object or as text which is compiled into a template.  Returns a true
    value ('block' or the compiled block reference) if successful, or
    raises a TemplateException on failure.
    """
    # NOTE: This function is entirely untested by the test suite.
    if isinstance(block, str):
      block = self.template(util.Literal(block))
    self.__blocks[name] = block

  def define_filter(self, name, filter, dynamic=False):
    """Adds a new FILTER definition to the local FILTER_CACHE."""
    if dynamic:
      filter = util.dynamic_filter(filter)
    for provider in self.__load_filters:
      try:
        provider.store(name, filter)
        return 1
      except Exception, e:
        self.throw(ERROR_FILTER, e)
    self.throw(ERROR_FILTER,
               "FILTER providers declined to store filter %s" % name)

  def eval_python(self):
    return self.__eval_python

  def trim(self):
    return self.__trim

  def load_templates(self):
    return self.__load_templates

  def load_plugins(self):
    return self.__load_plugins

  def load_filters(self):
    return self.__load_filters

  def recursion(self):
    return self.__recursion


PREFIX_RE = re.compile(r"(\w{%d,}):(.*)" % (int(os.name == "nt") + 1), re.S)

def split_prefix(name):
  match = PREFIX_RE.match(name)
  return match and match.groups() or (None, name)


class Accessor:
  """Utility class that provides item access to either the items or
  attributes of a given object--the former if it is a dict, the latter
  otherwise.
  """
  def __init__(self, obj):
    self.obj = obj
    if isinstance(obj, dict):
      self.get, self.set = operator.getitem, operator.setitem
    else:
      self.get, self.set = getattr, setattr

  def __getitem__(self, attr):
    return self.get(self.obj, attr)

  def __setitem__(self, attr, value):
    self.set(self.obj, attr, value)
