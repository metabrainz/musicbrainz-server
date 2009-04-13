#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

import re
import sys

from template import util
from template.constants import *
from template.directive import Directive
from template.grammar import Grammar
from template.util import TemplateException


"""
template.parser - LALR(1) parser for compiling template documents


SYNOPSIS

    import template.parser

    parser = template.parser.Parser(config)
    template = parser.parse(text)


DESCRIPTION

The template.parser module implements a LALR(1) parser and associated
methods for parsing template documents into Python code.


PUBLIC METHODS

__init__(params)

The constructor initializes a new template.parser.Parser object.  A
dictionary may be supplied as a parameter to provide configuration
values.  These may include:

* START_TAG, END_TAG

The START_TAG and END_TAG options are used to specify character
sequences or regular expressions that mark the start and end of a
template directive.  The default values for START_TAG and END_TAG are
'[%' and '%]' respectively, giving us the familiar directive style:

    [% example %]

Any Python regex characters can be used and therefore should be
escaped (or use the re.escape function) if they are intended to
represent literal characters.

    parser = template.parser.Parser({
  	'START_TAG': re.escape('<+'),
  	'END_TAG': re.escape('+>'),
    })

example:

    <+ INCLUDE foobar +>

The TAGS directive can also be used to set the START_TAG and END_TAG values
on a per-template file basis.

    [% TAGS <+ +> %]

* TAG_STYLE

The TAG_STYLE option can be used to set both START_TAG and END_TAG
according to pre-defined tag styles.

    parser = template.parser.Parser({
  	'TAG_STYLE': 'star',
    })

Available styles are:

    template    [% ... %]               (default)
    template1   [% ... %] or %% ... %%  (TT version 1)
    metatext    %% ... %%               (Text::MetaText)
    star        [* ... *]               (TT alternate)
    php         <? ... ?>               (PHP)
    asp         <% ... %>               (ASP)
    mason       <% ...  >               (HTML::Mason)
    html        <!-- ... -->            (HTML comments)

Any values specified for START_TAG and/or END_TAG will over-ride those
defined by a TAG_STYLE.

The TAGS directive may also be used to set a TAG_STYLE

    [% TAGS html %]
    <!-- INCLUDE header -->

* PRE_CHOMP, POST_CHOMP

Anything outside a directive tag is considered plain text and is
generally passed through unaltered (but see the INTERPOLATE option).
This includes all whitespace and newlines characters surrounding
directive tags.  Directives that don't generate any output will leave
gaps in the output document.

Example:

    Foo
    [% a = 10 %]
    Bar

Output:

    Foo

    Bar

The PRE_CHOMP and POST_CHOMP options can help to clean up some of this
extraneous whitespace.  Both are disabled by default.

    parser = template.parser.Parser({
        'PRE_CHOMP': 1,
        'POST_CHOMP': 1,
    })

With PRE_CHOMP set to 1, the newline and whitespace preceding a
directive at the start of a line will be deleted.  This has the effect
of concatenating a line that starts with a directive onto the end of
the previous line.

        Foo E<lt>----------.
                       |
    ,---(PRE_CHOMP)----'
    |
    `-- [% a = 10 %] --.
                       |
    ,---(POST_CHOMP)---'
    |
    `-E<gt> Bar

With POST_CHOMP set to 1, any whitespace after a directive up to and
including the newline will be deleted.  This has the effect of joining
a line that ends with a directive onto the start of the next line.

If PRE_CHOMP or POST_CHOMP is set to 2, all whitespace including any
number of newline will be removed and replaced with a single space.
This is useful for HTML, where (usually) a contiguous block of
whitespace is rendered the same as a single space.

With PRE_CHOMP or POST_CHOMP set to 3, all adjacent whitespace
(including newlines) will be removed entirely.

These values are defined as CHOMP_NONE, CHOMP_ONE, CHOMP_COLLAPSE and
CHOMP_GREEDY constants in the template.constants module.  CHOMP_ALL
is also defined as an alias for CHOMP_ONE to provide backwards
compatability with earlier version of the Template Toolkit.

Additionally the chomp tag modifiers listed below may also be used for
the PRE_CHOMP and POST_CHOMP configuration.

     tt = template.Template({
        'PRE_CHOMP': '~',
        'POST_CHOMP': '-',
     })

PRE_CHOMP and POST_CHOMP can be activated for individual directives by
placing a '-' immediately at the start and/or end of the directive.

    [% FOREACH user IN userlist %]
       [%- user -%]
    [% END %]

This has the same effect as CHOMP_ONE in removing all whitespace
before or after the directive up to and including the newline.  The
template will be processed as if written:

    [% FOREACH user IN userlist %][% user %][% END %]

To remove all whitespace including any number of newlines, use the '~'
character instead.

    [% FOREACH user IN userlist %]

       [%~ user ~%]

    [% END %]

To collapse all whitespace to a single space, use the '=' character.

    [% FOREACH user IN userlist %]

       [%= user =%]

    [% END %]

Here the template is processed as if written:

    [% FOREACH user IN userlist %] [% user %] [% END %]

If you have PRE_CHOMP or POST_CHOMP set as configuration options then
you can use '+' to disable any chomping options (i.e.  leave the
whitespace intact) on a per-directive basis.

    [% FOREACH user = userlist %]
    User: [% user +%]
    [% END %]

With POST_CHOMP set to CHOMP_ONE, the above example would be parsed as
if written:

    [% FOREACH user = userlist %]User: [% user %]
    [% END %]

For reference, the PRE_CHOMP and POST_CHOMP configuration options may be set to any of the following:

     Constant      Value   Tag Modifier
     ----------------------------------
     CHOMP_NONE      0          +
     CHOMP_ONE       1          -
     CHOMP_COLLAPSE  2          =
     CHOMP_GREEDY    3          ~

* INTERPOLATE

The INTERPOLATE flag, when set to any true value will cause variable
references in plain text (i.e. not surrounded by START_TAG and
END_TAG) to be recognised and interpolated accordingly.

    parser = template.parser.Parser({
  	'INTERPOLATE': 1,
    })

Variables should be prefixed by a '$' to identify them.  Curly braces
can be used in the familiar Perl/shell style to explicitly scope the
variable name where required.

    # INTERPOLATE => 0
    <a href="http://[% server %]/[% help %]">
    <img src="[% images %]/help.gif"></a>
    [% myorg.name %]

    # INTERPOLATE => 1
    <a href="http://$server/$help">
    <img src="$images/help.gif"></a>
    $myorg.name

    # explicit scoping with {  }
    <img src="$images/${icon.next}.gif">

Note that a limitation in Perl's regex engine restricts the maximum
length of an interpolated template to around 32 kilobytes or possibly
less.  Files that exceed this limit in size will typically cause Perl
to dump core with a segmentation fault.  If you routinely process
templates of this size then you should disable INTERPOLATE or split
the templates in several smaller files or blocks which can then be
joined backed together via PROCESS or INCLUDE.

It is unknown whether this limitation is shared by the Python regex
engine.

* ANYCASE

By default, directive keywords should be expressed in UPPER CASE.  The
ANYCASE option can be set to allow directive keywords to be specified
in any case.

    # ANYCASE => 0 (default)
    [% INCLUDE foobar %]	# OK
    [% include foobar %]        # ERROR
    [% include = 10   %]        # OK, 'include' is a variable

    # ANYCASE => 1
    [% INCLUDE foobar %]	# OK
    [% include foobar %]	# OK
    [% include = 10   %]        # ERROR, 'include' is reserved word

One side-effect of enabling ANYCASE is that you cannot use a variable
of the same name as a reserved word, regardless of case.  The reserved
words are currently:

        GET CALL SET DEFAULT INSERT INCLUDE PROCESS WRAPPER
    IF UNLESS ELSE ELSIF FOR FOREACH WHILE SWITCH CASE
    USE PLUGIN FILTER MACRO PYTHON RAWPYTHON BLOCK META
    TRY THROW CATCH FINAL NEXT LAST BREAK RETURN STOP
    CLEAR TO STEP AND OR NOT MOD DIV END

The only lower case reserved words that cannot be used for variables,
regardless of the ANYCASE option, are the operators:

    and or not mod div

* V1DOLLAR

In version 1 of the Template Toolkit, an optional leading '$' could be placed
on any template variable and would be silently ignored.

    # VERSION 1
    [% $foo %]       ===  [% foo %]
    [% $hash.$key %] ===  [% hash.key %]

To interpolate a variable value the '${' ... '}' construct was used.
Typically, one would do this to index into a hash array when the key
value was stored in a variable.

example:

    vars = {
	users => {
	    'aba': { 'name': 'Alan Aardvark', ... },
	    'abw': { 'name': 'Andy Wardley', ... },
            ...
	},
	'uid': 'aba',
        ...
    }

    template.process('user/home.html', vars)

'user/home.html':

    [% user = users.${uid} %]     # users.aba
    Name: [% user.name %]         # Alan Aardvark

This was inconsistent with double quoted strings and also the
INTERPOLATE mode, where a leading '$' in text was enough to indicate a
variable for interpolation, and the additional curly braces were used
to delimit variable names where necessary.  Note that this use is
consistent with UNIX and Perl conventions, among others.

    # double quoted string interpolation
    [% name = "$title ${user.name}" %]

    # INTERPOLATE = 1
    <img src="$images/help.gif"></a>
    <img src="$images/${icon.next}.gif">

For version 2, these inconsistencies have been removed and the syntax
clarified.  A leading '$' on a variable is now used exclusively to
indicate that the variable name should be interpolated
(e.g. subsituted for its value) before being used.  The earlier example
from version 1:

    # VERSION 1
    [% user = users.${uid} %]
    Name: [% user.name %]

can now be simplified in version 2 as:

    # VERSION 2
    [% user = users.$uid %]
    Name: [% user.name %]

The leading dollar is no longer ignored and has the same effect of
interpolation as '${' ... '}' in version 1.  The curly braces may
still be used to explicitly scope the interpolated variable name
where necessary.

e.g.

    [% user = users.${me.id} %]
    Name: [% user.name %]

The rule applies for all variables, both within directives and in
plain text if processed with the INTERPOLATE option.  This means that
you should no longer (if you ever did) add a leading '$' to a variable
inside a directive, unless you explicitly want it to be interpolated.

One obvious side-effect is that any version 1 templates with variables
using a leading '$' will no longer be processed as expected.  Given
the following variable definitions,

    [% foo = 'bar'
       bar = 'baz'
    %]

version 1 would interpret the following as:

    # VERSION 1
    [% $foo %] => [% GET foo %] => bar

whereas version 2 interprets it as:

    # VERSION 2
    [% $foo %] => [% GET $foo %] => [% GET bar %] => baz

In version 1, the '$' is ignored and the value for the variable 'foo'
is retrieved and printed.  In version 2, the variable '$foo' is first
interpolated to give the variable name 'bar' whose value is then
retrieved and printed.

The use of the optional '$' has never been strongly recommended, but
to assist in backwards compatibility with any version 1 templates that
may rely on this "feature", the V1DOLLAR option can be set to 1
(default: 0) to revert the behaviour and have leading '$' characters
ignored.

    parser = template.parser.Parser->new({
	'V1DOLLAR': 1,
    });

* GRAMMAR

The GRAMMAR configuration item can be used to specify an alternate
grammar for the parser.  This allows a modified or entirely new
template language to be constructed and used by the Template Toolkit.

Source templates are compiled to Python code by the template.parser
module using the template.grammar module (by default) to define the
language structure and semantics.  Compiled templates are thus
inherently "compatible" with each other and there is nothing to prevent
any number of different template languages being compiled and used within
the same Template Toolkit processing environment (other than the usual
time and memory constraints).

The template.grammar file is constructed from a YACC like grammar
(using Parse::YAPP) and a skeleton module template.  These files are
provided, along with a small script to rebuild the grammar, in the
'parser' sub-directory of the distribution.  You don't have to know or
worry about these unless you want to hack on the template language or
define your own variant.  There is a README file in the same directory
which provides some small guidance but it is assumed that you know
what you're doing if you venture herein.  If you grok LALR parsers,
then you should find it comfortably familiar.

By default, an instance of the default template.grammar.Grammar will
be created and used automatically if a GRAMMAR item isn't specified.

    import myorg.template.grammar

    parser = template.parser.Parser({
       	'GRAMMAR': myorg.template.grammar.Grammar(),
    })

* DEBUG

The DEBUG option can be used to enable various debugging features of
the Template::Parser module.

    from template.constants import *

    tt = template.Template({
	'DEBUG': DEBUG_PARSER | DEBUG_DIRS,
    })

The DEBUG value can include any of the following.  Multiple values
should be combined using the logical OR operator, '|'.

** DEBUG_PARSER

This flag causes the Parser to generate debugging messages that show
the Python code generated by parsing and compiling each template.

** DEBUG_DIRS

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


parse(text)

The parse() method parses the text passed in the first parameter and
returns a dictionary of data defining the compiled representation of
the template text, suitable for passing to the
template.document.Document constructor.

Example:

    data = parser.parse(text)

The data dictionary returned contains a BLOCK item containing the
compiled Python code for the template, a DEFBLOCKS item containing a
dictionary of sub-template BLOCKs defined within in the template, and
a METADATA item containing a dictionary of metadata values defined in
META tags.

"""


