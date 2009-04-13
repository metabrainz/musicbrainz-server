#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

from template.plugin import Plugin
from template.iterator import Iterator


"""
template.plugin.table - Plugin to present data in a table


SYNOPSIS

    [% USE table(list, rows=n, cols=n, overlap=n, pad=0) %]

    [% FOREACH item = table.row(n) %]
       [% item %]
    [% END %]

    [% FOREACH item = table.col(n) %]
       [% item %]
    [% END %]

    [% FOREACH row = table.rows %]
       [% FOREACH item = row %]
          [% item %]
       [% END %]
    [% END %]

    [% FOREACH col = table.cols %]
       [% col.first %] - [% col.last %] ([% col.size %] entries)
    [% END %]


DESCRIPTION

The Table plugin allows you to format a list of data items into a
virtual table.  When you create a Table plugin via the USE directive,
simply pass a list as the first parameter and then specify a fixed
number of rows or columns.

    [% USE Table(list, rows=5) %]
    [% USE table(list, cols=5) %]

The 'Table' plugin name can also be specified in lower case as shown
in the second example above.  You can also specify an alternative
variable name for the plugin as per regular Template Toolkit syntax.

    [% USE mydata = table(list, rows=5) %]

The plugin then presents a table based view on the data set.  The data
isn't actually reorganised in any way but is available via the row(),
col(), rows() and cols() as if formatted into a simple two dimensional
table of n rows x n columns.  Thus, if our sample 'alphabet' list
contained the letters 'a' to 'z', the above USE directives would
create plugins that represented the following views of the alphabet.

    [% USE table(alphabet, ... %]

    rows=5                  cols=5
    a  f  k  p  u  z        a  g  m  s  y
    b  g  l  q  v           b  h  n  t  z
    c  h  m  r  w           c  i  o  u
    d  i  n  s  x           d  j  p  v
    e  j  o  t  y           e  k  q  w
                            f  l  r  x

We can request a particular row or column using the row() and col()
methods.

    [% USE table(alphabet, rows=5) %]
    [% FOREACH item = table.row(0) %]
       # [% item %] set to each of [ a f k p u z ] in turn
    [% END %]

    [% FOREACH item = table.col(2) %]
       # [% item %] set to each of [ m n o p q r ] in turn
    [% END %]

Data in rows is returned from left to right, columns from top to
bottom.  The first row/column is 0.  By default, rows or columns that
contain empty values will be padded with the None to fill it to the
same size as all other rows or columns.  For example, the last row
(row 4) in the first example would contain the values [ e j o t y
undef ]. The Template Toolkit will safely accept these undefined
values and print a empty string.  You can also use the IF directive to
test if the value is set.

   [% FOREACH item = table.row(4) %]
      [% IF item %]
         Item: [% item %]
      [% END %]
   [% END %]

You can explicitly disable the 'pad' option when creating the plugin
to returned shortened rows/columns where the data is empty.

   [% USE table(alphabet, cols=5, pad=0) %]
   [% FOREACH item = table.col(4) %]
      # [% item %] set to each of 'y z'
   [% END %]

The rows() method returns all rows/columns in the table as a list of
rows (themselves lists).  The row() methods when called without any
arguments calls rows() to return all rows in the table.

Ditto for cols() and col().

    [% USE table(alphabet, cols=5) %]
    [% FOREACH row = table.rows %]
       [% FOREACH item = row %]
          [% item %]
       [% END %]
    [% END %]

The Template Toolkit provides the first(), last() and size() methods
that can be called on lists to return the first/last entry or the
number of entried.  The following example shows how we might use this
to provide an alphabetical index split into 3 even parts.

    [% USE table(alphabet, cols=3, pad=0) %]
    [% FOREACH group = table.col %]
       [ [% group.first %] - [% group.last %] ([% group.size %] letters) ]
    [% END %]

This produces the following output:

    [ a - i (9 letters) ]
    [ j - r (9 letters) ]
    [ s - z (8 letters) ]

We can also use the general purpose join() list method which joins the
items of the list using the connecting string specified.

    [% USE table(alphabet, cols=5) %]
    [% FOREACH row = table.rows %]
       [% row.join(' - ') %]
    [% END %]

Data in the table is ordered downwards rather than across but can easily
be transformed on output.  For example, to format our data in 5 columns
with data ordered across rather than down, we specify 'rows=5' to order
the data as such:

    a  f  .  .
    b  g  .
    c  h
    d  i
    e  j

and then iterate down through each column (a-e, f-j, etc.) printing
the data across.

    a  b  c  d  e
    f  g  h  i  j
    .  .
    .

Example code to do so would be much like the following:

    [% USE table(alphabet, rows=3) %]
    [% FOREACH cols = table.cols %]
      [% FOREACH item = cols %]
        [% item %]
      [% END %]
    [% END %]

    a  b  c
    d  e  f
    g  h  i
    j  .  .
    .

In addition to a list, the Table plugin constructor may be passed a
reference to a template.iterator.Iterator object or subclass thereof.
The get_all() method is first called on the iterator to return all
remaining items.  These are then available via the usual Table
interface.

    [% USE DBI(dsn,user,pass) -%]

    # query() returns an iterator
    [% results = DBI.query('SELECT * FROM alphabet ORDER BY letter') %]

    # pass into Table plugin
    [% USE table(results, rows=8 overlap=1 pad=0) -%]

    [% FOREACH row = table.cols -%]
       [% row.first.letter %] - [% row.last.letter %]:
          [% row.join(', ') %]
    [% END %]

"""


