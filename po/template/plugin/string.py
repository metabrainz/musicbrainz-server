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


"""
template.plugin.string - Object oriented interface for string manipulation


SYNOPSIS

    # create String objects via USE directive
    [% USE String %]
    [% USE String 'initial text' %]
    [% USE String text => 'initial text' %]

    # or from an existing String via new()
    [% newstring = String.new %]
    [% newstring = String.new('newstring text') %]
    [% newstring = String.new( text => 'newstring text' ) %]

    # or from an existing String via copy()
    [% newstring = String.copy %]

    # append text to string
    [% String.append('text to append') %]

    # format left, right or center/centre padded
    [% String.left(20) %]
    [% String.right(20) %]
    [% String.center(20) %]   # American spelling
    [% String.centre(20) %]   # European spelling

    # and various other methods...


DESCRIPTION

This module implements a String class for doing stringy things to text
in an object-oriented way.

You can create a String object via the USE directive, adding any
initial text value as an argument or as the named parameter 'text'.

    [% USE String %]
    [% USE String 'initial text' %]
    [% USE String text='initial text' %]

The object created will be referenced as 'String' by default, but you
can provide a different variable name for the object to be assigned
to:

    [% USE greeting = String 'Hello World' %]

Once you've got a String object, you can use it as a prototype to
create other String objects with the new() method.

    [% USE String %]
    [% greeting = String.new('Hello World') %]

The new() method also accepts an initial text string as an argument
or the named parameter 'text'.

    [% greeting = String.new( text => 'Hello World' ) %]

You can also call copy() to create a new String as a copy of the
original.

    [% greet2 = greeting.copy %]

The String object has a text() method to return the content of the
string.

    [% greeting.text %]

However, it is sufficient to simply print the string and let the
__str__ method call the text() method automatically for you.

    [% greeting %]

Thus, you can treat String objects pretty much like any regular piece
of text, interpolating it into other strings, for example:

    [% msg = "It printed '$greeting' and then dumped core\n" %]

You also have the benefit of numerous other methods for manipulating
the string.

    [% msg.append("PS  Don't eat the yellow snow") %]

Note that all methods operate on and mutate the contents of the string
itself.  If you want to operate on a copy of the string then simply
take a copy first:

    [% msg.copy.append("PS  Don't eat the yellow snow") %]

These methods return a reference to the String object itself.  This
allows you to chain multiple methods together.

    [% msg.copy.append('foo').right(72) %]

It also means that in the above examples, the String is returned which
causes the text() method to be called, which results in the new value of
the string being printed.  To suppress printing of the string, you can
use the CALL directive.

    [% foo = String.new('foo') %]

    [% foo.append('bar') %]         # prints "foobar"

    [% CALL foo.append('bar') %]    # nothing


METHODS

Construction Methods

The following methods are used to create new String objects.

__init__()

Creates a new string using an initial value passed as a positional
argument or the named parameter 'text'.

    [% USE String %]
    [% msg = String.new('Hello World') %]
    [% msg = String.new( text => 'Hello World' ) %]

copy()

Creates a new String object which contains a copy of the original string.

    [% msg2 = msg.copy %]


Inspection Methods

These methods are used to inspect the string content or other parameters
relevant to the string.

text()

Returns the internal text value of the string.  The same as __str__.
Thus the following are equivalent:

    [% msg.text %]
    [% msg %]

length()

Returns the length of the string.

    [% USE String("foo") %]

    [% String.length %]   # => 3

search(pattern)

Searches the string for the regular expression specified in 'pattern',
returning true if found or false otherwise.

    [% item = String.new('foo bar baz wiz waz woz') %]

    [% item.search('wiz') ? 'WIZZY! :-)' : 'not wizzy :-(' %]

split(pattern, limit)

Splits the string based on the delimiter pattern and optional limit.

    [% FOREACH item.split %]
         ...
    [% END %]

    [% FOREACH item.split('baz|waz') %]
         ...
    [% END %]

substr(offset, length, replacement)

Returns a substring starting at 'offset', for 'length' characters.

    [% str = String.new('foo bar baz wiz waz woz') %]
    [% str.substr(4, 3) %]    # bar

If length is not specified then it returns everything from the offset
to the end of the string.

    [% str.substr(12) %]      # wiz waz woz

If both 'length' and 'replacement' are specified, then the method
replaces everything from 'offset' for 'length' characters with
'replacement'.  The substring removed from the string is then
returned.

    [% str.substr(0, 11, 'FOO') %]   # foo bar baz
    [% str %]                        # FOO wiz waz woz


Mutation Methods

These methods modify the internal value of the string.  For example:

    [% USE str=String('foobar') %]

    [% str.append('.html') %]	# str => 'foobar.html'

The value of the String 'str' is now 'foobar.html'.  If you don't want
to modify the string then simply take a copy first.

    [% str.copy.append('.html') %]

These methods all return a reference to the String object itself.
This has two important benefits.  The first is that when used as
above, the String object 'str' returned by the append() method will be
stringified with a call to its text() method.  This will return the
newly modified string content.  In other words, a directive like:

    [% str.append('.html') %]

will update the string and also print the new value.  If you just want
to update the string but not print the new value then use CALL.

    [% CALL str.append('.html') %]

The other benefit of these methods returning a reference to the String
is that you can chain as many different method calls together as you
like.  For example:

    [% String.append('.html').trim.format(href) %]

Here are the methods:

push(suffix, ...) / append(suffix, ...)

Appends all arguments to the end of the string.  The append() method
is provided as an alias for push().

    [% msg.push('foo', 'bar') %]
    [% msg.append('foo', 'bar') %]

pop(suffix)

Removes the suffix passed as an argument from the end of the String.

    [% USE String 'foo bar' %]
    [% String.pop(' bar')   %]   # => 'foo'

unshift(prefix, ...) / prepend(prefix, ...)

Prepends all arguments to the beginning of the string.  The
prepend() method is provided as an alias for unshift().

    [% msg.unshift('foo ', 'bar ') %]
    [% msg.prepend('foo ', 'bar ') %]

shift(prefix)

Removes the prefix passed as an argument from the start of the String.

    [% USE String 'foo bar' %]
    [% String.shift('foo ') %]   # => 'bar'

left(pad)

If the length of the string is less than 'pad' then the string is left
formatted and padded with spaces to 'pad' length.

    [% msg.left(20) %]

right(pad)

As per left() but right padding the String to a length of 'pad'.

    [% msg.right(20) %]

center(pad) / centre(pad)

As per left() and right() but formatting the String to be centered
within a space padded string of length 'pad'.  The centre() method is
provided as an alias for center() to keep Yanks and Limeys happy.

    [% msg.center(20) %]    # American spelling
    [% msg.centre(20) %]    # European spelling

format(format)

Apply a format in the style of the % operator to the string.

    [% USE String("world") %]
    [% String.format("Hello %s\n") %]  # => "Hello World\n"

upper()

Converts the string to upper case.

    [% USE String("foo") %]

    [% String.upper %]  # => 'FOO'

lower()

Converts the string to lower case

    [% USE String("FOO") %]

    [% String.lower %]  # => 'foo'

capital()

Converts the first character of the string to upper case.

    [% USE String("foo") %]

    [% String.capital %]  # => 'Foo'

The remainder of the string is left untouched.  To force the string to
be all lower case with only the first letter capitalised, you can do
something like this:

    [% USE String("FOO") %]

    [% String.lower.capital %]  # => 'Foo'

chop()

Removes the last character from the string.

    [% USE String("foop") %]

    [% String.chop %]	# => 'foo'

chomp()

Removes the trailing newline from the string.

    [% USE String("foo\n") %]

    [% String.chomp %]	# => 'foo'

trim()

Removes all leading and trailing whitespace from the string

    [% USE String("   foo   \n\n ") %]

    [% String.trim %]	# => 'foo'

collapse()

Removes all leading and trailing whitespace and collapses any sequences
of multiple whitespace to a single space.

    [% USE String(" \n\r  \t  foo   \n \n bar  \n") %]

    [% String.collapse %]   # => "foo bar"

truncate(length, suffix)

Truncates the string to 'length' characters.

    [% USE String('long string') %]
    [% String.truncate(4) %]  # => 'long'

If 'suffix' is specified then it will be appended to the truncated
string.  In this case, the string will be further shortened by the
length of the suffix to ensure that the newly constructed string
complete with suffix is exactly 'length' characters long.

    [% USE msg = String('Hello World') %]
    [% msg.truncate(8, '...') %]   # => 'Hello...'

replace(search, replace)

Replaces all occurences of the regular expression 'search' in the
string with the string 'replace'.

    [% USE String('foo bar foo baz') %]
    [% String.replace('foo', 'wiz')  %]  # => 'wiz bar wiz baz'

remove(search)

Remove all occurences of the regular expression 'search' in the string.

    [% USE String('foo bar foo baz') %]
    [% String.remove('foo ')  %]  # => 'bar baz'

repeat(count)

Repeats the string 'count' times.

    [% USE String('foo ') %]
    [% String.repeat(3)  %]  # => 'foo foo foo '

"""


