#
#  The Template-Python distribution is Copyright (C) Sean McAfee 2007-2008,
#  derived from the Perl Template Toolkit Copyright (C) 1996-2007 Andy
#  Wardley.  All Rights Reserved.
#
#  The file "LICENSE" at the top level of this source distribution describes
#  the terms under which this file may be distributed.
#

from template.util import Code, chop, unpack, unindent


class Directive:
  def __init__(self, config):
    self.__namespace = config.get("NAMESPACE")

  def template(self, block):
    if not block or block.isspace():
      return "def block(context):\n return ''\n"
    return Code.format(
      "def block(context):",
      Code.indent,
        "stash = context.stash()",
        "output = Buffer()",
        "try:",
        Code.indent,
          block,
        Code.unindent,
        "except Error, e:",
        " error = context.catch(e, output)",
        " if error.type() != 'return':",
        "  raise error",
        "return output.get()")

  def anon_block(self, block):   # [% BLOCK %] ... [% END %]
    return Code.format(
      "def block():",
      Code.indent,
        "output = Buffer()",
        "try:",
        Code.indent,
          block,
        Code.unindent,
        "except Error, e:",
        " error = context.catch(e, output)",
        " if error.type() != 'return':",
        "  raise error",
        "return output.get()",
      Code.unindent,
      "block()")

  def block(self, block=None):
    return "\n".join(block or [])

  def textblock(self, text):
    return "output.write(%s)" % self.text(text)

  def text(self, text):
    return repr(text)

  def quoted(self, items):  # "foo$bar"
    if not items:
      return ""
    else:
      return "Concat(%s)" % ", ".join(items)

  def ident(self, ident):   # foo.bar(baz)
    if ident and len(ident) > 2 and self.__namespace:
      key = ident[0]
      if key.startswith("'") and key.endswith("'"):
        key = key[1:-1]
      ns = self.__namespace.get(key)
      if ns:
        return ns.ident(ident)
    return self.Ident(ident)

  @classmethod
  def Ident(cls, ident):
    if not ident:
      return "''"
    if len(ident) <= 2 and (len(ident) <= 1 or not ident[1]):
      ident = ident[0]
    else:
      ident = "[%s]" % ", ".join(str(x) for x in ident)
    return "stash.get(%s)" % ident

  def identref(self, ident):  # \foo.bar(baz)
    if not ident:
      return "''"
    if len(ident) <= 2 and not ident[1]:
      ident = ident[0]
    else:
      ident = "[%s]" % ", ".join(str(x) for x in ident)
    return "stash.getref(%s)" % ident

  def assign(self, var, val, default=False):  # foo = bar
    if not isinstance(var, str):
      if len(var) == 2 and not var[1]:
        var = var[0]
      else:
        var = "[%s]" % ", ".join(str(x) for x in var)
    if default:
      val += ", 1"
    return "stash.set(%s, %s)" % (var, val)

  def args(self, args):  # foo, bar, baz = qux
    args = list(args)
    hash = args.pop(0)
    if hash:
      args.append("Dict(%s)" % ", ".join(hash))
    if not args:
      return "0"
    else:
      return "[" + ", ".join(args) + "]"

  def filenames(self, names):
    if len(names) > 1:
      names = "[%s]" % ", ".join(names)
    else:
      names = names[0]
    return names

  def get(self, expr):  # [% foo %]
    return "output.write(%s)" % (expr,)

  def call(self, expr):  # [% CALL bar %]
    return expr

  def set(self, setlist):  # [% foo = bar, baz = qux %]
    return "\n".join([self.assign(var, val)
                      for var, val in chop(setlist, 2)])

  def default(self, setlist):   # [% DEFAULT foo = bar, baz = qux %]
    return "\n".join(self.assign(var, val, 1)
                     for var, val in chop(setlist, 2))

  def insert(self, nameargs):  # [% INSERT file %]
    return "output.write(context.insert(%s))" % self.filenames(nameargs[0])

  def include(self, nameargs):   # [% INCLUDE template foo = bar %]
    file, args = unpack(nameargs, 2)
    hash = args.pop(0)
    file = self.filenames(file)
    if hash:
      file += ", Dict(%s)" % ", ".join(hash)
    return "output.write(context.include(%s))" % file

  def process(self, nameargs):  # [% PROCESS template foo = bar %]
    file, args = unpack(nameargs, 2)
    hash = args.pop(0)
    file = self.filenames(file)
    if hash:
      file += ", Dict(%s)" % ", ".join(hash)
    return "output.write(context.process(%s))" % file

  def if_(self, expr, block, else_=None):
    # [% IF foo < bar %] ... [% ELSE %] ... [% END %]
    if else_:
      elses = else_[:]
    else:
      elses = []
    if elses:
      else_ = elses.pop()
    else:
      else_ = None
    code = Code()
    code.write("if %s:" % expr, code.indent, block)
    for expr, block in elses:
      code.write(code.unindent, "elif %s:" % expr,
                 code.indent, block)
    if else_ is not None:
      code.write(code.unindent, "else:", code.indent, else_)
    return code.text()

  def foreach(self, target, list, args, block):
    # [% FOREACH x = [ foo bar ] %] ... [% END %]
    if target:
      loop_save = "oldloop = %s" % (self.ident(["'loop'"]),)
      loop_set = "stash['%s'] = value" % (target,)
      loop_restore = "stash.set('loop', oldloop)"
    else:
      loop_save = "stash = context.localise()"
      loop_set = ("if isinstance(value, dict):\n"
                  " stash.get(['import', [value]])")
      loop_restore = "stash = context.delocalise()"
    return Code.format(
      "def block(stash):",
      Code.indent,
        "oldloop = None",
        "loop = Iterator(%s)" % list,
        loop_save,
        "stash.set('loop', loop)",
        "try:",
        Code.indent,
          "for value in loop:",
          Code.indent,
            "try:",
            Code.indent,
              loop_set,
              block,
            Code.unindent,
            "except Continue:",
            " continue",
            "except Break:",
            " break",
          Code.unindent,
        Code.unindent,
        "finally:",
        Code.indent,
          loop_restore,
        Code.unindent,
      Code.unindent,
      "block(stash)")

  def next(self, *args):
    return "raise Continue"

  def wrapper(self, nameargs, block):  # [% WRAPPER template foo = bar %]
    file, args = unpack(nameargs, 2)
    hash = args.pop(0)
    if len(file) > 1:
      return self.multi_wrapper(file, hash, block)
    file = file[0]
    hash.append("('content', output.get())")
    file += ", Dict(%s)" % ", ".join(hash)
    return Code.format(
      "def block():",
      Code.indent,
        "output = Buffer()",
        block,
        "return context.include(%s)" % file,
      Code.unindent,
      "output.write(block())")

  def multi_wrapper(self, file, hash, block):
    hash.append("('content', output.get())")
    return Code.format(
      "def block():",
      Code.indent,
        "output = Buffer()",
        block,
        "for file in %s:" % ", ".join(reversed(file)),
        " output.reset(context.include(file, Dict(%s)))" % ", ".join(hash),
        "return output.get()",
      Code.unindent,
      "output.write(block())")

  WHILE_MAX = 1000

  def while_(self, expr, block):  # [% WHILE x < 10 %] ... [% END %]
    return Code.format(
      "def block():",
      Code.indent,
        "failsafe = %d" % (self.WHILE_MAX - 1),
        "while failsafe and (%s):" % expr,
        Code.indent,
          "try:",
          Code.indent,
            "failsafe -= 1",
            block,
          Code.unindent,
          "except Continue:",
          " continue",
          "except Break:",
          " break",
        Code.unindent,
        "if not failsafe:",
        " raise Error(None, 'WHILE loop terminated (> %d iterations)')"
          % self.WHILE_MAX,
      Code.unindent,
      "block()")

  def switch(self, expr, cases):  # [% SWITCH %] [% CASE foo %] ... [% END %]
    code = Code()
    code.write("def block():",
               code.indent,
                 "result = Regex(str(%s) + '$')" % expr)
    default = cases.pop()
    for match, block in cases:
      code.write("for match in Switch(%s):" % match,
                 code.indent,
                   "if result.match(str(match)):",
                   code.indent,
                     block,
                     "return",
                   code.unindent,
                 code.unindent)
    if default is not None:
      code.write(default)
    code.write(code.unindent, "block()")
    return code.text()

  def try_(self, block, catches):  # [% TRY %] ... [% CATCH %] ... [% END %]
    handlers = []
    final = catches.pop()
    default = None
    catchblock = Code()
    n = 0

    for catch in catches:
      if catch[0]:
        match = catch[0]
      else:
        if default is None:
          default = catch[1]
        continue
      mblock = catch[1]
      handlers.append("'%s'" % match)
      catchblock.write((n == 0 and "if" or "elif")
                       + " handler == '%s':" % match)
      n += 1
      catchblock.write(catchblock.indent, mblock, catchblock.unindent)
    catchblock.write("error = 0")
    if default:
      default = Code.format("else:", Code.indent, default, "error = ''")
    else:
      default = "# NO DEFAULT"
    handlers = "[%s]" % ", ".join(handlers)

    return Code.format(
      "def block():",
      Code.indent,
        "output = Buffer()",
        "error = None",
        "try:",
        Code.indent,
          block,
        Code.unindent,
        "except Exception, e:",
        Code.indent,
          "error = context.catch(e, output)",
          "if error.type() in ('return', 'stop'):",
          " raise error",
          "stash.set('error', error)",
          "stash.set('e', error)",
          "handler = error.select_handler(%s)" % handlers,
          "if handler:",
          Code.indent,
            catchblock.text(),
          Code.unindent,
          default,
        Code.unindent,
        final,
        "if error:",
        " raise error",
        "return output.get()",
      Code.unindent,
      "output.write(block())")

  def throw(self, nameargs):  # [% THROW foo "bar error" %]
    type, args = nameargs
    if args:
      hash = args.pop(0)
    else:
      hash = None
    if args:
      info = args.pop(0)
    else:
      info = None
    type = type.pop(0)
    if not info:
      info = "None"
    elif hash or args:
      info = "Dict(('args', List(%s)), %s)" % (
        ", ".join([info] + args),
        ", ".join(["(%d, %s)" % pair for pair in enumerate([info] + args)]
                  + hash))
    else:
      pass
    return "context.throw(%s, %s, output)" % (type, info)

  def clear(self):  # [% CLEAR %]
    return "output.clear()"

  def break_(self):  # [% BREAK %]
    return "raise Break"

  def return_(self):  # [% RETURN %]
    return "context.throw('return', '', output)"

  def stop(self):  # [% STOP %]
    return "context.throw('stop', '', output)"

  def use(self, lnameargs):  # [% USE alias = plugin(args) %]
    file, args, alias = unpack(lnameargs, 3)
    file = file[0]
    alias = alias or file
    args = self.args(args)
    if args:
      file = "%s, %s" % (file, args)
    return "stash.set(%s, context.plugin(%s))" % (alias, file)

  def view(self, nameargs, block, defblocks):  # [% VIEW name args %]
    name, args = unpack(nameargs, 2)
    hash = args.pop(0)
    name = name.pop(0)
    if defblocks:
      hash.append("('blocks', dict((%s,)))" % ", ".join("(%r, Document.evaluate(%r, 'block'))" % pair for pair in defblocks.items()))
    return Code.format(
      "def block():",
      Code.indent,
        "output = Buffer()",
        "oldv = stash.get('view')",
        "view = context.view(Dict(%s))" % ", ".join(hash),
        "stash.set(%s, view)" % (name,),
        "stash.set('view', view)",
        block,
        "stash.set('view', oldv)",
        "view.seal()",
      Code.unindent,
      "block()")

  def python(self, block):
    return Code.format(
      "if not context.eval_python():",
      " context.throw('python', 'EVAL_PYTHON not set')",
      "def block():",
      Code.indent,
        "output = Buffer()",
        block,
        "return Evaluate(output.get(), context, stash)",
      Code.unindent,
      "output.write(block())")

  def no_python(self):
    return "context.throw('python', 'EVAL_PYTHON not set')"

  def rawpython(self, block, line):
    line = line and " (starting line %s)" % line or ""
    return "#line 1 'RAWPYTHON block%s'\n%s" % (line, unindent(block))

  def filter(self, lnameargs, block):
    name, args, alias = unpack(lnameargs, 3)
    name = name[0]
    args = self.args(args)
    if alias:
      if args:
        args = "%s, %s" % (args, alias)
      else:
        args = ", None, %s" % alias
    if args:
      name += ", %s" % args
    return Code.format(
      "def block():",
      Code.indent,
        "output = Buffer()",
        "filter = context.filter(%s)" % name,
        block,
        "return filter(output.get())",
      Code.unindent,
      "output.write(block())")

  def capture(self, name, block):
    if isinstance(name, list):
      if len(name) == 2 and not name[1]:
        name = name[0]
      else:
        name = "[" + ", ".join(name) + "]"
    return Code.format(
      "def block():",
      Code.indent,
        "output = Buffer()",
        block,
        "return output.get()",
      Code.unindent,
      "stash.set(%s, block())" % name)

  def macro(self, ident, block, args=None):
    code = Code()
    if args:
      proto = ("arg%d=None" % n for n in range(len(args)))
      params = ("%r: arg%d" % (arg, n) for n, arg in enumerate(args))
      code.write(
        "def block(%s, extra=None):" % ", ".join(proto),
        code.indent,
          "params = { %s }" % ", ".join(params),
          "params.update(extra or {})")
    else:
      code.write(
        "def block(params=None):",
        code.indent,
          "params = params or {}")
    code.write(
      "output = Buffer()",
      "stash = context.localise(params)",
      "try:",
      code.indent,
        block,
      code.unindent,
      "finally:",
      " stash = context.delocalise()",
      "return output.get()")
    code.write(code.unindent, "stash.set(%r, block)" % str(ident))
    return code.text()
