#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

import re
import sys

from template.util import registrar, unscalar_lex


factory = None
rawstart = None

class Grammar:
  def __init__(self):
    self.lextable = LEXTABLE
    self.states = STATES
    self.rules = RULES

  def install_factory(self, new_factory):
    global factory
    factory = new_factory


RESERVED = (
  "GET", "CALL", "SET", "DEFAULT", "INSERT", "INCLUDE", "PROCESS",
  "WRAPPER", "BLOCK", "END", "USE", "PLUGIN", "FILTER", "MACRO",
  "PYTHON", "RAWPYTHON", "TO", "STEP", "AND", "OR", "NOT", "DIV",
  "MOD", "IF", "UNLESS", "ELSE", "ELSIF", "FOR", "NEXT", "WHILE",
  "SWITCH", "CASE", "META", "IN", "TRY", "THROW", "CATCH", "FINAL",
  "LAST", "RETURN", "STOP", "CLEAR", "VIEW", "DEBUG"
)

CMPOP = dict((op, op) for op in (
    "!=", "==", "<", ">", ">=", "<=",
    # Add these items to enable the eq, lt, and gt operators:
    # "eq", "lt", "gt"
    ))

LEXTABLE = {
  "FOREACH": "FOR",
  "BREAK":   "LAST",
  "&&":      "AND",
  "||":      "OR",
  "!":       "NOT",
  "|":       "FILTER",
  ".":       "DOT",
  "_":       "CAT",
  "..":      "TO",
  "=":       "ASSIGN",
  "=>":      "ASSIGN",
  ",":       "COMMA",
  "\\":      "REF",
  "and":     "AND",
  "or":      "OR",
  "not":     "NOT",
  "mod":     "MOD",
  "div":     "DIV",
}

tokens = ("(", ")", "[", "]", "{", "}", "${", "$", "+", "/", ";", ":", "?")

for keyword in RESERVED:
  LEXTABLE[keyword] = keyword

for op in CMPOP.iterkeys():
  LEXTABLE[op] = "CMPOP"

for op in "-", "*", "%":
  LEXTABLE[op] = "BINOP"

for token in tokens:
  LEXTABLE[token] = token