class String(Plugin):
  """Template Toolkit plugin to implement a basic String object."""
  def __init__(self, context, *args):
    Plugin.__init__(self)
    args, config = self._split_arguments(args)
    if "text" in config:
      self._text = config["text"]
    elif args:
      self._text = args[0]
    else:
      self._text = ""
    self.filters = []
    self._CONTEXT = context
    filter = config.get("filter") or config.get("filters")
    if filter:
      self.output_filter(filter)

  # Perl-style "new" method:
  def new(self, *args):
    return self.__class__(self._CONTEXT, *args)

  def text(self):
    if not self.filters:
      return self._text
    _text = self._text
    for name, args in self.filters:
      code = self._CONTEXT.filter(name, args)
      _text = code(_text)
    return _text

  __str__ = text

  def __eq__(self, other):
    return self.text() == other.text()

  def __ne__(self, other):
    return self.text() != other.text()

  def copy(self):
    return String(self._CONTEXT, self._text)

  def output_filter(self, filter):
    if isinstance(filter, dict):
      filter = list(sum(filter.items(), ()))
    elif isinstance(filter, str):
      filter = re.split(r"\s*\W+\s*", filter)

    while filter:
      name = filter.pop(0)
      if filter and (isinstance(filter[0], (list, tuple, dict))
                     or len(filter[0]) == 0):
        args = filter.pop(0)
        if args:
          if not isinstance(args, (list, tuple)):
            args = [args]
        else:
          args = []
      else:
        args = []
      self.filters.append([name, args])
    return ""

  def push(self, *args):
    self._text += "".join(args)
    return self

  def unshift(self, *args):
    self._text = "".join(args) + self._text
    return self

  def pop(self, strip=None):
    if strip is not None:
      self._text = re.sub(strip + "$", "", self._text)
    return self

  def shift(self, strip=None):
    if strip is not None:
      self._text = re.sub("^" + strip, "", self._text)
    return self

  def center(self, width=0):
    length = len(self._text)
    if length < width:
      lpad = (width - length) // 2
      rpad = width - length - lpad
      self._text = " " * lpad + self._text + " " * rpad
    return self

  def left(self, width=0):
    if width > len(self._text):
      self._text += " " * (width - len(self._text))
    return self

  def right(self, width=0):
    if width > len(self._text):
      self._text = " " * (width - len(self._text)) + self._text
    return self

  def format(self, fmt="%s"):
    self._text = fmt % self._text
    return self

  def filter(self, name, *args):
    code = self._CONTEXT.filter(name, args)
    return code(self._text)

  def upper(self):
    self._text = self._text.upper()
    return self

  def lower(self):
    self._text = self._text.lower()
    return self

  def capital(self):
    if self._text:
      self._text = self._text[0].upper() + self._text[1:]
    return self

  def chop(self):
    if self._text:
      self._text = self._text[:-1]
    return self

  def chomp(self):
    # Not exactly like Perl's chomp, but what is one to do...
    if self._text and self._text[-1] == "\n":
      self._text = self._text[:-1]
    return self

  def trim(self):
    self._text = self._text.strip()
    return self

  def collapse(self):
    self._text = re.sub(r"\s+", " ", self._text.strip())
    return self

  def length(self):
    return len(self._text)

  def truncate(self, length=None, suffix=""):
    if length is not None:
      if len(self._text) > length:
        self._text = self._text[:length - len(suffix)] + suffix
    return self

  def substr(self, offset=0, length=None, replacement=None):
    if length is not None:
      if replacement is not None:
        removed = self._text[offset:offset+length]
        self._text = (self._text[:offset]
                      + replacement
                      + self._text[offset+length:])
        return removed
      else:
        return self._text[offset:offset+length]
    else:
      return self._text[offset:]

  def repeat(self, n=None):
    if n is not None:
      self._text = self._text * n
    return self

  def replace(self, search=None, replace=""):
    if search is not None:
      self._text = re.sub(search, lambda match: replace, self._text)
    return self

  def remove(self, search=""):
    self._text = re.sub(search, "", self._text)
    return self

  def split(self, split=r"\s", limit=0):
    if limit == 0:
      return re.split(split, self._text)
    else:
      return re.split(split, self._text, limit - 1)

  def search(self, pattern):
    return re.search(pattern, self._text) is not None

  def equals(self, comparison=""):
    return self._text == str(comparison)

  # Alternate method names:
  centre = center
  append = push
  prepend = unshift

