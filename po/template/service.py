#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

import sys

from template.config import Config
from template.constants import DEBUG_SERVICE
from template.util import StringBuffer, TemplateException, is_seq


"""

NAME

template.service.Service - General purpose template processing service

SYNOPSIS

    import template.service

    service = template.service.Service({
        'PRE_PROCESS': [ 'config', 'header' ],
        'POST_PROCESS': 'footer',
        'ERROR': {
            'user': 'user/index.html',
            'dbi': 'error/database',
            'default': 'error/default',
        }
    })

    try:
        output = service.process(template_name, replace)
    except TemplateException, e:
        ...


DESCRIPTION

The Service class implements an object class for providing
a consistent template processing service.

Standard header (PRE_PROCESS) and footer (POST_PROCESS) templates may
be specified which are prepended and appended to all templates
processed by the service (but not any other templates or blocks
INCLUDEd or PROCESSed from within).  An ERROR dict may be specified
which redirects the service to an alternate template file in the case
of uncaught exceptions being thrown.  This allows errors to be
automatically handled by the service and a guaranteed valid response
to be generated regardless of any processing problems encountered.

A default Service object is created by the Template module.  Any
Service options may be passed to the Template new() constructor method
and will be forwarded to the Service constructor.

    import template

    tmpl = template.Template({
        'PRE_PROCESS': 'header',
        'POST_PROCESS': 'footer',
    })

Similarly, the Service constructor will forward all configuration
parameters onto other default objects (e.g. Context) that it may
need to instantiate.

A Service object (or subclass/derivative) can be explicitly
instantiated and passed to the Template constructor method as the
SERVICE item.

    import template
    import template.service

    service = template.service.Service({
        'PRE_PROCESS': 'header',
        'POST_PROCESS': 'footer',
    })

    tmpl = template.Template({
        'SERVICE': service,
    })

The Service class can be sub-classed to create custom service
handlers.

    import template
    import myorg.template.service

    service = myorg.template.service.Service({
	'PRE_PROCESS': 'header',
	'POST_PROCESS': 'footer',
	'COOL_OPTION': 'enabled in spades',
    });

    tmpl = template.Template({
	'SERVICE': service,
    })

The Template class uses the Config service() factory method to create
a default service object when required.  The Config.SERVICE global
variable may be set to specify an alternate service module.  This will
be loaded automatically and its constructor called by the service()
factory method when a default service object is required.  Thus the
previous example could be written as:

    import template
    import template.config

    template.config.SERVICE = ('myorg.template.service', 'Service')

    tmpl = template.Template({
	'PRE_PROCESS': 'header',
	'POST_PROCESS': 'footer',
	'COOL_OPTION': 'enabled in spades',
    })

METHODS
=======

__init__(config)

The new() constructor method is called to instantiate a Service
object.  Configuration parameters may be specified via the config
parameter, a dictionary.

    service1 = template.service.Service({
	'PRE_PROCESS': 'header',
	'POST_PROCESS': 'footer',
    })

    service2 = template.service.Service({ 'ERROR': 'error.html' })

The following configuration items may be specified:

PRE_PROCESS, POST_PROCESS
-------------------------

These values may be set to contain the name(s) of template files
(relative to INCLUDE_PATH) which should be processed immediately
before and/or after each template.  These do not get added to
templates processed into a document via directives such as INCLUDE,
PROCESS, WRAPPER etc.

    service = template.service.Service({
	'PRE_PROCESS': 'header',
	'POST_PROCESS': 'footer',
    })

Multiple templates may be specified as a sequence object.  Each is
processed in the order defined.

    service = template.service.Service({
	'PRE_PROCESS': [ 'config', 'header' ],
	'POST_PROCESS': 'footer',
    })

Alternately, multiple template may be specified as a single string,
delimited by ':'.  This delimiter string can be changed via the
DELIMITER option.

    service = template.service.Service({
	'PRE_PROCESS': 'config:header',
	'POST_PROCESS': 'footer',
    })

The PRE_PROCESS and POST_PROCESS templates are evaluated in the same
variable context as the main document and may define or update
variables for subsequent use.

config:

    [% # set some site-wide variables
       bgcolor = '#ffffff'
       version = 2.718
    %]

header:

    [% DEFAULT title = 'My Funky Web Site' %]
    <html>
    <head>
    <title>[% title %]</title>
    </head>
    <body bgcolor="[% bgcolor %]">

footer:

    <hr>
    Version [% version %]
    </body>
    </html>

The template.document.Document object representing the main template
being processed is available within PRE_PROCESS and POST_PROCESS
templates as the 'template' variable.  Metadata items defined via the
META directive may be accessed accordingly.

    service.process('mydoc.html', vars)

mydoc.html:

    [% META title = 'My Document Title' %]
    blah blah blah
    ...

header:

    <html>
    <head>
    <title>[% template.title %]</title></head>
    <body bgcolor="[% bgcolor %]">


PROCESS
-------

The PROCESS option may be set to contain the name(s) of template files
(relative to INCLUDE_PATH) which should be processed instead of the
main template passed to the template.service.Service process() method.
This can be used to apply consistent wrappers around all templates,
similar to the use of PRE_PROCESS and POST_PROCESS templates.

    service = template.service.Service({
	'PROCESS': 'content',
    })

    # processes 'content' instead of 'foo.html'
    service.process('foo.html')

A reference to the original template is available in the 'template'
variable.  Metadata items can be inspected and the template can be
processed by specifying it as a variable reference (i.e. prefixed by
'$') to an INCLUDE, PROCESS or WRAPPER directive.

content:

    <html>
    <head>
    <title>[% template.title %]</title>
    </head>

    <body>
    [% PROCESS $template %]
    <hr>
    &copy; Copyright [% template.copyright %]
    </body>
    </html>

foo.html:

    [% META
       title     = 'The Foo Page'
       author    = 'Fred Foo'
       copyright = '2000 Fred Foo'
    %]
    <h1>[% template.title %]</h1>
    Welcome to the Foo Page, blah blah blah

output:

    <html>
    <head>
    <title>The Foo Page</title>
    </head>

    <body>
    <h1>The Foo Page</h1>
    Welcome to the Foo Page, blah blah blah
    <hr>
    &copy; Copyright 2000 Fred Foo
    </body>
    </html>


ERROR
-----

The ERROR (or ERRORS if you prefer) configuration item can be used to
name a single template or specify a dict mapping exception types to
templates which should be used for error handling.  If an uncaught
exception is raised from within a template then the appropriate error
template will instead be processed.

If specified as a single value then that template will be processed
for all uncaught exceptions.

    service = template.service.Service({
	'ERROR': 'error.html'
    })

If the ERROR item is a dict, the keys are assumed to be exception
types and the relevant template for a given exception will be
selected.  A 'default' template may be provided for the general case.
Note that 'ERROR' can be pluralised to 'ERRORS' if you find it more
appropriate in this case.

    service = template.service.Service({
	'ERRORS': {
	    'user': 'user/index.html',
	    'dbi': 'error/database',
	    'default': 'error/default',
	},
    })

In this example, any 'user' exceptions thrown will cause the
'user/index.html' template to be processed, 'dbi' errors are handled
by 'error/database' and all others by the 'error/default' template.
Any PRE_PROCESS and/or POST_PROCESS templates will also be applied
to these error templates.

Note that exception types are hierarchical and a 'foo' handler will
catch all 'foo.*' errors (e.g. foo.bar, foo.bar.baz) if a more
specific handler isn't defined.

    service = template.service.Service({
	'ERROR': {
	    'user.login': 'user/login.html',
	    'user.passwd': 'user/badpasswd.html',
	    'user': 'user/index.html',
	    'default': 'error/default',
	},
    });

In this example, any template processed by the service object, or
other templates or code called from within, can raise a 'user.login'
exception and have the service redirect to the 'user/login.html'
template.  Similarly, a 'user.passwd' exception has a specific
handling template, 'user/badpasswd.html', while all other 'user' or
'user.*' exceptions cause a redirection to the 'user/index.html' page.
All other exception types are handled by 'error/default'.

Exceptions can be raised in a template using the THROW directive,

    [% THROW user.login 'no user id: please login' %]

or by calling the throw() method on the current template.context.Context
object,

    context.throw('user.passwd', 'Incorrect Password');
    context.throw('Incorrect Password');    # type 'None'

or from Python code by raising a template.TemplateException object,

    raise template.TemplateException('user.denied', 'Invalid User ID')


AUTO_RESET
---------0

The AUTO_RESET option is set by default and causes the local BLOCKS
cache for the template.context.Context object to be reset on each call
to the Template process() method.  This ensures that any BLOCKs
defined within a template will only persist until that template is
finished processing.  This prevents BLOCKs defined in one processing
request from interfering with other independent requests subsequently
processed by the same context object.

The BLOCKS item may be used to specify a default set of block
definitions for the template.context.Context object.  Subsequent BLOCK
definitions in templates will over-ride these but they will be
reinstated on each reset if AUTO_RESET is enabled (default), or if the
template.context.Context reset() method is called.


DEBUG
-----

The DEBUG option can be used to enable debugging messages from the
template.service.Service module by setting it to include the
DEBUG_SERVICE value.

    import template.constants

    tmpl = template.Template->new({
	'DEBUG': template.constants.DEBUG_SERVICE,
    })


process(input, replace)

The process() method is called to process a template specified as the
first parameter, input.  This may be a file name, file object, or a
template.Literal object that contains the template text.  An
additional dict may be passed containing template variable
definitions.

The method processes the template, adding any PRE_PROCESS or POST_PROCESS
templates defined, and returns the output text.  An uncaught exception thrown
by the template will be handled by a relevant ERROR handler if defined.
Errors that occur in the PRE_PROCESS or POST_PROCESS templates, or those that
occur in the main input template and aren't handled, cause a
template.TemplateException to be raised.


context()

Returns a reference to the internal context object which is, by default, an
instance of the template.context.Context class.

"""