STATES = [
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'RAWPYTHON': 13,
      'META': 15,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'MACRO': 18,
      'WRAPPER': 55,
      ";": -18,
      'FOR': 21,
      'LITERAL': 57,
      'NEXT': 22,
      '"': 60,
      'TEXT': 24,
      'PROCESS': 61,
      'RETURN': 64,
      'FILTER': 25,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 28,
      'DEFAULT': 69,
      "{": 30,
      'USE': 32,
      'VIEW': 36,
      '${': 37
    },
    'DEFAULT': -3,
    'GOTOS': {
      'item': 39,
      'loop': 4,
      'capture': 42,
      'statement': 5,
      'view': 7,
      'wrapper': 46,
      'atomexpr': 48,
      'chunk': 11,
      'atomdir': 12,
      'anonblock': 50,
      'template': 52,
      'defblockname': 14,
      'ident': 16,
      'assign': 19,
      'macro': 20,
      'lterm': 56,
      'node': 23,
      'term': 58,
      'rawpython': 59,
      'expr': 62,
      'use': 63,
      'defblock': 66,
      'filter': 29,
      'sterm': 68,
      'python': 31,
      'chunks': 33,
      'setlist': 70,
      'try': 35,
      'switch': 34,
      'directive': 71,
      'block': 72,
      'condition': 73
    }
  },
  {
    'ACTIONS': {
      '$': 43,
      'LITERAL': 75,
      'IDENT': 2,
      '${': 37
    },
    'GOTOS': {
      'setlist': 76,
      'item': 39,
      'assign': 19,
      'node': 23,
      'ident': 74
    }
  },
  {
    'DEFAULT': -130
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 79,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'DEFAULT': -23
  },
  {
    'ACTIONS': {
      ";": 80
    }
  },
  {
    'DEFAULT': -37
  },
  {
    'DEFAULT': -14
  },
  {
    'ACTIONS': {
      '"': 89,
      '$': 86,
      'LITERAL': 88,
      'FILENAME': 83,
      'IDENT': 81,
      'NUMBER': 84
    },
    'GOTOS': {
      'filepart': 87,
      'names': 91,
      'nameargs': 90,
      'filename': 85,
      'name': 82
    }
  },
  {
    'ACTIONS': {
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      "]": 94,
      '${': 37
    },
    'GOTOS': {
      'sterm': 96,
      'item': 39,
      'range': 93,
      'node': 23,
      'ident': 77,
      'term': 95,
      'lterm': 56,
      'list': 92
    }
  },
  {
    'ACTIONS': {
      ";": 97
    }
  },
  {
    'DEFAULT': -5
  },
  {
    'ACTIONS': {
      ";": -20
    },
    'DEFAULT': -27
  },
  {
    'DEFAULT': -78,
    'GOTOS': {
      '@5-1': 98
    }
  },
  {
    'ACTIONS': {
      'IDENT': 99
    },
    'DEFAULT': -87,
    'GOTOS': {
      'blockargs': 102,
      'metadata': 101,
      'meta': 100
    }
  },
  {
    'ACTIONS': {
      'IDENT': 99
    },
    'GOTOS': {
      'metadata': 103,
      'meta': 100
    }
  },
  {
    'ACTIONS': {
      'DOT': 104,
      'ASSIGN': 105
    },
    'DEFAULT': -109
  },
  {
    'ACTIONS': {
      '"': 89,
      '$': 86,
      'LITERAL': 88,
      'FILENAME': 83,
      'IDENT': 81,
      'NUMBER': 84
    },
    'GOTOS': {
      'filepart': 87,
      'names': 91,
      'nameargs': 106,
      'filename': 85,
      'name': 82
    }
  },
  {
    'ACTIONS': {
      'IDENT': 107
    }
  },
  {
    'DEFAULT': -149
  },
  {
    'DEFAULT': -12
  },
  {
    'ACTIONS': {
      "{": 30,
      'LITERAL': 78,
      'IDENT': 108,
      '"': 60,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'sterm': 68,
      'item': 39,
      'loopvar': 110,
      'node': 23,
      'ident': 77,
      'term': 109,
      'lterm': 56
    }
  },
  {
    'DEFAULT': -40
  },
  {
    'DEFAULT': -127
  },
  {
    'DEFAULT': -6
  },
  {
    'ACTIONS': {
      '"': 117,
      '$': 114,
      'LITERAL': 116,
      'FILENAME': 83,
      'IDENT': 111,
      'NUMBER': 84,
      '${': 37
    },
    'GOTOS': {
      'names': 91,
      'lvalue': 112,
      'item': 113,
      'name': 82,
      'filepart': 87,
      'filename': 85,
      'nameargs': 118,
      'lnameargs': 115
    }
  },
  {
    'DEFAULT': -113
  },
  {
    'ACTIONS': {
      '$': 43,
      'IDENT': 2,
      '${': 37
    },
    'GOTOS': {
      'item': 39,
      'node': 23,
      'ident': 119
    }
  },
  {
    'ACTIONS': {
      'LITERAL': 124,
      'FILENAME': 83,
      'IDENT': 120,
      'NUMBER': 84
    },
    'DEFAULT': -87,
    'GOTOS': {
      'blockargs': 123,
      'filepart': 87,
      'filename': 122,
      'blockname': 121,
      'metadata': 101,
      'meta': 100
    }
  },
  {
    'DEFAULT': -43
  },
  {
    'ACTIONS': {
      '$': 43,
      'LITERAL': 129,
      'IDENT': 2,
      '${': 37
    },
    'DEFAULT': -119,
    'GOTOS': {
      'params': 128,
      'hash': 125,
      'item': 126,
      'param': 127
    }
  },
  {
    'DEFAULT': -25
  },
  {
    'ACTIONS': {
      '"': 117,
      '$': 114,
      'LITERAL': 116,
      'FILENAME': 83,
      'IDENT': 111,
      'NUMBER': 84,
      '${': 37
    },
    'GOTOS': {
      'names': 91,
      'lvalue': 112,
      'item': 113,
      'name': 82,
      'filepart': 87,
      'filename': 85,
      'nameargs': 118,
      'lnameargs': 130
    }
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'RAWPYTHON': 13,
      'META': 15,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'MACRO': 18,
      'WRAPPER': 55,
      ";": -18,
      'FOR': 21,
      'LITERAL': 57,
      'NEXT': 22,
      '"': 60,
      'TEXT': 24,
      'PROCESS': 61,
      'RETURN': 64,
      'FILTER': 25,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 28,
      'DEFAULT': 69,
      "{": 30,
      'USE': 32,
      'VIEW': 36,
      '${': 37
    },
    'DEFAULT': -2,
    'GOTOS': {
      'item': 39,
      'node': 23,
      'rawpython': 59,
      'term': 58,
      'loop': 4,
      'use': 63,
      'expr': 62,
      'capture': 42,
      'statement': 5,
      'view': 7,
      'wrapper': 46,
      'atomexpr': 48,
      'chunk': 131,
      'defblock': 66,
      'atomdir': 12,
      'anonblock': 50,
      'sterm': 68,
      'defblockname': 14,
      'filter': 29,
      'ident': 16,
      'python': 31,
      'setlist': 70,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'directive': 71,
      'macro': 20,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'DEFAULT': -22
  },
  {
    'DEFAULT': -24
  },
  {
    'ACTIONS': {
      '"': 89,
      '$': 86,
      'LITERAL': 88,
      'FILENAME': 83,
      'IDENT': 81,
      'NUMBER': 84
    },
    'GOTOS': {
      'filepart': 87,
      'names': 91,
      'nameargs': 132,
      'filename': 85,
      'name': 82
    }
  },
  {
    'ACTIONS': {
      '"': 60,
      '$': 43,
      'LITERAL': 78,
      'IDENT': 2,
      'REF': 27,
      'NUMBER': 26,
      '${': 37
    },
    'GOTOS': {
      'sterm': 133,
      'item': 39,
      'node': 23,
      'ident': 77
    }
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 134,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      "(": 135
    },
    'DEFAULT': -128
  },
  {
    'ACTIONS': {
      ";": 136
    }
  },
  {
    'DEFAULT': -38
  },
  {
    'DEFAULT': -11
  },
  {
    'ACTIONS': {
      'IDENT': 137
    }
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 138,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 139,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'DEFAULT': -42
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 140,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'IF': 144,
      'FILTER': 143,
      'FOR': 142,
      'WHILE': 146,
      'WRAPPER': 145,
      'UNLESS': 141
    }
  },
  {
    'DEFAULT': -39
  },
  {
    'DEFAULT': -10
  },
  {
    'ACTIONS': {
      '"': 89,
      '$': 86,
      'LITERAL': 88,
      'FILENAME': 83,
      'IDENT': 81,
      'NUMBER': 84
    },
    'GOTOS': {
      'filepart': 87,
      'names': 91,
      'nameargs': 147,
      'filename': 85,
      'name': 82
    }
  },
  {
    'ACTIONS': {
      '': 148
    }
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 57,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 151,
      'sterm': 68,
      'item': 39,
      'assign': 150,
      'node': 23,
      'ident': 149,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 152,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      '"': 89,
      '$': 86,
      'LITERAL': 88,
      'FILENAME': 83,
      'IDENT': 81,
      'NUMBER': 84
    },
    'GOTOS': {
      'filepart': 87,
      'names': 91,
      'nameargs': 153,
      'filename': 85,
      'name': 82
    }
  },
  {
    'DEFAULT': -103
  },
  {
    'ACTIONS': {
      'ASSIGN': 154
    },
    'DEFAULT': -112
  },
  {
    'DEFAULT': -146
  },
  {
    'DEFAULT': -15
  },
  {
    'DEFAULT': -176,
    'GOTOS': {
      'quoted': 155
    }
  },
  {
    'ACTIONS': {
      '"': 89,
      '$': 86,
      'LITERAL': 88,
      'FILENAME': 83,
      'IDENT': 81,
      'NUMBER': 84
    },
    'GOTOS': {
      'filepart': 87,
      'names': 91,
      'nameargs': 156,
      'filename': 85,
      'name': 82
    }
  },
  {
    'ACTIONS': {
      ";": -16,
      "+": 157,
      'CAT': 163,
      'CMPOP': 164,
      "?": 158,
      'DIV': 159,
      'MOD': 165,
      "/": 166,
      'AND': 160,
      'BINOP': 161,
      'OR': 162
    },
    'DEFAULT': -26
  },
  {
    'DEFAULT': -13
  },
  {
    'DEFAULT': -36
  },
  {
    'ACTIONS': {
      '"': 89,
      '$': 86,
      'LITERAL': 88,
      'FILENAME': 83,
      'IDENT': 81,
      'NUMBER': 84
    },
    'GOTOS': {
      'filepart': 87,
      'names': 91,
      'nameargs': 167,
      'filename': 85,
      'name': 82
    }
  },
  {
    'DEFAULT': -9
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 168,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'DEFAULT': -104
  },
  {
    'ACTIONS': {
      '$': 43,
      'LITERAL': 75,
      'IDENT': 2,
      '${': 37
    },
    'GOTOS': {
      'setlist': 169,
      'item': 39,
      'assign': 19,
      'node': 23,
      'ident': 74
    }
  },
  {
    'ACTIONS': {
      '$': 43,
      'COMMA': 171,
      'LITERAL': 75,
      'IDENT': 2,
      '${': 37
    },
    'DEFAULT': -19,
    'GOTOS': {
      'item': 39,
      'assign': 170,
      'node': 23,
      'ident': 74
    }
  },
  {
    'DEFAULT': -8
  },
  {
    'DEFAULT': -1
  },
  {
    'DEFAULT': -21
  },
  {
    'ACTIONS': {
      'ASSIGN': 172,
      'DOT': 104
    }
  },
  {
    'ACTIONS': {
      'ASSIGN': 154
    }
  },
  {
    'ACTIONS': {
      'COMMA': 171,
      'LITERAL': 75,
      'IDENT': 2,
      '$': 43,
      '${': 37
    },
    'DEFAULT': -30,
    'GOTOS': {
      'item': 39,
      'assign': 170,
      'node': 23,
      'ident': 74
    }
  },
  {
    'ACTIONS': {
      'DOT': 104
    },
    'DEFAULT': -109
  },
  {
    'DEFAULT': -112
  },
  {
    'ACTIONS': {
      'CMPOP': 164,
      "?": 158,
      ";": 173,
      "+": 157,
      'MOD': 165,
      'DIV': 159,
      "/": 166,
      'AND': 160,
      'CAT': 163,
      'BINOP': 161,
      'OR': 162
    }
  },
  {
    'DEFAULT': -7
  },
  {
    'DEFAULT': -173
  },
  {
    'DEFAULT': -166
  },
  {
    'DEFAULT': -172
  },
  {
    'DEFAULT': -174
  },
  {
    'ACTIONS': {
      'DOT': 174
    },
    'DEFAULT': -168
  },
  {
    'ACTIONS': {
      '$': 43,
      'IDENT': 2,
      '${': 37
    },
    'GOTOS': {
      'item': 39,
      'node': 23,
      'ident': 175
    }
  },
  {
    'DEFAULT': -171
  },
  {
    'DEFAULT': -169
  },
  {
    'DEFAULT': -176,
    'GOTOS': {
      'quoted': 176
    }
  },
  {
    'DEFAULT': -35
  },
  {
    'ACTIONS': {
      "+": 177,
      "(": 178
    },
    'DEFAULT': -156,
    'GOTOS': {
      'args': 179
    }
  },
  {
    'ACTIONS': {
      "{": 30,
      'COMMA': 182,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      "]": 180,
      '${': 37
    },
    'GOTOS': {
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 181,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      "]": 183
    }
  },
  {
    'DEFAULT': -107
  },
  {
    'DEFAULT': -116
  },
  {
    'ACTIONS': {
      'TO': 184
    },
    'DEFAULT': -104
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'RAWPYTHON': 13,
      'META': 15,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'MACRO': 18,
      'WRAPPER': 55,
      ";": -18,
      'FOR': 21,
      'LITERAL': 57,
      'NEXT': 22,
      '"': 60,
      'TEXT': 24,
      'PROCESS': 61,
      'RETURN': 64,
      'FILTER': 25,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 28,
      'DEFAULT': 69,
      "{": 30,
      'USE': 32,
      'VIEW': 36,
      '${': 37
    },
    'DEFAULT': -3,
    'GOTOS': {
      'item': 39,
      'node': 23,
      'rawpython': 59,
      'term': 58,
      'loop': 4,
      'use': 63,
      'expr': 62,
      'capture': 42,
      'statement': 5,
      'view': 7,
      'wrapper': 46,
      'atomexpr': 48,
      'chunk': 11,
      'defblock': 66,
      'atomdir': 12,
      'anonblock': 50,
      'sterm': 68,
      'defblockname': 14,
      'filter': 29,
      'ident': 16,
      'python': 31,
      'setlist': 70,
      'chunks': 33,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'block': 185,
      'directive': 71,
      'macro': 20,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      ";": 186
    }
  },
  {
    'ACTIONS': {
      'ASSIGN': 187
    }
  },
  {
    'DEFAULT': -99
  },
  {
    'ACTIONS': {
      'COMMA': 189,
      'IDENT': 99
    },
    'DEFAULT': -86,
    'GOTOS': {
      'meta': 188
    }
  },
  {
    'ACTIONS': {
      ";": 190
    }
  },
  {
    'ACTIONS': {
      'COMMA': 189,
      'IDENT': 99
    },
    'DEFAULT': -17,
    'GOTOS': {
      'meta': 188
    }
  },
  {
    'ACTIONS': {
      '$': 43,
      'IDENT': 2,
      'NUMBER': 192,
      '${': 37
    },
    'GOTOS': {
      'item': 39,
      'node': 191
    }
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'WRAPPER': 55,
      'FOR': 21,
      'NEXT': 22,
      'LITERAL': 57,
      '"': 60,
      'PROCESS': 61,
      'FILTER': 25,
      'RETURN': 64,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 193,
      'DEFAULT': 69,
      "{": 30,
      '${': 37
    },
    'GOTOS': {
      'item': 39,
      'node': 23,
      'term': 58,
      'loop': 4,
      'expr': 195,
      'wrapper': 46,
      'atomexpr': 48,
      'atomdir': 12,
      'mdir': 194,
      'filter': 29,
      'sterm': 68,
      'ident': 149,
      'python': 31,
      'setlist': 70,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'directive': 196,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'DEFAULT': -33
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'INCLUDE': 17,
      "(": 198,
      'SWITCH': 54,
      'WRAPPER': 55,
      'FOR': 21,
      'NEXT': 22,
      'LITERAL': 57,
      '"': 60,
      'PROCESS': 61,
      'FILTER': 25,
      'RETURN': 64,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 193,
      'DEFAULT': 69,
      "{": 30,
      '${': 37
    },
    'GOTOS': {
      'item': 39,
      'node': 23,
      'term': 58,
      'loop': 4,
      'expr': 199,
      'wrapper': 46,
      'atomexpr': 48,
      'atomdir': 12,
      'mdir': 197,
      'filter': 29,
      'sterm': 68,
      'ident': 149,
      'python': 31,
      'setlist': 70,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'directive': 196,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'IN': 201,
      'ASSIGN': 200
    },
    'DEFAULT': -130
  },
  {
    'DEFAULT': -156,
    'GOTOS': {
      'args': 202
    }
  },
  {
    'ACTIONS': {
      ";": 203
    }
  },
  {
    'ACTIONS': {
      'ASSIGN': -130
    },
    'DEFAULT': -173
  },
  {
    'ACTIONS': {
      'ASSIGN': 204
    }
  },
  {
    'DEFAULT': -159
  },
  {
    'ACTIONS': {
      '$': 43,
      'IDENT': 205,
      '${': 37
    },
    'GOTOS': {
      'item': 39,
      'node': 23,
      'ident': 175
    }
  },
  {
    'ACTIONS': {
      ";": 206
    }
  },
  {
    'ACTIONS': {
      'ASSIGN': -161
    },
    'DEFAULT': -169
  },
  {
    'DEFAULT': -176,
    'GOTOS': {
      'quoted': 207
    }
  },
  {
    'DEFAULT': -158
  },
  {
    'ACTIONS': {
      'DOT': 104
    },
    'DEFAULT': -110
  },
  {
    'ACTIONS': {
      'ASSIGN': 187
    },
    'DEFAULT': -173
  },
  {
    'DEFAULT': -83
  },
  {
    'ACTIONS': {
      'DOT': 174
    },
    'DEFAULT': -84
  },
  {
    'ACTIONS': {
      ";": 208
    }
  },
  {
    'DEFAULT': -85
  },
  {
    'ACTIONS': {
      "}": 209
    }
  },
  {
    'ACTIONS': {
      'ASSIGN': 210
    }
  },
  {
    'DEFAULT': -122
  },
  {
    'ACTIONS': {
      '$': 43,
      'COMMA': 212,
      'LITERAL': 129,
      'IDENT': 2,
      '${': 37
    },
    'DEFAULT': -118,
    'GOTOS': {
      'item': 126,
      'param': 211
    }
  },
  {
    'ACTIONS': {
      'ASSIGN': 213
    }
  },
  {
    'DEFAULT': -73
  },
  {
    'DEFAULT': -4
  },
  {
    'ACTIONS': {
      ";": 214
    }
  },
  {
    'ACTIONS': {
      "}": 215
    }
  },
  {
    'ACTIONS': {
      'DIV': 159,
      'BINOP': 161,
      "+": 157,
      'CAT': 163,
      'CMPOP': 164,
      'MOD': 165,
      "/": 166
    },
    'DEFAULT': -142
  },
  {
    'DEFAULT': -156,
    'GOTOS': {
      'args': 216
    }
  },
  {
    'DEFAULT': -76,
    'GOTOS': {
      '@4-2': 217
    }
  },
  {
    'DEFAULT': -132
  },
  {
    'ACTIONS': {
      'CMPOP': 164,
      "?": 158,
      ";": 218,
      "+": 157,
      'MOD': 165,
      'DIV': 159,
      "/": 166,
      'AND': 160,
      'CAT': 163,
      'BINOP': 161,
      'OR': 162
    }
  },
  {
    'ACTIONS': {
      "+": 157,
      'CAT': 163,
      'CMPOP': 164,
      "?": 158,
      'DIV': 159,
      'MOD': 165,
      "/": 166,
      'AND': 160,
      'BINOP': 161,
      'OR': 162
    },
    'DEFAULT': -29
  },
  {
    'ACTIONS': {
      "+": 157,
      'CAT': 163,
      'CMPOP': 164,
      "?": 158,
      'DIV': 159,
      'MOD': 165,
      "/": 166,
      'AND': 160,
      'BINOP': 161,
      'OR': 162
    },
    'DEFAULT': -28
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 219,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      "{": 30,
      'LITERAL': 78,
      'IDENT': 108,
      '"': 60,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'sterm': 68,
      'item': 39,
      'loopvar': 220,
      'node': 23,
      'ident': 77,
      'term': 109,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      '"': 117,
      '$': 114,
      'LITERAL': 116,
      'FILENAME': 83,
      'IDENT': 111,
      'NUMBER': 84,
      '${': 37
    },
    'GOTOS': {
      'names': 91,
      'lvalue': 112,
      'item': 113,
      'name': 82,
      'filepart': 87,
      'filename': 85,
      'nameargs': 118,
      'lnameargs': 221
    }
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 222,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      '"': 89,
      '$': 86,
      'LITERAL': 88,
      'FILENAME': 83,
      'IDENT': 81,
      'NUMBER': 84
    },
    'GOTOS': {
      'filepart': 87,
      'names': 91,
      'nameargs': 223,
      'filename': 85,
      'name': 82
    }
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 224,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'DEFAULT': -41
  },
  {
    'DEFAULT': 0
  },
  {
    'ACTIONS': {
      'DOT': 104,
      'ASSIGN': 172
    },
    'DEFAULT': -109
  },
  {
    'ACTIONS': {
      ")": 225
    }
  },
  {
    'ACTIONS': {
      'CMPOP': 164,
      "?": 158,
      "+": 157,
      'MOD': 165,
      'DIV': 159,
      "/": 166,
      'AND': 160,
      'CAT': 163,
      'BINOP': 161,
      ")": 226,
      'OR': 162
    }
  },
  {
    'ACTIONS': {
      'CMPOP': 164,
      "?": 158,
      ";": 227,
      "+": 157,
      'MOD': 165,
      'DIV': 159,
      "/": 166,
      'AND': 160,
      'CAT': 163,
      'BINOP': 161,
      'OR': 162
    }
  },
  {
    'ACTIONS': {
      ";": 228
    }
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 229,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      '"': 234,
      'TEXT': 231,
      ";": 233,
      '$': 43,
      'IDENT': 2,
      '${': 37
    },
    'GOTOS': {
      'item': 39,
      'node': 23,
      'ident': 230,
      'quotable': 232
    }
  },
  {
    'DEFAULT': -34
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 235,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 236,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 237,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 238,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 239,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 240,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 241,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 242,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 243,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 244,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'DEFAULT': -32
  },
  {
    'ACTIONS': {
      'CMPOP': 164,
      "?": 158,
      ";": 245,
      "+": 157,
      'MOD': 165,
      'DIV': 159,
      "/": 166,
      'AND': 160,
      'CAT': 163,
      'BINOP': 161,
      'OR': 162
    }
  },
  {
    'ACTIONS': {
      'COMMA': 171,
      'LITERAL': 75,
      'IDENT': 2,
      '$': 43,
      '${': 37
    },
    'DEFAULT': -31,
    'GOTOS': {
      'item': 39,
      'assign': 170,
      'node': 23,
      'ident': 74
    }
  },
  {
    'DEFAULT': -147
  },
  {
    'DEFAULT': -148
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 246,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'RAWPYTHON': 13,
      'META': 15,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'MACRO': 18,
      'WRAPPER': 55,
      ";": -18,
      'FOR': 21,
      'LITERAL': 57,
      'NEXT': 22,
      '"': 60,
      'TEXT': 24,
      'PROCESS': 61,
      'RETURN': 64,
      'FILTER': 25,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 28,
      'DEFAULT': 69,
      "{": 30,
      'USE': 32,
      'VIEW': 36,
      '${': 37
    },
    'DEFAULT': -3,
    'GOTOS': {
      'item': 39,
      'node': 23,
      'rawpython': 59,
      'term': 58,
      'loop': 4,
      'use': 63,
      'expr': 62,
      'capture': 42,
      'statement': 5,
      'view': 7,
      'wrapper': 46,
      'atomexpr': 48,
      'chunk': 11,
      'defblock': 66,
      'atomdir': 12,
      'anonblock': 50,
      'sterm': 68,
      'defblockname': 14,
      'filter': 29,
      'ident': 16,
      'python': 31,
      'setlist': 70,
      'chunks': 33,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'block': 247,
      'directive': 71,
      'macro': 20,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'FILENAME': 83,
      'IDENT': 81,
      'NUMBER': 84
    },
    'GOTOS': {
      'filepart': 248
    }
  },
  {
    'ACTIONS': {
      'DOT': 104
    },
    'DEFAULT': -156,
    'GOTOS': {
      'args': 249
    }
  },
  {
    'ACTIONS': {
      '"': 250,
      'TEXT': 231,
      ";": 233,
      '$': 43,
      'IDENT': 2,
      '${': 37
    },
    'GOTOS': {
      'item': 39,
      'node': 23,
      'ident': 230,
      'quotable': 232
    }
  },
  {
    'ACTIONS': {
      '"': 89,
      'LITERAL': 88,
      'FILENAME': 83,
      'IDENT': 81,
      'NUMBER': 84
    },
    'GOTOS': {
      'filepart': 87,
      'filename': 85,
      'name': 251
    }
  },
  {
    'DEFAULT': -156,
    'GOTOS': {
      'args': 252
    }
  },
  {
    'ACTIONS': {
      'NOT': 38,
      'LITERAL': 256,
      'IDENT': 2,
      '"': 60,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      "{": 30,
      'COMMA': 258,
      "(": 53,
      '${': 37
    },
    'DEFAULT': -163,
    'GOTOS': {
      'expr': 257,
      'sterm': 68,
      'item': 254,
      'param': 255,
      'node': 23,
      'ident': 253,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'DEFAULT': -105
  },
  {
    'DEFAULT': -114
  },
  {
    'DEFAULT': -115
  },
  {
    'DEFAULT': -106
  },
  {
    'ACTIONS': {
      '"': 60,
      '$': 43,
      'LITERAL': 78,
      'IDENT': 2,
      'REF': 27,
      'NUMBER': 26,
      '${': 37
    },
    'GOTOS': {
      'sterm': 259,
      'item': 39,
      'node': 23,
      'ident': 77
    }
  },
  {
    'ACTIONS': {
      'FINAL': 260,
      'CATCH': 262
    },
    'DEFAULT': -72,
    'GOTOS': {
      'final': 261
    }
  },
  {
    'ACTIONS': {
      'TEXT': 263
    }
  },
  {
    'ACTIONS': {
      '"': 266,
      'LITERAL': 265,
      'NUMBER': 264
    }
  },
  {
    'DEFAULT': -97
  },
  {
    'DEFAULT': -98
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'RAWPYTHON': 13,
      'META': 15,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'MACRO': 18,
      'WRAPPER': 55,
      ";": -18,
      'FOR': 21,
      'LITERAL': 57,
      'NEXT': 22,
      '"': 60,
      'TEXT': 24,
      'PROCESS': 61,
      'RETURN': 64,
      'FILTER': 25,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 28,
      'DEFAULT': 69,
      "{": 30,
      'USE': 32,
      'VIEW': 36,
      '${': 37
    },
    'DEFAULT': -3,
    'GOTOS': {
      'item': 39,
      'loop': 4,
      'capture': 42,
      'statement': 5,
      'view': 7,
      'wrapper': 46,
      'atomexpr': 48,
      'chunk': 11,
      'atomdir': 12,
      'anonblock': 50,
      'template': 267,
      'defblockname': 14,
      'ident': 16,
      'assign': 19,
      'macro': 20,
      'lterm': 56,
      'node': 23,
      'term': 58,
      'rawpython': 59,
      'expr': 62,
      'use': 63,
      'defblock': 66,
      'filter': 29,
      'sterm': 68,
      'python': 31,
      'chunks': 33,
      'setlist': 70,
      'switch': 34,
      'try': 35,
      'directive': 71,
      'block': 72,
      'condition': 73
    }
  },
  {
    'DEFAULT': -125
  },
  {
    'DEFAULT': -126
  },
  {
    'ACTIONS': {
      ";": 268
    }
  },
  {
    'DEFAULT': -89
  },
  {
    'ACTIONS': {
      ";": -150,
      "+": 157,
      'LITERAL': -150,
      'IDENT': -150,
      'CAT': 163,
      '$': -150,
      'CMPOP': 164,
      "?": 158,
      'DIV': 159,
      'MOD': 165,
      'COMMA': -150,
      "/": 166,
      'AND': 160,
      'BINOP': 161,
      'OR': 162,
      '${': -150
    },
    'DEFAULT': -26
  },
  {
    'DEFAULT': -92
  },
  {
    'DEFAULT': -91
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 57,
      'IDENT': 269,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 151,
      'sterm': 68,
      'item': 39,
      'assign': 150,
      'margs': 270,
      'node': 23,
      'ident': 149,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      "+": 157,
      'CAT': 163,
      'CMPOP': 164,
      "?": 158,
      'DIV': 159,
      'MOD': 165,
      "/": 166,
      'AND': 160,
      'BINOP': 161,
      'OR': 162
    },
    'DEFAULT': -26
  },
  {
    'ACTIONS': {
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 271,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 272,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'COMMA': 258,
      'LITERAL': 256,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'DEFAULT': -64,
    'GOTOS': {
      'expr': 257,
      'sterm': 68,
      'item': 254,
      'param': 255,
      'node': 23,
      'ident': 253,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'DEFAULT': -56,
    'GOTOS': {
      '@1-3': 273
    }
  },
  {
    'ACTIONS': {
      '"': 89,
      '$': 86,
      'LITERAL': 88,
      'FILENAME': 83,
      'IDENT': 81,
      'NUMBER': 84
    },
    'GOTOS': {
      'filepart': 87,
      'names': 91,
      'nameargs': 274,
      'filename': 85,
      'name': 82
    }
  },
  {
    'ACTIONS': {
      'ASSIGN': -132
    },
    'DEFAULT': -130
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'RAWPYTHON': 13,
      'META': 15,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'MACRO': 18,
      'WRAPPER': 55,
      ";": -18,
      'FOR': 21,
      'LITERAL': 57,
      'NEXT': 22,
      '"': 60,
      'TEXT': 24,
      'PROCESS': 61,
      'RETURN': 64,
      'FILTER': 25,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 28,
      'DEFAULT': 69,
      "{": 30,
      'USE': 32,
      'VIEW': 36,
      '${': 37
    },
    'DEFAULT': -3,
    'GOTOS': {
      'item': 39,
      'node': 23,
      'rawpython': 59,
      'term': 58,
      'loop': 4,
      'use': 63,
      'expr': 62,
      'capture': 42,
      'statement': 5,
      'view': 7,
      'wrapper': 46,
      'atomexpr': 48,
      'chunk': 11,
      'defblock': 66,
      'atomdir': 12,
      'anonblock': 50,
      'sterm': 68,
      'defblockname': 14,
      'filter': 29,
      'ident': 16,
      'python': 31,
      'setlist': 70,
      'chunks': 33,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'block': 275,
      'directive': 71,
      'macro': 20,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      '"': 276,
      'TEXT': 231,
      ";": 233,
      '$': 43,
      'IDENT': 2,
      '${': 37
    },
    'GOTOS': {
      'item': 39,
      'node': 23,
      'ident': 230,
      'quotable': 232
    }
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'RAWPYTHON': 13,
      'META': 15,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'MACRO': 18,
      'WRAPPER': 55,
      ";": -18,
      'FOR': 21,
      'LITERAL': 57,
      'NEXT': 22,
      '"': 60,
      'TEXT': 24,
      'PROCESS': 61,
      'RETURN': 64,
      'FILTER': 25,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 28,
      'DEFAULT': 69,
      "{": 30,
      'USE': 32,
      'VIEW': 36,
      '${': 37
    },
    'DEFAULT': -3,
    'GOTOS': {
      'item': 39,
      'node': 23,
      'rawpython': 59,
      'term': 58,
      'loop': 4,
      'use': 63,
      'expr': 62,
      'capture': 42,
      'statement': 5,
      'view': 7,
      'wrapper': 46,
      'atomexpr': 48,
      'chunk': 11,
      'defblock': 66,
      'atomdir': 12,
      'anonblock': 50,
      'sterm': 68,
      'defblockname': 14,
      'filter': 29,
      'ident': 16,
      'python': 31,
      'setlist': 70,
      'chunks': 33,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'block': 277,
      'directive': 71,
      'macro': 20,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'DEFAULT': -108
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 278,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'DEFAULT': -120
  },
  {
    'DEFAULT': -121
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 279,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'DEFAULT': -74,
    'GOTOS': {
      '@3-3': 280
    }
  },
  {
    'DEFAULT': -131
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'COMMA': 258,
      'LITERAL': 256,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      ")": 281,
      '${': 37
    },
    'GOTOS': {
      'expr': 257,
      'sterm': 68,
      'item': 254,
      'param': 255,
      'node': 23,
      'ident': 253,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'RAWPYTHON': 13,
      'META': 15,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'MACRO': 18,
      'WRAPPER': 55,
      ";": -18,
      'FOR': 21,
      'LITERAL': 57,
      'NEXT': 22,
      '"': 60,
      'TEXT': 24,
      'PROCESS': 61,
      'RETURN': 64,
      'FILTER': 25,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 28,
      'DEFAULT': 69,
      "{": 30,
      'USE': 32,
      'VIEW': 36,
      '${': 37
    },
    'DEFAULT': -3,
    'GOTOS': {
      'item': 39,
      'node': 23,
      'rawpython': 59,
      'term': 58,
      'loop': 4,
      'use': 63,
      'expr': 62,
      'capture': 42,
      'statement': 5,
      'view': 7,
      'wrapper': 46,
      'atomexpr': 48,
      'chunk': 11,
      'defblock': 66,
      'atomdir': 12,
      'anonblock': 50,
      'sterm': 68,
      'defblockname': 14,
      'filter': 29,
      'ident': 16,
      'python': 31,
      'setlist': 70,
      'chunks': 33,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'block': 282,
      'directive': 71,
      'macro': 20,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'RAWPYTHON': 13,
      'META': 15,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'MACRO': 18,
      'WRAPPER': 55,
      ";": -18,
      'FOR': 21,
      'LITERAL': 57,
      'NEXT': 22,
      '"': 60,
      'TEXT': 24,
      'PROCESS': 61,
      'RETURN': 64,
      'FILTER': 25,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 28,
      'DEFAULT': 69,
      "{": 30,
      'USE': 32,
      'VIEW': 36,
      '${': 37
    },
    'DEFAULT': -3,
    'GOTOS': {
      'item': 39,
      'node': 23,
      'rawpython': 59,
      'term': 58,
      'loop': 4,
      'use': 63,
      'expr': 62,
      'capture': 42,
      'statement': 5,
      'view': 7,
      'wrapper': 46,
      'atomexpr': 48,
      'chunk': 11,
      'defblock': 66,
      'atomdir': 12,
      'anonblock': 50,
      'sterm': 68,
      'defblockname': 14,
      'filter': 29,
      'ident': 16,
      'python': 31,
      'setlist': 70,
      'chunks': 33,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'block': 283,
      'directive': 71,
      'macro': 20,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'CMPOP': 164,
      "?": 158,
      "+": 157,
      'MOD': 165,
      'DIV': 159,
      "/": 166,
      'AND': 160,
      'CAT': 163,
      'BINOP': 161,
      'OR': 162
    },
    'DEFAULT': -47
  },
  {
    'DEFAULT': -58
  },
  {
    'DEFAULT': -81
  },
  {
    'ACTIONS': {
      'CMPOP': 164,
      "?": 158,
      "+": 157,
      'MOD': 165,
      'DIV': 159,
      "/": 166,
      'AND': 160,
      'CAT': 163,
      'BINOP': 161,
      'OR': 162
    },
    'DEFAULT': -45
  },
  {
    'DEFAULT': -66
  },
  {
    'ACTIONS': {
      'CMPOP': 164,
      "?": 158,
      "+": 157,
      'MOD': 165,
      'DIV': 159,
      "/": 166,
      'AND': 160,
      'CAT': 163,
      'BINOP': 161,
      'OR': 162
    },
    'DEFAULT': -61
  },
  {
    'DEFAULT': -144
  },
  {
    'DEFAULT': -145
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'RAWPYTHON': 13,
      'META': 15,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'MACRO': 18,
      'WRAPPER': 55,
      ";": -18,
      'FOR': 21,
      'LITERAL': 57,
      'NEXT': 22,
      '"': 60,
      'TEXT': 24,
      'PROCESS': 61,
      'RETURN': 64,
      'FILTER': 25,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 28,
      'DEFAULT': 69,
      "{": 30,
      'USE': 32,
      'VIEW': 36,
      '${': 37
    },
    'DEFAULT': -3,
    'GOTOS': {
      'item': 39,
      'node': 23,
      'rawpython': 59,
      'term': 58,
      'loop': 4,
      'use': 63,
      'expr': 62,
      'capture': 42,
      'statement': 5,
      'view': 7,
      'wrapper': 46,
      'atomexpr': 48,
      'chunk': 11,
      'defblock': 66,
      'atomdir': 12,
      'anonblock': 50,
      'sterm': 68,
      'defblockname': 14,
      'filter': 29,
      'ident': 16,
      'python': 31,
      'setlist': 70,
      'chunks': 33,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'block': 284,
      'directive': 71,
      'macro': 20,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'RAWPYTHON': 13,
      'META': 15,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'MACRO': 18,
      'WRAPPER': 55,
      ";": -18,
      'FOR': 21,
      'LITERAL': 57,
      'NEXT': 22,
      '"': 60,
      'TEXT': 24,
      'PROCESS': 61,
      'RETURN': 64,
      'FILTER': 25,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 28,
      'DEFAULT': 69,
      "{": 30,
      'USE': 32,
      'VIEW': 36,
      '${': 37
    },
    'DEFAULT': -3,
    'GOTOS': {
      'item': 39,
      'node': 23,
      'rawpython': 59,
      'term': 58,
      'loop': 4,
      'use': 63,
      'expr': 62,
      'capture': 42,
      'statement': 5,
      'view': 7,
      'wrapper': 46,
      'atomexpr': 48,
      'chunk': 11,
      'defblock': 66,
      'atomdir': 12,
      'anonblock': 50,
      'sterm': 68,
      'defblockname': 14,
      'filter': 29,
      'ident': 16,
      'python': 31,
      'setlist': 70,
      'chunks': 33,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'block': 285,
      'directive': 71,
      'macro': 20,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      "+": 157,
      'CAT': 163,
      'CMPOP': 164,
      "?": 158,
      'DIV': 159,
      'MOD': 165,
      "/": 166,
      'AND': 160,
      'BINOP': 161,
      'OR': 162
    },
    'DEFAULT': -151
  },
  {
    'ACTIONS': {
      'DOT': 104
    },
    'DEFAULT': -177
  },
  {
    'DEFAULT': -178
  },
  {
    'DEFAULT': -175
  },
  {
    'DEFAULT': -179
  },
  {
    'DEFAULT': -111
  },
  {
    'ACTIONS': {
      'DIV': 159,
      'MOD': 165,
      "/": 166
    },
    'DEFAULT': -135
  },
  {
    'ACTIONS': {
      ":": 286,
      'CMPOP': 164,
      "?": 158,
      "+": 157,
      'MOD': 165,
      'DIV': 159,
      "/": 166,
      'AND': 160,
      'CAT': 163,
      'BINOP': 161,
      'OR': 162
    }
  },
  {
    'ACTIONS': {
      'MOD': 165
    },
    'DEFAULT': -136
  },
  {
    'ACTIONS': {
      'DIV': 159,
      'BINOP': 161,
      "+": 157,
      'CAT': 163,
      'CMPOP': 164,
      'MOD': 165,
      "/": 166
    },
    'DEFAULT': -140
  },
  {
    'ACTIONS': {
      'DIV': 159,
      "+": 157,
      'MOD': 165,
      "/": 166
    },
    'DEFAULT': -133
  },
  {
    'ACTIONS': {
      'DIV': 159,
      'BINOP': 161,
      "+": 157,
      'CAT': 163,
      'CMPOP': 164,
      'MOD': 165,
      "/": 166
    },
    'DEFAULT': -141
  },
  {
    'ACTIONS': {
      'DIV': 159,
      'BINOP': 161,
      "+": 157,
      'CMPOP': 164,
      'MOD': 165,
      "/": 166
    },
    'DEFAULT': -139
  },
  {
    'ACTIONS': {
      'DIV': 159,
      'BINOP': 161,
      "+": 157,
      'MOD': 165,
      "/": 166
    },
    'DEFAULT': -138
  },
  {
    'DEFAULT': -137
  },
  {
    'ACTIONS': {
      'DIV': 159,
      'MOD': 165
    },
    'DEFAULT': -134
  },
  {
    'DEFAULT': -59,
    'GOTOS': {
      '@2-3': 287
    }
  },
  {
    'ACTIONS': {
      "+": 157,
      'CAT': 163,
      'CMPOP': 164,
      "?": 158,
      'DIV': 159,
      'MOD': 165,
      "/": 166,
      'AND': 160,
      'BINOP': 161,
      'OR': 162
    },
    'DEFAULT': -150
  },
  {
    'ACTIONS': {
      'ELSIF': 290,
      'ELSE': 288
    },
    'DEFAULT': -50,
    'GOTOS': {
      'else': 289
    }
  },
  {
    'DEFAULT': -170
  },
  {
    'ACTIONS': {
      'NOT': 38,
      'LITERAL': 256,
      'IDENT': 2,
      '"': 60,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      "{": 30,
      'COMMA': 258,
      "(": 53,
      '${': 37
    },
    'DEFAULT': -162,
    'GOTOS': {
      'expr': 257,
      'sterm': 68,
      'item': 254,
      'param': 255,
      'node': 23,
      'ident': 253,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'DEFAULT': -167
  },
  {
    'DEFAULT': -165
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'COMMA': 258,
      'LITERAL': 256,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      ")": 291,
      '${': 37
    },
    'GOTOS': {
      'expr': 257,
      'sterm': 68,
      'item': 254,
      'param': 255,
      'node': 23,
      'ident': 253,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'DOT': 104,
      'ASSIGN': 292
    },
    'DEFAULT': -109
  },
  {
    'ACTIONS': {
      "(": 135,
      'ASSIGN': 210
    },
    'DEFAULT': -128
  },
  {
    'DEFAULT': -153
  },
  {
    'ACTIONS': {
      'ASSIGN': 213
    },
    'DEFAULT': -112
  },
  {
    'ACTIONS': {
      "+": 157,
      'CAT': 163,
      'CMPOP': 164,
      "?": 158,
      'DIV': 159,
      'MOD': 165,
      "/": 166,
      'AND': 160,
      'BINOP': 161,
      'OR': 162
    },
    'DEFAULT': -152
  },
  {
    'DEFAULT': -155
  },
  {
    'DEFAULT': -117
  },
  {
    'ACTIONS': {
      ";": 293
    }
  },
  {
    'ACTIONS': {
      'END': 294
    }
  },
  {
    'ACTIONS': {
      ";": 296,
      'DEFAULT': 297,
      'FILENAME': 83,
      'IDENT': 81,
      'NUMBER': 84
    },
    'GOTOS': {
      'filepart': 87,
      'filename': 295
    }
  },
  {
    'ACTIONS': {
      'END': 298
    }
  },
  {
    'DEFAULT': -102
  },
  {
    'DEFAULT': -100
  },
  {
    'ACTIONS': {
      'TEXT': 299
    }
  },
  {
    'ACTIONS': {
      'END': 300
    }
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'RAWPYTHON': 13,
      'META': 15,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'MACRO': 18,
      'WRAPPER': 55,
      ";": -18,
      'FOR': 21,
      'LITERAL': 57,
      'NEXT': 22,
      '"': 60,
      'TEXT': 24,
      'PROCESS': 61,
      'RETURN': 64,
      'FILTER': 25,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 28,
      'DEFAULT': 69,
      "{": 30,
      'USE': 32,
      'VIEW': 36,
      '${': 37
    },
    'DEFAULT': -3,
    'GOTOS': {
      'item': 39,
      'node': 23,
      'rawpython': 59,
      'term': 58,
      'loop': 4,
      'use': 63,
      'expr': 62,
      'capture': 42,
      'statement': 5,
      'view': 7,
      'wrapper': 46,
      'atomexpr': 48,
      'chunk': 11,
      'defblock': 66,
      'atomdir': 12,
      'anonblock': 50,
      'sterm': 68,
      'defblockname': 14,
      'filter': 29,
      'ident': 16,
      'python': 31,
      'setlist': 70,
      'chunks': 33,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'block': 301,
      'directive': 71,
      'macro': 20,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'IDENT': -96,
      ")": -96,
      'COMMA': -96
    },
    'DEFAULT': -130
  },
  {
    'ACTIONS': {
      'COMMA': 304,
      'IDENT': 302,
      ")": 303
    }
  },
  {
    'DEFAULT': -156,
    'GOTOS': {
      'args': 305
    }
  },
  {
    'DEFAULT': -156,
    'GOTOS': {
      'args': 306
    }
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'RAWPYTHON': 13,
      'META': 15,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'MACRO': 18,
      'WRAPPER': 55,
      ";": -18,
      'FOR': 21,
      'LITERAL': 57,
      'NEXT': 22,
      '"': 60,
      'TEXT': 24,
      'PROCESS': 61,
      'RETURN': 64,
      'FILTER': 25,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 28,
      'DEFAULT': 69,
      "{": 30,
      'USE': 32,
      'VIEW': 36,
      '${': 37
    },
    'DEFAULT': -3,
    'GOTOS': {
      'item': 39,
      'node': 23,
      'rawpython': 59,
      'term': 58,
      'loop': 4,
      'use': 63,
      'expr': 62,
      'capture': 42,
      'statement': 5,
      'view': 7,
      'wrapper': 46,
      'atomexpr': 48,
      'chunk': 11,
      'defblock': 66,
      'atomdir': 12,
      'anonblock': 50,
      'sterm': 68,
      'defblockname': 14,
      'filter': 29,
      'ident': 16,
      'python': 31,
      'setlist': 70,
      'chunks': 33,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'block': 307,
      'directive': 71,
      'macro': 20,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'DEFAULT': -157
  },
  {
    'ACTIONS': {
      'END': 308
    }
  },
  {
    'ACTIONS': {
      'ASSIGN': -160
    },
    'DEFAULT': -167
  },
  {
    'ACTIONS': {
      'END': 309
    }
  },
  {
    'ACTIONS': {
      'DIV': 159,
      'AND': 160,
      'BINOP': 161,
      'OR': 162,
      "+": 157,
      'CAT': 163,
      'CMPOP': 164,
      "?": 158,
      'MOD': 165,
      "/": 166
    },
    'DEFAULT': -124
  },
  {
    'ACTIONS': {
      'DIV': 159,
      'AND': 160,
      'BINOP': 161,
      'OR': 162,
      "+": 157,
      'CAT': 163,
      'CMPOP': 164,
      "?": 158,
      'MOD': 165,
      "/": 166
    },
    'DEFAULT': -123
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'RAWPYTHON': 13,
      'META': 15,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'MACRO': 18,
      'WRAPPER': 55,
      ";": -18,
      'FOR': 21,
      'LITERAL': 57,
      'NEXT': 22,
      '"': 60,
      'TEXT': 24,
      'PROCESS': 61,
      'RETURN': 64,
      'FILTER': 25,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 28,
      'DEFAULT': 69,
      "{": 30,
      'USE': 32,
      'VIEW': 36,
      '${': 37
    },
    'DEFAULT': -3,
    'GOTOS': {
      'item': 39,
      'node': 23,
      'rawpython': 59,
      'term': 58,
      'loop': 4,
      'use': 63,
      'expr': 62,
      'capture': 42,
      'statement': 5,
      'view': 7,
      'wrapper': 46,
      'atomexpr': 48,
      'chunk': 11,
      'defblock': 66,
      'atomdir': 12,
      'anonblock': 50,
      'sterm': 68,
      'defblockname': 14,
      'filter': 29,
      'ident': 16,
      'python': 31,
      'setlist': 70,
      'chunks': 33,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'block': 310,
      'directive': 71,
      'macro': 20,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'DEFAULT': -129
  },
  {
    'ACTIONS': {
      'END': 311
    }
  },
  {
    'ACTIONS': {
      'ELSIF': 290,
      'ELSE': 288
    },
    'DEFAULT': -50,
    'GOTOS': {
      'else': 312
    }
  },
  {
    'ACTIONS': {
      'CASE': 313
    },
    'DEFAULT': -55,
    'GOTOS': {
      'case': 314
    }
  },
  {
    'ACTIONS': {
      'END': 315
    }
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 316,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'RAWPYTHON': 13,
      'META': 15,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'MACRO': 18,
      'WRAPPER': 55,
      ";": -18,
      'FOR': 21,
      'LITERAL': 57,
      'NEXT': 22,
      '"': 60,
      'TEXT': 24,
      'PROCESS': 61,
      'RETURN': 64,
      'FILTER': 25,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 28,
      'DEFAULT': 69,
      "{": 30,
      'USE': 32,
      'VIEW': 36,
      '${': 37
    },
    'DEFAULT': -3,
    'GOTOS': {
      'item': 39,
      'node': 23,
      'rawpython': 59,
      'term': 58,
      'loop': 4,
      'use': 63,
      'expr': 62,
      'capture': 42,
      'statement': 5,
      'view': 7,
      'wrapper': 46,
      'atomexpr': 48,
      'chunk': 11,
      'defblock': 66,
      'atomdir': 12,
      'anonblock': 50,
      'sterm': 68,
      'defblockname': 14,
      'filter': 29,
      'ident': 16,
      'python': 31,
      'setlist': 70,
      'chunks': 33,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'block': 317,
      'directive': 71,
      'macro': 20,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      ";": 318
    }
  },
  {
    'ACTIONS': {
      'END': 319
    }
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 320,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'DEFAULT': -164
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'expr': 321,
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'RAWPYTHON': 13,
      'META': 15,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'MACRO': 18,
      'WRAPPER': 55,
      ";": -18,
      'FOR': 21,
      'LITERAL': 57,
      'NEXT': 22,
      '"': 60,
      'TEXT': 24,
      'PROCESS': 61,
      'RETURN': 64,
      'FILTER': 25,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 28,
      'DEFAULT': 69,
      "{": 30,
      'USE': 32,
      'VIEW': 36,
      '${': 37
    },
    'DEFAULT': -3,
    'GOTOS': {
      'item': 39,
      'node': 23,
      'rawpython': 59,
      'term': 58,
      'loop': 4,
      'use': 63,
      'expr': 62,
      'capture': 42,
      'statement': 5,
      'view': 7,
      'wrapper': 46,
      'atomexpr': 48,
      'chunk': 11,
      'defblock': 66,
      'atomdir': 12,
      'anonblock': 50,
      'sterm': 68,
      'defblockname': 14,
      'filter': 29,
      'ident': 16,
      'python': 31,
      'setlist': 70,
      'chunks': 33,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'block': 322,
      'directive': 71,
      'macro': 20,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'DEFAULT': -67
  },
  {
    'ACTIONS': {
      'DOT': 174,
      ";": 323
    }
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'RAWPYTHON': 13,
      'META': 15,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'MACRO': 18,
      'WRAPPER': 55,
      ";": -18,
      'FOR': 21,
      'LITERAL': 57,
      'NEXT': 22,
      '"': 60,
      'TEXT': 24,
      'PROCESS': 61,
      'RETURN': 64,
      'FILTER': 25,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 28,
      'DEFAULT': 69,
      "{": 30,
      'USE': 32,
      'VIEW': 36,
      '${': 37
    },
    'DEFAULT': -3,
    'GOTOS': {
      'item': 39,
      'node': 23,
      'rawpython': 59,
      'term': 58,
      'loop': 4,
      'use': 63,
      'expr': 62,
      'capture': 42,
      'statement': 5,
      'view': 7,
      'wrapper': 46,
      'atomexpr': 48,
      'chunk': 11,
      'defblock': 66,
      'atomdir': 12,
      'anonblock': 50,
      'sterm': 68,
      'defblockname': 14,
      'filter': 29,
      'ident': 16,
      'python': 31,
      'setlist': 70,
      'chunks': 33,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'block': 324,
      'directive': 71,
      'macro': 20,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      ";": 325
    }
  },
  {
    'DEFAULT': -79
  },
  {
    'ACTIONS': {
      '"': 326
    }
  },
  {
    'DEFAULT': -82
  },
  {
    'ACTIONS': {
      'END': 327
    }
  },
  {
    'DEFAULT': -94
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'WRAPPER': 55,
      'FOR': 21,
      'NEXT': 22,
      'LITERAL': 57,
      '"': 60,
      'PROCESS': 61,
      'FILTER': 25,
      'RETURN': 64,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 193,
      'DEFAULT': 69,
      "{": 30,
      '${': 37
    },
    'GOTOS': {
      'item': 39,
      'node': 23,
      'term': 58,
      'loop': 4,
      'expr': 199,
      'wrapper': 46,
      'atomexpr': 48,
      'atomdir': 12,
      'mdir': 328,
      'filter': 29,
      'sterm': 68,
      'ident': 149,
      'python': 31,
      'setlist': 70,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'directive': 196,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'DEFAULT': -95
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'COMMA': 258,
      'LITERAL': 256,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'DEFAULT': -62,
    'GOTOS': {
      'expr': 257,
      'sterm': 68,
      'item': 254,
      'param': 255,
      'node': 23,
      'ident': 253,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'NOT': 38,
      "{": 30,
      'COMMA': 258,
      'LITERAL': 256,
      'IDENT': 2,
      '"': 60,
      "(": 53,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'DEFAULT': -63,
    'GOTOS': {
      'expr': 257,
      'sterm': 68,
      'item': 254,
      'param': 255,
      'node': 23,
      'ident': 253,
      'term': 58,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'END': 329
    }
  },
  {
    'DEFAULT': -80
  },
  {
    'DEFAULT': -88
  },
  {
    'ACTIONS': {
      'END': 330
    }
  },
  {
    'DEFAULT': -77
  },
  {
    'ACTIONS': {
      'END': 331
    }
  },
  {
    'ACTIONS': {
      ";": 332,
      'DEFAULT': 334,
      "{": 30,
      'LITERAL': 78,
      'IDENT': 2,
      '"': 60,
      '$': 43,
      "[": 9,
      'NUMBER': 26,
      'REF': 27,
      '${': 37
    },
    'GOTOS': {
      'sterm': 68,
      'item': 39,
      'node': 23,
      'ident': 77,
      'term': 333,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'END': 335
    }
  },
  {
    'DEFAULT': -65
  },
  {
    'ACTIONS': {
      'DIV': 159,
      'AND': 160,
      'BINOP': 161,
      'OR': 162,
      "+": 157,
      'CAT': 163,
      'CMPOP': 164,
      "?": 158,
      'MOD': 165,
      "/": 166
    },
    'DEFAULT': -143
  },
  {
    'ACTIONS': {
      'END': 336
    }
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'RAWPYTHON': 13,
      'META': 15,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'MACRO': 18,
      'WRAPPER': 55,
      ";": -18,
      'FOR': 21,
      'LITERAL': 57,
      'NEXT': 22,
      '"': 60,
      'TEXT': 24,
      'PROCESS': 61,
      'RETURN': 64,
      'FILTER': 25,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 28,
      'DEFAULT': 69,
      "{": 30,
      'USE': 32,
      'VIEW': 36,
      '${': 37
    },
    'DEFAULT': -3,
    'GOTOS': {
      'item': 39,
      'node': 23,
      'rawpython': 59,
      'term': 58,
      'loop': 4,
      'use': 63,
      'expr': 62,
      'capture': 42,
      'statement': 5,
      'view': 7,
      'wrapper': 46,
      'atomexpr': 48,
      'chunk': 11,
      'defblock': 66,
      'atomdir': 12,
      'anonblock': 50,
      'sterm': 68,
      'defblockname': 14,
      'filter': 29,
      'ident': 16,
      'python': 31,
      'setlist': 70,
      'chunks': 33,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'block': 337,
      'directive': 71,
      'macro': 20,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'DEFAULT': -46
  },
  {
    'ACTIONS': {
      'CMPOP': 164,
      "?": 158,
      ";": 338,
      "+": 157,
      'MOD': 165,
      'DIV': 159,
      "/": 166,
      'AND': 160,
      'CAT': 163,
      'BINOP': 161,
      'OR': 162
    }
  },
  {
    'ACTIONS': {
      "+": 157,
      'CAT': 163,
      'CMPOP': 164,
      "?": 158,
      'DIV': 159,
      'MOD': 165,
      "/": 166,
      'AND': 160,
      'BINOP': 161,
      'OR': 162
    },
    'DEFAULT': -154
  },
  {
    'DEFAULT': -71
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'RAWPYTHON': 13,
      'META': 15,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'MACRO': 18,
      'WRAPPER': 55,
      ";": -18,
      'FOR': 21,
      'LITERAL': 57,
      'NEXT': 22,
      '"': 60,
      'TEXT': 24,
      'PROCESS': 61,
      'RETURN': 64,
      'FILTER': 25,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 28,
      'DEFAULT': 69,
      "{": 30,
      'USE': 32,
      'VIEW': 36,
      '${': 37
    },
    'DEFAULT': -3,
    'GOTOS': {
      'item': 39,
      'node': 23,
      'rawpython': 59,
      'term': 58,
      'loop': 4,
      'use': 63,
      'expr': 62,
      'capture': 42,
      'statement': 5,
      'view': 7,
      'wrapper': 46,
      'atomexpr': 48,
      'chunk': 11,
      'defblock': 66,
      'atomdir': 12,
      'anonblock': 50,
      'sterm': 68,
      'defblockname': 14,
      'filter': 29,
      'ident': 16,
      'python': 31,
      'setlist': 70,
      'chunks': 33,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'block': 339,
      'directive': 71,
      'macro': 20,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'FINAL': 260,
      'CATCH': 262
    },
    'DEFAULT': -72,
    'GOTOS': {
      'final': 340
    }
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'RAWPYTHON': 13,
      'META': 15,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'MACRO': 18,
      'WRAPPER': 55,
      ";": -18,
      'FOR': 21,
      'LITERAL': 57,
      'NEXT': 22,
      '"': 60,
      'TEXT': 24,
      'PROCESS': 61,
      'RETURN': 64,
      'FILTER': 25,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 28,
      'DEFAULT': 69,
      "{": 30,
      'USE': 32,
      'VIEW': 36,
      '${': 37
    },
    'DEFAULT': -3,
    'GOTOS': {
      'item': 39,
      'node': 23,
      'rawpython': 59,
      'term': 58,
      'loop': 4,
      'use': 63,
      'expr': 62,
      'capture': 42,
      'statement': 5,
      'view': 7,
      'wrapper': 46,
      'atomexpr': 48,
      'chunk': 11,
      'defblock': 66,
      'atomdir': 12,
      'anonblock': 50,
      'sterm': 68,
      'defblockname': 14,
      'filter': 29,
      'ident': 16,
      'python': 31,
      'setlist': 70,
      'chunks': 33,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'block': 341,
      'directive': 71,
      'macro': 20,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'DEFAULT': -101
  },
  {
    'DEFAULT': -93
  },
  {
    'DEFAULT': -90
  },
  {
    'DEFAULT': -57
  },
  {
    'DEFAULT': -75
  },
  {
    'DEFAULT': -44
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'RAWPYTHON': 13,
      'META': 15,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'MACRO': 18,
      'WRAPPER': 55,
      ";": -18,
      'FOR': 21,
      'LITERAL': 57,
      'NEXT': 22,
      '"': 60,
      'TEXT': 24,
      'PROCESS': 61,
      'RETURN': 64,
      'FILTER': 25,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 28,
      'DEFAULT': 69,
      "{": 30,
      'USE': 32,
      'VIEW': 36,
      '${': 37
    },
    'DEFAULT': -3,
    'GOTOS': {
      'item': 39,
      'node': 23,
      'rawpython': 59,
      'term': 58,
      'loop': 4,
      'use': 63,
      'expr': 62,
      'capture': 42,
      'statement': 5,
      'view': 7,
      'wrapper': 46,
      'atomexpr': 48,
      'chunk': 11,
      'defblock': 66,
      'atomdir': 12,
      'anonblock': 50,
      'sterm': 68,
      'defblockname': 14,
      'filter': 29,
      'ident': 16,
      'python': 31,
      'setlist': 70,
      'chunks': 33,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'block': 342,
      'directive': 71,
      'macro': 20,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      ";": 343
    }
  },
  {
    'ACTIONS': {
      ";": 344
    }
  },
  {
    'DEFAULT': -51
  },
  {
    'DEFAULT': -60
  },
  {
    'DEFAULT': -49
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'RAWPYTHON': 13,
      'META': 15,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'MACRO': 18,
      'WRAPPER': 55,
      ";": -18,
      'FOR': 21,
      'LITERAL': 57,
      'NEXT': 22,
      '"': 60,
      'TEXT': 24,
      'PROCESS': 61,
      'RETURN': 64,
      'FILTER': 25,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 28,
      'DEFAULT': 69,
      "{": 30,
      'USE': 32,
      'VIEW': 36,
      '${': 37
    },
    'DEFAULT': -3,
    'GOTOS': {
      'item': 39,
      'node': 23,
      'rawpython': 59,
      'term': 58,
      'loop': 4,
      'use': 63,
      'expr': 62,
      'capture': 42,
      'statement': 5,
      'view': 7,
      'wrapper': 46,
      'atomexpr': 48,
      'chunk': 11,
      'defblock': 66,
      'atomdir': 12,
      'anonblock': 50,
      'sterm': 68,
      'defblockname': 14,
      'filter': 29,
      'ident': 16,
      'python': 31,
      'setlist': 70,
      'chunks': 33,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'block': 345,
      'directive': 71,
      'macro': 20,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'FINAL': 260,
      'CATCH': 262
    },
    'DEFAULT': -72,
    'GOTOS': {
      'final': 346
    }
  },
  {
    'DEFAULT': -70
  },
  {
    'ACTIONS': {
      'FINAL': 260,
      'CATCH': 262
    },
    'DEFAULT': -72,
    'GOTOS': {
      'final': 347
    }
  },
  {
    'DEFAULT': -54
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'RAWPYTHON': 13,
      'META': 15,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'MACRO': 18,
      'WRAPPER': 55,
      ";": -18,
      'FOR': 21,
      'LITERAL': 57,
      'NEXT': 22,
      '"': 60,
      'TEXT': 24,
      'PROCESS': 61,
      'RETURN': 64,
      'FILTER': 25,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 28,
      'DEFAULT': 69,
      "{": 30,
      'USE': 32,
      'VIEW': 36,
      '${': 37
    },
    'DEFAULT': -3,
    'GOTOS': {
      'item': 39,
      'node': 23,
      'rawpython': 59,
      'term': 58,
      'loop': 4,
      'use': 63,
      'expr': 62,
      'capture': 42,
      'statement': 5,
      'view': 7,
      'wrapper': 46,
      'atomexpr': 48,
      'chunk': 11,
      'defblock': 66,
      'atomdir': 12,
      'anonblock': 50,
      'sterm': 68,
      'defblockname': 14,
      'filter': 29,
      'ident': 16,
      'python': 31,
      'setlist': 70,
      'chunks': 33,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'block': 348,
      'directive': 71,
      'macro': 20,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'SET': 1,
      'PYTHON': 40,
      'NOT': 38,
      'IDENT': 2,
      'CLEAR': 41,
      'UNLESS': 3,
      'IF': 44,
      '$': 43,
      'STOP': 6,
      'CALL': 45,
      'THROW': 8,
      'GET': 47,
      "[": 9,
      'TRY': 10,
      'LAST': 49,
      'DEBUG': 51,
      'RAWPYTHON': 13,
      'META': 15,
      'INCLUDE': 17,
      "(": 53,
      'SWITCH': 54,
      'MACRO': 18,
      'WRAPPER': 55,
      ";": -18,
      'FOR': 21,
      'LITERAL': 57,
      'NEXT': 22,
      '"': 60,
      'TEXT': 24,
      'PROCESS': 61,
      'RETURN': 64,
      'FILTER': 25,
      'INSERT': 65,
      'NUMBER': 26,
      'REF': 27,
      'WHILE': 67,
      'BLOCK': 28,
      'DEFAULT': 69,
      "{": 30,
      'USE': 32,
      'VIEW': 36,
      '${': 37
    },
    'DEFAULT': -3,
    'GOTOS': {
      'item': 39,
      'node': 23,
      'rawpython': 59,
      'term': 58,
      'loop': 4,
      'use': 63,
      'expr': 62,
      'capture': 42,
      'statement': 5,
      'view': 7,
      'wrapper': 46,
      'atomexpr': 48,
      'chunk': 11,
      'defblock': 66,
      'atomdir': 12,
      'anonblock': 50,
      'sterm': 68,
      'defblockname': 14,
      'filter': 29,
      'ident': 16,
      'python': 31,
      'setlist': 70,
      'chunks': 33,
      'try': 35,
      'switch': 34,
      'assign': 19,
      'block': 349,
      'directive': 71,
      'macro': 20,
      'condition': 73,
      'lterm': 56
    }
  },
  {
    'ACTIONS': {
      'ELSIF': 290,
      'ELSE': 288
    },
    'DEFAULT': -50,
    'GOTOS': {
      'else': 350
    }
  },
  {
    'DEFAULT': -68
  },
  {
    'DEFAULT': -69
  },
  {
    'ACTIONS': {
      'CASE': 313
    },
    'DEFAULT': -55,
    'GOTOS': {
      'case': 351
    }
  },
  {
    'DEFAULT': -53
  },
  {
    'DEFAULT': -48
  },
  {
    'DEFAULT': -52
  }
];

