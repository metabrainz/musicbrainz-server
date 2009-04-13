#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

from template.util import get_class


"""

template.config.Config - Factory class for instantiating other TT2 modules


SYNOPSIS

    import template.config


DESCRIPTION

This class implements various methods for loading and instantiating
other modules that comprise the Template Toolkit.  It provides a
consistent way to create toolkit components and allows custom modules
to be used in place of the regular ones.

Class variables such as STASH, SERVICE, CONTEXT, etc., contain the
default module/package name for each component (template.stash.Stash,
template.service.Service and template.context.Context, respectively)
and are used by the various factory methods (stash(), service() and
context()) to load the appropriate module.  Changing these class
variables will cause subsequent calls to the relevant factory method
to load and instantiate an object from the new class.


PUBLIC METHODS

context(config)

Instantiate a new template context object (default:
template.context.Context).

filters(config)

Instantiate a new filter provider object (default:
template.filters.Filters).

parser(config)

Instantiate a new parser object (default: template.parser.Parser).

plugins(config)

Instantiate a new plugins provider object (default:
template.plugins.Plugins).

provider(config)

Instantiate a new template provider object (default:
template.provider.Provider).

service(config)

Instantiate a new template service object (default:
template.service.Service).

stash(vars)

Instantiate a new stash object (default: template.stash.Stash) using
the contents of the optional dictionary passed by parameter as initial
variable definitions.

"""


def _loader(field):
  def load(cls, params):
    return get_class(getattr(cls, field))(params)
  return classmethod(load)


class Config:
  CONSTANTS = ("template.namespace.constants", "Constants")
  constants = _loader("CONSTANTS")

  CONTEXT = ("template.context", "Context")
  context = _loader("CONTEXT")

  FILTERS = ("template.filters", "Filters")
  filters = _loader("FILTERS")

  ITERATOR = ("template.iterator", "Iterator")
  iterator = _loader("ITERATOR")

  PARSER = ("template.parser", "Parser")
  parser = _loader("PARSER")

  PLUGINS = ("template.plugins", "Plugins")
  plugins = _loader("PLUGINS")

  PROVIDER = ("template.provider", "Provider")
  provider = _loader("PROVIDER")

  SERVICE = ("template.service", "Service")
  service = _loader("SERVICE")

  STASH = ("template.stash", "Stash")
  stash = _loader("STASH")
