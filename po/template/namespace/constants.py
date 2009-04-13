#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

from template.config import Config
from template.directive import Directive
from template.util import PerlScalar


"""
template.namespace.constants - Compile time constant folding


SYNOPSIS

    # easy way to define constants
    import template

    tt = template.Template({
	'CONSTANTS': {
	    'pi': 3.14,
	    'e': 2.718,
	},
    })

    # nitty-gritty, hands-dirty way
    import template.namespace.constants

    tt = template.Template({
	'NAMESPACE': {
	    'constants': template.namespace.constants.Constants({
		'pi': 3.14,
	        'e': 2.718,
            },
	},
    })


DESCRIPTION

The template.namespace.constants.Constants class implements a
namespace handler which is plugged into the
template.directive.Directive compiler class.  This then performs
compile time constant folding of variables in a particular namespace.


PUBLIC METHODS

__init__(constants)

The constructor initializes a new Constants object.  This creates an
internal stash to store the constant variable definitions passed as
arguments.

    handler = template.namespace.constants.Constants({
	'pi': 3.14,
	'e': 2.718,
    })

ident(ident)

Method called to resolve a variable identifier into a compiled form.
In this case, the method fetches the corresponding constant value from
its internal stash and returns it.

"""


class Constants:
  """Plugin compiler class for performing constant folding at compile time
  on variables in a particular namespace.
  """
  def __init__(self, config):
    self.__stash = Config.stash(config)

  def ident(self, ident):
    save = ident[:]
    ident[:2] = []
    nelems = len(ident) / 2
    for e in range(nelems):
      # Node name must be a constant.
      if ident[e * 2].startswith("'") and ident[e * 2].endswith("'"):
        ident[e * 2] = ident[e * 2][1:-1]
      else:
        return Directive.Ident(save)
      # If args is nonzero then it must be eval-ed.
      if ident[e * 2 + 1]:
        args = ident[e * 2 + 1]
        try:
          comp = eval(args, {"scalar": PerlScalar})
        except:
          return Directive.Ident(save)
        ident[e * 2 + 1] = comp

    result = self.__stash.get(ident).value()
    if len(str(result)) == 0 or not isinstance(result, (str, int, long)):
      return Directive.Ident(save)
    else:
      return repr(result)
