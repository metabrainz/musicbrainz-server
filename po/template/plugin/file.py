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

try:
  import pwd
  import grp
except ImportError:
  # Modules not available, probably because this is Windows:
  pwd = grp = None

from template import util
from template.plugin import Plugin
from template.util import TemplateException


"""
template.plugin.file - Plugin providing information about files


SYNOPSIS

    [% USE File(filepath) %]
    [% File.path %]         # full path
    [% File.name %]	    # filename
    [% File.dir %]          # directory


DESCRIPTION

This plugin provides an abstraction of a file.  It can be used to
fetch details about files from the file system, or to represent
abstract files (e.g. when creating an index page) that may or may not
exist on a file system.

A file name or path should be specified as a constructor argument.  e.g.

    [% USE File('foo.html') %]
    [% USE File('foo/bar/baz.html') %]
    [% USE File('/foo/bar/baz.html') %]

The file should exist on the current file system (unless 'nostat'
option set, see below) as an absolute file when specified with as
leading '/' as per '/foo/bar/baz.html', or otherwise as one relative
to the current working directory.  The initializer performs a stat()
on the file and makes the 13 elements returned available as the plugin
items:

    dev ino mode nlink uid gid rdev size
    atime mtime ctime blksize blocks

e.g.

    [% USE File('/foo/bar/baz.html') %]

    [% File.mtime %]
    [% File.mode %]
    ...

In addition, the 'user' and 'group' items are set to contain the user
and group names as returned by calls to getpwuid() and getgrgid() for
the file 'uid' and 'gid' elements, respectively.  On Win32 platforms
on which getpwuid() and getgrid() are not available, these values are
None.

    [% USE File('/tmp/foo.html') %]
    [% File.uid %]	# e.g. 500
    [% File.user %]     # e.g. abw

This user/group lookup can be disabled by setting the 'noid' option.

    [% USE File('/tmp/foo.html', noid=1) %]
    [% File.uid %]	# e.g. 500
    [% File.user %]     # nothing

The 'isdir' flag will be set if the file is a directory.

    [% USE File('/tmp') %]
    [% File.isdir %]	# 1

If the stat() on the file fails (e.g. file doesn't exists, bad
permission, etc) then the constructor will throw a 'File' exception.
This can be caught within a TRY...CATCH block.

    [% TRY %]
       [% USE File('/tmp/myfile') %]
       File exists!
    [% CATCH File %]
       File error: [% error.info %]
    [% END %]

Note the capitalisation of the exception type, 'File' to indicate an
error thrown by the 'File' plugin, to distinguish it from a regular
'file' exception thrown by the Template Toolkit.

Note that the 'File' plugin can also be referenced by the lower case
name 'file'.  However, exceptions are always thrown of the 'File'
type, regardless of the capitalisation of the plugin named used.

    [% USE file('foo.html') %]
    [% file.mtime %]

As with any other Template Toolkit plugin, an alternate name can be
specified for the object created.

    [% USE foo = file('foo.html') %]
    [% foo.mtime %]

The 'nostat' option can be specified to prevent the plugin initializer
from performing a stat() on the file specified.  In this case, the
File does not have to exist in the file system, no attempt will be
made to verify that it does, and no error will be thrown if it
doesn't.  The entries for the items usually returned by stat() will be
set empty.

    [% USE file('/some/where/over/the/rainbow.html', nostat=1) %]
    [% file.mtime %]     # nothing

All File plugins, regardless of the nostat option, have set a number
of items relating to the original path specified.

* path

The full, original file path specified to the constructor.

    [% USE file('/foo/bar.html') %]
    [% file.path %]	# /foo/bar.html

* name

The name of the file without any leading directories.

    [% USE file('/foo/bar.html') %]
    [% file.name %]	# bar.html

* dir

The directory element of the path with the filename removed.

    [% USE file('/foo/bar.html') %]
    [% file.name %]	# /foo

* ext

The file extension, if any, appearing at the end of the path following
a '.' (not included in the extension).

    [% USE file('/foo/bar.html') %]
    [% file.ext %]	# html

* home

This contains a string of the form '../..' to represent the upward path
from a file to its root directory.

    [% USE file('bar.html') %]
    [% file.home %]	# nothing

    [% USE file('foo/bar.html') %]
    [% file.home %]	# ..

    [% USE file('foo/bar/baz.html') %]
    [% file.home %]	# ../..

* root

The 'root' item can be specified as a constructor argument, indicating
a root directory in which the named file resides.  This is otherwise
set empty.

    [% USE file('foo/bar.html', root='/tmp') %]
    [% file.root %]	# /tmp

* abs

This returns the absolute file path by constructing a path from the
'root' and 'path' options.

    [% USE file('foo/bar.html', root='/tmp') %]
    [% file.path %]	# foo/bar.html
    [% file.root %]	# /tmp
    [% File.abs %]	# /tmp/foo/bar.html


In addition, the following method is provided:

* rel(path)

This returns a relative path from the current file to another path specified
as an argument.  It is constructed by appending the path to the 'home'
item.

    [% USE file('foo/bar/baz.html') %]
    [% file.rel('wiz/waz.html') %]	# ../../wiz/waz.html


EXAMPLES

    [% USE file('/foo/bar/baz.html') %]

    [% file.path  %]      # /foo/bar/baz.html
    [% file.dir   %]      # /foo/bar
    [% file.name  %]      # baz.html
    [% file.home  %]      # ../..
    [% file.root  %]      # ''
    [% file.abs   %]      # /foo/bar/baz.html
    [% file.ext   %]      # html
    [% file.mtime %]	  # 987654321
    [% file.atime %]      # 987654321
    [% file.uid   %]      # 500
    [% file.user  %]      # abw

    [% USE file('foo.html') %]

    [% file.path %]	  # foo.html
    [% file.dir  %]       # ''
    [% file.name %]	  # foo.html
    [% file.root %]       # ''
    [% file.home %]       # ''
    [% file.abs  %]       # foo.html

    [% USE file('foo/bar/baz.html') %]

    [% file.path %]	  # foo/bar/baz.html
    [% file.dir  %]       # foo/bar
    [% file.name %]	  # baz.html
    [% file.root %]       # ''
    [% file.home %]       # ../..
    [% file.abs  %]       # foo/bar/baz.html

    [% USE file('foo/bar/baz.html', root='/tmp') %]

    [% file.path %]	  # foo/bar/baz.html
    [% file.dir  %]       # foo/bar
    [% file.name %]	  # baz.html
    [% file.root %]       # /tmp
    [% file.home %]       # ../..
    [% file.abs  %]       # /tmp/foo/bar/baz.html

    # calculate other file paths relative to this file and its root
    [% USE file('foo/bar/baz.html', root => '/tmp/tt2') %]

    [% file.path('baz/qux.html') %]	    # ../../baz/qux.html
    [% file.dir('wiz/woz.html')  %]     # ../../wiz/woz.html

"""


