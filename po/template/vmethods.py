#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

import re

from template.util import chop, is_seq, numify, registrar


class VMethods:
  ROOT = { }
  TEXT = { }
  HASH = { }
  LIST = { }


root_op = registrar(VMethods.ROOT)

scalar_op = registrar(VMethods.TEXT)

hash_op = registrar(VMethods.HASH)

list_op = registrar(VMethods.LIST)


@root_op("inc")
def root_inc(x):
  return x + 1


@root_op("dec")
def root_dec(x):
  return x - 1


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
    return list[numify(item)]
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
    return dict(chop(list, 2))


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
      return int(list[numify(index)] is not None)
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
  start = numify(start)
  if start < 0:
    start = len(list) + start
  if to is None or to < 0:
    return list[start:]
  else:
    to = numify(to)
    return list[start:to + 1]


@list_op("splice")
def list_splice(seq, start=0, length=None, *replace):
  start = numify(start)
  if start < 0:
    start = len(seq) + start
  if length is not None:
    stop = start + length
  else:
    stop = len(seq)
  if len(replace) == 1 and is_seq(replace[0]):
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