RULES = [None] * 180

NULL_RULES = (
  ("$start", 2, (0,)),
  ("statement", 1, (8, 9, 10, 11, 12, 13, 14, 15)),
  ("statement", 0, (18,)),
  ("directive", 1, (20, 21, 22, 23, 24, 25)),
  ("atomexpr", 1, (27,)),
  ("atomdir", 1, (42, 43, 44)),
  ("blockname", 1, (84, 86)),
  ("blockargs", 1, (86,)),
  ("blockargs", 0, (87,)),
  ("mdir", 1, (92,)),
  ("metadata", 2, (98,)),
  ("metadata", 1, (99,)),
  ("term", 1, (103, 104)),
  ("sterm", 1, (112, 113)),
  ("list", 2, (115,)),
  ("list", 1, (116,)),
  ("hash", 1, (118,)),
  ("params", 2, (121,)),
  ("params", 1, (122,)),
  ("ident", 1, (127,)),
  ("expr", 1, (146,)),
  ("setlist", 2, (148,)),
  ("setlist", 1, (149,)),
  ("lnameargs", 1, (158,)),
  ("lvalue", 1, (159, 161)),
  ("name", 1, (169,)),
  ("filename", 1, (171,)),
  ("filepart", 1, (172, 173, 174))
)

# NULL_RULES = (
#   (0, "$start", 2),
#   (8, "statement", 1),
#   (9, "statement", 1),
#   (10, "statement", 1),
#   (11, "statement", 1),
#   (12, "statement", 1),
#   (13, "statement", 1),
#   (14, "statement", 1),
#   (15, "statement", 1),
#   (18, "statement", 0),
#   (20, "directive", 1),
#   (21, "directive", 1),
#   (22, "directive", 1),
#   (23, "directive", 1),
#   (24, "directive", 1),
#   (25, "directive", 1),
#   (27, "atomexpr", 1),
#   (42, "atomdir", 1),
#   (43, "atomdir", 1),
#   (44, "atomdir", 1),
#   (84, "blockname", 1),
#   (86, "blockargs", 1),
#   (87, "blockargs", 0),
#   (92, "mdir", 1),
#   (98, "metadata", 2),
#   (99, "metadata", 1),
#   (103, "term", 1),
#   (104, "term", 1),
#   (112, "sterm", 1),
#   (113, "sterm", 1),
#   (115, "list", 2),
#   (116, "list", 1),
#   (118, "hash", 1),
#   (121, "params", 2),
#   (122, "params", 1),
#   (127, "ident", 1),
#   (146, "expr", 1),
#   (148, "setlist", 2),
#   (149, "setlist", 1),
#   (158, "lnameargs", 1),
#   (159, "lvalue", 1),
#   (161, "lvalue", 1),
#   (169, "name", 1),
#   (171, "filename", 1),
#   (172, "filepart", 1),
#   (173, "filepart", 1),
#   (174, "filepart", 1)
# )

