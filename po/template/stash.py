#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

import re

from template import util
from template.vmethods import VMethods


"""
template.stash.Stash - Magical storage for template variables


SYNOPSIS

    import template.stash

    stash = template.stash.Stash(vars)

    # get variable values
    value = stash.get(variable)
    value = stash.get([compound, ...])

    # set variable value
    stash.set(variable, value);
    stash.set([compound, ...], value)

    # default variable value
    stash.set(variable, value, 1)
    stash.set([compound, ...], $value, 1)

    # set variable values en masse
    stash.update(new_vars)

    # methods for (de-)localising variables
    stash = stash.clone(new_vars)
    stash = stash.declone()


DESCRIPTION

The template.stash.Stash module defines a class which is used to store
variable values for the runtime use of the template processor.
Variable values are stored internally in a dictionary and are
accessible via the get() and set() methods.

Variables may reference dictionaries, lists, functions and objects as
well as simple values.  The stash automatically performs the right
magic when dealing with variables, calling code or object methods,
indexing into lists, dictionaries, etc.

The stash has clone() and declone() methods which are used by the
template processor to make temporary copies of the stash for
localising changes made to variables.


PUBLIC METHODS

__init__(params)

The constructor initializes a new template.stash.Stash object.

    stash = template.stash.Stash()

A dictionary may be passed to provide variables and values which
should be used to initialise the stash.

    stash = template.stash.Stash({ 'var1': 'value1',
				   'var2': 'value2' })

get(variable)

The get() method retrieves the variable named by the first parameter.

    value = stash.get('var1')

Dotted compound variables can be retrieved by specifying the variable
elements by list.  Each node in the variable occupies two entries in
the list.  The first gives the name of the variable element, the
second is a list of arguments for that element, or 0 if none.

    [% foo.bar(10).baz(20) %]

    stash.get([ 'foo', 0, 'bar', [ 10 ], 'baz', [ 20 ] ])


set(variable, value, default)

The set() method sets the variable name in the first parameter to the
value specified in the second.

    stash.set('var1', 'value1')

If the third parameter evaluates to a true value, the variable is
set only if it did not have a true value before.

    stash.set('var2', 'default_value', 1)

Dotted compound variables may be specified as per get() above.

    [% foo.bar = 30 %]

    stash.set([ 'foo', 0, 'bar', 0 ], 30)

The magical variable 'IMPORT' can be specified whose corresponding
value should be a dictionary.  The contents of the dictionary are
copied (i.e. imported) into the current namespace.

    # foo.bar = baz, foo.wiz = waz
    stash.set('foo', { 'bar': 'baz', 'wiz': 'waz' })

    # import 'foo' into main namespace: bar = baz, wiz = waz
    stash.set('IMPORT', stash.get('foo'))


clone(params)

The clone() method creates and returns a new Stash object which
represents a localised copy of the parent stash.  Variables can be
freely updated in the cloned stash and when declone() is called, the
original stash is returned with all its members intact and in the same
state as they were before clone() was called.

For convenience, a dictionary of parameters may be passed into clone()
which is used to update any simple variable (i.e. those that don't
contain any namespace elements like 'foo' and 'bar' but not 'foo.bar')
variables while cloning the stash.  For adding and updating complex
variables, the set() method should be used after calling clone().
This will correctly resolve and/or create any necessary namespace
hashes.

A cloned stash maintains a reference to the stash that it was copied
from in its '__parent' member.

=head2 declone()

The declone() method returns the '__parent' reference and can be used
to restore the state of a stash as described above.

"""


