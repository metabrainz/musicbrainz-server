#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

# STATUS constants returned by directives
STATUS_OK = 0      # ok
STATUS_RETURN = 1      # ok, block ended by RETURN
STATUS_STOP = 2      # ok, stoppped by STOP
STATUS_DONE = 3      # ok, iterator done
STATUS_DECLINED = 4      # ok, declined to service request
STATUS_ERROR = 255      # error condition

# ERROR constants for indicating exception types
ERROR_RETURN = 'return' # return a status code
ERROR_FILE = 'file'   # file error: I/O, parse, recursion
ERROR_VIEW = 'view'   # view error
ERROR_UNDEF = 'undef'  # undefined variable value used
ERROR_PYTHON = 'python'   # error in [% PYTHON %] block
ERROR_FILTER = 'filter' # filter error
ERROR_PLUGIN = 'plugin' # plugin error

# CHOMP constants for PRE_CHOMP and POST_CHOMP
CHOMP_NONE = 0 # do not remove whitespace
CHOMP_ALL = 1 # remove whitespace up to newline
CHOMP_ONE = 1 # new name for CHOMP_ALL
CHOMP_COLLAPSE = 2 # collapse whitespace to a single space
CHOMP_GREEDY = 3 # remove all whitespace including newlines

# DEBUG constants to enable various debugging options
DEBUG_OFF = 0 # do nothing
DEBUG_ON = 1 # basic debugging flag
DEBUG_UNDEF = 2 # throw undef on undefined variables
DEBUG_VARS = 4 # general variable debugging
DEBUG_DIRS = 8 # directive debugging
DEBUG_STASH = 16 # general stash debugging
DEBUG_CONTEXT = 32 # context debugging
DEBUG_PARSER = 64 # parser debugging
DEBUG_PROVIDER = 128 # provider debugging
DEBUG_PLUGINS = 256 # plugins debugging
DEBUG_FILTERS = 512 # filters debugging
DEBUG_SERVICE = 1024 # context debugging
DEBUG_ALL = 2047 # everything

# extra debugging flags
DEBUG_CALLER = 4096 # add caller file/line
DEBUG_FLAGS = 4096 # bitmask to extraxt flags
