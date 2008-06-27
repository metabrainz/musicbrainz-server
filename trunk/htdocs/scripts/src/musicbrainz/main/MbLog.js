/*----------------------------------------------------------------------------\
|                              Musicbrainz.org                                |
|                 Copyright (c) 2005 Stefan Kestenholz (keschte)              |
|-----------------------------------------------------------------------------|
| This software is provided "as is", without warranty of any kind, express or |
| implied, including  but not limited  to the warranties of  merchantability, |
| fitness for a particular purpose and noninfringement. In no event shall the |
| authors or  copyright  holders be  liable for any claim,  damages or  other |
| liability, whether  in an  action of  contract, tort  or otherwise, arising |
| from,  out of  or in  connection with  the software or  the  use  or  other |
| dealings in the software.                                                   |
| - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - |
| GPL - The GNU General Public License    http://www.gnu.org/licenses/gpl.txt |
| Permits anyone the right to use and modify the software without limitations |
| as long as proper  credits are given  and the original  and modified source |
| code are included. Requires  that the final product, software derivate from |
| the original  source or any  software  utilizing a GPL  component, such  as |
| this, is also licensed under the GPL license.                               |
|                                                                             |
| $Id$
\----------------------------------------------------------------------------*/

/**
 * Logging functionality of the MusicBrainz framework
 **/
