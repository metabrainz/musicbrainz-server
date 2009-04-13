# coding: latin-1
#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

import errno
import os
import re
import sys

from template import util
from template.constants import *
from template.plugin.filter import Filter
from template.util import Literal, EvaluateCode, TemplateException, \
     dynamic_filter, numify, registrar, unpack

"""
template.filters - Post-processing filters for template blocks


SYNOPSIS

    import template.filters

    filters = template.filters.Filters(config)

    try:
      filter = filters.fetch(name, args, context)
    except TemplateException, e:
      # Handle error.
    if filter is None:
      # Request was declined.


DESCRIPTION

The template.filters.Filters class implements a provider for creating
and/or returning subroutines that implement the standard filters.
Additional custom filters may be provided via the FILTERS options.


METHODS

new(params)

Constructor which instantiates and returns a template.filters.Filters
object.  A dictionary of configuration items may be passed as a
parameter.  These are described below.

    filters = template.filters.Filters({
        'FILTERS': { ... },
    })

    tt = template.Template({
        'LOAD_FILTERS': [ filters ],
    })

A default Filters object is created by the template module if the
LOAD_FILTERS option isn't specified.  All configuration parameters are
forwarded to the constructor.

    tt = template.Template({
        'FILTERS': { ... },
    })

fetch(name, args, context)

Called to request that a filter of a given name be provided.  The name
of the filter should be specified as the first parameter.  This should
be one of the standard filters or one specified in the FILTERS
configuration dictionary.  The second argument should be a list
containing configuration parameters for the filter.  This may be
specified as 0, or None where no parameters are provided.  The third
argument should be the current template.context.Context object.

The method returns a filter sub-routine on success.  It may also
return None to decline the request, to allow delegation onto other
filter providers in the LOAD_FILTERS chain of responsibility.  On
error, a TemplateException is raised.

When the TOLERANT option is set, None is returned when an exception would
otherwise be raised.


CONFIGURATION OPTIONS

The following list details the configuration options that can be provided
to the Filters constructor.

FILTERS

The FILTERS option can be used to specify custom filters which can
then be used with the FILTER directive like any other.  These are
added to the standard filters which are available by default.  Filters
specified via this option will mask any standard filters of the same
name.

The FILTERS option should be specified as a dictionary
in which each key represents the name of a filter.  The corresponding
value should be a callable object.  If the object has an attribute
"dynamic_filter" which is true, the filter is taken to by dynamic;
otherwise, it is taken to be static.  The template.util module offers
a function decorator dynamic_filter which sets the attribute to True:

    @template.util.dynamic_filter
    def my_dynamic_factory(*args):
      ...

    filters = template.filters.Filters({
        'FILTERS': {
            'sfilt1': static_filter,
            'dfilt1': my_dynamic_factory,
            'dfilt2': template.util.dynamic_filter(another_dynamic_factory),
        },
    })

Additional filters can be specified at any time by calling the
define_filter() method on the current template.context.Context object.
The method accepts a filter name, a filter subroutine, and an optional
boolean flag to indicate if the filter is dynamic.

    context = template.context()
    context.define_filter('new_html', new_html)
    context.define_filter('new_repeat', new_repeat, 1)

Static filters are those where a single function is used
for all invocations of a particular filter.  Filters that don't accept
any configuration parameters (e.g. 'html') can be implemented statically.  The subroutine is simply returned
when that particular filter is requested.  The subroutine is called to
filter the output of a template block which is passed as the only
argument.  The subroutine should return the modified text.

    def static_filter(text):
      # do something to modify $text...
      return text

The following template fragment:

    [% FILTER sfilt1 %]
    Blah blah blah.
    [% END %]

is approximately equivalent to:

    static_filter("\nBlah blah blah.\n")

Filters that can accept parameters (e.g. 'truncate') should be
implemented dynamically.  In this case, the subroutine is taken to be
a filter 'factory' that is called to create a unique filter function
each time one is requested.  A reference to the current
template.context.Context object is passed as the first parameter,
followed by any additional parameters specified.  The function should
return another function which implements the filter.

    def dynamic_filter_factory(context, *args):
      def filter(text):
        # do something to modify text...
        return text
      return filter

The following template fragment:

    [% FILTER dfilt1(123, 456) %]
    Blah blah blah
    [% END %]

is approximately equivalent to:

    filter = dynamic_filter_factory(context, 123, 456)
    filter("\nBlah blah blah.\n")

See the FILTER directive for further examples.


TOLERANT

The TOLERANT flag is used by the various Template Toolkit provider
modules (template.provider, template.plugins, template.filters) to
control their behaviour when errors are encountered.  By default, any
errors are reported as such, with the request for the particular
resource (template, plugin, filter) being denied and an exception
raised.  When the TOLERANT flag is set to any true values, errors will
be silently ignored and the provider will instead return None.  This
allows a subsequent provider to take responsibility for providing the
resource, rather than failing the request outright.  If all providers
decline to service the request, either through tolerated failure or a
genuine disinclination to comply, then a 'resource not found' exception
is raised.


DEBUG

The DEBUG option can be used to enable debugging messages from the
template.filters module by setting it to include the DEBUG_FILTERS
value.

    from template.constants import *

    tt = template.Template({
	'DEBUG': DEBUG_FILTERS | DEBUG_PLUGINS,
    })


TEMPLATE TOOLKIT FILTERS

The following standard filters are distributed with the Template Toolkit.


format(format)

The 'format' filter takes a Python format string as a parameter
and formats each line of text accordingly.

    [% FILTER format('<!-- %-40s -->') %]
    This is a block of text filtered
    through the above format.
    [% END %]

output:

    <!-- This is a block of text filtered        -->
    <!-- through the above format.               -->

Python note:  Python's formatting operator "%" is stricter than
Perl's printf, and will raise an exception if the number of supplied
arguments does not match the number of format parameters.


upper

Folds the input to UPPER CASE.

    [% "hello world" FILTER upper %]

output:

    HELLO WORLD


lower

Folds the input to lower case.

    [% "Hello World" FILTER lower %]

output:

    hello world


ucfirst

Folds the first character of the input to UPPER CASE.

    [% "hello" FILTER ucfirst %]

output:

    Hello


lcfirst

Folds the first character of the input to lower case.

    [% "HELLO" FILTER lcfirst %]

output:

    hELLO


trim

Trims any leading or trailing whitespace from the input text.  Particularly
useful in conjunction with INCLUDE, PROCESS, etc., having the same effect
as the TRIM configuration option.

    [% INCLUDE myfile | trim %]


collapse

Collapse any whitespace sequences in the input text into a single space.
Leading and trailing whitespace (which would be reduced to a single space)
is removed, as per trim.

    [% FILTER collapse %]

       The   cat

       sat    on

       the   mat

    [% END %]

output:

    The cat sat on the mat


repr

Passes text to Python's builtin 'repr' function.  Useful for escaping
strings in a PYTHON block, eg:

[% PYTHON %]
  print 'My name is', [% name | repr %], 'and I live at', [% address | repr %]
[% END %]


html

Converts the characters '<', '>', '&' and '\"' to '&lt;',
'&gt;', '&amp;', and '&quot;' respectively, protecting them from being
interpreted as representing HTML tags or entities.

    [% FILTER html %]
    Binary "<=>" returns -1, 0, or 1 depending on...
    [% END %]

output:

    Binary "&lt;=&gt;" returns -1, 0, or 1 depending on...


html_entity

The html filter is fast and simple but it doesn't encode the full
range of HTML entities that your text may contain.  The html_entity
filter uses the htmlentitydefs module to perform the encoding.  The
text will be encoded to convert all extended characters into their
appropriate HTML entities (e.g. converting 'é' to '&eacute;').

For further information on HTML entity encoding, see
http://www.w3.org/TR/REC-html40/sgml/entities.html.


html_para

This filter formats a block of text into HTML paragraphs.  A sequence of 
two or more newlines is used as the delimiter for paragraphs which are 
then wrapped in HTML <p>...</p> tags.

    [% FILTER html_para %]
    The cat sat on the mat.

    Mary had a little lamb.
    [% END %]

output:

    <p>
    The cat sat on the mat.
    </p>

    <p>
    Mary had a little lamb.
    </p>


html_break / html_para_break

Similar to the html_para filter described above, but uses the HTML tag
sequence <br><br> to join paragraphs.

    [% FILTER html_break %]
    The cat sat on the mat.

    Mary had a little lamb.
    [% END %]

output:

    The cat sat on the mat.
    <br>
    <br>
    Mary had a little lamb.


html_line_break

This filter replaces any newlines with <br> HTML tags, thus preserving
the line breaks of the original text in the HTML output.

    [% FILTER html_line_break %]
    The cat sat on the mat.
    Mary had a little lamb.
    [% END %]

output:

    The cat sat on the mat.<br>
    Mary had a little lamb.<br>


uri

This filter URI escapes the input text, converting any characters
outside of the permitted URI character set (as defined by RFC 2396)
into a %nn hex escape.

    [% 'my file.html' | uri %]

output:

    my%20file.html

The uri filter correctly encodes all reserved characters, including &,
@, /, ;, :, =, +, ? and $.  This filter is typically used to encode
parameters in a URL that could otherwise be interpreted as part of the
URL.  Here's an example:

    [% path  = 'http://tt2.org/example'
       back  = '/other?foo=bar&baz=bam'
       title = 'Earth: "Mostly Harmless"'
    %]
    <a href="[% path %]?back=[% back | uri %]&title=[% title | uri %]">

The output generated is rather long so we'll show it split across two
lines:

    <a href="http://tt2.org/example?back=%2Fother%3Ffoo%3Dbar%26
    baz%3Dbam&title=Earth%3A%20%22Mostly%20Harmless%22">

Without the uri filter the output would look like this (also split
across two lines).

    <a href="http://tt2.org/example?back=/other?foo=bar
    &baz=bam&title=Earth: "Mostly Harmless"">

In this rather contrived example we've manage to generate both a
broken URL (the repeated ? is not allowed) and a broken HTML element
(the href attribute is terminated by the first '"' after 'Earth: '
leaving 'Mostly Harmless"' dangling on the end of the tag in
precisely the way that harmless things shouldn't dangle). So don't do
that. Always use the uri filter to encode your URL parameters.

However, you should NOT use the uri filter to encode an entire URL.

   <a href="[% page_url | uri %]">   # WRONG!

This will incorrectly encode any reserved characters like ":" and "/"
and that's almost certainly not what you want in this case.  Instead
you should use the "url" (note spelling) filter for this purpose.

   <a href="[% page_url | url %]">   # CORRECT

Please note that this behaviour was changed in version 2.16 of the
Template Toolkit.  Prior to that, the uri filter did not encode the
reserved characters, making it technically incorrect according to the
RFC 2396 specification.  So we fixed it in 2.16 and provided the url
filter to implement the old behaviour of not encoding reserved
characters.

url

The url filter is a less aggressive version of the uri filter.  It
encodes any characters outside of the permitted URI character set (as
defined by RFC 2396) into "%nn" hex escapes.  However, unlike the uri
filter, the url filter does NOT encode the reserved characters &,
@, /, ;, :, =, +, ? and $.

indent(pad)

Indents the text block by a fixed pad string or width.  The 'pad' argument
can be specified as a string, or as a numerical value to indicate a pad
width (spaces).  Defaults to 4 spaces if unspecified.

    [% FILTER indent('ME> ') %]
    blah blah blah
    cabbages, rhubard, onions
    [% END %]

output:

    ME> blah blah blah
    ME> cabbages, rhubard, onions


truncate(length, dots)

Truncates the text block to the length specified, or a default length
of 32.  Truncated text will be terminated with '...' (i.e. the '...'
falls inside the required length, rather than appending to it).

    [% FILTER truncate(21) %]
    I have much to say on this matter that has previously
    been said on more than one occasion.
    [% END %]

output:

    I have much to say...

If you want to use something other than '...' you can pass that as a
second argument.

    [% FILTER truncate(26, '&hellip;') %]
    I have much to say on this matter that has previously
    been said on more than one occasion.
    [% END %]

output:

    I have much to say&hellip;


repeat(iterations)

Repeats the text block for as many iterations as are specified (default: 1).

    [% FILTER repeat(3) %]
    We want more beer and we want more beer,
    [% END %]
    We are the more beer wanters!

output:

    We want more beer and we want more beer,
    We want more beer and we want more beer,
    We want more beer and we want more beer,
    We are the more beer wanters!


remove(string)

Searches the input text for any occurrences of the specified string
and removes them.  A Python regular expression may be specified as the
search string.

    [% "The  cat  sat  on  the  mat" FILTER remove('\s+') %]

output:

    Thecatsatonthemat


replace(search, replace)

Similar to the remove filter described above, but taking a second parameter
which is used as a replacement string for instances of the search string.

    [% "The  cat  sat  on  the  mat" | replace('\s+', '_') %]

output:

    The_cat_sat_on_the_mat


redirect(file, options)

The 'redirect' filter redirects the output of the block into a separate
file, specified relative to the OUTPUT_PATH configuration item.

    [% FOREACH user = myorg.userlist %]
       [% FILTER redirect("users/${user.id}.html") %]
          [% INCLUDE userinfo %]
       [% END %]
    [% END %]

or more succinctly, using side-effect notation:

    [% INCLUDE userinfo
         FILTER redirect("users/${user.id}.html")
	   FOREACH user = myorg.userlist
    %]

A 'file' exception will be thrown if the OUTPUT_PATH option is undefined.

An optional 'binmode' argument can follow the filename to explicitly set
the output file to binary mode.

    [% PROCESS my/png/generator
         FILTER redirect("images/logo.png", binmode=1) %]

For backwards compatibility with earlier versions, a single true/false
value can be used to set binary mode.

    [% PROCESS my/png/generator
         FILTER redirect("images/logo.png", 1) %]

For the sake of future compatibility and clarity, if nothing else, we
would strongly recommend you explicitly use the named 'binmode' option
as shown in the first example.


eval / evaltt

The 'eval' filter evaluates the block as template text, processing
any directives embedded within it.  This allows template variables to
contain template fragments, or for some method to be provided for
returning template fragments from an external source such as a
database, which can then be processed in the template as required.

    vars = {
	'fragment': 'The cat sat on the [% place %]',
    }
    template.process(file, vars);

The following example:

    [% fragment | eval %]

is therefore equivalent to

    The cat sat on the [% place %]

The 'evaltt' filter is provided as an alias for 'eval'.


python

The 'python' filter evaluates the block as Python code.  The
EVAL_PYTHON option must be set to a true value or a 'python'
TemplateExecption will be thrown.

    [% my_python_code | python %]

In most cases, the [% PYTHON %] ... [% END %] block should suffice for
evaluating Python code, given that template directives are processed
before being evaluate as Python.  Thus, the previous example could
have been written in the more verbose form:

    [% PYTHON %]
    [% my_python_code %]
    [% END %]

as well as

    [% FILTER python %]
    [% my_python_code %]
    [% END %]


stdout(options)

The stdout filter prints the output generated by the enclosing block
to sys.stdout.

    [% PROCESS something/cool
           FILTER stdout %]

The stdout filter can be used to inside redirect, null or stderr
blocks to make sure that particular output goes to stdout. See the
null filter below for an example.


stderr

The stderr filter prints the output generated by the enclosing block to
sys.stderr.


null

The null filter prints nothing.  This is useful for plugins whose
methods return values that you don't want to appear in the output.
Rather than assigning every plugin method call to a dummy variable
to silence it, you can wrap the block in a null filter:

    [% FILTER null;
        USE im = GD.Image(100,100);
        black = im.colorAllocate(0,   0, 0);
        red   = im.colorAllocate(255,0,  0);
        blue  = im.colorAllocate(0,  0,  255);
        im.arc(50,50,95,75,0,360,blue);
        im.fill(50,50,red);
        im.png | stdout;
       END;
    -%]

Notice the use of the stdout filter to ensure that a particular expression
generates output to stdout.

"""