class Stash:
  """Definition of an object class which stores and manages access to
  variables for the Template Toolkit.
  """

  # Regular expression that identifies "private" stash entries.
  PRIVATE = r"^[_.]"

  # Dictionary of root operations.
  ROOT_OPS = VMethods.ROOT

  # Dictionary of scalar operations.
  SCALAR_OPS = VMethods.TEXT

  # Dictionary of list operations.
  LIST_OPS = VMethods.LIST

  # Dictionary of hash operations.
  HASH_OPS = VMethods.HASH

  # Mapping of names to ops dictionaries, see define_vmethod method.
  OPS = { "scalar": SCALAR_OPS,
          "item": SCALAR_OPS,
          "list": LIST_OPS,
          "array": LIST_OPS,
          "hash": HASH_OPS }

  def __init__(self, params=None):
    params = params or {}
    self.__contents = {"global": {}}
    self.__contents.update(params)
    self.__contents.update(self.ROOT_OPS)
    self.__parent = None
    self.__debug = bool(params.get("_DEBUG"))

  def __getitem__(self, key):
    """Provides direct, container-like read access to the stash contents."""
    return self.__contents.get(key)

  def __setitem__(self, key, value):
    """Provides direct, container-like write access to the stash contents."""
    self.__contents[key] = value

  def clone(self, params=None):
    """Creates a copy of the current stash object to effect
    localisation of variables.

    The new stash is blessed into the same class as the parent (which
    may be a derived class) and has a '__parent' member added which
    contains a reference to the parent stash that created it (self).
    This member is used in a successive declone() method call to
    return the reference to the parent.

    A parameter may be provided which should be a dictionary of
    variable/values which should be defined in the new stash.  The
    update() method is called to define these new variables in the
    cloned stash.

    Returns the cloned Stash.
    """
    params = params or {}
    import_ = params.get("import")
    if isinstance(import_, dict):
      del params["import"]
    else:
      import_ = None
    clone = Stash()
    clone.__contents.update(self.__contents)
    clone.__contents.update(params)
    clone.__debug = self.__debug
    clone.__parent = self
    if import_:
      self.HASH_OPS["import"](clone, import_)
    return clone

  def declone(self):
    """Returns a reference to the PARENT stash.

    When called in the following manner:

      stash = stash.declone()

    the reference count on the current stash will drop to 0 and be "freed"
    and the caller will be left with a reference to the parent.  This
    contains the state of the stash before it was cloned.
    """
    return self.__parent or self

  def get(self, ident, args=None):
    """Returns the value for an variable stored in the stash.

    The variable may be specified as a simple string, e.g. 'foo', or
    as an array reference representing compound variables.  In the
    latter case, each pair of successive elements in the list
    represent a node in the compound variable.  The first is the
    variable name, the second a list of arguments or 0 if undefined.
    So, the compound variable [% foo.bar('foo').baz %] would be
    represented as the list [ 'foo', 0, 'bar', ['foo'], 'baz', 0 ].
    Returns the value of the identifier or an empty string if
    undefined.
    """
    ident = util.unscalar(ident)
    root = self
    if isinstance(ident, str) and ident.find(".") != -1:
      ident = [y for x in ident.split(".")
                 for y in (re.sub(r"\(.*$", "", x), 0)]
    if isinstance(ident, (list, tuple)):
      for a, b in util.chop(ident, 2):
        result = self.__dotop(root, a, b)
        if result is not None:
          root = result
        else:
          break
    else:
      result = self.__dotop(root, ident, args)

    if result is None:
      result = self.undefined(ident, args)
    return util.PerlScalar(result)

  def set(self, ident, value, default=False):
    """Updates the value for a variable in the stash.

    The first parameter should be the variable name or list, as per
    get().  The second parameter should be the intended value for the
    variable.  The third, optional parameter is a flag which may be
    set to indicate 'default' mode.  When set true, the variable will
    only be updated if it is currently undefined or has a false value.
    The magical 'IMPORT' variable identifier may be used to indicate
    that value is a dictionary whose values should be imported.
    Returns the value set, or an empty string if not set (e.g. default
    mode).  In the case of IMPORT, returns the number of items
    imported from the hash.
    """

    root = self
    ident = util.unscalar(ident)
    value = util.unscalar(value)
    # ELEMENT: {
    if isinstance(ident, str) and ident.find(".") >= 0:
      ident = [y for x in ident.split(".")
                 for y in (re.sub(r"\(.*$", "", x), 0)]
    if isinstance(ident, (list, tuple)):
      chopped = list(util.chop(ident, 2))
      for i in range(len(chopped)-1):
        x, y = chopped[i]
        result = self.__dotop(root, x, y, True)
        if result is None:
          # last ELEMENT
          return ""
        else:
          root = result
      result = self.__assign(root, chopped[-1][0], chopped[-1][1],
                            value, default)
    else:
      result = self.__assign(root, ident, 0, value, default)

    if result is None:
      return ""
    else:
      return result

  def __assign(self, root, item, args=None, value=None, default=False):
    """Similar to __dotop, but assigns a value to the given variable
    instead of simply returning it.

    The first three parameters are the root item, the item and
    arguments, as per __dotop, followed by the value to which the
    variable should be set and an optional 'default' flag.  If set
    true, the variable will only be set if currently false.
    """
    item = util.unscalar(item)
    args = util.unscalar_list(args)
    atroot = root is self
    if root is None or item is None:
      return None
    elif self.PRIVATE and re.search(self.PRIVATE, item):
      return None
    elif isinstance(root, dict) or atroot:
      if not (default and root.get(item)):
        root[item] = value
        return value
    elif isinstance(root, (list, tuple)) and re.match(r"-?\d+$", str(item)):
      item = int(item)
      if not (default and 0 <= item < len(root) and root[item]):
        root[item] = value
        return value
    elif util.is_object(root):
      if not (default and getattr(root, item)()):
        args.append(value)
        return getattr(root, item)(*args)
    else:
      raise Error("don't know how to assign to %s.%s" % (root, item))

    return None

  def __dotop(self, root, item, args=None, lvalue=False):
    """This is the core 'dot' operation method which evaluates
    elements of variables against their root.

    All variables have an implicit root which is the stash object
    itself.  Thus, a non-compound variable 'foo' is actually
    '(stash.)foo', the compound 'foo.bar' is '(stash.)foo.bar'.  The
    first parameter is the current root, initially the stash itself.
    The second parameter contains the name of the variable element,
    e.g. 'foo'.  The third optional parameter is a list of any
    parenthesised arguments specified for the variable, which are
    passed to sub-routines, object methods, etc.  The final parameter
    is an optional flag to indicate if this variable is being
    evaluated on the left side of an assignment (e.g. foo.bar.baz =
    10).  When set true, intermediated dictionaries will be created
    (e.g. bar) if necessary.

    Returns the result of evaluating the item against the root, having
    performed any variable "magic".  The value returned can then be used
    as the root of the next __dotop() in a compound sequence.  Returns
    None if the variable is undefined.
    """
    root = util.unscalar(root)
    item = util.unscalar(item)
    args = util.unscalar_list(args)
    atroot = root is self
    result = None

    # return undef without an error if either side of dot is unviable
    if root is None or item is None:
      return None

    # or if an attempt is made to access a private member, starting _ or .
    if (self.PRIVATE
        and isinstance(item, str)
        and re.search(self.PRIVATE, item)):
      return None

    found = True
    isdict = isinstance(root, dict)
    if atroot or isdict:
      # if root is a regular dict or a Template::Stash kinda dict (the
      # *real* root of everything).  We first lookup the named key
      # in the hash, or create an empty hash in its place if undefined
      # and the lvalue flag is set.  Otherwise, we check the HASH_OPS
      # pseudo-methods table, calling the code if found, or return None
      if isdict:
        # We have to try all these variants because Perl hash keys are
        # stringified, but Python's aren't.
        try:
          value = root[item]
        except (KeyError, TypeError):
          try:
            value = root[str(item)]
          except (KeyError, TypeError):
            try:
              value = root[int(item)]
            except (KeyError, TypeError, ValueError):
              value = None
      else:
        value = root[item]
      if value is not None:
        if callable(value):
          result = value(*args)
        else:
          return value
      elif lvalue:
        # we create an intermediate hash if this is an lvalue
        root[item] = {}
        return root[item]
      # ugly hack: only allow import vmeth to be called on root stash
      else:
        try:
          value = self.HASH_OPS.get(item)
        except TypeError:  # Because item is not hashable, presumably.
          value = None
        if (value and not atroot) or item == "import":
          result = value(root, *args)
        else:
          try:
            return _slice(root, item)
          except TypeError:
            found = False
    elif isinstance(root, (list, tuple, util.Sequence)):
      # if root is a list then we check for a LIST_OPS pseudo-method
      # or return the numerical index into the list, or None
      if isinstance(root, util.Sequence):
        root = root.as_list()
      try:
        value = self.LIST_OPS.get(item)
      except TypeError:  # Because item is not hashable, presumably.
        value = None
      if value:
        result = value(root, *args)
      else:
        try:
          value = root[int(item)]
        except TypeError:
          sliced = []
          try:
            return _slice(root, item)
          except TypeError:
            pass
        except IndexError:
          return None
        else:
          if callable(value):
            result = value(*args)
          else:
            return value
    elif util.is_object(root):
      try:
        value = getattr(root, item)
      except (AttributeError, TypeError):
        # Failed to get object method, so try some fallbacks.
        try:
          func = self.HASH_OPS[item]
        except (KeyError, TypeError):
          pass
        else:
          return func(root.__dict__, *args)
      else:
        if callable(value):
          return value(*args)
        else:
          return value
    elif item in self.SCALAR_OPS and not lvalue:
      result = self.SCALAR_OPS[item](root, *args)
    elif item in self.LIST_OPS and not lvalue:
      result = self.LIST_OPS[item]([root], *args)
    elif self.__debug:
      raise Error("don't know how to access [%r].%s" % (root, item))
    else:
      result = []

    if not found and self.__debug:
      raise Error("%s is undefined" % (item,))
    elif result is not None:
      return result
    elif self.__debug:
      raise Error("%s is undefined" % (item,))
    else:
      return None

  def getref(self, ident, args=None):
    """Returns a "reference" to a particular item.

    This is represented as a function which will return the actual
    stash item when called.  WARNING: still experimental!
    """
    root = self
    if util.is_seq(ident):
      chopped = list(util.chop(ident, 2))
      for i, (item, args) in enumerate(chopped):
        if i == len(chopped) - 1:
          break
        root = self.__dotop(root, item, args)
        if root is None:
          break
    else:
      item = ident
    if root is not None:
      return lambda *x: self.__dotop(root, item, tuple(args or ()) + x)
    else:
      return lambda *x: ""


  def update(self, params):
    """Update multiple variables en masse.

    No magic is performed.  Simple variable names only.
    """
    if params is not None:
      import_ = params.get("import")
      if isinstance(import_, dict):
        self.__contents.update(import_)
        del params["import"]
      self.__contents.update(params)

  def undefined(self, ident, args):
    """Method called when a get() returns an undefined value.

    Can be redefined in a subclass to implement alternate handling.
    """
    return ""

  def define_vmethod(self, type, name, func):
    """Defines a virtual method of type 'type' ('scalar', 'item',
    'hash', 'list', or 'array'), with name 'name', that invokes 'func'
    when called.

    It is expected that func be able to handle the type that it will
    be called upon.
    """
    try:
      self.OPS[type.lower()][name] = func
    except KeyError:
      raise Error("invalid vmethod type: %s\n" % type)