for lhs, args, indices in NULL_RULES:
  for index in indices:
    RULES[index] = (lhs, args, None)

# Registration decorator for RULES:

define = registrar(RULES, lambda f, key, lhs, args: ((key, (lhs, args, f)),))


@define(1, "template", 1)
def rule(*args):
  return factory.template(args[1])


@define(2, "block", 1)
def rule(*args):
  return factory.block(args[1])


@define(3, "block", 0)
def rule(*args):
  return factory.block()


@define(4, "chunks", 2)
def rule(*args):
  if len(args) >= 3 and args[2] is not None:
    args[1].append(args[2])
  return args[1]


@define(5, "chunks", 1)
def rule(*args):
  if len(args) >= 2 and args[1] is not None:
    return [args[1]]
  else:
    return []


@define(6, "chunk", 1)
def rule(*args):
  return factory.textblock(args[1])


@define(7, "chunk", 2)
def rule(*args):
  if not args[1]:
    return ""
  else:
    return args[0].location() + args[1]


@define(16, "statement", 1)
def rule(*args):
  return factory.get(args[1])


@define(17, "statement", 2)
def rule(*args):
  return args[0].add_metadata(args[2])


@define(19, "directive", 1)
def rule(*args):
  return factory.set(args[1])


@define(26, "atomexpr", 1)
def rule(*args):
  return factory.get(args[1])