class Service:
  """Class implementing a template processing service which wraps a
  template within PRE_PROCESS and POST_PROCESS templates and offers
  ERROR recovery.
  """

  def __init__(self, config=None):
    config = config or {}
    delim = config.get("DELIMITER", ":")

    # coerce PRE_PROCESS, PROCESS, and POST_PROCESS to lists if necessary,
    # by splitting on non-word characters
    self.__preprocess = Split(config.get("PRE_PROCESS"), delim)
    self.__process = Split(config.get("PROCESS"), delim)
    self.__postprocess = Split(config.get("POST_PROCESS"), delim)
    self.__wrapper = Split(config.get("WRAPPER"), delim)

    # unset PROCESS option unless explicitly specified in config
    if config.get("PROCESS") is None:
      self.__process = None

    self.__error = config.get("ERROR") or config.get("ERRORS")
    self.__autoreset = config.get("AUTO_RESET") is None or \
                       config.get("AUTO_RESET")
    self.__debug = config.get("DEBUG", 0) & DEBUG_SERVICE
    self.__context = config.get("CONTEXT") or Config.context(config)
    if not self.__context:
      raise TemplateException()

  def context(self):
    return self.__context

  def process(self, template, params=None):
    """Process a template within a service framework.

    A service may encompass PRE_PROCESS and POST_PROCESS templates and
    an ERROR dictionary which names templates to be substituted for
    the main template document in case of error.  Each service
    invocation begins by resetting the state of the context object via
    a call to reset().  The AUTO_RESET option may be set to 0
    (default: 1) to bypass this step.
    """
    context = self.__context
    output = StringBuffer()
    procout = StringBuffer()

    if self.__autoreset:
      context.reset()

    template = context.template(template)

    # localise the variable stash with any parameters passed
    # and set the 'template' variable
    params = params or {}
    if not callable(template):
      params["template"] = template
    context.localise(params)

    try:
      for name in self.__preprocess:
        output.write(context.process(name))
      if self.__process is not None:
        proc = self.__process
      else:
        proc = [template]
      try:
        for name in proc:
          procout.write(context.process(name))
      except TemplateException, e:
        procout.reset(self.__recover(e))

      procout = procout.get()
      for name in reversed(self.__wrapper):
        procout = context.process(name, {"content": procout})
      output.write(procout)

      for name in self.__postprocess:
        output.write(context.process(name))

    finally:
      context.delocalise()
      if "template" in params:
        del params["template"]

    return output.get()

  def __recover(self, exception):
    """Examines the internal ERROR dictionary to find a handler
    suitable for the passed exception object.

    Selecting the handler is done by delegation to the exception's
    select_handler() method, passing the set of handler keys as
    arguments.  A 'default' handler may also be provided.  The handler
    value represents the name of a template which should be processed.
    """
    if not isinstance(exception, TemplateException):
      return None

    # A 'stop' exception is thrown by [% STOP %] - we return the output
    # buffer stored in the exception object.
    if exception.type() == "stop":
      return exception.text()

    if not self.__error:
      raise exception

    if not isinstance(self.__error, dict):
      handler = self.__error
    else:
      hkey = exception.select_handler(self.__error.keys())
      if hkey:
        handler = self.__error.get(hkey)
      else:
        handler = self.__error.get("default")
        if not handler:
          raise exception

    handler = self.__context.template(handler)
    self.__context.stash().set("error", exception)
    return self.__context.process(handler)


def Split(param, delimiter):
  if param:
    if not is_seq(param):
      param = str(param).split(delimiter)
    return param
  else:
    return []
