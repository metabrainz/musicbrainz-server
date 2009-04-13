#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

import os
import PIL.Image

from template.plugin import Plugin
from template.util import TemplateException


"""
template.plugin.image - Plugin access to image sizes


SYNOPSIS

    [% USE Image(filename) %]
    [% Image.width %]
    [% Image.height %]
    [% Image.size.join(', ') %]
    [% Image.attr %]
    [% Image.tag %]


DESCRIPTION

This plugin provides an interface to the PIL module for determining
the size of image files.

You can specify the plugin name as either 'Image' or 'image'.  The
plugin object created will then have the same name.  The file name of
the image should be specified as a positional or named argument.

    [% # all these are valid, take your pick %]
    [% USE Image('foo.gif') %]
    [% USE image('bar.gif') %]
    [% USE Image 'ping.gif' %]
    [% USE image(name='baz.gif') %]
    [% USE Image name='pong.gif' %]

A 'root' parameter can be used to specify the location of the image file:

    [% USE Image(root='/path/to/root', name='images/home.png') %]
    # image path: /path/to/root/images/home.png
    # img src: images/home.png

In cases where the image path and image url do not match up, specify the
file name directly:

    [% USE Image(file='/path/to/home.png', name='/images/home.png') %]

The 'alt' parameter can be used to specify an alternate name for the
image, for use in constructing an XHTML element (see the tag() method
below).

    [% USE Image('home.png', alt='Home') %]

You can also provide an alternate name for an Image plugin object.

    [% USE img1 = image 'foo.gif' %]
    [% USE img2 = image 'bar.gif' %]

The 'name' method returns the image file name.

    [% img1.name %]     # foo.gif

The 'width' and 'height' methods return the width and height of the
image, respectively.  The 'size' method returns a reference to a
2-tuple containing the width and height.

    [% USE image 'foo.gif' %]
    width: [% image.width %]
    height: [% image.height %]
    size: [% image.size.join(', ') %]

The 'modtime' method returns the ctime of the file in question, suitable
for use with date.format:

    [% USE image 'foo.gif' %]
    [% USE date %]
    [% date.format(image.modtime, '%B, %e %Y') %]

The 'attr' method returns the height and width as HTML/XML attributes.

    [% USE image 'foo.gif' %]
    [% image.attr %]

Typical output:

    width='60' height='20'

The 'tag' method returns a complete XHTML tag referencing the image.

    [% USE image 'foo.gif' %]
    [% image.tag %]

Typical output:

    <img src="foo.gif" width="60" height="20" alt="" />

You can provide any additional attributes that should be added to the
XHTML tag.

    [% USE image 'foo.gif' %]
    [% image.tag(class='logo' alt='Logo') %]

Typical output:

    <img src='foo.gif' width='60' height='20' alt='Logo' class='logo' />

Note that the 'alt' attribute is mandatory in a strict XHTML 'img'
element (even if it's empty) so it is always added even if you don't
explicitly provide a value for it.  You can do so as an argument to
the 'tag' method, as shown in the previous example, or as an argument

    [% USE image('foo.gif', alt='Logo') %]


CATCHING ERRORS

If the image file cannot be found then the above methods will throw an
'Image' error.  You can enclose calls to these methods in a
TRY...CATCH block to catch any potential errors.

    [% TRY;
         image.width;
       CATCH;
         error;      # print error
       END
    %]

"""


def Init(func):
  """Decorator that ensures self.init() is called first."""
  def decorated(self):
    self.init()
    return func(self)
  return decorated


class Image(Plugin):
  """Plugin for encapsulating information about an image."""
  def __init__(self, context, name=None, config=None):
    if isinstance(name, dict):
      name, config = None, name
    Plugin.__init__(self)
    if not isinstance(config, dict):
      config = {}
    if name is None:
      name = config.get("name")
    if not name:
      return self.throw("no image file specfied")
    root = config.get("root")
    if root:
      file = os.path.join(root, name)
    else:
      file = config.get("file") or name
    self.__name = name
    self.__file = file
    self.__root = root
    self.__size = None
    self.__width = None
    self.__height = None
    self.__alt = config.get("alt", "")

  def init(self):
    if self.__size is None:
      try:
        self.__size = PIL.Image.open(self.__file).size
      except Exception, e:
        self.throw(e)
      self.__width, self.__height = self.__size
      self.__modtime = os.stat(self.__file).st_mtime
    return self

  @Init
  def name(self):
    return self.__name

  @Init
  def file(self):
    return self.__file

  @Init
  def size(self):
    return self.__size

  @Init
  def width(self):
    return self.__width

  @Init
  def height(self):
    return self.__height

  @Init
  def root(self):
    return self.__root

  @Init
  def modtime(self):
    """Return last modification time as a time_t."""
    return self.__modtime

  def attr(self):
    """Return the width and height as HTML/XML attributes."""
    return 'width="%d" height="%d"' % self.size()

  def tag(self, options=None):
    """Returns an XHTML img tag."""
    options = options or {}
    options.setdefault("alt", self.__alt)
    return '<img src="%s" %s%s />' % (
      self.name(), self.attr(),
      "".join(' %s="%s"' % (key, escape(value))
              for key, value in options.items()))

  def throw(self, error):
    raise TemplateException("Image", error)


def escape(text):
  return str(text) \
         .replace("&", "&amp;") \
         .replace("<", "&lt;") \
         .replace(">", "&gt;") \
         .replace('"', "&quot;")