class Filters:
  FILTERS = {}  # Built-in filters

  def __init__(self, params):
    self.__filters = params.get("FILTERS") or {}
    self.__tolerant = bool(params.get("TOLERANT"))
    self.__debug = (params.get("DEBUG") or 0) & DEBUG_FILTERS

  def fetch(self, name, args, context):
    """Attempts to instantiate or return a filter function named by
    the first parameter, name, with additional constructor arguments
    passed as the second parameter, args.  A reference to the calling
    template.context.Context object is passed as the third paramter.

    Returns a filter function on success or None if the request was
    declined.  Raises a TemplateException on error.
    """
    if not isinstance(name, str):
      if not isinstance(name, Filter):
        return name
      factory = name.factory()
    else:
      factory = self.__filters.get(name) or self.FILTERS.get(name)
      if not factory:
        return None

    try:
      if not callable(factory):
        raise Error("invalid FILTER entry for '%s' (not callable)" % (name,))
      elif getattr(factory, "dynamic_filter", False):
        args = args or ()
        filter = factory(context, *args)
      else:
        filter = factory
      if not callable(filter):
        raise Error("invalid FILTER for '%s' (not callable)" % (name,))
    except Exception, e:
      if self.__tolerant:
        return None
      if not isinstance(e, TemplateException):
        e = TemplateException(ERROR_FILTER, e)
      raise e

    return filter

  def store(self, name, filter):
    """Stores a new filter in the internal __filters dictionary."""
    self.__filters[name] = filter

  def tolerant(self):
    """Simple accessor for the tolerant flag."""
    return self.__tolerant