class Error(Exception):
  """A trivial local exception class."""
  pass


scalar_op = util.registrar(Stash.SCALAR_OPS)

list_op = util.registrar(Stash.LIST_OPS)

hash_op = util.registrar(Stash.HASH_OPS)


@scalar_op("item")
def scalar_item(scalar):
  return scalar


@scalar_op("list")
def scalar_list(scalar):
  return [scalar]


@scalar_op("hash")
def scalar_hash(scalar):
  return {"value": scalar}


@scalar_op("length")
def scalar_length(scalar):
  return len(str(scalar))


@scalar_op("size")
def scalar_size(scalar):
  return 1


@scalar_op("defined")
def scalar_defined(scalar):
  return 1


@scalar_op("match")
def scalar_match(scalar, search=None, matchall=False):
  if scalar is None or search is None:
    return scalar
  if matchall:
    matches = re.findall(search, str(scalar))
    if not matches:
      matches = None
    elif isinstance(matches[0], tuple):
      matches = [item for group in matches for item in group]  # flatten
  else:
    match = re.search(search, str(scalar))
    if match:
      matches = match.groups() or [1]
    else:
      matches = ""
  return matches


@scalar_op("search")
def scalar_search(scalar=None, pattern=None):
  if scalar is None or pattern is None:
    return scalar
  return re.search(pattern, str(scalar)) and True or False


