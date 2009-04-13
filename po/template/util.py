#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

import cStringIO
import os
import re
import sys


class Error(Exception):
  """A trivial local exception class."""
  pass


class ControlFlowException(Exception):
  """Base class for exceptions related to control flow in generated code.

  Not strictly necessary, but useful for documentation purposes."""
  pass


class Continue(ControlFlowException):
  """Exception raised by the NEXT template directive."""
  pass


class Break(ControlFlowException):
  """Exception raised by the LAST template directive."""
  pass


class TemplateException(Exception):
  def __init__(self, type, info, buffer=None):
    Exception.__init__(self, type, info)
    self.__type = type
    self.__info = info
    self.__buffer = buffer

  def text(self, buffer=None):
    if buffer:
      if self.__buffer and self.__buffer is not buffer:
        buffer.reset(buffer.get() + self.__buffer.get())
      self.__buffer = buffer
      return ""
    elif self.__buffer:
      return self.__buffer.get()
    else:
      return ""

  def select_handler(self, options):
    type = str(self.__type)
    hlut = dict((str(option), True) for option in options)
    while type:
      if hlut.get(type):
        return type
      type = re.sub(r'\.?[^.]*$', '', type)
    return None

  def type(self):
    return self.__type

  def info(self):
    return self.__info

  def type_info(self):
    return self.__type, self.__info

  def __str__(self):
    return "%s error - %s" % (self.__type or "", self.__info)

  @classmethod
  def convert(cls, exception):
    if not isinstance(exception, TemplateException):
      exception = TemplateException(None, exception)
    return exception


class StringBuffer:
  """A wrapper around a StringIO object that stringifies all of its
  arguments before writing them.  Provides a handful of other useful
  methods as well.
  """

  def __init__(self, contents=None):
    """Initializes the object.  If the contents argument is not None, it
    is immediately passed to the write method.
    """
    self.buffer = cStringIO.StringIO()
    if contents is not None:
      self.write(contents)

  def write(self, *args):
    """Stringifies each argument in turn and writes it to the internal
    buffer.
    """
    for arg in args:
      self.buffer.write(str(arg))

  def clear(self):
    """Clears the contents of the internal buffer."""
    self.buffer.seek(0)
    self.buffer.truncate(0)

  def reset(self, *args):
    """Clears the internal buffer, then passes all of the arguments
    to the write method.
    """
    self.clear()
    self.write(*args)

  def get(self):
    """Returns the contents of the internal buffer."""
    return self.buffer.getvalue()


class Code:
  """Utility class for constructing snippets of properly-indented Python
  code.

  The write() method takes any number of arguments, which are
  processed in order.  An argument which is identically equal to one
  of the class members named"indent" or "unindent" has the effect of
  increasing or decreasing, respectively, the indentation level of
  the following lines by one space.  All other arguments are stringified,
  split on newlines, and printed line by line to an internal buffer, each
  line being indented to the current indentation level.  Empty lines
  are skipped.

  The "text" method returns the contents of the internal buffer.

  The class method "format" instantiates an object, writes all of its
  arguments to it, and returns the buffer contents, all in one step.
  """

  indent   = Error()  # any distinct objects
  unindent = Error()  # will do

  @classmethod
  def format(cls, *args):
    code = cls()
    code.write(*args)
    return code.text()

  def __init__(self):
    self.__buffer = StringBuffer()
    self.__depth = 0

  def write(self, *args):
    for arg in args:
      if arg is self.indent:
        self.__depth += 1
      elif arg is self.unindent:
        if self.__depth == 0:
          raise Error("Internal error: too many unindents")
        self.__depth -= 1
      elif not arg:
        pass  # skip blank lines
      else:
        for line in str(arg).split("\n"):
          if line and not line.isspace():
            self.__buffer.write(" " * self.__depth, line, "\n")

  def text(self):
    return self.__buffer.get()