class Error(Exception):
  """A trivial local exception class."""
  pass


register = util.registrar(Filters.FILTERS)

@register("html")
def html_filter(text):
  return str(text) \
         .replace("&", "&amp;") \
         .replace("<", "&lt;") \
         .replace(">", "&gt;") \
         .replace('"', "&quot;")


@register("html_para")
def html_paragraph(text):
  return ("<p>\n"
          + "\n</p>\n\n<p>\n".join(re.split(r"(?:\r?\n){2,}", str(text)))
          + "</p>\n")



@register("html_break", "html_para_break")
def html_para_break(text):
  return re.sub(r"(\r?\n){2,}", r"\1<br />\1<br />\1", str(text))


@register("html_line_break")
def html_line_break(text):
  return re.sub(r"(\r?\n)", r"<br />\1", str(text))


def _escape(match):
  return "%%%02X" % ord(match.group())


URI_REGEX = re.compile(r"[^-A-Za-z0-9_.!~*'()]")

@register("uri")
def uri_filter(text):
  return URI_REGEX.sub(_escape, str(text))


URL_REGEX = re.compile(r"[^-;\/?:@&=+\$,A-Za-z0-9_.!~*'()]")

@register("url")
def url_filter(text):
  return URL_REGEX.sub(_escape, str(text))


