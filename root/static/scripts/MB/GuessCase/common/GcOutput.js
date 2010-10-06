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
| $Id: GcOutput.js 9485 2007-09-30 11:30:27Z luks $
\----------------------------------------------------------------------------*/

/**
 * Holds the output variables
 **/
function GcOutput() {
	mb.log.enter("GcOutput", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "GcOutput";
	this.GID = "gc.o";

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------

	this._w = [];

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Initialise the GcOutput object for another run
	 **/
	this.init = function() {
		this._w = [];
		this._output = "";
	};
	this.toString = function() {
		return this.CN;
	};


	/**
	 * @returns the length
	 **/
	this.getLength = function() {
		return this._w.length;
	};


	/**
	 * @returns if the array is empty
	 **/
	this.isEmpty = function() {
		var f = (this.getLength() == 0);
		return f;
	};

	/**
	 * Fetches the current word from the GcInput
	 * object, and appends it to the wordlist.
	 **/
	this.appendCurrentWord = function() {
		mb.log.enter(this.GID, "appendWord");
		var w;
		if ((w = gc.i.getCurrentWord()) != null) {
			this.appendWord(w);
		}
		mb.log.exit();
	};

	/**
	 * Append the word w to the worlist
	 *
	 * @param w		the word
	 **/
	this.appendWord = function(w) {
		mb.log.enter(this.GID, "appendWord");
		if (w == " ") {
			gc.o.appendSpace();
		} else if (w != "" && w != null) {
			mb.log.debug('Added $ to output.', w);
			this._w[this._w.length] = w;
		}
		mb.log.exit();
	};

	/**
	 * Adds a space to the processed wordslist
	 **/
	this.appendSpace = function() {
		mb.log.enter(this.GID, "appendSpace");
		this._w[this._w.length] = " ";
		mb.log.exit();
	};

	/**
	 * Checks the global flag gc.f.spaceNextWord and adds a space to the
	 * processed wordlist if needed. The flag is *NOT* reset.
	 **/
	this.appendSpaceIfNeeded = function() {
		mb.log.enter(this.GID, "appendSpaceIfNeeded");
		if (gc.f.spaceNextWord) {
			gc.o.appendSpace();
		}
		mb.log.exit();
	};

	/**
	 * Returns the word at the index, or null if index outside bounds
	 **/
	this.getWordAtIndex = function(index) {
		if (this._w[index]) {
			return this._w[index];
		} else {
			return null;
		}
	};

	/**
	 * Returns the word at the index, or null if index outside bounds
	 **/
	this.setWordAtIndex = function(index, word) {
		if (this.getWordAtIndex(index)) {
			this._w[index] = word;
		}
	};

	/**
	 * Returns the last word of the wordlist
	 **/
	this.getLastWord = function() {
		if (!this.isEmpty()) {
			return this._w[this._w.length-1];
		} else {
			return null;
		}
	};

	/**
	 * Returns the last word of the wordlist
	 **/
	this.dropLastWord = function() {
		if (!this.isEmpty()) {
			return this._w.pop();
		}
		return null;
	};

	/**
	 * Capitalize the word at the current cursor position.
	 **/
	this.capitalizeWordAtIndex = function(index, overrideCaps) {
		overrideCaps = (overrideCaps != null ? overrideCaps : gc.f.forceCaps);
		mb.log.enter(this.GID, "capitalizeWordAtIndex");
		if ((!gc.getMode().isSentenceCaps() || overrideCaps) &&
			(!this.isEmpty()) &&
			(this.getWordAtIndex(index) != null)) {

			// don't capitalize last word before puncuation/end of string in sentence mode.
			var w = this.getWordAtIndex(index), o = w;

			// check that last word is NOT an acronym.
			if (w.match(/^\w\..*/) == null) {

				// some words that were manipulated might have space padding
				var probe = gc.u.trim(w.toLowerCase());

				// If inside brackets, do nothing.
				if (!overrideCaps &&
					gc.f.isInsideBrackets() &&
					gc.u.isLowerCaseBracketWord(probe)) {

				// If it is an UPPERCASE word,do nothing.
				} else if (!overrideCaps &&
						    gc.mode.isUpperCaseWord(probe)) {

				// else capitalize the current word.
				} else {
					// rewind pos pointer on input
					var bef = gc.i.getPos(), pos = bef-1;
					while (pos >= 0 && gc.u.trim(gc.i.getWordAtIndex(pos).toLowerCase()) != probe) {
						pos--;
					}
					mb.log.debug("Setting pos on input to $",pos);
					gc.i.setPos(pos);
					o = gc.u.titleString(w, overrideCaps);
					// restore pos pointer on input
					gc.i.setPos(bef);
					if (w != o) {
						this.setWordAtIndex(index, o);
						mb.log.debug('index=$/$, before: $, after: $', index, this.getLength()-1, w, o);
					}
				}
			}
		}
		mb.log.exit();
	};

	/**
	 * Capitalize the word at the current cursor position.
	 * Modifies the last element of the processed wordlist
	 *
	 * @param	overrideCaps	can be used to override
	 *							the gc.f.forceCaps parameter.
	 **/
	this.capitalizeLastWord = function(overrideCaps) {
		mb.log.enter(this.GID, "capitalizeLastWord");
		
		overrideCaps = (overrideCaps != null ? overrideCaps : null);
		mb.log.debug('Capitalizing last word... index: $: overrideCaps: $', this.getLength()-1, overrideCaps);
		this.capitalizeWordAtIndex(this.getLength()-1, overrideCaps);
		
		mb.log.exit();
	};

	/**
	 * Apply post-processing, and return the string
	 **/
	this.getOutput = function() {
		mb.log.enter(this.GID, "getOutput");
		mb.log.debug('Collecting words...');
		
		// if *not* sentence mode, force caps on last word.
		gc.f.forceCaps = !gc.getMode().isSentenceCaps(); 
		this.capitalizeLastWord();
		
		this.closeOpenBrackets();
		var os = gc.u.trim(this._w.join(""));
		return mb.log.exit(os);
	};

	/**
	 * Work through the stack of opened parentheses and close them
	 **/
	this.closeOpenBrackets = function() {
		mb.log.enter(this.GID, "closeOpenBrackets");
		mb.log.debug('Open brackets stack: $', gc.f.openBrackets);
		var parts = new Array();
		while (gc.f.isInsideBrackets()) {
			// close brackets that were opened before
			parts[parts.length] = gc.f.popBracket();
		}
		this.appendWord(parts.join(""));
		mb.log.exit();
	};

	/**
	 * This function checks the wordlist for spaces before
	 * and after the current cursor position, and modifies
	 * the spaces of the input string.
	 *
	 * @param c		configuration wrapper
	 *				c.apply: 	if true, apply changes
	 *				c.capslast: if true, capitalize word before
	 **/
	this.appendWordPreserveWhiteSpace = function(c) {
		if (c) {
			var ws = { before: gc.i.isPreviousWord(" "), after: gc.i.isNextWord(" ") };
			if (c.apply) {
				// do not register method, such that this message appears as
				// it were sent from the calling method.
				mb.log.debug('Consumed #cw, space before: $, after: $', ws.before, ws.after);
				if (c.capslast) {
					this.capitalizeLastWord(true); // capitalize last word before current
				}
				if (ws.before) {
					this.appendSpace();  // preserve whitespace before,
				}
				this.appendCurrentWord(); // append current word
				gc.f.spaceNextWord = (ws.after); // and afterwards as well
			}
			return ws;
		}
		return null;
	};

	// exit constructor
	mb.log.exit();
}