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
| $Id: GcInput.js 7536 2006-05-12 23:31:35Z keschte $
\----------------------------------------------------------------------------*/

/**
 * Holds the input variables
 **/
function GcInput() {
	mb.log.enter("GcInput", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "GcInput";
	this.GID = "gc.i";

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------
	this._source = "";
	this._w = [];
	this._l = 0;
	this._wi = 0;

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Initialise the GcInput object
	 **/
	this.init = function(is, w) {
		mb.log.enter(this.GID, "init");
		mb.log.debug('words: $', w);
		this._source = (is || "");
		this._w = (w || []);
		this._l = this._w.length;
		this._wi = 0;
		mb.log.exit();
	};
	this.toString = function() {
		return this.CN+' ['+this._w.join(",")+']';
	};

	/**
	 * Returns the length of the wordlist
	 **/
	this.getLength = function() {
		return this._l;
	};

	/**
	 * Returns true if the lenght==0
	 **/
	this.isEmpty = function() {
		var f = (this.getLength() == 0);
		return f;
	};

	/**
	 * Get the cursor position
	 **/
	this.getPos = function() {
		return this._wi;
	};

	/**
	 * Set the cursor to a new position
	 **/
	this.setPos = function(index) {
		if (index >= 0 && index < this.getLength()) {
			this._wi = index;
		}
	};

	/**
	 * Accessors for strings at certain positions.
	 **/
	this.getWordAtIndex = function(index) {
		return (this._w[index] || null);
	};
	this.getNextWord = function() {
		return this.getWordAtIndex(this._wi+1);
	};
	this.getCurrentWord = function() {
		return this.getWordAtIndex(this._wi);
	};
	this.getPreviousWord = function() {
		return this.getWordAtIndex(this._wi-1);
	};

	/**
	 * Test methods
	 **/
	this.isFirstWord = function() {
		return (0 == this._wi);
	};
	this.isLastWord = function() {
		return (this.getLength() == this._wi-1);
	};
	this.isNextWord = function(s) {
		return (this.hasMoreWords() && this.getNextWord() == s);
	};
	this.isPreviousWord = function(s) {
		return (!this.isFirstWord() && this.getPreviousWord() == s);
	};

	/**
	 * Match the word at the current index against the
	 * regular expression or string given
	 **/
	this.matchCurrentWord = function(re) {
		mb.log.enter(this.GID, "matchCurrentWord");
		var f = (this.matchWordAtIndex(this.getPos(), re));
		return mb.log.exit(f);
	};

	/**
	 * Match the word at index wi against the
	 * regular expression or string given
	 **/
	this.matchWordAtIndex = function(index, re) {
		mb.log.enter(this.GID, "matchWordAtIndex");
		var cw = (this.getWordAtIndex(index) || "");
		var f;
		if (mb.utils.isString(re)) {
			f = (re == cw);
			if (f) {
				mb.log.debug('Matched w: $ at index: $, string: $', cw, index, re);
			}
		} else {
			f = (cw.match(re) != null);
			if (f) {
				mb.log.debug('Matched w: $ at index: $, re: $', cw, index, re);
			}
		}
		return mb.log.exit(f);
	};

	/**
	 * Index methods
	 **/
	this.hasMoreWords = function() {
		return (this._wi == 0 && this.getLength() > 0 || this._wi-1 < this.getLength());
	};
	this.isIndexAtEnd = function() {
		return (this._wi == this.getLength());
	};
	this.nextIndex = function() {
		this._wi++;
	};

	/**
	 * Returns the last word of the wordlist
	 **/
	this.dropLastWord = function() {
		if (this.getLength() > 0) {
			this._w.pop();
			if (this.isIndexAtEnd()) {
				this._wi--;
			}
		}
	};

	/**
	 * Capitalize the word at the current position
	 **/
	this.insertWordsAtIndex = function(index, w) {
		mb.log.enter(this.GID, "insertWordsAtIndex");
		var part1 = this._w.slice(0,index);
		var part2 = this._w.slice(index, this._w.length);
		this._w = part1.concat(w).concat(part2);
		this._l = this._w.length;
		mb.log.debug('Inserted $ at index $', w, index);
		mb.log.exit();
	};

	/**
	 * Capitalize the word at the current position
	 **/
	this.capitalizeCurrentWord = function() {
		mb.log.enter(this.GID, "capitalizeCurrentWord");
		var w;
		if ((w = this.getCurrentWord()) != null) {
			var o = gc.u.titleString(w);
			if (w != o) {
				this.updateCurrentWord(o);
				mb.log.debug('Before: $, After: $', w, o);
			}
			return mb.log.exit(o);
		} else {
			mb.log.error('Attempted to modify currentWord, but it is null!');
		}
		return mb.log.exit(null);
	};

	/**
	 * Update the word at the current position
	 **/
	this.updateCurrentWord = function(o) {
		mb.log.enter(this.GID, "updateCurrentWord");
		var w = this.getCurrentWord();
		if (w != null) {
			this._w[this._wi] = o;
		} else {
			mb.log.error('Attempted to modify currentWord, but it is null!');
		}
		mb.log.exit();
	};

	/**
	 * Insert a word at the end of the wordlist
	 **/
	this.insertWordAtEnd = function(w) {
		mb.log.enter(this.GID, "insertWordAtEnd");
		mb.log.debug('Added word $ at the end', w);
		this._w[this._w.length] = w;
		this._l++;
		mb.log.exit();
	};

	/**
	 * This function returns an array of all the words, punctuation and
	 * spaces of the input string
	 *
	 * Before splitting the string into the different candidates,the following actions are taken:
	 *  * remove leading and trailing whitespace
	 *  * compress whitespace,e.g replace all instances of multiple space with a single space
	 * @param	 	is the un-processed input string
	 * @returns		sets the GLOBAL array of words and puctuation characters
	 **/
	this.splitWordsAndPunctuation = function(is) {
		mb.log.enter(this.GID, "splitWordsAndPunctuation");
		is = is.replace(/^\s\s*/,""); // delete leading space
		is = is.replace(/\s\s*$/,""); // delete trailing space
		is = is.replace(/\s\s*/g," "); // compress whitespace:
		var chars = is.split("");
		var splitwords = [];
		var word = [];
		if (!gc.re.SPLITWORDSANDPUNCTUATION) {
			gc.re.SPLITWORDSANDPUNCTUATION = /[^!\"%&'´`()\[\]\{\}\*\+,-\.\/:;<=>\?\s#]/;
		}
		for (var i=0; i<chars.length; i++) {
			if (chars[i].match(gc.re.SPLITWORDSANDPUNCTUATION)) {
				// see http://www.codingforums.com/archive/index.php/t-49001
				// for reference (escaping the sequence)
				word.push(chars[i]); // greedy match anything except our stop characters
			} else {
				if (word.length > 0) {
					splitwords.push(word.join(""));
				}
				splitwords.push(chars[i]);
				word = [];
			}
		}
		if (word.length > 0) {
			splitwords.push(word.join(""));
		}
		mb.log.debug('words: $', splitwords);
		return mb.log.exit(splitwords);
	};

	// exit constructor
	mb.log.exit();
}