@register("upper")
def upper(text):
  return str(text).upper()


@register("lower")
def lower(text):
  return str(text).lower()


@register("ucfirst")
def ucfirst(text):
  text = str(text)
  if text:
    text = text[0].upper() + text[1:]
  return text


@register("lcfirst")
def lcfirst(text):
  text = str(text)
  if text:
    text = text[0].lower() + text[1:]
  return text


@register("stderr")
def stderr(*args):
  for arg in args:
    sys.stderr.write(str(arg))
  return ""


@register("trim")
def trim(text):
  return str(text).strip()


@register("null")
def null(text):
  return ""


@register("collapse")
def collapse(text):
  return re.sub(r"\s+", " ", str(text).strip())


@register("repr")
def repr_(text):
  return repr(str(text))


ENTITY_REGEX = re.compile(r"[^\n\r\t !#$%'-;=?-~]")

@register("html_entity")
@dynamic_filter
def html_entity_filter_factory(context):
  from htmlentitydefs import codepoint2name
  def encode(char):
    char = ord(char)
    name = codepoint2name.get(char)
    if name is not None:
      return "&%s;" % name
    else:
      return "%%%02X" % char
  def html_entity_filter(text=""):
    return ENTITY_REGEX.sub(lambda match: encode(match.group()), str(text))
  return html_entity_filter


