#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

import os

from template.plugin.file import File
from template.util import TemplateException


"""
template.plugin.directory - Plugin for generating directory listings


SYNOPSIS

    [% USE dir = Directory(dirpath) %]

    # files returns list of regular files
    [% FOREACH file = dir.files %]
       [% file.name %] [% file.path %] ...
    [% END %]

    # dirs returns list of sub-directories
    [% FOREACH subdir = dir.dirs %]
       [% subdir.name %] [% subdir.path %] ...
    [% END %]

    # list returns both interleaved in order
    [% FOREACH item = dir.list %]
       [% IF item.isdir %]
	  Directory: [% item.name %]
       [% ELSE %]
          File: [% item.name %]
       [% END %]
    [% END %]


DESCRIPTION

This Template Toolkit plugin provides a simple interface to directory
listings.  It is derived from the template.plugin.file module and uses
File object instances to represent files within a directory.
Sub-directories within a directory are represented by further
Directory instances.

The constructor expects a directory name as an argument.

    [% USE dir = Directory('/tmp') %]

It then provides access to the files and sub-directories contained
within the directory.

    # regular files (not directories)
    [% FOREACH file = dir.files %]
       [% file.name %]
    [% END %]

    # directories only
    [% FOREACH file = dir.dirs %]
       [% file.name %]
    [% END %]

    # files and/or directories
    [% FOREACH file = dir.list %]
       [% file.name %] ([% file.isdir ? 'directory' : 'file' %])
    [% END %]

    [% USE Directory('foo/baz') %]

The plugin constructor will throw a 'Directory' error if the specified
path does not exist, is not a directory or fails to stat() (see
template.plugin.file).  Otherwise, it will scan the directory and
create lists named 'files' containing files, 'dirs' containing
directories and 'list' containing both files and directories combined.
The 'nostat' option can be set to disable all file/directory checks
and directory scanning.

Each file in the directory will be represented by a File object
instance, and each directory by another Directory.  If the 'recurse'
flag is set, then those directories will contain further nested
entries, and so on.  With the 'recurse' flag unset, as it is by
default, then each is just a place marker for the directory and does
not contain any further content unless its scan() method is explicitly
called.  The 'isdir' flag can be tested against files and/or
directories, returning true if the item is a directory or false if it
is a regular file.

    [% FOREACH file = dir.list %]
       [% IF file.isdir %]
          * Directory: [% file.name %]
       [% ELSE %]
          * File: [% file.name %]
       [% END %]
    [% END %]

This example shows how you might walk down a directory tree,
displaying content as you go.  With the recurse flag disabled, as is
the default, we need to explicitly call the scan() method on each
directory, to force it to lookup files and further sub-directories
contained within.

    [% USE dir = Directory(dirpath) %]
    * [% dir.path %]
    [% INCLUDE showdir %]

    [% BLOCK showdir -%]
      [% FOREACH file = dir.list -%]
        [% IF file.isdir -%]
        * [% file.name %]
          [% file.scan -%]
	  [% INCLUDE showdir dir=file FILTER indent(4) -%]
        [% ELSE -%]
        - [% f.name %]
        [% END -%]
      [% END -%]
     [% END %]

This example is adapted (with some re-formatting for clarity) from a
test in t/directory_test.py which produces the following output:

    * test/dir
    	- file1
    	- file2
    	* sub_one
    	    - bar
    	    - foo
    	* sub_two
    	    - waz.html
    	    - wiz.html
    	- xyzfile

The 'recurse' flag can be set (disabled by default) to cause the
constructor to automatically recurse down into all sub-directories,
creating a new Directory object for each one and filling it with any
further content.  In this case there is no need to explicitly call the
scan() method.

    [% USE dir = Directory(dirpath, recurse=1) %]
       ...

        [% IF file.isdir -%]
        * [% file.name %]
	  [% INCLUDE showdir dir=file FILTER indent(4) -%]
        [% ELSE -%]
           ...

With the recurse option disabled, as it is by default, the 'directory'
block should explicitly call a scan() on each directory.

    [% VIEW myview %]
    [% BLOCK file %]
       - [% item.name %]
    [% END %]

    [% BLOCK directory %]
       * [% item.name %]
	 [% item.scan %]
         [% item.content(myview) FILTER indent %]
    [% END %]
    [% END %]

    [% USE dir = Directory(dirpath) %]
    [% myview.print(dir) %]


TODO

Might be nice to be able to specify accept/ignore options to catch
a subset of files.

"""


class Directory(File):
  """Plugin for encapsulating information about a file system directory."""
  def __init__(self, context, path=None, config=None):
    if not isinstance(config, dict):
      config = {}
    if not path:
      self.throw("no directory specified")
    File.__init__(self, context, path, config)
    self.files = []
    self.dirs  = []
    self.list  = []
    self._dir  = {}
    # don't read directory if 'nostat' or 'noscan' set
    if config.get("nostat") or config.get("noscan"):
      return
    if not self.isdir:
      self.throw("%s: not a directory" % path)
    self.scan(config)

  def scan(self, config=None):
    """Scan directory for files and sub-directories."""
    if not config:
      config = {}
    # set 'noscan' in config if recurse isn't set, to ensure Directories
    # created don't try to scan deeper
    if not config.get("recurse"):
      config["noscan"] = True
    try:
      files = os.listdir(self.abs)
    except OSError, e:
      self.throw("%s: %s" % (self.abs, e))
    self.files = []
    self.dirs  = []
    self.list  = []
    for name in sorted(files):
      if name.startswith("."):
        continue
      abs = os.path.join(self.abs, name)
      rel = os.path.join(self.path, name)
      if os.path.isdir(abs):
        item = Directory(None, rel, config)
        self.dirs.append(item)
      else:
        item = File(None, rel, config)
        self.files.append(item)
      self.list.append(item)
      self._dir[name] = item
    return ""

  def file(self, name):
    """Fetch a named file from this directory."""
    return self._dir.get(name)

  def throw(self, error):
    """Throw a 'Directory' exception."""
    raise TemplateException("Directory", error)