@define(28, "atomdir", 2)
def rule(*args):
  return factory.get(args[2])


@define(29, "atomdir", 2)
def rule(*args):
  return factory.call(args[2])


@define(30, "atomdir", 2)
def rule(*args):
  return factory.set(args[2])


@define(31, "atomdir", 2)
def rule(*args):
  return factory.default(args[2])


@define(32, "atomdir", 2)
def rule(*args):
  return factory.insert(args[2])


@define(33, "atomdir", 2)
def rule(*args):
  return factory.include(args[2])


@define(34, "atomdir", 2)
def rule(*args):
  return factory.process(args[2])


@define(35, "atomdir", 2)
def rule(*args):
  return factory.throw(args[2])


@define(36, "atomdir", 1)
def rule(*args):
  return factory.return_()


@define(37, "atomdir", 1)
def rule(*args):
  return factory.stop()


@define(38, "atomdir", 1)
def rule(*args):
  return "output.clear()"


@define(39, "atomdir", 1)
def rule(*args):
  if args[0].infor or args[0].inwhile:
    return "raise Break"
  else:
    return "break"


@define(40, "atomdir", 1)
def rule(*args):
  if args[0].infor:
    return factory.next()
  elif args[0].inwhile:
    return "raise Continue"
  else:
    return "continue"