@scalar_op("repeat")
def scalar_repeat(scalar="", count=1):
  return str(scalar) * count


@scalar_op("replace")
def scalar_replace(scalar="", pattern="", replace="", all=True):
  scalar = str(scalar)
  pattern = str(pattern)
  replace = str(replace)
  if re.search(r"\$\d+", replace):
    def expand(match1):
      def matched(match2):
        escaped = match2.group(1)
        if escaped:
          return escaped
        index = int(match2.group(2))
        if 0 < index <= len(match1.groups()):
          return match1.group(index)
        else:
          return ""
      return re.sub(r"\\([\\$])|\$(\d+)", matched, replace)
  else:
    expand = lambda _: replace
  return re.sub(pattern, expand, scalar, int(not all))


@scalar_op("remove")
def scalar_remove(scalar=None, search=None):
  if scalar is None or search is None:
    return scalar
  return re.sub(search, "", str(scalar))


@scalar_op("split")
def scalar_split(scalar="", split=None, limit=None):
  if limit is not None:
    return str(scalar).split(split, limit - 1)
  else:
    return str(scalar).split(split)


@scalar_op("chunk")
def scalar_chunk(scalar="", size=1):
  string = str(scalar)
  if size > 0:
    return [string[pos:pos+size] for pos in range(0, len(string), size)]
  else:
    seq = [string[max(pos,0):pos-size]
           for pos in range(len(string) + size, size, size)]
    seq.reverse()
    return seq


