#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

import os

from template import util
from template.service import Service
from template.config import Config
from template.util import Literal, TemplateException


"""

Template - Front-end module to the Template Toolkit


SYNOPSIS
========

  import template

  # some useful options (see below for full list)
  config = {
      'INCLUDE_PATH': '/search/path',  # or list
      'INTERPOLATE': 1,        # expand "$var" in plain text
      'POST_CHOMP': 1,         # cleanup whitespace
      'PRE_PROCESS': 'header', # prefix each template
      'EVAL_PYTHON': 1,        # evaluate Python code blocks
  };

  # create Template object
  tt = template.Template(config)

  # define template variables for replacement
  vars = {
      'var1': value,
      'var2': dict,
      'var3': list,
      'var4': code,
      'var5': object,
  };

  # specify input filename, or file handle, text reference, etc.
  input = 'myfile.html'

  # process input template, substituting variables
  tt.process(input, vars)


DESCRIPTION
===========

This documentation describes the Template class which is the direct
Python interface into the Template Toolkit.  It covers the use of the
class and gives a brief summary of configuration options and template
directives.


METHODS
=======

__init__(config=None)

The constructor initializes a new template.Template object.  A dict of
configuration items may be passed as a parameter.

    tt = template.Template({
    	'INCLUDE_PATH': '/usr/local/templates',
	'EVAL_PYTHON': 1,
    })

A reference to a new Template object is returned.  A
template.TemplateException is raised on error.


process(tt, vars=None, options=None)

processString(tt, vars=None, options=None)

The process() method is called to process a template.  The first
parameter indicates the input template as one of: a filename relative
to INCLUDE_PATH, if defined, or a file object from which the template
can be read.  The processString() variant accepts as its first
parameter a string containing the template text to be processed.  A
dict may be passed as the second parameter, containing definitions of
template variables.

    text = '[% INCLUDE header %]\nHello world!\n[% INCLUDE footer %]'

    try:
        # filename
        print tt.process('welcome.tt2')
        # template text
        print tt.processString(text)
        # file object
        print tt.process(os.fdopen(5))
    except template.TemplateException, e:
        print 'Got exception:', e


The processed template output is returned.

The optional 'options' dict providing further options for the output.
The only option currently supported is "binmode" which, when set to
any true value will ensure that files created will be opened in binary
mode.  (See the OUTPUT and OUPUT_PATH parameters, below.)

    tt.process(infile, vars, { 'binmode': 1 })

The OUTPUT configuration item can be used to specify an output
location to which the processed template will be written, in addition
to being returned.  The OUTPUT_PATH specifies a directory which should
be prefixed to all output locations specified as filenames.


Errors are represented in the Template Toolkit by objects of the
template.TemplateException class.  The type() and info() methods can
called on the object to retrieve the error type and information
string, respectively.  The as_string() method can be called to return
a string of the form '%s - %s' % (type, info).

    try:
        tt.process('somefile')
    except template.TemplateException, e:
        print 'error type:', e.type()
        print 'error info:', e.info()
        print e


service()

The Template module delegates most of the effort of processing
templates to an underlying template.service.Service object.  This
method returns a reference to that object.


context()

The template.service.Service class uses a core
template.context.Context object for runtime processing of templates.
This method returns a reference to that object and is equivalent to
tt.service.context().


CONFIGURATION SUMMARY
=====================

The following list gives a short summary of each Template Toolkit
configuration option.

Template Style and Parsing Options
----------------------------------

START_TAG, END_TAG

Define tokens that indicate start and end of directives (default: '[%' and
'%]').

TAG_STYLE

Set START_TAG and END_TAG according to a pre-defined style (default:
'template', as above).

PRE_CHOMP, POST_CHOMP

Remove whitespace before/after directives (default: 0/0).

TRIM

Remove leading and trailing whitespace from template output (default: 0).

INTERPOLATE

Interpolate variables embedded like $this or ${this} (default: 0).

ANYCASE

Allow directive keywords in lower case (default: 0 - UPPER only).


Template Files and Blocks
-------------------------

INCLUDE_PATH

One or more directories to search for templates.

DELIMITER

Delimiter for separating paths in INCLUDE_PATH (default: ':').

ABSOLUTE

Allow absolute file names, e.g. /foo/bar.html (default: False).

RELATIVE

Allow relative filenames, e.g. ../foo/bar.html (default: False).

DEFAULT

Default template to use when another not found.

BLOCKS

Dict pre-defining template blocks.

AUTO_RESET

Enabled by default causing BLOCK definitions to be reset each time a
template is processed.  Disable to allow BLOCK definitions to persist.

RECURSION

Flag to permit recursion into templates (default: False).


Template Variables
------------------

VARIABLES, PRE_DEFINE

Dict of variables and values to pre-define in the stash.


Runtime Processing Options
--------------------------

EVAL_PYTHON

Flag to indicate if PYTHON/RAWPYTHON blocks should be processed
(default: False).

PRE_PROCESS, POST_PROCESS

Name of template(s) to process before/after main template.

PROCESS

Name of template(s) to process instead of main template.

ERROR

Name of error template or reference to dict mapping error types to
templates.

OUTPUT

Default output location.

OUTPUT_PATH

Directory into which output files can be written.

DEBUG

Enable debugging messages.


Caching and Compiling Options
-----------------------------

CACHE_SIZE

Maximum number of compiled templates to cache in memory (default:
None - cache all)

COMPILE_EXT

Filename extension for compiled template files (default: None - don't
compile).

COMPILE_DIR

Root of directory in which compiled template files should be written
(default: None - don't compile).


Plugins and Filters
-------------------

PLUGINS

Reference to a dict mapping plugin names to Python modules and classes.

PLUGIN_BASE

One or more base classes under which plugins may be found.

LOAD_PYTHON

Flag to indicate regular Python modules should be loaded if a named
plugin can't be found (default: 0).

FILTERS

Dict mapping filter names to filter subroutines or factories.


Compatibility, Customisation and Extension
------------------------------------------

V1DOLLAR

Backwards compatibility flag enabling version 1.* handling (i.e. ignore it)
of leading '$' on variables (default: 0 - '$' indicates interpolation).

LOAD_TEMPLATES

List of template providers.

LOAD_PLUGINS

List of plugin providers.

LOAD_FILTERS

List of filter providers.

TOLERANT

Set providers to tolerate errors as declinations (default: False).

SERVICE

Reference to a custom service object (default: template.service.Service).

CONTEXT

Reference to a custom context object (default: template.context.Context).

STASH

Reference to a custom stash object (default: template.stash.Stash).

PARSER

Reference to a custom parser object (default: template.parser.Parser).

GRAMMAR

Reference to a custom grammar object (default: template.grammar.Grammar).


DIRECTIVE SUMMARY
-----------------

The following list gives a short summary of each Template Toolkit directive.
See the Template Toolkit documentation for full details.


GET

Evaluate and print a variable or value.

    [%   GET variable %]    # 'GET' keyword is optional

    [%       variable %]
    [%       hash.key %]
    [%         list.n %]
    [%     code(args) %]
    [% obj.meth(args) %]
    [%  "value: $var" %]

CALL

As per GET but without printing result (e.g. call code)

    [%  CALL variable %]

SET

Assign a values to variables.

    [% SET variable = value %]    # 'SET' also optional

    [%     variable = other_variable
    	   variable = 'literal text @ $100'
    	   variable = "interpolated text: $var"
    	   list     = [ val, val, val, val, ... ]
    	   list     = [ val..val ]
    	   hash     = { var => val, var => val, ... }
    %]

DEFAULT

Like SET above, but variables are only set if currently unset (i.e. have no
true value).

    [% DEFAULT variable = value %]

INSERT

Insert a file without any processing performed on the contents.

    [% INSERT legalese.txt %]

INCLUDE

Process another template file or block and include the output.  Variables
are localised.

    [% INCLUDE template %]
    [% INCLUDE template  var = val, ... %]

PROCESS

As INCLUDE above, but without localising variables.

    [% PROCESS template %]
    [% PROCESS template  var = val, ... %]

WRAPPER

Process the enclosed block WRAPPER ... END block then INCLUDE the
named template, passing the block output in the 'content' variable.

    [% WRAPPER template %]
       content...
    [% END %]

BLOCK

Define a named template block for subsequent INCLUDE, PROCESS, etc.,

    [% BLOCK template %]
       content
    [% END %]

FOREACH

Repeat the enclosed FOREACH ... END block for each value in the list.

    [% FOREACH variable = [ val, val, val ] %]	  # either
    [% FOREACH variable = list %]                 # or
    [% FOREACH list %]                            # or
       content...
       [% variable %]
    [% END %]

WHILE

Enclosed WHILE ... END block is processed while condition is true.

    [% WHILE condition %]
       content
    [% END %]

IF / UNLESS / ELSIF / ELSE

Enclosed block is processed if the condition is true / false.

    [% IF condition %]
       content
    [% ELSIF condition %]
	 content
    [% ELSE %]
	 content
    [% END %]

    [% UNLESS condition %]
       content
    [% # ELSIF/ELSE as per IF, above %]
       content
    [% END %]

SWITCH / CASE

Multi-way switch/case statement.

    [% SWITCH variable %]
    [% CASE val1 %]
       content
    [% CASE [ val2, val3 ] %]
       content
    [% CASE %]         # or [% CASE DEFAULT %]
       content
    [% END %]

MACRO

Define a named macro.

    [% MACRO name <directive> %]
    [% MACRO name(arg1, arg2) <directive> %]
    ...
    [% name %]
    [% name(val1, val2) %]

FILTER

Process enclosed FILTER ... END block then pipe through a filter.

    [% FILTER name %]			    # either
    [% FILTER name( params ) %]		    # or
    [% FILTER alias = name( params ) %]	    # or
       content
    [% END %]

USE

Load a "plugin" module, or any regular Python module if LOAD_PYTHON
option is set.

    [% USE name %]			    # either
    [% USE name( params ) %]		    # or
    [% USE var = name( params ) %]	    # or
    ...
    [% name.method %]
    [% var.method %]

PYTHON / RAWPYTHON

Evaluate enclosed blocks as Python code (requires EVAL_PYTHON option
to be set).

    [% PYTHON %]
	 # python code goes here
	 stash.set('foo', 10)
	 print "set 'foo' to ", stash.get('foo')
	 print context.include('footer', { 'var': val })
    [% END %]

    [% RAWPYTHON %]
       # raw python code goes here, no magic but fast.
       output.write('some output')
    [% END %]

TRY / THROW / CATCH / FINAL

Exception handling.

    [% TRY %]
	 content
       [% THROW type info %]
    [% CATCH type %]
	 catch content
       [% error.type %] [% error.info %]
    [% CATCH %]	# or [% CATCH DEFAULT %]
	 content
    [% FINAL %]
       this block is always processed
    [% END %]

NEXT

Jump straight to the next item in a FOREACH/WHILE loop.

    [% NEXT %]

LAST

Break out of FOREACH/WHILE loop.

    [% LAST %]

RETURN

Stop processing current template and return to including templates.

    [% RETURN %]

STOP

Stop processing all templates and return to caller.

    [% STOP %]

TAGS

Define new tag style or characters (default: [% %]).

    [% TAGS html %]
    [% TAGS <!-- --> %]

COMMENTS

Ignored and deleted.

    [% # this is a comment to the end of line
       foo = 'bar'
    %]

    [%# placing the '#' immediately inside the directive
        tag comments out the entire directive
    %]

"""