@define(41, "atomdir", 2)
def rule(*args):
  if args[2][0][0] in ("'on'", "'off'"):
    args[0].debug_dirs = args[2][0][0] == "'on'"
    return factory.debug(args[2])
  else:
    if args[0].debug_dirs:
      return factory.debug(args[2])
    else:
      return ""


@define(44, "condition", 6)
def rule(*args):
  return factory.if_(args[2], args[4], args[5])


@define(45, "condition", 3)
def rule(*args):
  return factory.if_(args[3], args[1])


@define(46, "condition", 6)
def rule(*args):
  return factory.if_("not (%s)" % args[2], args[4], args[5])


@define(47, "condition", 3)
def rule(*args):
  return factory.if_("not (%s)" % args[3], args[1])


@define(48, "else", 5)
def rule(*args):
  args[5].insert(0, [args[2], args[4]])
  return args[5]


@define(49, "else", 3)
def rule(*args):
  return [args[3]]


@define(50, "else", 0)
def rule(*args):
  return [None]


@define(51, "switch", 6)
def rule(*args):
  return factory.switch(args[2], args[5])


@define(52, "case", 5)
def rule(*args):
  args[5].insert(0, [args[2], args[4]])
  return args[5]


@define(53, "case", 4)
def rule(*args):
  return [args[4]]


