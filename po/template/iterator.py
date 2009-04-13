#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

import operator
import sys

from template.config import Config
from template.constants import *
from template.util import unscalar, unscalar_list


"""
template.iterator - Data iterator used by the FOREACH directive


SYNOPSIS

    iter = template.iterator.Iterator(data, options)


DESCRIPTION

The template.iterator.Iterator class defines a generic data iterator
for use by the FOREACH directive.

It may be used as the base class for custom iterators.


PUBLIC METHODS

__init__(data)

Constructor.  A list of values is passed as the first parameter.
Subsequent calls to get_first() and get_next() calls will return each
element from the list.

    iter = template.iterator.Iterator([ 'foo', 'bar', 'baz' ])

The constructor will also accept a dictionary and will expand it into
a list in which each entry is a dictionary containing a 'key' and
'value' item, sorted according to the keys.

    iter = template.iterator.Iterator({
	'foo': 'Foo Item',
	'bar': 'Bar Item',
    })

This is equivalent to:

    iter = template.iterator.Iterator([
	{ 'key': 'bar', 'value': 'Bar Item' },
	{ 'key': 'foo', 'value': 'Foo Item' },
    ])

When passed a single item which is not a sequence type (other than a
string), the constructor will automatically create a list containing
that single item.

    iter = template.iterator.Iterator('foo')

This is equivalent to:

    iter = template.iterator.Iterator([ 'foo' ])

If the object supports iteration (such as via an __iter__ method),
then the Iterator will call that method to return the list of data.
For example:

    class MyListObject:
      def __init__(self, *args):
        self.items = args

    listobj = MyListObject('foo', 'bar')
    iter = template.iterator.Iterator(listobj)

This is then functionally equivalent to:

    iter = template.iterator.Iterator([ listobj ])

The iterator will return only one item, a reference to the MyListObject
object, listobj.

By adding an __iter__ method to the MyListObject class, we can force
the Iterator constructor to treat the object as a list and use the
data contained within.

    class MyListObject:
      ...

    def __iter__(self):
      return iter(self.items)

    listobj = MyListObject('foo', 'bar')
    iter = template.iterator.Iterator(listobj)

The iterator will now return the two item, 'foo' and 'bar', which the
MyObjectList encapsulates.

get_first()

Returns a (value, error) pair for the first item in the iterator set.
The error returned may be zero or None to indicate a valid datum was
successfully returned.  Returns an error of STATUS_DONE if the list is
empty.

get_next()

Returns a (value, error) pair for the next item in the iterator set.
Returns an error of STATUS_DONE if all items in the list have been
visited.

get_all()

Returns a (values, error) pair for all remaining items in the iterator
set.  Returns an error of STATUS_DONE if all items in the list have
been visited.

size()

Returns the size of the data set or None if unknown.

max()

Returns the maximum index number (i.e. the index of the last element)
which is equivalent to size() - 1.

index()

Returns the current index number which is in the range 0 to max().

count()

Returns the current iteration count in the range 1 to size().  This is
equivalent to index() + 1.  Note that number() is supported as an alias
for count() for backwards compatability.

first()

Returns a boolean value to indicate if the iterator is currently on
the first iteration of the set.

last()

Returns a boolean value to indicate if the iterator is currently on
the last iteration of the set.

prev()

Returns the previous item in the data set, or None if the iterator is
on the first item.

next()

Returns the next item in the data set or None if the iterator is on
the last item.

"""