class Template:
  """Module implementing a simple, user-oriented front-end to the Template
  Toolkit.
  """

  DEBUG = False

  BINMODE = False

  def __init__(self, config=None):
    config = config or {}
    # Prepare a namespace handler for any CONSTANTS definition.
    constants = config.get("CONSTANTS")
    if constants:
      namespace = config.get("CONSTANTS_NAMESPACE", "constants")
      config.setdefault("NAMESPACE", {})[namespace] = (
        Config.constants(constants))
    self.__service = Service(config)
    self.__output = config.get("OUTPUT")
    self.__output_path = config.get("OUTPUT_PATH")

  def processString(self, template, vars=None, options=None):
    """A simple wrapper around process() that wraps its template argument
    in a Literal.
    """
    return self.process(Literal(template), vars, options)

  def process(self, template, vars=None, options=None):
    """Main entry point for the Template Toolkit.  Delegates most of the
    processing effort to the underlying Service object.
    """
    options = options or {}
    if options.setdefault("binmode", self.BINMODE) and self.DEBUG:
      util.Debug("set binmode\n")

    output = self.__service.process(template, vars)
    self.__MaybeWriteOutput(output, options["binmode"])
    return output

  def service(self):
    """Returns a reference to this object's Service object."""
    return self.__service

  def context(self):
    """Returns a reference to this object's Service object's Context
    object.
    """
    return self.__service.context()

  def __MaybeWriteOutput(self, text, binmode=False):
    if not self.__output:
      return
    if not isinstance(self.__output, str):
      self.__output.write(text)
    else:
      path = self.__output
      if self.__output_path:
        path = os.path.join(self.__output_path, path)
      if binmode:
        mode = "wb"
      else:
        mode = "w"
      fh = open(path, mode)
      fh.write(text)
      fh.close()

