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
 * Holds the state of the current GC operation
 */
function GcFlags() {
	mb.log.enter("GcFlags", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "GcFlags";
	this.GID = "gc.f";

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Reset the context
	 **/
	this.resetContext = function() {
		mb.log.enter(this.GID, "resetContext");
		this.whitespace = false;
		this.openingBracket = false;
		this.hypen = false;
		this.colon = false;
		this.acronym_split = false;
		this.singlequote = false;
		this.ellipsis = false;
		mb.log.exit();
	};

	/**
	 * Reset the variables for the SeriesNumberStyle
	 **/
	this.resetSeriesNumberStyleFlags = function() {
		this.disc = false; // flag is used for the detection of SeriesStyles
		this.part = false;
		this.volume = false;
		this.feat = false;
	};


	/**
	 * Reset the variables for the processed string
	 **/
	this.resetOutputFlags = function() {
		// flag to force next to caps first letter.
		// seeded true because the first word is always capped
		this.forceCaps = true;
 		// flag to force a space before the next word
		this.spaceNextWord = false;
	};

	/**
	 * Reset the open/closed bracket variables
	 **/
	this.resetBrackets = function() {
		this.openBrackets = new Array();
		this.slurpExtraTitleInformation = false;
	};

	/**
	 * Returns if there are opened brackets at current position
	 * in the string.
	 **/
	this.isInsideBrackets = function() {
		return (this.openBrackets.length > 0);
	};
	this.pushBracket = function(b) {
		this.openBrackets.push(b);
	};
	this.popBracket = function(b) {
		if (this.openBrackets.length == 0) {
			return null;
		} else {
			var cb = this.getCurrentCloseBracket();
			this.openBrackets.pop();
			return cb;
		}
	};
	this.getOpenedBracket = function(b) {
		if (this.openBrackets.length == 0) {
			return null;
		} else {
			return this.openBrackets[this.openBrackets.length-1];
		}
	};
	this.getCurrentCloseBracket = function() {
		var ob;
		if ((ob = this.getOpenedBracket()) != null) {
			return gc.u.getCorrespondingBracket(ob);
		}
		return null;
	};

	/**
	 * Initialise GcFlags object for another run
	 **/
	this.init = function() {
		this.resetOutputFlags();
		this.resetBrackets();
		this.resetContext();
		this.resetSeriesNumberStyleFlags();
		this.acronym = false; // flag so we know not to lowercase acronyms if followed by major punctuation
		this.number = false; // flag is used for the number splitting routine (ie: 10,000,000)

		// defines the current number split. note that this will not be cleared, which
		// has the side-effect of forcing the first type of number split encountered
		// to be the only one used for the entire string,assuming that people aren't
		// going to be mixing grammar in titles.
		this.numberSplitChar = null;
		this.numberSplitExpect = false;
	};

	/**
	 * Returns all the flags that are different that the initial value.
	 **/
	this.dumpRaisedFlags = function() {
		var s = this.toString();
		if (s != "") {
			mb.log.debug("Current flags: [$]", s);
		} else {
			mb.log.debug("No specific flags set!");
		}
	};

	/**
	 * Returns all the flags that are different that the initial value.
	 **/
	this.toString = function() {
		var dump = [];
		var nl = ", ";
		if (!gc.fdef) {
			gc.fdef = new GcFlags();
			gc.fdef.init();
		}
		if (!gc.i.isFirstWord() && this.forceCaps == gc.fdef.forceCaps) {
			// special case, forceCaps is usually false after first word,
			// which is seeded true.
			dump.push(nl);
			dump.push("forceCaps="+this.forceCaps);
		}
		if (!gc.i.isFirstWord() && this.spaceNextWord == gc.fdef.spaceNextWord) {
			// special case, spaceNextWord is usually true after first word,
			// which is seeded false.
			dump.push(nl);
			dump.push("spaceNextWord="+this.spaceNextWord);
		}
		if (this.whitespace != gc.fdef.whitespace) {
			dump.push(nl);
			dump.push("whitespace="+this.whitespace);
		}
		if (this.openingBracket != gc.fdef.openingBracket) {
			dump.push(nl);
			dump.push("openingBracket="+this.openingBracket);
		}
		if (this.hypen != gc.fdef.hypen) {
			dump.push(nl);
			dump.push("hypen="+this.hypen);
		}
		if (this.colon != gc.fdef.colon) {
			dump.push(nl);
			dump.push("colon="+this.colon);
		}
		if (this.acronym_split != gc.fdef.acronym_split) {
			dump.push(nl);
			dump.push("acronym_split="+this.acronym_split);
		}
		if (this.singlequote != gc.fdef.singlequote) {
			dump.push(nl);
			dump.push("singlequote="+this.singlequote);
		}
		if (this.ellipsis != gc.fdef.ellipsis) {
			dump.push(nl);
			dump.push("ellipsis="+this.ellipsis);
		}
		if (this.disc != gc.fdef.disc) {
			dump.push(nl);
			dump.push("disc="+this.disc);
		}
		if (this.part != gc.fdef.part) {
			dump.push(nl);
			dump.push("part="+this.part);
		}
		if (this.volume != gc.fdef.volume) {
			dump.push(nl);
			dump.push("volume="+this.volume);
		}
		if (this.feat != gc.fdef.feat) {
			dump.push(nl);
			dump.push("feat="+this.feat);
		}
		if (dump.length > 1) {
			dump[0] = null;
		} else {
			dump = [];
		}
		return dump.join("");
	};

	// exit constructor
	mb.log.exit();
}