CONTINUE = 0
ACCEPT   = 1
ERROR    = 2
ABORT    = 3

TAG_STYLE = {
  "default":   (r"\[%",   r"%\]"),
  "template1": (r"[[%]%", r"%[]%]"),
  "metatext":  (r"%%",    r"%%"),
  "html":      (r"<!--",  r"-->"),
  "mason":     (r"<%",    r">"),
  "asp":       (r"<%",    r"%>"),
  "php":       (r"<\?",   r"\?>"),
  "star":      (r"\[\*",  r"\*\]"),
}

TAG_STYLE["template"] = TAG_STYLE["tt2"] = TAG_STYLE["default"]

DEFAULT_STYLE = {
  "START_TAG":   TAG_STYLE["default"][0],
  "END_TAG":     TAG_STYLE["default"][1],
  "ANYCASE":     0,
  "INTERPOLATE": 0,
  "PRE_CHOMP":   0,
  "POST_CHOMP":  0,
  "V1DOLLAR":    0,
  "EVAL_PYTHON": 0,
}

ESCAPE = {"n": "\n", "r": "\r", "t": "\t"}

CHOMP_FLAGS = r"[-=~+]"

CHOMP_ALL = str(CHOMP_ALL)
CHOMP_COLLAPSE = str(CHOMP_COLLAPSE)
CHOMP_GREEDY = str(CHOMP_GREEDY)
CHOMP_NONE = str(CHOMP_NONE)