function MbLog() {
	mb.log = this;

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "MbLog";
	this.GID = "mb.log";

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------

	/* trace detail level */
	this.TRACE = 0;
	this.DEBUG = 1;
	this.INFO = 2;
	this.WARNING = 3;
	this.ERROR = 4;
	this.LEVEL_DESC = [ "TRACE", "DEBUG", "INFO&nbsp;", "WARN&nbsp;", "ERROR" ];

	/* persistence for _level */
	this.COOKIE_LEVEL = this.CN+".level";

	/* variables which hold the messages/method stacks */
	this._level = this.INFO;
	this._list = [];
	this._stack = [];
	this._start = new Date().getTime();

	/* flag if method names should be listed */
	this.LOG_METHODS = true;

	/* name of the div where the logmessages are written to. */
	this.LOGDIV = "MbLogDiv";

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------


	/**
	 * Read the log level from the cookie, and sets
	 * it if one was found, or the default level INFO.
	 *
	 * @param quiet		if the setLevel method should
	 *					be chatty or not.
	 **/
	this.getLevel = function(quiet) {
		this.enter(this.GID, "getLevel");
		quiet = (quiet || true);
		var cv = mb.cookie.get(this.COOKIE_LEVEL);
		this.setLevel(cv || this.INFO, quiet);
		this.exit();
	};

	/**
	 * Sets the log level to l
	 *
	 * @param l			the new log level
	 * @param quiet		if the method should be chatty or not.
	 **/
	this.setLevel = function(l, quiet) {
		this.enter(this.GID, "setLevel");
		if (l != this._level) {
			if (l >= this.TRACE && l <= this.ERROR) {
				this._level = l;
				if (!quiet) {
					this.info("Changing log level to: $", this.LEVEL_DESC[this._level]);
				}
			}
		} else {
			if (!quiet) {
				this.info("No change, level is: $", this.LEVEL_DESC[this._level]);
			}
		}
		this.exit();
	};

	/**
	 * Check the current set debuglevel (l) to
	 * the given argument
	 **/
	this.onSetLevelClicked = function(level) {
		this.scopeStart("Handling click on loglevel checkbox");
		this.enter(this.GID, "onSetLevelClicked");
		this.setLevel(level);
		mb.cookie.set(this.COOKIE_LEVEL, this._level, 365);
		this.exit();
		this.scopeEnd();
	};

	/**
	 * Check the current set debuglevel (l) to
	 * the given argument
	 **/
	this.checkLevel = function(l) {
		return (l >= this._level);
	};

	/**
	 * Returns true if the logLevel is set to DEBUG
	 **/
	this.isDebugMode = function() {
		this.enter(this.GID, "isDebugMode");
		var f = (this._level == this.DEBUG);
		return this.exit(f);
	};

	/**
	 * Start a new logging scope
	 *
	 * @param	scope	The name of the scope, which
	 *					can be used to separate different
	 *					phases of a function trace.
	 **/
	this.scopeStart = function(scope) {
		var m = this.getMethodFromStack();
		if (mb.isPageLoading && !mb.isPageLoading()) {
			// reset starttime, if an scope is started
			// after the page has loaded.
			this._start = new Date().getTime();
		}
		if (scope) {
			var s = [];
			s.push('<div class="log-scope">');
			s.push(scope);
			s.push((m != " " ? " &nbsp;&mdash;&nbsp; <i>" + m + "</i>" : ''));
			s.push('&#x2026;');
			s.push('</div>');
			this._list.push(s.join(""));
		}
	};

	/**
	 * Writes the list of messages to the LOGDIV.
	 * The list of messages is cleared after they are
	 * written to the document.
	 **/
	this.scopeEnd = function() {
		var obj;
		if (mb.ui) {
			if ((obj = mb.ui.get(this.LOGDIV)) != null) {
				obj.innerHTML = this._list.join("");
			} else {
				this.error("Did not find the LOGDIV!");
			}
		}
		this._list = []; // reset message list
		this._stack = []; // reset method stack
	};

	/**
	 * Returns the list of messages.
	 * The list of message is not cleared.
	 *
	 * @return raw html code
	 **/
	this.getMessages = function() {
		this.enter(this.GID, "getMessages");
		return this.exit(this._list || []);
	};

	/**
	 * Register a ClassName.methodName for debug messages
	 **/
	this.enter = function(className, methodName) {
		this._stack.push([className, methodName]);
		if (this.checkLevel(this.TRACE)) {
			var s = [];
			s.push('<div class="log-enter">');
			s.push(this.getStackIndent());
			s.push('Entering: ');
			var m = this.getMethodFromStack();
			s.push((m != " " ? m : '???'));
			s.push('</div>');
			this._list.push(s.join(""));
		}
	};

	/**
	 * Signal the methods tracker that a method has been left
	 *
	 * @returns the unchanged return value the current method wants to
	 * return to its calling method.
	 **/
	this.exit = function(r) {
		if (this.checkLevel(this.TRACE)) {
			var s = [];
			s.push('<div class="log-exit">');
			s.push(this.getStackIndent());
			s.push('Leaving: &nbsp;');
			var m = this.getMethodFromStack();
			s.push((m != " " ? m : '???'));
			s.push('</div>');
			this._list.push(s.join(""));
		}
		this._stack.pop();
		return r; // return the returnvalue or null.
	};

	/**
	 * Returns a spacer for the methodstack level
	 * indication.
	 **/
	this.getStackIndent = function(s) {
		s = (s || "&nbsp;&nbsp;");
		return (new Array(this._stack.length)).join(s);
	};

	/**
	 * Returns the current method from the method stack.
	 *
	 * @returns the ClassName.methodName string, if
	 * the stack is not empty, else ""
	 **/
	this.getMethodFromStack = function(index) {
		var m = " ";
		if (this._stack.length != 0) {
			index = (index || this._stack.length-1);
			m = this._stack[index];
			m = (m[0] ? m[0]+"." : "") +
				(m[1] ? m[1]+"() " : " ");
		}
		return m;
	};

	/**
	 * Returns the stacktrace.
	 *
	 * @return a list of the method on the stack, each on a new line.
	 **/
	this.getStackTrace = function() {
		this.enter(this.GID, "getStackTrace");
		var s = ["Stacktrace: "];
		for (var i=this._stack.length-1; i>=0; i--) {
			s.push(this.getMethodFromStack(i).replace(/[\s:]*$/, ""));
		}
		s = s.join("\n * ");
		return this.exit(s);
	};

	/**
	 * Wraps a word into a highlight <span>
	 * If the word is an array, it is split and each word
	 * is highlighted by itself, with words separated
	 * by commas [a,b]
	 *
	 * @param w		the object to wrap.
	 * @return raw html code
	 **/
	this.getHighlightHtml = function(w) {
		var s = [];
		var pre = '<span class="log-highlight">';
		var end = '</span>';
		if (mb.utils.isArray(w)) {
			s.push("[");
			s.push(pre);
			s.push(w.join(end+", "+pre));
			s.push(end);
			s.push("]");
		} else {
			if (mb.utils.isString(w)) {
				w = w.replace(/\$/g, "&#36;");
			}
			s.push(pre);
			try {
				s.push(w.toString());
			} catch (ex) {
				s.push(w);
			}
			s.push(end);
		}
		return s.join("");
	};

	/**
	 * Get time, padded to 3 digits
	 **/
	this.getTimeSinceStart = function() {
		var time = (new Date().getTime() - this._start);
		if (time < 10) {
			time = "  "+time;
		} else if (time < 100) {
			time = " "+time;
		} else {
			time = ""+time;
		}
		return time.replace(/\s/g, "&nbsp;");
	};

	/**
	 * Get start of the typewrap html.
	 *
	 * @param level		the type of message to wrap
	 * @return raw html code
	 **/
	this.getMessageStartHtml = function(level) {
		var s = [];
		s.push('<div class="log-level-');
		switch (level) {
			case this.DEBUG: s.push('debug'); break;
			case this.INFO: s.push('info'); break;
			case this.WARNING: s.push('warning'); break;
			case this.ERROR: s.push('error'); break;
		}
		s.push('">');
		s.push(this.getTimeSinceStart());
		s.push("ms - ");
		s.push(this.LEVEL_DESC[level]);
		s.push(" - ");
		return s.join("");
	};

	/**
	 * Get end of the typewrap html.
	 *
	 * @param level		the type of message to wrap
	 * @return raw html code
	 **/
	this.getMessageEndHtml = function(level) {
		return "</div>";
	};

	/**
	 * Returns the HTML code for the debug area.
	 * The level radiobutton-group is set to the current state.
	 *
	 * @return raw html code
	 **/
	this.writeUI = function() {
		this.enter(this.GID, "writeUI");
		this.getLevel(true);
		var s = [];
		s.push('<table class="log-messages">');
		s.push('  <tr><td class="header">');
		s.push('    Set Debug Level: &nbsp;');
		var f = 'mb.log.onSetLevelClicked(this.id)';
		for (var i=0; i<this.LEVEL_DESC.length; i++) {
			s.push('<input name="debuglevel" id="'+i+'" type="radio" ');
			s.push((this._level == i ? ' checked="checked" ' : ''));
			s.push('onClick="'+f+'">'+this.LEVEL_DESC[i]+' &nbsp;');
		}
		s.push('&nbsp; <input type="button" onclick="mb.log.scopeEnd()" value="Dump"/>');
		s.push('  </td></tr>');
		s.push('  <tr><td class="title">');
		s.push('    Log Messages:');
		s.push('  </td></tr>');
		s.push('  <tr><td>');
		s.push('<div id="'+this.LOGDIV+'" class="inner"></td>');
		s.push('</tr>');
		s.push('</table>');
		document.write(s.join(""));
		this.exit();
	};

	/**
	 * Register a trace message.
	 * This message is added to the stack if TRACE level is set.
	 *
	 * @param	arguments	hands any number of arguments over
	 *						to the logMessage method
	 * @see	#logMessage
	 **/
	this.trace = function() {
		if (this.checkLevel(this.TRACE)) {
			this.logMessage(this.TRACE, arguments);
		}
	};
	/**
	 * Register a debug message.
	 * This message is added to the stack if DEBUG level is set.
	 *
	 * @param	arguments	hands any number of arguments over
	 *						to the logMessage method
	 * @see	#logMessage
	 **/
	this.debug = function() {
		if (this.checkLevel(this.DEBUG)) {
			this.logMessage(this.DEBUG, arguments);
		}
	};

	/**
	 * Register an info message.
	 * This message is added to the stack if INFO level is set.
	 *
	 * @param	arguments	hands any number of arguments over
	 *						to the logMessage method
	 * @see	#logMessage
	 **/
	this.info = function() {
		if (this.checkLevel(this.INFO)) {
			this.logMessage(this.INFO, arguments);
		}
	};

	/**
	 * Register a warning message.
	 * This message is added to the stack if WARNING level is set.
	 *
	 * @param	arguments	hands any number of arguments over
	 *						to the logMessage method
	 * @see	#logMessage
	 **/
	this.warning = function() {
		if (this.checkLevel(this.WARNING)) {
			this.logMessage(this.WARNING, arguments);
		}
	};

	/**
	 * Register an error message.
	 * This message is always added to the stack.
	 *
	 * @param	arguments	hands any number of arguments over
	 *						to the logMessage method
	 * @see	#logMessage
	 **/
	this.error = function() {
		if (this.checkLevel(this.ERROR)) {
			this.logMessage(this.ERROR, arguments);
		}
	};

	/**
	 * Adds a new message to the list of messages.
	 *
	 * @param	level	The level of the current message
	 * @param	msg		The message text
	 * @param	0-n		The variables to be replaced in the text.
	 **/
	this.logMessage = function() {
		if (arguments.length != 2) {
			this.enter(this.GID, "logMessage");
			this.error("Expected level, message arguments, but got $ arguments", arguments.length);
			this.exit();
		} else {
			var level = arguments[0];
			var args = arguments[1];
			var msg = "";
			if (args && (msg = args[0]) != null) {
				// replace spaces with non-breaking spaces
				msg = msg.split(" ").join("&nbsp;");
				msg = msg.split(/\n/).join("<br/>");

				// replace #cw with current word.
				if (typeof(gc) != "undefined" &&
				    gc != null && gc.getCurrentWord) {
					var cw;
					if ((cw = gc.getCurrentWord()) != null) {
						msg = msg.replace("#cw", this.getHighlightHtml(cw));
					}
				}

				// replace next-first occurence of $ with current argument.
				if (args.length > 1) {
					for (var i=1; i<args.length;i++) {
						msg = msg.replace(/\$/, this.getHighlightHtml(args[i]));
					}
				}

				// compile message
				var t = [];
				t.push(this.getMessageStartHtml(level));
				if (this.LOG_METHODS) {
					t.push(this.getMethodFromStack());
					t.push(" :: ");
				}
				t.push(msg);
				t.push(this.getMessageEndHtml(level));
				msg = t.join("");
				this._list.push(msg);
			} else {
				this.enter(this.GID, "logMessage");
				this.error("Expected args[0] to be the message, but got null.");
			}
		}
	};

	// get the current level from the cookie,
	// or use default INFO level
	this.getLevel();

	// clean slate, and start logging.
	this.scopeEnd();
	this.scopeStart("Loading the Logging object");
	this.enter(this.GID, "__constructor");
	this.exit();
}