@register("indent")
@dynamic_filter
def indent_filter_factory(context, pad=4):
  try:
    count = int(pad)
  except (ValueError, TypeError):
    pass
  else:
    if count >= 0:
      pad = " " * count
  def indent_filter(text=""):
    return re.sub(r"(?m)^(?=(?s).)", lambda _: str(pad), str(text))
  return indent_filter


@register("format")
@dynamic_filter
def format_filter_factory(context, formatstr="%s"):
  def format_filter(text=""):
    # The "rstrip" is to emulate Perl's strip, which elides trailing nulls.
    return "\n".join(str(formatstr) % string
                     for string in str(text).rstrip("\n").split("\n"))
  return format_filter


@register("truncate")
@dynamic_filter
def truncate_filter_factory(context, length=32, char="..."):
  length = numify(length)
  char = str(char)
  def truncate_filter(text=""):
    text = str(text)
    if len(text) <= length:
      return text
    else:
      return text[:length - len(char)] + char
  return truncate_filter


@register("repeat")
@dynamic_filter
def repeat_filter_factory(context, count=1):
  def repeat_filter(text=""):
    return str(text) * numify(count)
  return repeat_filter


@register("replace")
@dynamic_filter
def replace_filter_factory(context, search="", replace=""):
  def replace_filter(text=""):
    return re.sub(str(search), lambda _: str(replace), str(text))
  return replace_filter