CHOMP_CONST = {
  "-": CHOMP_ALL,
  "=": CHOMP_COLLAPSE,
  "~": CHOMP_GREEDY,
  "+": CHOMP_NONE
}

PRE_CHOMP = {
  CHOMP_ALL:      lambda x: re.sub(r"(\n|^)[^\S\n]*\Z", "", x),
  CHOMP_COLLAPSE: lambda x: re.sub(r"\s+\Z", " ", x),
  CHOMP_GREEDY:   lambda x: re.sub(r"\s+\Z", "", x),
  CHOMP_NONE:     lambda x: x,
}

def postchomp(regex, prefix):
  regex = re.compile(regex)
  def strip(text, postlines):
    match = regex.match(text)
    if match:
      text = prefix + text[match.end():]
      postlines += match.group().count("\n")
    return text, postlines
  return strip

POST_CHOMP = {
  CHOMP_ALL:      postchomp(r"[^\S\n]*\n", ""),
  CHOMP_COLLAPSE: postchomp(r"\s+", " "),
  CHOMP_GREEDY:   postchomp(r"\s+", ""),
  CHOMP_NONE:     lambda x, y: (x, y),
}

def Chomp(x):
  return re.sub(r"[-=~+]", lambda m: CHOMP_CONST[m.group()], str(x))