class Literal:
  """A trivial wrapper for a template supplied as a string.

  This class is necessary so that the framework can distinguish a string
  meant to be a file or block name from a string meant to be the contents
  of a template.  The Perl version of the Toolkit requires one to pass in
  the latter type of string via a reference, but such semantics are
  unidiomatic and awkward in Python.

  A user shouldn't typically need to make explicit use of this class,
  but should just call Template.processString rather than Template.process.
  One may, however, pass a Literal to Template.process if one has a mind to.
  """

  # TODO: Re-engineer the way the PyTT passes document identifiers around
  # to make this class unnecessary.

  def __init__(self, text):
    self.__text = str(text)

  def text(self):
    return self.__text


class PerlScalar:
  """An object wrapper that imposes certain aspects of Perl's scalar
  semantics on the wrapped object.

  First, the wrapped object is expressed as a string or number, as the
  situation warrants.  Strings are converted to numbers using Perl's
  rules: extra characters beyond the leading numeric portion are ignored,
  and a string that does not have a leading numeric portion is converted
  to zero.  The Python literal True is normalized to the integer 1 on
  being wrapped, and the literals False and None are normalized to the
  empty string.

  Second, all of the arithmetic and logical operations supported by the
  Template Toolkit's template language are supported between two
  PerlScalars, and result in another PerlScalar.  These operations
  include addition, subtraction, multiplication, division, division
  with truncation, and the Boolean operations and, or, and not.  The
  usual Boolean comparisons (==, !=, >, >=, <, and <=) and the cmp
  operation are supported; the resulting value is wrapped in another
  PerlScalar.

  Third, the truth value of the wrapped value is evaluated according
  to Perl's rules: only the strings "" and "0" and the numeric value
  0 are considered false; everything else is true.

  The wrapped value can be retrieved with the value() method.

  This class also has some additional semantics that enable its objects to
  be dropped in to expressions generated by the PyTT parser.

  The bitwise-and operator performs string concatenation.

  Iteration is dispatched to the wrapped object.

  PerlScalars may be placed on the right-hand side of the exponentiation
  operator.  The result of the expression is another PerlScalar object
  that wraps the same object, but which its truth value frozen to true.
  The left-hand side of the exponentiation is ignored.  This awkward
  construction is necessary to support the template language's ternary
  operator; "a ? b : c" in a template becomes "a and 1**b or c" in
  the generated code.  Furthermore, the frozen truth value is "sticky".
  In any arithmetic operating involving two PerlScalars, if the left-hand
  operand has a frozen truth value, the resulting PerlScalar has the
  same frozen truth value.  This is so that a template expression such as
  "a ? b + c : d + e" can be converted to a generated expression like
  "a and 1**b + c or d + e".

  A frozen truth value persists for just one evaluation of the boolean
  value of the scalar.

  Examples:

  PerlScalar(1) + PerlScalar(2) --> PerlScalar(3)

  PerlScalar('4 mississippi') / PerlScalar('  1.0e-2') --> PerlScalar(400.0)

  PerlScalar('text') + PerlScalar(3) --> PerlScalar(3)

  PerlScalar('1') and PerlScalar('0') --> PerlScalar(True)

  not PerlScalar('stuff') --> PerlScalar(False)

  PerlScalar('foo') & PerlScalar('bar') --> PerlScalar('foobar')

  PerlScalar(None) & PerlScalar(True) & PerlScalar(False) --> PerlScalar('1')

  PerlScalar(True) / PerlScalar(4) --> PerlScalar(0.25)

  dict(PerlScalar([('foo', 'bar')])) --> { 'foo': 'bar' } # forwarded iteration

  bool(PerlScalar([])) --> True

  bool(1 ** PerlScalar(False)) --> True

  PerlScalar(True).value() --> 1

  PerlScalar(False).value() --> ""

  1 ** PerlScalar(False) or 42 --> PerlScalar(False)
  """

  __False = (0, "", "0")

  def __init__(self, value, truth=None):
    if isinstance(value, PerlScalar):
      # Sanity check: One PerlScalar should never need to wrap another.
      raise Error("Attempted to wrap a PerlScalar (%s) in another PerlScalar" %
                  value)
    if value is True:
      self.__value = 1
    elif value is False or value is None:
      self.__value = ""
    else:
      self.__value = value
    self.__truth = truth

  def value(self):
    return self.__value

  def __add__(self, other):
    return PerlScalar(self.__numify() + other.__numify(), self.__truth)

  def __sub__(self, other):
    return PerlScalar(self.__numify() - other.__numify(), self.__truth)

  def __mul__(self, other):
    return PerlScalar(self.__numify() * other.__numify(), self.__truth)

  def __div__(self, other):
    return PerlScalar(self.__numify() / other.__numify(), self.__truth)

  def __mod__(self, other):
    return PerlScalar(self.__numify() % other.__numify(), self.__truth)

  def __floordiv__(self, other):
    return PerlScalar(self.__numify() // other.__numify(), self.__truth)

  # TODO: Figure out if any refinements are needed to the following
  # boolean comparisons.  For example, in Perl, "5foo" == 5, but
  # PerlScalar("5foo") != PerlScalar(5), because the wrapped Python
  # objects are being compared directly, and strings never equal integers.
  # All tests pass as-is, so I'm deferring investigation.  For complete
  # correctness, it may become necessary to store both the string and
  # numeric versions of the wrapped value, somewhat the way Perl scalar
  # are handled under the hood.

  def __eq__(self, other):
    return PerlScalar(self.__value == other.__value)

  def __ne__(self, other):
    return PerlScalar(self.__value != other.__value)

  def __gt__(self, other):
    return PerlScalar(self.__value > other.__value)

  def __ge__(self, other):
    return PerlScalar(self.__value >= other.__value)

  def __lt__(self, other):
    return PerlScalar(self.__value < other.__value)

  def __le__(self, other):
    return PerlScalar(self.__value <= other.__value)

  def __cmp__(self, other):
    return PerlScalar(cmp(self.__value, other.__value))

  def __and__(self, other):
    """String concatenation."""
    return PerlScalar("%s%s" % (self.__value, other.__value))

  def __rpow__(self, _):
    """Returns a new wrapper, with its truth value frozen to True, for the
    same object wrapped by this object.
    """
    return PerlScalar(self.__value, True)

  def __nonzero__(self):
    """Evaluates the truth of the wrapped object according to Perl's notion
    of truth.  If this object's truth value has been frozen, report that
    instead.
    """
    if self.__truth is not None:
      truth = self.__truth
      self.__truth = None
      return truth
    else:
      return self.__value not in self.__False

  def __invert__(self):
    return PerlScalar(not self)

  def __int__(self):
    return int(self.__numify())

  def __long__(self):
    return long(self.__numify())

  def __float__(self):
    return float(self.__numify())

  def __iter__(self):
    return iter(self.__value)

  def __str__(self):
    return str(self.__value)

  def __numify(self):
    return numify(self.__value)


# A regular expression object that identifies an integer or floating-point
# number, the latter optionally in scientific notation.

NUMBER_RE = re.compile(r"\s*[-+]?(?:\d+(\.\d*)?|(\.\d+))([Ee][-+]?\d+)?")


def numify(value):
  """Converts any object to a number using Perl's rules."""
  if isinstance(value, (int, long, float)):
    return value
  elif value is True:
    return 1
  elif value is False:
    return 0
  match = NUMBER_RE.match(str(value))
  if not match:
    return 0
  elif match.group(1) or match.group(2) or match.group(3):
    return float(match.group())
  else:
    return int(match.group())


def dynamic_filter(func):
  """Function decorator that sets the wrapped function's 'dynamic_filter'
  attribute to True.
  """
  func.dynamic_filter = True
  return func


def registrar(obj, store=lambda func, *args: ((name, func) for name in args)):
  """Returns a function decorator that registers the decorated function
  in a dictionary-like object 'obj' before returning the function, unmodified.

  The 'store' argument should be a callable object that describes how the
  function is registered.  It will be called with the function to be
  decorated as its first argument, followed by any arguments that were
  passed to the decorator itself.  The value returned by the object
  will be passed to the 'update' function of 'obj', and should therefore
  be an iterable object that returns key-value pairs.

  A default 'store' argument is provided which simply registers the
  function in 'obj' under each of the names provided to the decorator.

  Example:

  OBJECTS = {}

  register = registrar(OBJECTS)

  @register('add', 'accumulate')
  def addition(x, y):
    return x + y

  Now OBJECTS['add'] and OBJECTS['accumulate'] both refer to 'addition'.

  A more complicated, albeit contrived, example:

  register = registrar(OBJECTS, lambda f, a, b: ((x, f) for x in range(a, b)))

  @register(7, 10)
  def subtract(x, y):
    return x - y

  Now OBJECTS[7], OBJECTS[8], and OBJECTS[9] all refer to 'subtract'.
  """
  def register(*args):
    def decorator(func):
      for key, value in store(func, *args):
        obj[key] = value
      return func
    return decorator
  return register


def unindent(code):
  """Unindents a multiline block of text.

  Removes a number of leading whitespace characters from each line
  equal to the smallest number of leading whitespace characters found
  on any line, excluding lines consisting solely of whitespace characters.
  """
  try:
    indent = min(len(match.group())
                 for match in re.finditer(r"(?m)^[^\S\n]*(?=\S)", code))
  except ValueError:
    # No indentation found; min() complains of a zero-length sequence.
    pass
  else:
    code = re.sub(r"(?m)^.{%d}" % indent, "", code)
  return code


def EvaluateCode(code, context, stash):
  """Evaluates a snippet of Python code, returning everything that it
  writes to sys.stdout, which is temporarily redirected to a StringIO
  object.

  The global variables "context" and "stash" are set to the two
  function arguments of the same names, the variable "stdout" is set
  to sys.stdout (temporarily reassigned to a StringIO buffer object),
  and the variable "output" is set to the StringBuffer wrapper around
  sys.stdout.
  """
  code = unindent(code)
  stringbuf = StringBuffer()
  old_stdout = sys.stdout
  sys.stdout = stringbuf.buffer
  vars = { "context": context,
           "stash": stash,
           "stdout": sys.stdout,
           "output": stringbuf }
  try:
    exec code in vars
  finally:
    sys.stdout = old_stdout
  return stringbuf.get()


def unscalar(arg):
  """Unwraps a PerlScalar object.

  If the sole argument is a PerlScalar, returns the value wrapped by
  that object; otherwise just returns the argument.
  """
  if isinstance(arg, PerlScalar):
    return arg.value()
  else:
    return arg


def unscalar_lex(arg):
  """Lexically unwraps a string containing a string or numeric constant,
  such as are created by the PyTT parser.

  If the argument (presumed to be a string) starts with the string "scalar("
  and ends with the string ")", evaluates and returns the portion of the
  argument between those strings; otherwise just returns the argument.
  """
  if arg.startswith("scalar(") and arg.endswith(")"):
    return eval(arg[7:-1])
  else:
    return arg


def unscalar_list(seq):
  """Creates and returns a list containing the results of applying the
  unscalar function to each element in seq, a sequence.

  If seq is not a sequence, returns an empty list.
  """
  try:
    return [unscalar(item) for item in seq]
  except TypeError:
    # seq is not a sequence.
    return []


def ScalarList(*args):
  """Returns a PerlScalar that wraps a list containing the result of
  applying the unscalar function to each argument of this function--
  except for xrange objects, which are flattened into the output list
  instead.
  """
  list = []
  for arg in args:
    if isinstance(arg, xrange):
      list.extend(arg)
    else:
      list.append(unscalar(arg))
  return PerlScalar(list)


def ScalarDictionary(*pairs):
  """Applies the unscalar function to each element of each two-element
  tuple in pairs, constructs a dictionary from the unscalared pairs,
  and returns the dictionary, wrapped in a PerlScalar.
  """
  return PerlScalar(dict((unscalar(key), unscalar(val)) for key, val in pairs))


def SwitchList(arg):
  """If arg (a PerlScalar) wraps a sequence type (other than a string),
  arg is returned; otherwise, a PerlScalar that wraps a single-element
  list containing the value wrapped by arg is returned.

  The function's name reflects its utility in executing the SWITCH
  template directive.
  """
  value = arg.value()
  if is_seq(value):
    return arg
  else:
    return ScalarList(value)


def Concatenate(*args):
  """Constructs the string resulting from concatenating the stringified
  arguments to this function, in order, then returns that string wrapped
  in a PerlScalar.
  """
  return PerlScalar("".join(str(x) for x in args))


def can(object, method):
  """Returns true iff object has a callable attribute with the given name."""
  return callable(getattr(object, method, None))


def chop(seq, count):
  """Returns an iterator that traverses the given sequence, returning tuples
  of count items at a time.  The final tuple is padded with Nones if there
  aren't enough items in the sequence.
  """
  buf = []
  for elt in seq:
    buf.append(elt)
    if len(buf) == count:
      yield tuple(buf)
      buf[:] = []
  if buf:
    yield tuple(buf) + (None,) * (count - len(buf))


def unpack(seq, n):
  """Returns the first tuple generated by chop(seq, n).

  This function provides semantics similar to Perl's

  ($a, $b, $c) = func();

  One may say:

  a, b, c = unpack(func(), 3)

  ...and not suffer an error if there are fewer than three elements
  in the tuple returned by func.
  """
  return chop(seq, n).next()


def listify(arg):
  """If arg is a list, returns arg; otherwise returns a single-element
  list containing arg.
  """
  if isinstance(arg, list):
    return arg
  else:
    return [arg]


def is_seq(obj):
  """Returns true iff obj is any object, other than a string, that
  supports iteration.
  """
  try:
    iter(obj)
  except TypeError:
    return False
  else:
    return not isinstance(obj, basestring)


def slice(seq, indices):
  """Performs a Perl-style slice, substituting None for out-of-range
  indices rather than raising an exception.
  """
  sliced = []
  for index in indices:
    try:
      sliced.append(seq[int(index)])
    except IndexError:
      sliced.append(None)
  return sliced


def split_arguments(args):
  """Returns the 2-tuple (args[:-1], args[-1]) if args[-1] exists and
  is a dict; otherwise returns (args, {}).
  """
  if args and isinstance(args[-1], dict):
    return args[:-1], args[-1]
  else:
    return args, {}


def slurp(path):
  """Returns the contents of the file at the given path."""
  f = None
  try:
    f = open(path)
    return f.read()
  finally:
    if f:
      f.close()


def is_object(x):
  """Returns True if x has a __dict__ attribute.

  This function is intended to determine if its argument is an object
  in the "classic" sense--that is, one belonging to a type created by the
  "class" construct, and excluding such built-in types as int, str, and
  list, which are, strictly speaking, also objects in a general sense.

  This function also returns True if x is a class or module.
  """
  return hasattr(x, "__dict__")


def modtime(path):
  """Returns the modification time of the file at the given path, or None
  if the time could not be determined for any reason.
  """
  try:
    return os.stat(path).st_mtime
  except EnvironmentError:
    return None


class InvalidClassIdentifier(Exception):
  pass


def _load_class(modname, clsname, base):
  if base is not None:
    modname = "%s.%s" % (base, modname)
  module = __import__(modname, globals(), [], ["."])
  return getattr(module, clsname)


def get_class(classid, base=None):
  """Returns an object generator (typically but not necessarily a
  class object) identified by two-element tuple or name.

  If classid is a callable object, it is returned immediately.

  If classid is a two-element tuple, the elements are taken to be
  a module name and class name, in that order.  The module is imported,
  and the class is fetched by name and returned.

  If classid is a string, it is taken to be a module name.  The named
  module is imported.  The class name is taken to be the final component
  of the module name with its first character capitalized.

  In the latter two cases, the parameter 'base' is prepended to the
  module name along with a separating period, if it is not None.

  If classid is not one of the above types, an exception is raised.
  """
  if callable(classid):
    return classid
  elif isinstance(classid, tuple):
    if len(classid) == 2:
      return _load_class(classid[0], classid[1], base)
  elif isinstance(classid, str):
    dot = classid.rfind(".")
    if dot != len(classid) - 1:
      clsname = classid[dot+1].upper() + classid[dot+2:]
      return _load_class(classid, clsname, base)
  raise InvalidClassIdentifier(classid)


def Debug(*args):
  sys.stderr.write("DEBUG: ")
  for arg in args:
    sys.stderr.write(str(arg))


class Sequence:
  """Mix-in that tags a class as supporting an as_list method.

  This is a hack, made necessary by the fact that a Perl object can
  be implemented as a list and treated as such independently of its
  object nature; this concept does not translate to Python.
  """
  def as_list(self):
    raise NotImplementedError


class Struct:
  """A do-nothing class that can be used as a bag of attributes."""
  pass