@scalar_op("substr")
def scalar_substr(scalar="", offset=0, length=None, replacement=None):
  scalar = str(scalar)
  if length is not None:
    if replacement is not None:
      return (scalar[:offset]
              + str(replacement)
              + scalar[offset + length:])
    else:
      return scalar[offset:offset + length]
  else:
    return scalar[offset:]


@hash_op("item")
def hash_item(hash, item=""):
  if Stash.PRIVATE and re.search(Stash.PRIVATE, item):
    return None
  else:
    return hash.get(item)


@hash_op("hash")
def hash_hash(hash):
  return hash


@hash_op("size")
def hash_size(hash):
  return len(hash)


@hash_op("each", "items")
def hash_each(hash):
  return [item for pair in hash.iteritems() for item in pair]


@hash_op("keys")
def hash_keys(hash):
  return hash.keys()


@hash_op("values")
def hash_values(hash):
  return hash.values()


@hash_op("pairs")
def hash_pairs(hash):
  return [{"key": key, "value": value} for key, value in sorted(hash.items())]


@hash_op("list")
def hash_list(hash, what=""):
  if what == "keys":
    return hash_keys(hash)
  elif what == "values":
    return hash_values(hash)
  elif what == "each":
    return hash_each(hash)
  else:
    return hash_pairs(hash)


@hash_op("exists")
def hash_exists(hash, key):
  return key in hash


@hash_op("defined")
def hash_defined(hash, key=None):
  if key is None:
    return True
  else:
    return hash.get(key) is not None


@hash_op("delete")
def hash_delete(hash, *keys):
  for key in keys:
    try:
      del hash[key]
    except KeyError:
      pass


@hash_op("import")
def hash_import(hash, imp=None):
  if isinstance(imp, dict):
    hash.update(imp)
  return ""


@hash_op("sort")
def hash_sort(hash):
  return [pair[0] for pair in sorted(hash.items(), key=_by_value(_to_lower))]


@hash_op("nsort")
def hash_nsort(hash):
  return [pair[0] for pair in sorted(hash.items(), key=_by_value(_to_long))]


@list_op("item")
def list_item(list, item=0):
  try:
    return list[util.numify(item)]
  except IndexError:
    return None


@list_op("list")
def list_list(list):
  return list[:]