GRAMMAR = re.compile(r"""
    # strip out any comments
    (\#[^\n]*)
  |
    # a quoted string matches in $3
    (["'])    # $2 - opening quote, ' or "
    (         # $3 - quoted text buffer
      (?:     # repeat group (no backreference)
        \\\\  # an escaped backslash
      |       # ...or...
        \\\2  # an escaped quote \" or \' (match $1)
      |       # ...or...
        .     # any other character
      | \n
      )*?     # non-greedy repeat
    )         # end of $3
    \2        # match opening quote
  |
    # an unquoted number matches in $4
    (-? \d+ (?: \. \d+ )?)  # numbers
  |
    # filename matches in $5
      ( /? \w+ (?: (?: /|::? ) \w* )+ | /\w+ )
  |
    # an identifier matches in $6
    (\w+)
  |
    # an unquoted word or symbol matches in $7
    (  [(){}\[\]:;,/\\]  # misc parentheses and symbols
    |  ->                # arrow operator (for future?)
    |  [-+*]             # math operations
    |  \${?              # dollar with optional left brace
    |  =>                # like "="
    |  [=!<>]?= | [!<>]  # equality tests
    |  &&? | \|\|?       # boolean ops
    |  \.\.?             # n..n sequence
    |  \S+               # something unquoted
    )                    # end of $7
""", re.VERBOSE)