@define(54, "case", 3)
def rule(*args):
  return [args[3]]


@define(55, "case", 0)
def rule(*args):
  return [None]


@define(56, "@1-3", 0)
def rule(*args):
  retval = args[0].infor
  args[0].infor += 1
  return retval


@define(57, "loop", 6)
def rule(*args):
  args[0].infor -= 1
  return factory.foreach(*(args[2] + [args[5]]))


@define(58, "loop", 3)
def rule(*args):
  return factory.foreach(*(args[3] + [args[1]]))


@define(59, "@2-3", 0)
def rule(*args):
  retval = args[0].inwhile
  args[0].inwhile += 1
  return retval


@define(60, "loop", 6)
def rule(*args):
  args[0].inwhile -= 1
  return factory.while_(args[2], args[5])


@define(61, "loop", 3)
def rule(*args):
  return factory.while_(args[3], args[1])


@define(62, "loopvar", 4)
def rule(*args):
  return [args[1], args[3], args[4]]


@define(63, "loopvar", 4)
def rule(*args):
  return [args[1], args[3], args[4]]


@define(64, "loopvar", 2)
def rule(*args):
  return [0, args[1], args[2]]


@define(65, "wrapper", 5)
def rule(*args):
  return factory.wrapper(args[2], args[4])


@define(66, "wrapper", 3)
def rule(*args):
  return factory.wrapper(args[3], args[1])