class Iterator:
  """Class defining an iterator class which is used by the FOREACH
  directive for iterating through data sets.  This may be sub-classed
  to define more specific iterator types.

  An iterator is an object which provides a consistent way to navigate
  through data which may have a complex underlying form.  This
  implementation uses the get_first() and get_next() methods to
  iterate through a dataset.  The get_first() method is called once to
  perform any data initialisation and return the first value, then
  get_next() is called repeatedly to return successive values.  Both
  these methods return a pair of values which are the data item itself
  and a status code.  The default implementation handles iteration
  through a list of elements which is passed to the constructor.  An
  empty list is used if none is passed.  The module may be sub-classed
  to provide custom implementations which iterate through any kind of
  data in any manner as long as it can conforms to the
  get_first()/get_next() interface.  The object also implements the
  get_all() method for returning all remaining elements as a list.
  """
  def __init__(self, data=None, params=None):
    self._impl = self._IteratorImpl(normalize_data(data))

  @staticmethod
  def Create(expr):
    expr = unscalar(expr)
    if isinstance(expr, Iterator):
      return expr
    else:
      return Config.iterator(expr)

  def __iter__(self):
    return iter(self._impl)

  def size(self):
    return self._impl.size

  def max(self):
    return self._impl.max

  def index(self):
    return self._impl.index

  def count(self):
    return self._impl.count

  def number(self):
    return self._impl.count

  def first(self):
    return self._impl.first

  def last(self):
    return self._impl.last

  def prev(self):
    return self._impl.prev

  def next(self):
    return self._impl.next_

  def get_first(self):
    if self._impl.start():
      return self._impl.dataset[0]
    else:
      return None, STATUS_DONE

  def get_next(self):
    if self._impl.advance():
      return self._impl.data[self._impl.index]
    else:
      return None, STATUS_DONE

  def get_all(self):
    remaining = self._impl.remaining()
    if remaining:
      return remaining
    else:
      return None, STATUS_DONE

  # This implementation class provides a Pythonic iterator interface that's
  # useful in generated code.  The containing class provides the "classic"
  # get_first/get_next interface required by the builtin "loop" variable
  # and by the iterator plugin.  The two interfaces share the same state,
  # and so may be freely invoked in an interleaved fashion.

  class _IteratorImpl:
    def __init__(self, data):
      self.data = data
      self.error = ""
      self.dataset = None
      self.size = None
      self.max = None
      self.index = None
      self.count = None
      self.first = False
      self.last = False
      self.prev = None
      self.next_ = None

    def start(self):
      self.dataset = self.data
      self.size = len(self.data)
      if self.size == 0:
        return False
      self.max = self.size - 1
      self.index = 0
      self.count = 1
      self.first = True
      self.last = self.size == 1
      self.prev = None
      if len(self.dataset) >= 2:
        self.next_ = self.dataset[1]
      else:
        self.next_ = None
      return True

    def advance(self):
      if self.index is None:
        sys.stderr.write("iterator get_next() called before get_first()")
        return False
      elif self.index >= self.max:
        return False
      else:
        self.index += 1
        self.count = self.index + 1
        self.first = False
        self.last = self.index == self.max
        self.prev = self.data[self.index - 1]
        if self.index < len(self.data) - 1:
          self.next_ = self.data[self.index + 1]
        else:
          self.next_ = None
        return True

    def remaining(self):
      if self.index >= self.max:
        return None
      else:
        start = self.index + 1
        self.index = self.max
        self.count = self.max + 1
        self.first = False
        self.last = True
        return unscalar_list(self.dataset[start:])

    def __iter__(self):
      self.start()
      # Tell the next call to next() that the current state already
      # points to the first object, and not to advance to the second:
      self.ready = False
      return self

    def next(self):
      if not self.ready:
        self.ready = True
        if self.data:
          return unscalar(self.data[0])
      elif self.advance():
        return unscalar(self.data[self.index])
      raise StopIteration


def normalize_data(data):
  """Normalizes a sequence of input data according to the heuristic
  laid out in the module documentation.
  """
  data = data or []
  if isinstance(data, dict):
    data = [{"key": key, "value": value} for key, value in data.iteritems()]
    data.sort(key=operator.itemgetter("key"))
  elif isinstance(data, str):
    data = [data]
  elif not isinstance(data, list):
    try:
      data = list(data)
    except TypeError:
      data = [data]
  return data