@list_op("hash")
def list_hash(list, n=None):
  if n is not None:
    n = int(n or 0)
    return dict((index + n, item) for index, item in enumerate(list))
  else:
    return dict(util.chop(list, 2))


@list_op("push")
def list_push(list, *args):
  list.extend(args)
  return ""


@list_op("pop")
def list_pop(list):
  return list.pop()


@list_op("unshift")
def list_unshift(list, *args):
  list[:0] = args
  return ""


@list_op("shift")
def list_shift(list):
  try:
    return list.pop(0)
  except IndexError:
    return None


@list_op("max")
def list_max(list):
  return len(list) - 1


@list_op("size")
def list_size(list):
  return len(list)


@list_op("defined")
def list_defined(list, index=None):
  if index is None:
    return 1
  else:
    try:
      return int(list[util.numify(index)] is not None)
    except IndexError:
      return 0


@list_op("first")
def list_first(list, count=None):
  if count is None:
    if list:
      return list[0]
    else:
      return None
  else:
    return list[:count]


@list_op("last")
def list_last(list, count=None):
  if count is None:
    if list:
      return list[-1]
    else:
      return None
  else:
    return list[-count:]


@list_op("reverse")
def list_reverse(list):
  copy = list[:]
  copy.reverse()
  return copy


@list_op("grep")
def list_grep(list, pattern=""):
  regex = re.compile(pattern)
  return [item for item in list if regex.search(str(item))]


@list_op("join")
def list_join(list, joint=" "):
  return joint.join(str(item) for item in list)


@list_op("sort")
def list_sort(list, field=None):
  if len(list) <= 1:
    return list[:]
  elif field:
    return sorted(list, key=_smartsort(field, _to_lower))
  else:
    return sorted(list, key=_to_lower)


@list_op("nsort")
def list_nsort(list, field=None):
  if len(list) <= 1:
    return list[:]
  elif field:
    return sorted(list, key=_smartsort(field, _to_long))
  else:
    return sorted(list, key=_to_long)


@list_op("unique")
def list_unique(seq):
  # FIXME: This will break if the items of seq are unhashable.
  return list(set(seq))


@list_op("import")
def list_import(seq, *args):
  for arg in args:
    if isinstance(arg, list):
      seq.extend(x for x in arg if x is not None)
  return seq


@list_op("merge")
def list_merge(list_, *args):
  copy = list_[:]
  for arg in args:
    if isinstance(arg, list):
      copy.extend(x for x in arg if x is not None)
  return copy


@list_op("slice")
def list_slice(list, start=0, to=None):
  start = util.numify(start)
  if start < 0:
    start = len(list) + start
  if to is None or to < 0:
    return list[start:]
  else:
    to = util.numify(to)
    return list[start:to + 1]


@list_op("splice")
def list_splice(seq, start=0, length=None, *replace):
  start = util.numify(start)
  if start < 0:
    start = len(seq) + start
  if length is not None:
    stop = start + length
  else:
    stop = len(seq)
  if len(replace) == 1 and util.is_seq(replace[0]):
    replace = replace[0]
  s = slice(start, stop)
  removed = seq[s]
  seq[s] = replace
  return removed


def _smartsort(field, coerce):
  def getkey(element):
    key = element
    if isinstance(element, dict):
      key = element[field]
    else:
      attr = getattr(element, field, None)
      if callable(attr):
        key = attr()
    return coerce(key)
  return getkey


def _to_lower(x):
  return str(x).lower()


LONG_REGEX = re.compile(r"-?\d+")

def _to_long(x):
  try:
    return long(x)
  except ValueError:
    match = LONG_REGEX.match(str(x))
    if match:
      return long(match.group(0))
    else:
      return 0L


def _by_value(func):
  def wrapper(x):
    return func(x[1])
  return wrapper


def _slice(seq, items):
  if isinstance(items, str):
    raise TypeError
  sliced = []
  for x in items:
    try:
      sliced.append(seq[x])
    except KeyError:
      sliced.append(None)
  return sliced


def increment(x):
  return x + 1


def decrement(x):
  return x - 1


ROOT_OPS = {
  "inc": increment,
  "dec": decrement,
}