@define(67, "try", 5)
def rule(*args):
  return factory.try_(args[3], args[4])


@define(68, "final", 5)
def rule(*args):
  args[5].insert(0, [args[2], args[4]])
  return args[5]


@define(69, "final", 5)
def rule(*args):
  args[5].insert(0, [None, args[4]])
  return args[5]


@define(70, "final", 4)
def rule(*args):
  args[4].insert(0, [None, args[3]])
  return args[4]


@define(71, "final", 3)
def rule(*args):
  return [args[3]]


@define(72, "final", 0)
def rule(*args):
  return [0]


@define(73, "use", 2)
def rule(*args):
  return factory.use(args[2])


@define(74, "@3-3", 0)
def rule(*args):
  return args[0].push_defblock()


@define(75, "view", 6)
def rule(*args):
  return factory.view(args[2], args[5], args[0].pop_defblock())


@define(76, "@4-2", 0)
def rule(*args):
  args[0].inpython += 1


@define(77, "python", 5)
def rule(*args):
  args[0].inpython -= 1
  if args[0].eval_python:
    return factory.python(args[4])
  else:
    return factory.no_python()


@define(78, "@5-1", 0)
def rule(*args):
  global rawstart
  args[0].inpython += 1
  rawstart = args[0].line


@define(79, "rawpython", 5)
def rule(*args):
  args[0].inpython -= 1
  if args[0].eval_python:
    return factory.rawpython(args[4], rawstart)
  else:
    return factory.no_python()


@define(80, "filter", 5)
def rule(*args):
  return factory.filter(args[2], args[4])


@define(81, "filter", 3)
def rule(*args):
  return factory.filter(args[3], args[1])


@define(82, "defblock", 5)
def rule(*args):
  name = "/".join(args[0].defblocks)
  args[0].defblocks.pop()
  args[0].define_block(name, args[4])
  return None


@define(83, "defblockname", 2)
def rule(*args):
  args[0].defblocks.append(unscalar_lex(args[2]))
  return args[2]


@define(85, "blockname", 1)
def rule(*args):
  # FIXME: Should this just be eval(args[1])?
  return re.sub(r"^'(.*)'$", r"\1", args[1])


@define(88, "anonblock", 5)
def rule(*args):
  if args[2]:
    sys.stderr.write("experimental block args: [%s]\n" % ", ".join(args[2]))
  return factory.anon_block(args[4])


@define(89, "capture", 3)
def rule(*args):
  return factory.capture(args[1], args[3])


@define(90, "macro", 6)
def rule(*args):
  return factory.macro(args[2], args[6], args[4])


@define(91, "macro", 3)
def rule(*args):
  return factory.macro(args[2], args[3])


@define(93, "mdir", 4)
def rule(*args):
  return args[3]


@define(94, "margs", 2)
def rule(*args):
  args[1].append(args[2])
  return args[1]


@define(95, "margs", 2)
def rule(*args):
  return args[1]


@define(96, "margs", 1)
def rule(*args):
  return [args[1]]


@define(97, "metadata", 2)
def rule(*args):
  args[1].extend(args[2])
  return args[1]


@define(100, "meta", 3)
def rule(*args):
  return [args[1], unscalar_lex(args[3])]


@define(101, "meta", 5)
def rule(*args):
  return [args[1], args[4]]


@define(102, "meta", 3)
def rule(*args):
  return [args[1], args[3]]


@define(105, "lterm", 3)
def rule(*args):
  return "List(%s)" % args[2]


@define(106, "lterm", 3)
def rule(*args):
  return "List(%s)" % args[2]


@define(107, "lterm", 2)
def rule(*args):
  return "[]"


@define(108, "lterm", 3)
def rule(*args):
  return "Dict(%s)" % args[2]


@define(109, "sterm", 1)
def rule(*args):
  return factory.ident(args[1])


@define(110, "sterm", 2)
def rule(*args):
  return factory.identref(args[2])


@define(111, "sterm", 3)
def rule(*args):
  return factory.quoted(args[2])


@define(114, "list", 2)
def rule(*args):
  return "%s, %s" % (args[1], args[2])


@define(117, "range", 3)
def rule(*args):
  return "xrange(int(%s), int(%s) + 1)" % (args[1], args[3])


@define(119, "hash", 0)
def rule(*args):
  return ""


@define(120, "params", 2)
def rule(*args):
  return "%s, %s" % (args[1], args[2])


@define(123, "param", 3)
def rule(*args):
  return "(%s, %s)" % (args[1], args[3])


@define(124, "param", 3)
def rule(*args):
  return "(%s, %s)" % (args[1], args[3])


@define(125, "ident", 3)
def rule(*args):
  args[1].extend(args[3])
  return args[1]


@define(126, "ident", 3)
def rule(*args):
  for component in str(unscalar_lex(args[3])).split("."):
    args[1].extend((component, 0))
  return args[1]


@define(128, "node", 1)
def rule(*args):
  return [args[1], 0]


@define(129, "node", 4)
def rule(*args):
  return [args[1], factory.args(args[3])]


@define(130, "item", 1)
def rule(*args):
  return repr(args[1])


@define(131, "item", 3)
def rule(*args):
  return args[2]


@define(132, "item", 2)
def rule(*args):
  if args[0].v1dollar:
    return "'%s'" % args[2]
  else:
    return factory.ident(["'%s'" % args[2], 0])


@define(133, "expr", 3)
def rule(*args):
  return "%s %s %s" % (args[1], args[2], args[3])


@define(134, "expr", 3)
def rule(*args):
  return "%s %s %s" % (args[1], args[2], args[3])


@define(135, "expr", 3)
def rule(*args):
  return "%s %s %s" % (args[1], args[2], args[3])


@define(136, "expr", 3)
def rule(*args):
  return "%s // %s" % (args[1], args[3])


@define(137, "expr", 3)
def rule(*args):
  return "%s %% %s" % (args[1], args[3])


@define(138, "expr", 3)
def rule(*args):
  return "%s %s %s" % (args[1], CMPOP[args[2]], args[3])


@define(139, "expr", 3)
def rule(*args):
  return "%s & %s" % (args[1], args[3])


@define(140, "expr", 3)
def rule(*args):
  return "%s and %s" % (args[1], args[3])


@define(141, "expr", 3)
def rule(*args):
  return "%s or %s" % (args[1], args[3])


@define(142, "expr", 2)
def rule(*args):
  return "~%s" % args[2]


@define(143, "expr", 5)
def rule(*args):
  return "%s and 1**%s or %s" % (args[1], args[3], args[5])


@define(144, "expr", 3)
def rule(*args):
  return factory.assign(*args[2])


@define(145, "expr", 3)
def rule(*args):
  return "(%s)" % args[2]


@define(147, "setlist", 2)
def rule(*args):
  args[1].extend(args[2])
  return args[1]


@define(150, "assign", 3)
def rule(*args):
  return [args[1], args[3]]


@define(151, "assign", 3)
def rule(*args):
  return [args[1], args[3]]


@define(152, "args", 2)
def rule(*args):
  args[1].append(args[2])
  return args[1]


@define(153, "args", 2)
def rule(*args):
  args[1][0].append(args[2])
  return args[1]


@define(154, "args", 4)
def rule(*args):
  args[1][0].append("'', %s" % factory.assign(args[2], args[4]))
  return args[1]


@define(155, "args", 2)
def rule(*args):
  return args[1]


@define(156, "args", 0)
def rule(*args):
  return [ [ ] ]


@define(157, "lnameargs", 3)
def rule(*args):
  args[3].append(args[1])
  return args[3]


@define(160, "lvalue", 3)
def rule(*args):
  return factory.quoted(args[2])


@define(162, "nameargs", 3)
def rule(*args):
  return [[factory.ident(args[2])], args[3]]


@define(163, "nameargs", 2)
def rule(*args):
  return [args[1], args[2]]


@define(164, "nameargs", 4)
def rule(*args):
  return [args[1], args[3]]


@define(165, "names", 3)
def rule(*args):
  args[1].append(args[3])
  return args[1]


@define(166, "names", 1)
def rule(*args):
  return [args[1]]


@define(167, "name", 3)
def rule(*args):
  return factory.quoted(args[2])


@define(168, "name", 1)
def rule(*args):
  return "'%s'" % (args[1],)


@define(170, "filename", 3)
def rule(*args):
  return "%s.%s" % (args[1], args[3])


@define(175, "quoted", 2)
def rule(*args):
  if args[2] is not None:
    args[1].append(args[2])
  return args[1]


@define(176, "quoted", 0)
def rule(*args):
  return []


@define(177, "quotable", 1)
def rule(*args):
  return factory.ident(args[1])


@define(178, "quotable", 1)
def rule(*args):
  return factory.text(args[1])


@define(179, "quotable", 1)
def rule(*args):
  return None
