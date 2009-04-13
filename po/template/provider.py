#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

import os
import re
import sys
import time

from template.config import Config
from template.constants import *
from template.document import Document
from template.util import Literal, Struct, TemplateException, \
    can, modtime, slurp


"""
template.provider - Provider module for loading/compiling templates


SYNOPSIS

    provider = template.provider.Provider(options)

    tmpl = provider.fetch(name)


DESCRIPTION

The template.provider module is used to load, parse, compile and cache
template documents.  This object may be sub-classed to provide more
specific facilities for loading, or otherwise providing access to
templates.

The template.context.Context objects maintain a list of Provider
objects which are polled in turn (via fetch()) to return a requested
template.  Each may return a compiled template, raise an error, or
decline to serve the reqest, giving subsequent providers a chance to
do so.

This is the "Chain of Responsiblity" pattern.  See 'Design Patterns' for
further information.

The Provider class can also be subclassed to provide templates from a
different source; for example, a database.  See SUBCLASSIC, below.

This documentation needs work.


PUBLIC METHODS

__init__(options)

Constructor method which initializes a new Provider object.  The
optional parameter may be a dictionary containing any of the following
items:

* INCLUDE_PATH

The INCLUDE_PATH is used to specify one or more directories in which
template files are located.  When a template is requested that isn't
defined locally as a BLOCK, each of the INCLUDE_PATH directories is
searched in turn to locate the template file.  Multiple directories
can be specified as a list or as a single string where each directory
is delimited by ':'.

    provider = template.provider.Provider({
        'INCLUDE_PATH': '/usr/local/templates',
    })

    provider = template.provider.Provider({
        'INCLUDE_PATH': '/usr/local/templates:/tmp/my/templates',
    })

    provider = template.provider.Provider({
        'INCLUDE_PATH': [ '/usr/local/templates',
                          '/tmp/my/templates' ],
    })

On Win32 systems, a little extra magic is invoked, ignoring delimiters
that have ':' followed by a '/' or '\'.  This avoids confusion when using
directory names like 'C:\Blah Blah'.

When specified as a list, the INCLUDE_PATH path can contain elements
which dynamically generate a list of INCLUDE_PATH directories.  These
generator elements can be specified as a callable object or an object
which implements a paths() method.

    provider = template.provider.Provider({
        'INCLUDE_PATH': [ '/usr/local/templates',
                          lambda: incpath_generator(),
			  my.incpath.generator.Generator( ... ) ],
    })

Each time a template is requested and the INCLUDE_PATH examined, the
callable or object method will be called.  A list of directories
should be returned.  Generator subroutines and objects should report
errors by raising an exception.

For example:

      def incpath_generator():

	# ...some code...

        if all_is_well:
	    return [list_of_directories]
	else:
	    raise MyError("cannot generate INCLUDE_PATH...\n")

or:

    class MyGenerator:
      def paths(self):
        # ... some code ...
        if all_is_well:
          return [list_of_directories]
        else:
          raise MyError("cannot generate INCLUDE_PATH...\n")

* DELIMITER

Used to provide an alternative delimiter character sequence for
separating paths specified in the INCLUDE_PATH.  The default value for
DELIMITER is ':'.

    # tolerate Silly Billy's file system conventions
    provider = template.provider.Provider({
	'DELIMITER': '; ',
        'INCLUDE_PATH': 'C:/HERE/NOW; D:/THERE/THEN',
    })

    # better solution: install Linux!  :-)

On Win32 systems, the default delimiter is a little more intelligent,
splitting paths only on ':' characters that aren't followed by a '/'.
This means that the following should work as planned, splitting the
INCLUDE_PATH into 2 separate directories, C:/foo and C:/bar.

    # on Win32 only
    provider = template.provider.Provider({
	'INCLUDE_PATH': 'C:/Foo:C:/Bar'
    })

However, if you're using Win32 then it's recommended that you
explicitly set the DELIMITER character to something else (e.g. ';')
rather than rely on this subtle magic.

* ABSOLUTE

The ABSOLUTE flag is used to indicate if templates specified with
absolute filenames (e.g. '/foo/bar') should be processed.  It is
disabled by default and any attempt to load a template by such a
name will cause a 'file' exception to be raised.

    provider = template.provider.Provider({
	'ABSOLUTE': 1,
    })

    # this is why it's disabled by default
    [% INSERT /etc/passwd %]

On Win32 systems, the regular expression for matching absolute
pathnames is tweaked slightly to also detect filenames that start with
a driver letter and colon, such as:

    C:/Foo/Bar

* RELATIVE

The RELATIVE flag is used to indicate if templates specified with
filenames relative to the current directory (e.g. './foo/bar' or
'../../some/where/else') should be loaded.  It is also disabled by
default, and will raise a 'file' error if such template names are
encountered.

    provider = template.provider.Provider({
	'RELATIVE': 1,
    })

    [% INCLUDE ../logs/error.log %]

* DEFAULT

The DEFAULT option can be used to specify a default template which
should be used whenever a specified template can't be found in the
INCLUDE_PATH.

    provider = template.provider.Provider({
	'DEFAULT': 'notfound.html',
    })

If a non-existant template is requested through the template.process()
method, or by an INCLUDE, PROCESS or WRAPPER directive, then the
DEFAULT template will instead be processed, if defined.  Note that the
DEFAULT template is not used when templates are specified with
absolute or relative filenames, or as a file object or template literal.

* CACHE_SIZE

The template.provider module caches compiled templates to avoid the
need to re-parse template files or blocks each time they are used.
The CACHE_SIZE option is used to limit the number of compiled
templates that the module should cache.

By default, the CACHE_SIZE is None and all compiled templates are
cached.  When set to any positive value, the cache will be limited to
storing no more than that number of compiled templates.  When a new
template is loaded and compiled and the cache is full (i.e. the number
of entries == CACHE_SIZE), the least recently used compiled template
is discarded to make room for the new one.

The CACHE_SIZE can be set to 0 to disable caching altogether.

    provider = template.provider.Provider({
	'CACHE_SIZE': 64,   # only cache 64 compiled templates
    })

    provider = template.provider.Provider({
	'CACHE_SIZE': 0,   # don't cache any compiled templates
    })

As well as caching templates as they are found, the Provider also
implements negative caching to keep track of templates that are not
found.  This allows the provider to quickly decline a request for a
template that it has previously failed to locate, saving the effort of
going to look for it again.  This is useful when an INCLUDE_PATH
includes multiple providers, ensuring that the request is passed down
through the providers as quickly as possible.

* STAT_TTL

This value can be set to control how long the Provider will keep a
template cached in memory before checking to see if the source
template has changed.

    provider = template.provider.Provider({
        'STAT_TTL': 60,  # one minute
    })

The default value is 1 (second). You'll probably want to set this to a
higher value if you're running the Template Toolkit inside a
persistent web server application. For example, set it to 60 and the
provider will only look for changes to templates once a minute at
most. However, during development (or any time you're making frequent
changes to templates) you'll probably want to keep it set to a low
value so that you don't have to wait for the provider to notice that
your templates have changed.

* COMPILE_EXT

From version 2 onwards, the Template Toolkit has the ability to
compile templates to Python code and save them to disk for subsequent
use (i.e. cache persistence).  The COMPILE_EXT option may be provided
to specify a filename extension for compiled template files.  It is
None by default and no attempt will be made to read or write any
compiled template files.

    provider = template.provider.Provider({
	'COMPILE_EXT': '.ttc',
    })

If COMPILE_EXT is defined (and COMPILE_DIR isn't, see below) then compiled
template files with the COMPILE_EXT extension will be written to the same
directory from which the source template files were loaded.

Compiling and subsequent reuse of templates happens automatically
whenever the COMPILE_EXT or COMPILE_DIR options are set.  The Template
Toolkit will automatically reload and reuse compiled files when it
finds them on disk.  If the corresponding source file has been
modified since the compiled version as written, then it will load and
re-compile the source and write a new compiled version to disk.

This form of cache persistence offers significant benefits in terms of
time and resources required to reload templates.  Compiled templates
can be reloaded by a simple import, leaving Python to handle all the
parsing and compilation.  This is a Good Thing.

* COMPILE_DIR

The COMPILE_DIR option is used to specify an alternate directory root
under which compiled template files should be saved.

    provider = template.provider.Provider({
	'COMPILE_DIR': '/tmp/ttc',
    })

The COMPILE_EXT option may also be specified to have a consistent file
extension added to these files.

    provider1 = template.provider.Provider({
	'COMPILE_DIR': '/tmp/ttc',
	'COMPILE_EXT': '.ttc1',
    })

    provider2 = template.provider.Provider({
	'COMPILE_DIR': '/tmp/ttc',
	'COMPILE_EXT': '.ttc2',
    })

When COMPILE_EXT is undefined, the compiled template files have the
same name as the original template files, but reside in a different
directory tree.

Each directory in the INCLUDE_PATH is replicated in full beneath the
COMPILE_DIR directory.  This example:

    provider = template.provider.Provider({
	'COMPILE_DIR': '/tmp/ttc',
	'INCLUDE_PATH': '/home/abw/templates:/usr/share/templates',
    })

would create the following directory structure:

    /tmp/ttc/home/abw/templates/
    /tmp/ttc/usr/share/templates/

Files loaded from different INCLUDE_PATH directories will have their
compiled forms save in the relevant COMPILE_DIR directory.

On Win32 platforms a filename may by prefixed by a drive letter and
colon.  e.g.

    C:/My Templates/header

The colon will be silently stripped from the filename when it is added
to the COMPILE_DIR value(s) to prevent illegal filename being generated.
Any colon in COMPILE_DIR elements will be left intact.  For example:

    # Win32 only
    provider = template.provider.Provider({
	'DELIMITER': ';',
	'COMPILE_DIR': 'C:/TT2/Cache',
	'INCLUDE_PATH': 'C:/TT2/Templates;D:/My Templates',
    })

This would create the following cache directories:

    C:/TT2/Cache/C/TT2/Templates
    C:/TT2/Cache/D/My Templates

* TOLERANT

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
genuine disinclination to comply, then a'<resource> not found'
exception is raised.

* PARSER

The template.parser module implements a parser object for compiling
templates into Python code which can then be executed.  A default
object of this class is created automatically and then used by the
Provider whenever a template is loaded and requires compilation.  The
PARSER option can be used to provide an alternate parser object.

    provider = template.provider.Provider({
	'PARSER': myorg.template.parser.Parser({ ... }),
    })

* DEBUG

The DEBUG option can be used to enable debugging messages from the
template.provider module by setting it to include the DEBUG_PROVIDER
value.

    from template.constants import *

    template = template.Template({
	'DEBUG': DEBUG_PROVIDER,
    })


fetch(name)

Returns a compiled template for the name specified.  If the template
cannot be found then None is returned.  If an error occurs (e.g. read
error, parse error) then an exception is raised.  If the TOLERANT flag
is set the the method returns None instead of raising an exception.

store(name, template)

Stores the compiled template 'template' in the cache under the name 'name'.
Subsequent calls to fetch(name) will return this template in preference to
any disk-based file.

include_path(newpath)

Accessor method for the INCLUDE_PATH setting.  If called with an
argument, this method will replace the existing INCLUDE_PATH with
the new value.

paths()

This method generates a copy of the INCLUDE_PATH list.  Any elements
in the list which are dynamic generators (e.g. callables or objects
implementing a paths() method) will be called and the list of
directories returned merged into the output list.

It is possible to provide a generator which returns itself, thus
sending this method into an infinite loop.  To detect and prevent this
from happening, the MAX_DIRS class variable, set to 64 by default,
limits the maximum number of paths that can be added to, or generated
for the output list.  If this number is exceeded then the method will
immediately return an error reporting as much.


SUBCLASSING

The Provider class can be subclassed to provide templates from a
different source (e.g. a database).  In most cases you'll just need to
provide custom implementations of the _template_modified() and
_template_content() methods.

Caching in memory and on disk will still be applied (if enabled) when
overriding these methods.

_template_modified(path)

Returns a timestamp of the path passed in by calling stat().  This can
be overridden, for example, to return a last modified value from a
database.  The value returned should be a Unix epoch timestamp
although a sequence number should work as well.

_template_content(path, modtime=None)

This method returns the content of the template for all INCLUDE,
PROCESS, and INSERT directives.  It returns the content of the
template located at 'path', or None if no such file exists.

If the optional parameter 'modtime' is present, the modification time
of the file is stored in its 'modtime' attribute.

"""