@register("remove")
@dynamic_filter
def remove_filter_factory(context, search="", *args):
  def remove_filter(text=""):
    return re.sub(str(search), "", str(text))
  return remove_filter


@register("eval", "evaltt")
@dynamic_filter
def eval_filter_factory(context):
  def eval_filter(text=""):
    return context.process(util.Literal(str(text)))
  return eval_filter


@register("python")
@dynamic_filter
def python_filter_factory(context):
  if not context.eval_python():
    raise TemplateException("python", "EVAL_PYTHON is not set")
  def python_filter(text):
    return util.EvaluateCode(str(text), context, context.stash())
  return python_filter


@register("redirect", "file")
@dynamic_filter
def redirect_filter_factory(context, file, options=None):
  outpath = context.config().get("OUTPUT_PATH")
  if not outpath:
    raise TemplateException("redirect", "OUTPUT_PATH is not set")
  if re.search(r"(?:^|/)\.\./", file, re.MULTILINE):
    context.throw("redirect", "relative filenames are not supported: %s" % file)
  if not isinstance(options, dict):
    options = { "binmode": options }
  def redirect_filter(text=""):
    outpath = context.config().get("OUTPUT_PATH")
    if not outpath:
      return ""
    try:
      try:
        os.makedirs(outpath)
      except OSError, e:
        if e.errno != errno.EEXIST:
          raise
      outpath += "/" + str(file)
      if options.get("binmode"):
        mode = "wb"
      else:
        mode = "w"
      fh = open(outpath, mode)
      fh.write(text)
      fh.close()
    except Exception, e:
      raise TemplateException("redirect", e)
    return ""
  return redirect_filter


@register("stdout")
@dynamic_filter
def stdout_filter_factory(context, options=None):
  if not isinstance(options, dict):
    options = {"binmode": options}
  def stdout_filter(text):
    sys.stdout.write(str(text))
    return ""
  return stdout_filter