QUOTED_STRING = re.compile(r"""
   ( (?: \\. | [^\$] ){1,3000} ) # escaped or non-'$' character [$1]
   |
   ( \$ (?:                    # embedded variable              [$2]
     (?: \{ ([^\}]*) \} )      # ${ ... }                       [$3]
     |
     ([\w\.]+)                 # $word                          [$4]
     )
   )
""", re.VERBOSE)


class Error(Exception):
  """A trivial local exception class."""
  pass


class Parser:
  """This module implements a LALR(1) parser and assocated support
  methods to parse template documents into the appropriate "compiled"
  format.
  """
  def __init__(self, param):
    self.start_tag = param.get("START_TAG") or DEFAULT_STYLE["START_TAG"]
    self.end_tag = param.get("END_TAG") or DEFAULT_STYLE["END_TAG"]
    self.tag_style = param.get("TAG_STYLE", "default")
    self.anycase = param.get("ANYCASE", False)
    self.interpolate = param.get("INTERPOLATE", False)
    self.pre_chomp = param.get("PRE_CHOMP", CHOMP_NONE)
    self.post_chomp = param.get("POST_CHOMP", CHOMP_NONE)
    self.v1dollar = param.get("V1DOLLAR", False)
    self.eval_python = param.get("EVAL_PYTHON", False)
    self.file_info = param.get("FILE_INFO", 1)
    self.grammar = param.get("GRAMMAR", Grammar())
    self.factory = param.get("FACTORY", Directive)
    self.fileinfo = []
    self.defblocks = []
    self.defblock_stack = []
    self.infor = 0
    self.inwhile = 0
    self.style = []

    # Build a FACTORY object to include any NAMESPACE definitions,
    # but only if FACTORY isn't already a (non-callable) object.
    if callable(self.factory):
      self.factory = self.factory(param)

    self.lextable = self.grammar.lextable
    self.states = self.grammar.states
    self.rules = self.grammar.rules
    self.new_style(param)

    self.tokenize = (
      ((1,), self._comment),
      ((2, 3), self._string),
      ((4,), self._number),
      ((5,), self._filename),
      ((6,), self._identifier),
      ((7,), self._word),
    )

  def new_style(self, config):
    """Install a new (stacked) parser style.

    This feature is currently experimental but should mimic the
    previous behaviour with regard to TAG_STYLE, START_TAG, END_TAG,
    etc.
    """
    if self.style:
      style = self.style[-1]
    else:
      style = DEFAULT_STYLE
    style = style.copy()
    tagstyle = config.get("TAG_STYLE")
    if tagstyle:
      tags = TAG_STYLE.get(tagstyle)
      if tags is None:
        raise Error("Invalid tag style: %s" % tagstyle)
      start, end = tags
      config["START_TAG"] = config.get("START_TAG", start)
      config["END_TAG"] = config.get("END_TAG", end)
    for key in DEFAULT_STYLE.keys():
      value = config.get(key)
      if value is not None:
        style[key] = value
    self.style.append(style)
    return style

  def old_style(self):
    """Pop the current parser style and revert to the previous one.

    See new_style().  ** experimental **
    """
    if len(self.style) <= 1:
      raise Error("only 1 parser style remaining")
    self.style.pop()
    return self.style[-1]

  def location(self):
    """Return Python comment indicating current parser file and line."""
    if not self.file_info:
      return "\n"
    line = self.line
    info = self.fileinfo[-1]
    file = info and (info.path or info.name) or "(unknown template)"
    line = re.sub(r"-.*", "", str(line))  # might be 'n-n'
    return '#line %s "%s"\n' % (line, file)

  def parse(self, text, info=None):
    """Parses the text string, text, and returns a dictionary
    representing the compiled template block(s) as Python code, in the
    format expected by template.document.
    """
    self.defblock = {}
    self.metadata = {}
    tokens = self.split_text(text)
    if tokens is None:
      return None
    self.fileinfo.append(info)
    block = self._parse(tokens, info)
    self.fileinfo.pop()
    if block:
      return { "BLOCK": block,
               "DEFBLOCKS": self.defblock,
               "METADATA": self.metadata }
    else:
      return None

  def split_text(self, text):
    """Split input template text into directives and raw text chunks."""
    tokens = []
    line = 1
    style = self.style[-1]
    def make_splitter(delims):
      return re.compile(r"(?s)(.*?)%s(.*?)%s" % delims)
    splitter = make_splitter((style["START_TAG"], style["END_TAG"]))
    while True:
      match = splitter.match(text)
      if not match:
        break
      text = text[match.end():]
      pre, dir = match.group(1), match.group(2)
      prelines = pre.count("\n")
      dirlines = dir.count("\n")
      postlines = 0
      if dir.startswith("#"):
        # commment out entire directive except for any end chomp flag
        match = re.search(CHOMP_FLAGS + "$", dir)
        if match:
          dir = match.group()
        else:
          dir = ""
      else:
        # PRE_CHOMP: process whitespace before tag
        match = re.match(r"(%s)?\s*" % CHOMP_FLAGS, dir)
        chomp = Chomp(match and match.group(1) or style["PRE_CHOMP"])
        if match:
          dir = dir[match.end():]
        pre = PRE_CHOMP[chomp](pre)

      # POST_CHOMP: process whitespace after tag
      match = re.search(r"\s*(%s)?\s*$" % CHOMP_FLAGS, dir)
      chomp = Chomp(match and match.group(1) or style["POST_CHOMP"])
      if match:
        dir = dir[:match.start()]
      text, postlines = POST_CHOMP[chomp](text, postlines)

      if pre:
        if style["INTERPOLATE"]:
          tokens.append([pre, line, 'ITEXT'])
        else:
          tokens.extend(["TEXT", pre])
      line += prelines
      if dir:
        # The TAGS directive is a compile-time switch.
        match = re.match(r"(?i)TAGS\s+(.*)", dir)
        if match:
          tags = re.split(r"\s+", match.group(1))
          if len(tags) > 1:
            splitter = make_splitter(tuple(re.escape(x) for x in tags[:2]))
          elif tags[0] in TAG_STYLE:
            splitter = make_splitter(TAG_STYLE[tags[0]])
          else:
            sys.stderr.write("Invalid TAGS style: %s" % tags[0])
        else:
          if dirlines > 0:
            line_range = "%d-%d" % (line, line + dirlines)
          else:
            line_range = str(line)
          tokens.append([dir, line_range, self.tokenise_directive(dir)])
      line += dirlines + postlines

    if text:
      if style["INTERPOLATE"]:
        tokens.append([text, line, "ITEXT"])
      else:
        tokens.extend(["TEXT", text])

    return tokens

  def _comment(self, token):
    """Tokenizes a comment."""
    return ()

  def _string(self, quote, token):
    """Tokenizes a string."""
    if quote == '"':
      if re.search(r"[$\\]", token):
        # unescape " and \ but leave \$ escaped so that
        # interpolate_text() doesn't incorrectly treat it
        # as a variable reference
        token = re.sub(r'\\([\\"])', r'\1', token)
        token = re.sub(r'\\([^$nrt])', r'\1', token)
        token = re.sub(r'\\([nrt])', lambda m: ESCAPE[m.group(1)], token)
        return ['"', '"'] + self.interpolate_text(token) + ['"', '"']
      else:
        return "LITERAL", "scalar(%r)" % token
    else:
      # Remove escaped single quotes and backslashes:
      token = re.sub(r"\\(.)", lambda m: m.group(m.group(1) in "'\\"), token)
      return "LITERAL", "scalar(%r)" % token

  def _number(self, token):
    """Tokenizes a number."""
    return "NUMBER", "scalar(%s)" % token

  def _filename(self, token):
    """Tokenizes a filename."""
    return "FILENAME", token

  def _identifier(self, token):
    """Tokenizes an identifier."""
    if self.anycase:
      uctoken = token.upper()
    else:
      uctoken = token
    toktype = self.lextable.get(uctoken)
    if toktype is not None:
      return toktype, uctoken
    else:
      return "IDENT", token

  def _word(self, token):
    """Tokenizes an unquoted word or symbol ."""
    return self.lextable.get(token, "UNQUOTED"), token

  def tokenise_directive(self, dirtext):
    """Called by the private _parse() method when it encounters a
    DIRECTIVE token in the list provided by the split_text() or
    interpolate_text() methods.

    The method splits the directive into individual tokens as
    recognised by the parser grammar (see template.grammar for
    details).  It constructs a list of tokens each represented by 2
    elements, as per split_text() et al.  The first element contains
    the token type, the second the token itself.

    The method tokenises the string using a complex (but fast) regex.
    For a deeper understanding of the regex magic at work here, see
    Jeffrey Friedl's excellent book "Mastering Regular Expressions",
    from O'Reilly, ISBN 1-56592-257-3

    Returns the list of chunks (each one being 2 elements) identified
    in the directive text.
    """
    tokens = []
    for match in GRAMMAR.finditer(dirtext):
      for indices, method in self.tokenize:
        if match.group(indices[0]):
          tokens.extend(method(*map(match.group, indices)))
          break
    return tokens

  def _parse(self, tokens, info):
    """Parses the list of input tokens passed by reference and returns
    an object which contains the compiled representation of the
    template.

    This is the main parser DFA loop.  See embedded comments for
    further details.
    """
    self.grammar.install_factory(self.factory)
    stack = [[0, None]]  # DFA stack
    coderet = None
    token = None
    in_string = False
    in_python = False
    status = CONTINUE
    lhs = None
    text = None
    self.line = 0
    self.file = info and info.name
    self.inpython = 0
    value = None

    while True:
      stateno = stack[-1][0]
      state = self.states[stateno]

      # see if any lookaheads exist for the current state
      if "ACTIONS" in state:
        # get next token and expand any directives (ie. token is a
        # list) onto the front of the token list
        while token is None and tokens:
          token = tokens.pop(0)
          if isinstance(token, (list, tuple)):
            text, self.line, token = util.unpack(token, 3)
            if isinstance(token, (list, tuple)):
              tokens[:0] = token + [";", ";"]
              token = None  # force redo
            elif token == "ITEXT":
              if in_python:
                # don't perform interpolation in PYTHON blocks
                token = "TEXT"
                value = text
              else:
                tokens[:0] = self.interpolate_text(text, self.line)
                token = None  # force redo
          else:
            # toggle string flag to indicate if we're crossing
            # a string boundary
            if token == '"':
              in_string = not in_string
            value = tokens and tokens.pop(0) or None

        if token is None:
          token = ""

        # get the next state for the current lookahead token
        lookup = state["ACTIONS"].get(token)
        if lookup:
          action = lookup
        else:
          action = state.get("DEFAULT")

      else:
        # no lookahead assertions
        action = state.get("DEFAULT")

      # ERROR: no ACTION
      if action is None:
        break

      # shift (positive ACTION)
      if action > 0:
        stack.append([action, value])
        token = value = None
      else:
        # reduce (negative ACTION)
        lhs, len_, code = self.rules[-action]
        # no action implies ACCEPTance
        if not action:
          status = ACCEPT
        # use dummy sub if code ref doesn't exist
        if not code:
          code = lambda *arg: len(arg) >= 2 and arg[1] or None
        if len_ > 0:
          codevars = [x[1] for x in stack[-len_:]]
        else:
          codevars = []
        try:
          coderet = code(self, *codevars)
        except TemplateException, e:
          self._parse_error(str(e), info.name)
        # reduce stack by len_
        if len_ > 0:
          stack[-len_:] = []
        # ACCEPT
        if status == ACCEPT:
          return coderet
        elif status == ABORT:
          return None
        elif status == ERROR:
          break
        stack.append([self.states[stack[-1][0]].get("GOTOS", {}).get(lhs),
                      coderet])

    # ERROR
    if value is None:
      self._parse_error("unexpected end of input", info.name)
    elif value == ";":
      self._parse_error("unexpected end of directive", info.name, text)
    else:
      self._parse_error("unexpected token (%s)" %
                        util.unscalar_lex(value), info.name, text)

  def _parse_error(self, msg, name, text=None):
    """Method used to handle errors encountered during the parse process
    in the _parse() method.
    """
    line = self.line or "unknown"
    if text is not None:
      msg += "\n  [%% %s %%]" % text
    raise TemplateException("parse", "%s line %s: %s" % (name, line, msg))

  def define_block(self, name, block):
    """Called by the parser 'defblock' rule when a BLOCK definition is
    encountered in the template.

    The name of the block is passed in the first parameter and a
    reference to the compiled block is passed in the second.  This
    method stores the block in the self.defblock dictionary which has
    been initialised by parse() and will later be used by the same
    method to call the store() method on the calling cache to define
    the block "externally".
    """
    if self.defblock is None:
      return None
    self.defblock[name] = block
    return None

  def push_defblock(self):
    self.defblock_stack.append(self.defblock)
    self.defblock = {}

  def pop_defblock(self):
    if not self.defblock_stack:
      return self.defblock
    block = self.defblock
    self.defblock = self.defblock_stack.pop(0)
    return block

  def add_metadata(self, setlist):
    setlist = [util.unscalar_lex(x) for x in setlist]
    if self.metadata is not None:
      for key, value in util.chop(setlist, 2):
        self.metadata[key] = value
    return None

  def interpolate_text(self, text, line=0):
    """Examines text looking for any variable references embedded
    like $this or like ${ this }.
    """
    tokens = []
    for match in QUOTED_STRING.finditer(text):
      pre = match.group(1)
      var = match.group(3) or match.group(4)
      dir = match.group(2)
      # preceding text
      if pre:
        line += pre.count("\n")
        tokens.extend(("TEXT", pre.replace("\\$", "$")))
      # variable reference
      if var:
        line += dir.count("\n")
        tokens.append([dir, line, self.tokenise_directive(var)])
      # other '$' reference - treated as text
      elif dir:
        line += dir.count("\n")
        tokens.extend(("TEXT", dir))
    return tokens