STAT_KEYS = ("dev", "ino", "mode", "nlink", "uid", "gid", "rdev", "size",
             "atime", "mtime", "ctime", "blksize", "blocks")


class File(Plugin):
  """Plugin for encapsulating information about a system file."""
  def __init__(self, context, path, config=None):
    """Initialize a new File object.

    Takes the pathname of the file as the argument following the
    context and an optional dictionary of configuration parameters.
    """
    if not isinstance(config, dict):
      config = {}
    if not path:
      self.throw("no file specified")
    if os.path.isabs(path):
      root = ""
    else:
      root = config.get("root")
      if root:
        if root.endswith("/"):
          root = root[:-1]
      else:
        root = ""
    dir, name = os.path.split(path)
    name, ext = util.unpack(re.split(r"(\.\w+)$", name), 2)
    if ext is None:
      ext = ""
    if dir.endswith("/"):
      dir = dir[:-1]
    if dir == ".":
      dir = ""
    name = name + ext
    if ext.startswith("."):
      ext = ext[1:]
    fields = splitpath(dir)
    if fields and not fields[0]:
      fields.pop(0)
    home = "/".join(("..",) * len(fields))
    abspath = os.path.join(root, path)
    self.path = path
    self.name = name
    self.root = root
    self.home = home
    self.dir = dir
    self.ext = ext
    self.abs = abspath
    self.user = ""
    self.group = ""
    self.isdir = ""
    self.stat = config.get("stat") or not config.get("nostat")
    if self.stat:
      try:
        stat = os.stat(abspath)
      except OSError, e:
        self.throw("%s: %s" % (abspath, e))
      for key in STAT_KEYS:
        setattr(self, key, getattr(stat, "st_%s" % key, None))
      if not config.get("noid"):
        self.user = pwd and getpwuid(self.uid)
        self.group = grp and getgrgid(self.gid)
      self.isdir = os.path.isdir(abspath)
    else:
      for key in STAT_KEYS:
        setattr(self, key, "")

  def rel(self, path):
    """Generate a relative filename for some other file relative to this one.
    """
    if isinstance(path, self.__class__):
      path = path.path
    if path.startswith("/"):
      return path
    elif not self.home:
      return path
    else:
      return "%s/%s" % (self.home, path)

  def throw(self, error):
    raise TemplateException('File', error)


def splitpath(path):
  def helper(path):
    while True:
      path, base = os.path.split(path)
      if base:
        yield base
      else:
        break
  pathcomp = list(helper(path))
  pathcomp.reverse()
  return pathcomp


def getpwuid(uid):
  try:
    return pwd.getpwuid(uid).pw_name
  except KeyError:
    return uid


def getgrgid(gid):
  try:
    return grp.getgrgid(gid).gr_name
  except KeyError:
    return gid