class Error(Exception):
  """A trivial local exception class."""
  pass


class Table(Plugin):
  """Plugin to order a linear data set into a virtual 2-dimensional table
  from which row and column permutations can be fetched.
  """
  def __init__(self, context, data, params=None):
    """Initialises the object to iterate through the data set passed
    by list as the first parameter.

    It calculates the shape of the permutation table based on the ROWS
    or COLS parameters specified in the params dictionary.  The
    OVERLAP parameter may be provided to specify the number of common
    items that should be shared between subseqent columns.
    """
    Plugin.__init__(self)
    if isinstance(data, Iterator):
      data, error = data.get_all()
      if error:
        raise Error("iterator failed to provide data for table: %s" % error)
    if not isinstance(data, (tuple, list)):
      raise Error("invalid table data, expecting a list")

    if params is None:
      params = {}
    if not isinstance(params, dict):
      raise Error("invalid table parameters, expecting a dict")

    # ensure keys are folded to upper case
    params.update(dict((str(key).upper(), value)
                  for key, value in params.iteritems()))

    size = len(data)
    overlap = params.get("OVERLAP", 0)

    rows = params.get("ROWS")
    cols = params.get("COLS")
    if rows:
      if size < rows:
        rows = size
        cols = 1
        coloff = 0
      else:
        coloff = rows - overlap
        cols = size / coloff + int(size % coloff > overlap)
    elif cols:
      if size < cols:
        cols = size
        rows = 1
        coloff = 1
      else:
        coloff = size / cols + int(size % cols > overlap)
        rows = coloff + overlap
    else:
      rows = size
      cols = 1
      coloff = 0

    self._DATA = data
    self._SIZE = size
    self._NROWS = rows
    self._NCOLS = cols
    self._COLOFF = coloff
    self._OVERLAP = overlap
    self._PAD = params.get("PAD")
    if self._PAD is None:
      self._PAD = 1

  def row(self, row=None):
    """Returns a list containing the items in the row whose number is
    specified by parameter.

    If the row number is undefined, it calls rows() to return a list
    of all rows.
    """
    if row is None:
      return self.rows()
    if row >= self._NROWS or row < 0:
      return None
    index = row
    set = []
    for c in range(self._NCOLS):
      if index < self._SIZE:
        set.append(self._DATA[index])
      elif self._PAD:
        set.append(None)
      index += self._COLOFF
    return set

  def col(self, col=None):
    """Returns a list containing the items in the column whose number
    is specified by parameter.

    If the column number is undefined, it calls cols() to return a
    list of all columns.
    """
    if col is None:
      return self.cols()
    if col >= self._NCOLS or col < 0:
      return None
    blanks = 0
    start = self._COLOFF * col
    end = start + self._NROWS - 1
    if end < start:
      end = start
    if end >= self._SIZE:
      blanks = end - self._SIZE + 1
      end = self._SIZE - 1
    if start >= self._SIZE:
      return None
    set = self._DATA[start:end+1]
    if self._PAD:
      set.extend([None] * blanks)
    return set

  def rows(self):
    """Returns all rows as a list of rows."""
    return [row for row in [self.row(x) for x in range(self._NROWS)]
            if row is not None]

  def cols(self):
    """Returns all rows as a reference to a list of rows."""
    return [col for col in [self.col(x) for x in range(self._NCOLS)]
            if col is not None]

  def data(self):
    return self._DATA

  def size(self):
    return self._SIZE

  def nrows(self):
    return self._NROWS

  def ncols(self):
    return self._NCOLS

  def overlap(self):
    return self._OVERLAP

  def pad(self):
    return self._PAD

table = Table