RELATIVE_PATH = re.compile(r"(?:^|/)\.+/")


class Error(Exception):
  pass


class Provider:
  """This class handles the loading, compiling and caching of
  templates.

  Multiple Provider objects can be stacked and queried in turn to
  effect a Chain-of-Command between them.  A provider will attempt to
  return the requested template, raise an exception, or decline to
  provide the template (by returning None), allowing subsequent
  providers to attempt to deliver it.  See 'Design Patterns' for
  further details.
  """

  MAX_DIRS = 64

  STAT_TTL = 1

  DEBUG = False

  def __init__(self, params):
    size = params.get("CACHE_SIZE")
    paths = params.get("INCLUDE_PATH", ".")
    cdir = params.get("COMPILE_DIR", "")
    dlim = params.get("DELIMITER", os.name == "nt" and r":(?!\/)" or ":")
    debug = params.get("DEBUG")

    if isinstance(paths, str):
      paths = re.split(dlim, paths)
    if size == 1 or size < 0:
      size = 2
    if debug is not None:
      self.__debug = debug & (DEBUG_PROVIDER & DEBUG_FLAGS)
    else:
      self.__debug = self.DEBUG
    if cdir:
      for path in paths:
        if not isinstance(path, str):
          continue
        if os.name == "nt":
          path = path.replace(":", "")
        if not os.path.isdir(path):
          os.makedirs(path)

    self.__lookup = {}
    self.__notfound = {}  # Tracks templates *not* found.
    self.__slots = 0
    self.__size = size
    self.__include_path = paths
    self.__delimiter = dlim
    self.__compile_dir = cdir
    self.__compile_ext = params.get("COMPILE_EXT", "")
    self.__absolute = bool(params.get("ABSOLUTE"))
    self.__relative = bool(params.get("RELATIVE"))
    self.__tolerant = bool(params.get("TOLERANT"))
    self.__document = params.get("DOCUMENT", Document)
    self.__parser= params.get("PARSER")
    self.__default = params.get("DEFAULT")
    self.__encoding = params.get("ENCODING")
    self.__stat_ttl = params.get("STAT_TTL", self.STAT_TTL)
    self.__params = params
    self.__head = None
    self.__tail = None

  def fetch(self, name, prefix=None):
    """Returns a compiled template for the name specified by parameter.

    The template is returned from the internal cache if it exists, or
    loaded and then subsequently cached.  The ABSOLUTE and RELATIVE
    configuration flags determine if absolute (e.g. '/something...')
    and/or relative (e.g. './something') paths should be honoured.
    The INCLUDE_PATH is otherwise used to find the named file. 'name'
    may also be a template.util.Literal object that contains the
    template text, or a file object from which the content is read.
    The compiled template is not cached in these latter cases given
    that there is no filename to cache under.  A subsequent call to
    store(name, compiled) can be made to cache the compiled template
    for future fetch() calls, if necessary.

    Returns a compiled template or None if the template could not be
    found.  On error (e.g. the file was found but couldn't be read or
    parsed), an exception is raised.  The TOLERANT configuration
    option can be set to downgrade any errors to None.
    """
    if not isinstance(name, str):
      data = self._load(name)
      data = self._compile(data)
      return data and data.data
    elif os.path.isabs(name):
      if self.__absolute:
        return self._fetch(name)
      elif not self.__tolerant:
        raise Error("%s: absolute paths are not allowed (set ABSOLUTE option)"
                    % name)
    elif RELATIVE_PATH.search(name):
      if self.__relative:
        return self._fetch(name)
      elif not self.__tolerant:
        raise Error("%s: relative paths are not allowed (set RELATIVE option)"
                    % name)
    elif self.__include_path:
      return self._fetch_path(name)

    return None

  def _load(self, name, alias=None):
    """Load template text from a string (template.util.Literal), file
    object, or from an absolute filename.

    Returns an object with the following attributes:

      name    filename or 'alias', if provided, or 'input text', etc.
      text    template text
      time    modification time of file, or current time for files/strings
      load    time file was loaded (now!)

    On error, raises an exception, or returns None if TOLERANT is set.
    """
    now = time.time()
    if alias is None and isinstance(name, str):
      alias = name
    if isinstance(name, Literal):
      return Data(name.text(), alias, alt="input text", load=0)
    elif not isinstance(name, str):
      return Data(name.read(), alias, alt="input file", load=0)

    if self._template_modified(name):
      when = Struct()
      text = self._template_content(name, when)
      if text is not None:
        return Data(text, alias, when=when.modtime, path=name)

    return None

  def _fetch(self, name, t_name=None):
    """Fetch a file from cache or disk by specification of an absolute
    or relative filename.

    'name' is the path to search (possibly prefixed by INCLUDE_PATH).
    't_name' is the template name.

    No search of the INCLUDE_PATH is made.  If the file is found and
    loaded, it is compiled and cached.
    """
    # First see if the named template is in the memory cache.
    slot = self.__lookup.get(name)
    if slot:
      # Test is cache is fresh, and reload/compile if not.
      self._refresh(slot)
      return slot.data

    now = time.time()
    last_stat_time = self.__notfound.get(name)
    if last_stat_time:
      expires_in = last_stat_time + self.__stat_ttl - now
      if expires_in > 0:
        return None
      else:
        del self.__notfound[name]

    # Is there an up-to-date compiled version on disk?
    if self._compiled_is_current(name):
      compiled_template = self._load_compiled(self._compiled_filename(name))
      if compiled_template:
        return self.store(name, compiled_template)

    # Now fetch template from source, compile, and cache.
    tmpl = self._load(name, t_name)
    if tmpl:
      tmpl = self._compile(tmpl, self._compiled_filename(name))
      return self.store(name, tmpl.data)

    # Template could not be found.  Add to the negative/notfound cache.
    self.__notfound[name] = now
    return None

  def _compile(self, data, compfile=None):
    """Private method called to parse the template text and compile it
    into a runtime form.

    Creates and delegates a template.parser.Parser object to handle
    the compilation, or uses the object passed in PARSER.  On success,
    the compiled template is stored in the 'data' attribute of the
    'data' object and returned.  On error, an exception is raised, or
    None is returned if the TOLERANT flag is set.  The optional
    'compiled' parameter may be passed to specify the name of a
    compiled template file to which the generated Python code should
    be written.  Errors are (for now...) silently ignored, assuming
    that failures to open a file for writing are intentional (e.g
    directory write permission).
    """
    if data is None:
      return None

    text = data.text
    error = None

    if not self.__parser:
      self.__parser = Config.parser(self.__params)

    # discard the template text - we don't need it any more
    # del data.text

    parsedoc = self.__parser.parse(text, data)
    parsedoc["METADATA"].setdefault("name", data.name)
    parsedoc["METADATA"].setdefault("modtime", data.time)
    # write the Python code to the file compfile, if defined
    if compfile:
      basedir = os.path.dirname(compfile)
      if not os.path.isdir(basedir):
        try:
          os.makedirs(basedir)
        except IOError, e:
          error = Error("failed to create compiled templates "
                        "directory: %s (%s)" % (basedir, e))
      if not error:
        try:
          self.__document.write_python_file(compfile, parsedoc)
        except Exception, e:
          error = Error("cache failed to write %s: %s" % (
            os.path.basename(compfile), e))
      if error is None and data.time is not None:
        if not compfile:
          raise Error("invalid null filename")
        ctime = int(data.time)
        os.utime(compfile, (ctime, ctime))

    if not error:
      data.data = Document(parsedoc)
      return data

    if self.__tolerant:
      return None
    else:
      raise error

  def _compiled_is_current(self, template_name):
    """Returns True if template_name and its compiled name exists and
    they have the same mtime.
    """
    compiled_name = self._compiled_filename(template_name)
    if not compiled_name:
      return False

    compiled_mtime = modtime(compiled_name)
    if not compiled_mtime:
      return False

    template_mtime = self._template_modified(template_name)
    if not template_mtime:
      return False

    return compiled_mtime == template_mtime

  def _template_modified(self, path):
    """Returns the last modified time of the given path, or None if the
    path does not exist.

    Override if templates are not on disk, for example.
    """
    if path:
      return modtime(path)
    else:
      return None

  def _template_content(self, path, modtime=None):
    """Fetches content pointed to by 'path'.

    Stores the modification time of the file in the "modtime" attribute
    of the 'modtime' argument, if it is present.
    """
    if not path:
      raise Error("No path specified to fetch content from")

    f = None
    try:
      f = open(path)
      if modtime is not None:
        modtime.modtime = os.fstat(f.fileno()).st_mtime
      return f.read()
    finally:
      if f:
        f.close()

  def _fetch_path(self, name):
    """Fetch a file from cache or disk by specification of an absolute
    cache name (e.g. 'header') or filename relative to one of the
    INCLUDE_PATH directories.

    If the file isn't already cached and can be found and loaded, it
    is compiled and cached under the full filename.
    """
    # The template may have been stored using a non-filename name
    # so look for the plain name in the cache first.
    slot = self.__lookup.get(name)
    if slot:
      # Cached entry exists, so refresh slot and extract data.
      self._refresh(slot)
      return slot.data

    paths = self.paths()
    # Search the INCLUDE_PATH for the file, in cache or on disk.
    for dir in paths:
      path = os.path.join(dir, name)
      data = self._fetch(path, name)
      if data:
        return data

    # Not found in INCLUDE_PATH, now try DEFAULT.
    if self.__default is not None and name != self.__default:
      return self._fetch_path(self.__default)

    # We could not handle this template name.
    return None

  def _compiled_filename(self, path):
    if not (self.__compile_ext or self.__compile_dir):
      return None
    if os.name == "nt":
      path = path.replace(":", "")
    compiled = "%s%s" % (path, self.__compile_ext)
    if self.__compile_dir:
      # Can't use os.path.join here; compiled may be absolute.
      compiled = "%s%s%s" % (self.__compile_dir, os.path.sep, compiled)
    return compiled

  def _modified(self, name, time=None):
    """When called with a single argument, it returns the modification
    time of the named template.  When called with a second argument it
    returns true if 'name' has been modified since 'time'.
    """
    load = self._template_modified(name)
    if not load:
      return int(bool(time))
    if time:
      return int(load > time)
    else:
      return load

  def _refresh(self, slot):
    """Private method called to mark a cache slot as most recently used.

    A reference to the slot list should be passed by parameter.  The
    slot is relocated to the head of the linked list.  If the file
    from which the data was loaded has been updated since it was
    compiled, then it is re-loaded from disk and re-compiled.
    """
    data = None
    now = time.time()
    expires_in_sec = slot.stat + self.__stat_ttl - now
    if expires_in_sec <= 0:
      slot.stat = now
      template_mtime = self._template_modified(slot.name)
      if template_mtime is None or template_mtime != slot.load:
        try:
          data = self._load(slot.name, slot.data.name)
          data = self._compile(data)
        except:
          slot.stat = 0
          raise
        else:
          slot.data = data.data
          slot.load = data.time

    if self.__head is not slot:
      # remove existing slot from usage chain...
      if slot.prev:
        slot.prev.next = slot.next
      else:
        self.__head = slot.next
      if slot.next:
        slot.next.prev = slot.prev
      else:
        self.__tail = slot.prev
      # ...and add to start of list
      head = self.__head
      if head:
        head.prev = slot
      slot.prev = None
      slot.next = head
      self.__head = slot

    return data

  def _load_compiled(self, path):
    try:
      return Document.evaluate_file(path)
    except TemplateException, e:
      raise Error("compiled template %s: %s" % (path, e))

  def _store(self, name, data, compfile=None):
    """Private method called to add a data item to the cache.

    If the cache size limit has been reached then the oldest entry at
    the tail of the list is removed and its slot relocated to the head
    of the list and reused for the new data item.  If the cache is
    under the size limit, or if no size limit is defined, then the
    item is added to the head of the list.

    Returns compiled template.
    """
    # Return if memory cache disabled.
    if self.__size is not None and not self.__size:
      return data.data

    # Extract the compiled template from the data object.
    data = data.data
    # Check the modification time -- extra stat here.
    load = self._modified(name)
    if self.__size is not None and self.__slots >= self.__size:
      # cache has reached size limit, so reuse oldest entry
      # remove entry from tail or list
      slot = self.__tail
      slot.prev.next = None
      self.__tail = slot.prev

      # remove name lookup for old node
      del self.__lookup[slot.name]

      # add modified node to head of list
      head = self.__head
      if head:
        head.prev = slot

      slot.reset(name, data, load, time.time(), None, head)
      self.__head = slot

      # add name lookup for new node
      self.__lookup[name] = slot
    else:
      # cache is under size limit, or none is defined
      head = self.__head
      slot = Slot(name, data, load, time.time(), None, head)
      if head:
        head.prev = slot
      self.__head = slot
      if not self.__tail:
        self.__tail = slot
      # add lookup from name to slot and increment nslots
      self.__lookup[name] = slot
      self.__slots += 1

    return data

  def paths(self):
    """Evaluates the INCLUDE_PATH list, ignoring any blank entries,
    and calling any callable or objects to return dynamically
    generated path lists.

    Returns a new list of paths or raises an exception on error.
    """
    ipaths = self.__include_path[:]
    opaths = []
    count = self.MAX_DIRS
    while ipaths and count > 0:
      count -= 1
      dir = ipaths.pop(0)
      if not dir:
        continue
      # dir can be a sub or object ref which returns a reference
      # to a dynamically generated list of search paths
      if callable(dir):
        ipaths[:0] = dir()
      else:
        try:
          paths = dir.paths
        except AttributeError:
          pass
        else:
          if callable(paths):
            ipaths[:0] = paths()
            continue
        opaths.append(dir)

    if ipaths:
      raise Error("INCLUDE_PATH exceeds %d directories" % (self.MAX_DIRS,))
    else:
      return opaths

  def store(self, name, data):
    """Store a compiled template 'data' in the cache as 'name'.

    Returns compiled template.
    """
    return self._store(name, Data(data=data, load=0))

  def load(self, name, prefix=None):
    """Load a template without parsing/compiling it, suitable for use
    with the INSERT directive.

    There's some duplication with fetch() and at some point this could
    be reworked to integrate them a little closer.
    """
    path = name
    error = None
    if os.path.isabs(name):
      if not self.__absolute:
        error = ("%s: absolute paths are not allowed (set ABSOLUTE option)"
                 % name)
    elif RELATIVE_PATH.search(name):
      if not self.__relative:
        error = ("%s: relative paths are not allowed (set RELATIVE option)"
                 % name)
    else:
      for dir in self.paths():
        path = os.path.join(dir, name)
        if self._template_modified(path):
          break
      else:
        path = None

    if path and not error:
      try:
        data = self._template_content(path)
      except IOError, e:
        error = "%s: %s" % (name, e)

    if error:
      if not self.__tolerant:
        raise Error(error)
    elif path is not None:
      return data

    return None

  def include_path(self, path=None):
    """Accessor method for the INCLUDE_PATH setting.

    If called with an argument, this method will replace the existing
    INCLUDE_PATH with the new value.
    """
    if path:
      self.__include_path = path
    return self.__include_path

  def parser(self):
    return self.__parser

  def tolerant(self):
    return self.__tolerant


class Data:
  def __init__(self, text=None, name=None, alt=None, when=None, path=None,
               load=None, data=None):
    self.text = text
    if name is not None:
      self.name = name
    else:
      self.name = alt
    if when is not None:
      self.time = when
    else:
      self.time = time.time()
    if path is not None:
      self.path = path
    else:
      self.path = self.name
    self.load = load
    self.data = data

  def __repr__(self):
    return "Data(text=%r, name=%r, time=%r, path=%r, load=%r, data=%r)" % (
      self.text, self.name, self.time, self.path, self.load, self.data)

class Slot:
  def __init__(self, name, data, load, stat, prev=None, next=None):
    self.reset(name, data, load, stat, prev, next)

  def reset(self, name, data, load, stat, prev, next):
    self.name = name
    self.data = data
    self.load = load
    self.stat = stat
    self.prev = prev
    self.next = next
