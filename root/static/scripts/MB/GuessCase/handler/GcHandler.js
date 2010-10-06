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
| $Id: GcHandler.js 9484 2007-09-30 11:21:04Z luks $
\----------------------------------------------------------------------------*/

/**
 * Base class of the type specific handlers
 *
 * @see GcArtistHandler
 * @see GcLabelHandler
 * @see GcReleaseHandler
 * @see GcTrackHandler
 */
function GcHandler() {

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "GcHandler";
	this.GID = "gc.base";
	mb.log.enter(this.CN, "__constructor");

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------

	// Values of the specialcases defined in
	this.NOT_A_SPECIALCASE = -1;

	// artist cases
	this.SPECIALCASE_UNKNOWN = 10;		// [unknown]

	// release cases
	this.SPECIALCASE_DATA_TRACK = 20; 	// [data track]

	// track cases
	this.SPECIALCASE_DATA_TRACK = 30; 	// [data track]
	this.SPECIALCASE_SILENCE = 31;		// [silence]
	this.SPECIALCASE_UNTITLED = 32;		// [untitled]
	this.SPECIALCASE_CROWD_NOISE = 33;	// [crowd noise]
	this.SPECIALCASE_GUITAR_SOLO = 34;	// [guitar solo]
	this.SPECIALCASE_DIALOGUE= 35;		// [dialogue]


	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Returns true if the number corresponds to a special case.
	 **/
	this.isSpecialCase = function(num) {
		return (num != this.NOT_A_SPECIALCASE);
	}

	/**
	 * Returns the correctly formatted string of the
	 * special case, or the input string if num
	 * does not correspond to a special case
	 **/
	this.getSpecialCaseFormatted = function(is, num) {
		mb.log.enter(this.GID, "getSpecialCaseFormatted");
		switch (num) {
			case this.SPECIALCASE_DATA_TRACK:
				return mb.log.exit("[data track]");

			case this.SPECIALCASE_SILENCE:
				return mb.log.exit("[silence]");

			case this.SPECIALCASE_UNTITLED:
				return mb.log.exit("[untitled]");

			case this.SPECIALCASE_UNKNOWN:
				return mb.log.exit("[unknown]");

			case this.SPECIALCASE_CROWD_NOISE:
				return mb.log.exit("[crowd noise]");

			case this.SPECIALCASE_GUITAR_SOLO:
				return mb.log.exit("[guitar solo]");

			case this.SPECIALCASE_DIALOGUE:
				return mb.log.exit("[dialogue]");

			case this.NOT_A_SPECIALCASE:
			default:
				return mb.log.exit(is);
		}
	}

	/**
	 * Returns the output string from GuessCaseOutput
	 **/
	this.getOutput = function() {
		var is = gc.o.getOutput();
		var os = this.runPostProcess(is);
		return os;
	};

	/**
	 * Processes the next word from the GuessCaseInput
	 * returns true, if there are more words, else false.
	 **/
	this.processWord = function() {
		mb.log.enter(this.GID, "processWord");
		if (this.doWhiteSpace()) {
		} else {
			// dump information if in debug mode.
			if (mb.log.isDebugMode()) {
				mb.log.scopeStart("Handle next word: "+gc.i.getCurrentWord()+"");
				mb.log.debug("  Index: $/$ Word: #cw", gc.i.getPos(), gc.i.getLength()-1);
				gc.f.dumpRaisedFlags();
			}


			// try to decide if we need to check all the special cases,
			// or if it's possibly just a plain word. this should improve
			// performance a bit, since we don't have to go through all
			// the regex expressions to find that we didn't have to
			// check them.
			var handled = false;
			if (!gc.re.SPECIALCASES) {
				gc.re.SPECIALCASES = /(&|\?|\!|;|:|'|"|\-|\+|,|\*|\.|#|%|\/|\(|\)|\{|\}|\[|\])/;
			}
			if (gc.i.matchCurrentWord(gc.re.SPECIALCASES)) {
				handled = true;
				if (this.doDoubleQuote()) {
				} else if (this.doSingleQuote()) {
				} else if (this.doOpeningBracket()) {
				} else if (this.doClosingBracket()) {
				} else if (this.doComma()) {
				} else if (this.doPeriod()) {
				} else if (this.doLineStop()) {
				} else if (this.doAmpersand()) {
				} else if (this.doSlash()) {
				} else if (this.doColon()) {
				} else if (this.doHyphen()) {
				} else if (this.doPlus()) {
				} else if (this.doAsterix()) {
				} else if (this.doDiamond()) {
				} else if (this.doPercent()) {
				} else {
					handled = false;
				}
			}
			if (!handled) {
				if (this.doDigits()) {
				} else if (this.doAcronym()) {
				} else {
					this.doWord();
				}
			}
		}
		gc.i.nextIndex();
		mb.log.exit();
	};

	/**
	 * Delegate function for Artist/Release/Track specific handlers
	 **/
	this.doWord = function() {};

	/**
	 * Deal with whitespace (\t)
	 * primarily we only look at whitespace for context purposes
	 **/
	this.doWhiteSpace = function() {
		mb.log.enter(this.GID, "doWhiteSpace");
		if (!gc.re.WHITESPACE) {
			gc.re.WHITESPACE = " ";
		}
		if (gc.i.matchCurrentWord(gc.re.WHITESPACE)) {
			gc.f.whitespace = true;
			gc.f.spaceNextWord = true;
			if (gc.f.openingBracket) {
				gc.f.spaceNextWord = false;
			}
			return mb.log.exit(true);
		}
		return mb.log.exit(false);
	};

	/**
	 * Deal with colons (:)
	 * Colons are used as a sub-title split,and also for disc/box name splits
	 **/
	this.doColon = function() {
		mb.log.enter(this.GID, "doColon");
		if (!gc.re.COLON) {
			gc.re.COLON = ":";
		}
		if (gc.i.matchCurrentWord(gc.re.COLON)) {
			mb.log.debug('Handled #cw');

			// capitalize the last word before the colon (it's a line stop)
			// -- handle special case feat. "role" lowercase.
			var featIndex = gc.o.getLength()-3;
			var role;
			if (gc.f.slurpExtraTitleInformation &&
			    featIndex > 0 &&
			    gc.o.getWordAtIndex(featIndex) == "feat." &&
			    (role = gc.o.getLastWord()) != "") {

				gc.o.setWordAtIndex(gc.o.getLength()-1, role.toLowerCase());
			} else {

				// force capitalization of the last word,
				// because we are starting a new subtitle
				gc.o.capitalizeLastWord(true);
			}

			// from next position on, skip spaces and dots.
			var skip = false;
			var pos = gc.i.getPos();
			var len = gc.i.getLength();
			if (pos < len-2) {
				var nword = gc.i.getWordAtIndex(pos+1);
				var naword = gc.i.getWordAtIndex(pos+2);
				if (nword.match(gc.re.OPENBRACKET)) {
					skip = true;
					gc.f.spaceNextWord = true;
				}
				if (gc.i.isNextWord(" ") &&
					naword.match(gc.re.OPENBRACKET)) {
					gc.f.spaceNextWord = true;
					skip = true;
					gc.i.nextIndex();
				}
			}
			if (!skip) {
				// no whitespace before colons
				gc.o.appendCurrentWord();
				gc.f.resetContext();
				gc.f.forceCaps = true;
				gc.f.colon = true;
				gc.f.spaceNextWord = (gc.i.isNextWord(" "));
			}
			return mb.log.exit(true);
		}
		return mb.log.exit(false);
	};

	/**
	 * Deal with asterix (*)
	 **/
	this.doAsterix = function() {
		mb.log.enter(this.GID, "doAsterix");
		if (!gc.re.ASTERIX) {
			gc.re.ASTERIX = "*";
		}
		if (gc.i.matchCurrentWord(gc.re.ASTERIX)) {
			gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: true});
			gc.f.resetContext();
			return mb.log.exit(true);
		}
		return mb.log.exit(false);
	};

	/**
	 * Deal with diamond (#)
	 **/
	this.doDiamond = function() {
		mb.log.enter(this.GID, "doDiamond");
		if (!gc.re.DIAMOND) {
			gc.re.DIAMOND = "#";
		}
		if (gc.i.matchCurrentWord(gc.re.DIAMOND)) {
			gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: true});
			gc.f.resetContext();
			return mb.log.exit(true);
		}
		return mb.log.exit(false);
	};

	/**
	 * Deal with percent signs (%)
	 * TODO: lots of methods for special chars look the same, combine?
	 **/
	this.doPercent = function() {
		mb.log.enter(this.GID, "doPercent");
		if (!gc.re.PERCENT) {
			gc.re.PERCENT = "%";
		}
		if (gc.i.matchCurrentWord(gc.re.PERCENT)) {
			gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: true});
			gc.f.resetContext();
			return mb.log.exit(true);
		}
		return mb.log.exit(false);
	};

	/**
	 * Deal with ampersands (&)
	 **/
	this.doAmpersand = function() {
		mb.log.enter(this.GID, "doAmpersand");
		if (!gc.re.AMPERSAND) {
			gc.re.AMPERSAND = "&";
		}
		if (gc.i.matchCurrentWord(gc.re.AMPERSAND)) {
			mb.log.debug('Handled #cw');
			gc.f.resetContext();
			gc.f.forceCaps = true;
			gc.o.appendSpace(); // add a space,and remember to
			gc.f.spaceNextWord = true; // add one before the next word
			gc.o.appendCurrentWord();
			return mb.log.exit(true);
		}
		return mb.log.exit(false);
	};

	/**
	 * Deal with line terminators (?!;)
	 * (other than the period).
	 **/
	this.doLineStop = function() {
		mb.log.enter(this.GID, "doLineStop");
		if (!gc.re.LINESTOP) {
			gc.re.LINESTOP = /[\?\!\;]/;
		}
		if (gc.i.matchCurrentWord(gc.re.LINESTOP)) {
			mb.log.debug('Handled #cw');
			gc.f.resetContext();

			// force caps on word before the colon, if
			// the mode is not sentencecaps
			gc.o.capitalizeLastWord(!gc.getMode().isSentenceCaps());

			gc.f.forceCaps = true;
			gc.f.spaceNextWord = true;
			gc.o.appendCurrentWord();
			return mb.log.exit(true);
		}
		return mb.log.exit(false);
	};

	/**
	 * Deal with hyphens (-)
	 * if a hyphen has a space near it,then it should be spaced out and treated
	 * similar to a sentence pause,otherwise it's a part of a hyphenated word.
	 * unfortunately it's not practical to implement real em-dashes,however we'll
	 * treat a spaced hyphen as an em-dash for the purposes of caps.
	 **/
	this.doHyphen = function() {
		mb.log.enter(this.GID, "doHyphen");
		if (!gc.re.HYPHEN) {
			gc.re.HYPHEN = "-";
		}
		if (gc.i.matchCurrentWord(gc.re.HYPHEN)) {
			gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: !gc.getMode().isSentenceCaps()});
			gc.f.resetContext();

			// don't capitalize next word after hyphen in sentence mode.
			gc.f.forceCaps = !gc.getMode().isSentenceCaps();
			gc.f.hypen = true;
			return mb.log.exit(true);
		}
		return mb.log.exit(false);
	};

	/**
	 * Deal with plus symbol	(+)
	 **/
	this.doPlus = function() {
		mb.log.enter(this.GID, "doPlus");
		if (!gc.re.PLUS) {
			gc.re.PLUS = "+";
		}
		if (gc.i.matchCurrentWord(gc.re.PLUS)) {
			gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: true});
			gc.f.resetContext();
			return mb.log.exit(true);
		}
		return mb.log.exit(false);
	};

	/**
	 * Deal with slashes (/,\)
	 * If a slash has a space near it, pad it out, otherwise leave as is.
	 **/
	this.doSlash = function() {
		mb.log.enter(this.GID, "doSlash");
		if (!gc.re.SLASH) {
			gc.re.SLASH = /[\\\/]/;
		}
		if (gc.i.matchCurrentWord(gc.re.SLASH)) {
			gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: true});
			gc.f.resetContext();
			gc.f.forceCaps = true;
			return mb.log.exit(true);
		}
		return mb.log.exit(false);
	};

	/**
	 * Deal with double quotes (")
	 **/
	this.doDoubleQuote = function() {
		mb.log.enter(this.GID, "doDoubleQuote");
		if (!gc.re.DOUBLEQUOTE) {
			gc.re.DOUBLEQUOTE = "\"";
		}
		if (gc.i.matchCurrentWord(gc.re.DOUBLEQUOTE)) {

			// changed 05/2006: do not force capitalization before quotes
			gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: false});

			// changed 05/2006: do not force capitalization after quotes
			gc.f.resetContext();
			gc.f.forceCaps = !gc.i.isNextWord(" ");
			return mb.log.exit(true);
		}
		return mb.log.exit(false);
	};

	/**
	 * Deal with single quotes (')
	 * * need to keep context on whether gc.re.inside quotes or not.
	 * * Look for contractions (see contractions_words for a list of
	 *   Contractions that are handled,and format the right part (after)
	 *   the (') as lowercase.
	 **/
	this.doSingleQuote = function() {
		mb.log.enter(this.GID, "doSingleQuote");
		if (!gc.re.SINGLEQUOTE) {
			gc.re.SINGLEQUOTE = "'";
		}
		if (gc.i.matchCurrentWord(gc.re.SINGLEQUOTE)) {
			gc.f.forceCaps = false;
			var a = gc.i.isPreviousWord(" ");
			var b = gc.i.isNextWord(" ");
			var state = gc.f.openedSingleQuote;
			mb.log.debug('Consumed #cw, space before: $, after: $', a, b);

			// preserve whitespace before opening singlequote.
			// -- if it's a "Asdf 'Text in Quotes'"
			if (a && !b) {
				mb.log.debug('Found opening singlequote.', a, b);
				gc.o.appendSpace();
				gc.f.openedSingleQuote = true;
				gc.f.forceCaps = true;

			// preserve whitespace after closing singlequote.
			} else  if (!a && b) {
				if (state) {
					mb.log.debug('Found closing singlequote.', a, b);
					gc.f.forceCaps = true;
					gc.f.openedSingleQuote = false;
				} else {
					mb.log.debug('Found closing singlequote, but none was opened', a, b);
				}
				gc.o.capitalizeLastWord();
			}
			gc.f.spaceNextWord = b; // and keep whitespace intact
			gc.o.appendCurrentWord(); // append current word

			// if there is a space after the ' assume its a closing singlequote
			// do not force capitalization per default, else for "Rollin' on",
			// the "On" will be titled.
			gc.f.resetContext();

			// default, if singlequote state was not modified, is
			// not forcing caps.
			if (state == gc.f.openedSingleQuote) {
				gc.f.forceCaps = false;
			}
			gc.f.singlequote = true;
			return mb.log.exit(true);
		}
		return mb.log.exit(false);
	};

	/**
	 * Deal with opening parenthesis	(([{<)
	 * Knowing whether gc.re.inside parenthesis (and multiple levels thereof) is
	 * important for determining what words should be capped or not.
	 **/
	this.doOpeningBracket = function() {
		mb.log.enter(this.GID, "doOpeningBracket");
		if (!gc.re.OPENBRACKET) {
			gc.re.OPENBRACKET = /[\(\[\{\<]/;
		}
		if (gc.i.matchCurrentWord(gc.re.OPENBRACKET)) {
			mb.log.debug('Handled #cw, stack: $', gc.f.openBrackets);

			// force caps on last word before the opending bracket,
			// if the current mode is not sentence mode.
			gc.o.capitalizeLastWord(!gc.getMode().isSentenceCaps());

			// register current bracket as openening bracket
			gc.f.pushBracket(gc.i.getCurrentWord());
			var cb = gc.f.getCurrentCloseBracket();
			var forcelowercase = false;
			var pos = gc.i.getPos()+1;
			for (var i = pos; i < gc.i.getLength(); i++) {
				var w = (gc.i.getWordAtIndex(i) || "");
				if (w != " ") {
					if ((gc.u.isLowerCaseBracketWord(w)) ||
						(w.match(/^featuring$|^ft$|^feat$/i) != null)) {
						gc.f.slurpExtraTitleInformation = true;
						if (i == pos) {
							forcelowercase = true;
						}
					}
					if (w == cb) {
						break;
					}
				}
			}
			gc.o.appendSpace(); // always space brackets
			gc.f.resetContext();
			gc.f.spaceNextWord = false;
			gc.f.openingBracket = true;
			gc.f.forceCaps = !forcelowercase;
			gc.o.appendCurrentWord();
			gc.f.disc = false;
			gc.f.part = false;
			gc.f.volume = false;
			return mb.log.exit(true);
		}
		return mb.log.exit(false);
	};

	/**
	 * Deal with closing parenthesis	(([{<)
	 * knowing whether gc.re.inside parenthesis (and multiple levels thereof) is
	 * important for determining what words should be capped or not.
	 **/
	this.doClosingBracket = function() {
		mb.log.enter(this.GID, "doClosingBracket");
		if (!gc.re.CLOSEBRACKET) {
			gc.re.CLOSEBRACKET = /[\)\]\}\>]/;
		}
		if (gc.i.matchCurrentWord(gc.re.CLOSEBRACKET)) {
			mb.log.debug('Handled #cw, stack: $', gc.f.openBrackets);

			// capitalize the last word, if forceCaps was
			// set, else leave it like it is.
			gc.o.capitalizeLastWord();

			if (gc.f.isInsideBrackets()) {
				gc.f.popBracket();
				gc.f.slurpExtraTitleInformation = false;
			}
			gc.f.resetContext();
			gc.f.forceCaps = !gc.getMode().isSentenceCaps();
			gc.f.spaceNextWord = true;
			gc.o.appendCurrentWord();
			return mb.log.exit(true);
		}
		return mb.log.exit(false);
	};

	/**
	 * Deal with commas.			(,)
	 * commas can mean two things: a sentence pause,or a number split. We
	 * need context to guess which one it's meant to be, thus the digit
	 * triplet checking later on. Multiple commas are removed.
	 **/
	this.doComma = function() {
		mb.log.enter(this.GID, "doComma");
		if (!gc.re.COMMA) {
			gc.re.COMMA = ",";
		}
		if (gc.i.matchCurrentWord(gc.re.COMMA)) {
			mb.log.debug('Handled #cw');

			// skip duplicate commas.
			if (gc.o.getLastWord() != ",") {

				// capitalize the last word before the colon.
				// -- do words before comma need to be titled?
				// -- see http://bugs.musicbrainz.org/ticket/1317

				// handle comma
				gc.f.resetContext();
				gc.f.spaceNextWord = true;
				gc.f.forceCaps = false;
				gc.o.appendCurrentWord();
			}
			return mb.log.exit(true);
		}
		return mb.log.exit(false);
	};

	/**
	 * Deal with periods.		 (.)
	 * Periods can also mean four things:
	 *   * a sentence break (full stop);
	 *   * a number split in some countries
	 *   * part of an ellipsis (...)
	 *   * an acronym split.
	 * We flag digits and digit triplets in the words routine.
	 **/
	this.doPeriod = function() {
		mb.log.enter(this.GID, "doPeriod");
		if (!gc.re.PERIOD) {
			gc.re.PERIOD = ".";
		}
		if (gc.i.matchCurrentWord(gc.re.PERIOD)) {
			if (gc.o.getLastWord() == ".") {
				if (!gc.f.ellipsis) {
					mb.log.debug('Handled ellipsis');
					gc.o.appendWord("..");
					while (gc.i.isNextWord(".")) {
						gc.i.nextIndex(); // skip trailing (.)
					}
					gc.f.resetContext();
					gc.f.ellipsis = true;
				}
				gc.f.forceCaps = true; // capitalize next word in any case.
				gc.f.spaceNextWord = true;
			} else {
				mb.log.debug('Handled #cw');
				if (!gc.i.hasMoreWords() || gc.i.getNextWord() != ".") {

					// capitalize the last word, if forceCaps was
					// set, else leave it like it is.
					gc.o.capitalizeLastWord();
				}
				gc.o.appendWord(".");
				gc.f.resetContext();
				gc.f.forceCaps = true; // force caps on next word
				gc.f.spaceNextWord = (gc.i.isNextWord(" "));
			}
			return mb.log.exit(true);
		}
		return mb.log.exit(false);
	};

	/**
	 * Check for an acronym
	 **/
	this.doAcronym = function() {
		mb.log.enter(this.GID, "doAcronym");
		if (!gc.re.ACRONYM) {
			gc.re.ACRONYM = /^\w$/;
		}

		// acronym handling was made less strict to
		// fix broken acronyms which look like this: "A. B. C."
		// the variable gc.f.gotPeriod,is used such that such
		// cases do not yield false positives:
		// The method works as follows:
		// "A.B.C. I Love You" 		=> "A.B.C. I Love You"
		// "A. B. C. I Love You" 	=> "A.B.C. I Love You"
		// "A.B.C I Love You" 		=> "A.B. C I Love You"
		// "P.S I Love You" => "P. S I Love You"
		var subIndex, tmp = [];
		if (gc.i.matchCurrentWord(gc.re.ACRONYM)) {
			var cw = gc.i.getCurrentWord();
			tmp.push(cw.toUpperCase()); // add current word
			gc.f.expectWord = false;
			gc.f.gotPeriod = false;
			acronymloop:
			for (subIndex=gc.i.getPos()+1; subIndex<gc.i.getLength(); ) {
				cw = gc.i.getWordAtIndex(subIndex); // remember current word.
				mb.log.debug('Word: $, i: $, expectWord: $, gotPeriod: $', cw, subIndex, gc.f.expectWord, gc.f.gotPeriod);
				if (gc.f.expectWord && cw.match(gc.re.ACRONYM)) {
					tmp.push(cw.toUpperCase()); // do character
					gc.f.expectWord = false;
					gc.f.gotPeriod = false;
				} else {
					if (cw == "." && !gc.f.gotPeriod) {
						tmp[tmp.length] = "."; // do dot
						gc.f.gotPeriod = true;
						gc.f.expectWord = true;
					} else {
						if (gc.f.gotPeriod && cw == " ") {
							gc.f.expectWord = true; // do a single whitespace
						} else {
							if (tmp[tmp.length-1] != ".") {
								tmp.pop(); // loose last of the acronym
								subIndex--; // its for example "P.S. I" love you
							}
							break acronymloop; // found something which is not part of the acronym
						}
					}
				}
				subIndex++;
			}
		}
		if (tmp.length > 2) {
			var s = tmp.join(""); // yes,we have an acronym, get string
			s = s.replace(/(\.)*$/,"."); // replace any number of trailing "." with ". "
			mb.log.debug("Found acronym: $", s);
			gc.o.appendSpaceIfNeeded();
			gc.o.appendWord(s);

			gc.f.resetContext();
			gc.f.acronym = true;
			gc.f.spaceNextWord = true;
			gc.f.forceCaps = false;
			gc.i.setPos(subIndex-1); // set pointer to after acronym
			return mb.log.exit(true);
		}
		return mb.log.exit(false);
	};

	/**
	 * Check for a digit only string
	 **/
	this.doDigits = function() {
		mb.log.enter(this.GID, "doDigits");
		if (!gc.re.DIGITS) {
			gc.re.DIGITS = /^\d+$/;
			gc.re.DIGITS_NUMBERSPLIT = /[,.]/;
			gc.re.DIGITS_DUPLE = /^\d\d$/;
			gc.re.DIGITS_TRIPLE = /^\d\d\d$/;
			gc.re.DIGITS_NTUPLE = /^\d\d\d\d+$/;
		}
		var subIndex=null, tmp = [];
		if (gc.i.matchCurrentWord(gc.re.DIGITS)) {
			tmp.push(gc.i.getCurrentWord());
			gc.f.numberSplitExpect = true;
			numberloop:
			for (subIndex=gc.i.getPos()+1; subIndex<gc.i.getLength(); ) {
				if (gc.f.numberSplitExpect) {
					if (gc.i.matchWordAtIndex(subIndex, gc.re.DIGITS_NUMBERSPLIT)) {
						tmp.push(gc.i.getWordAtIndex(subIndex)); // found a potential number split
						gc.f.numberSplitExpect = false;
					} else {
						break numberloop;
					}
				} else {
					// look for a group of 3 digits
					if (gc.i.matchWordAtIndex(subIndex, gc.re.DIGITS_TRIPLE)) {
						if (gc.f.numberSplitChar == null) {
							gc.f.numberSplitChar = tmp[tmp.length - 1]; // confirmed number split
						}
						tmp.push(gc.i.getWordAtIndex(subIndex));
						gc.f.numberSplitExpect = true;
					} else {
						if (gc.i.matchWordAtIndex(subIndex, gc.re.DIGITS_DUPLE)) {
							if (tmp.length > 2 && gc.f.numberSplitChar != tmp[tmp.length - 1]) {
								// check for the opposite number splitter (,or .)
								// because numbers are generally either
								// 1,000,936.00 or 1.300.402,00 depending on
								// the country
								tmp.push(gc.i.getWordAtIndex(subIndex++));
							} else {
								tmp.pop(); // stand-alone number pair
								subIndex--;
							}
						} else {
							if (gc.i.matchWordAtIndex(subIndex, gc.re.DIGITS_NTUPLE)) {
								// big number at the end,probably a decimal point,
								// end of number in any case
								tmp.push(gc.i.getWordAtIndex(subIndex++));
							} else {
								tmp.pop(); // last number split was not
								subIndex--;	 // actually a number split
							}
						}
						break numberloop;
					}
				}
				subIndex++;
			}
			gc.i.setPos(subIndex-1);
			var number = tmp.join("");
			if (gc.f.disc || gc.f.part || gc.f.volume) {
				// delete leading '0',if last word was a seriesnumberstyle word.
				// e.g. disc 02 -> disc 2
				number = number.replace(/^0*/,"");
			}
			mb.log.debug('Processed number: $', tmp.join(''));

			// add : after disc with number,with more words following
			// only if there is a string which is assumed to be the
			// disc title.
			// e.g. Releasename cd 4 -> Releasename (disc 4)
			// but  Releasename cd 4 the name -> Releasename (disc 4: The Name)
			var addcolon = false;
			if (gc.f.disc || gc.f.volume) {
				var pos = gc.i.getPos();
				if (pos < gc.i.getLength()-2) {
					var nword = gc.i.getWordAtIndex(pos+1);
					var naword = gc.i.getWordAtIndex(pos+2);
					var nwordm = nword.match(/[\):\-&]/);
					var nawordm = naword.match(/[\(:\-&]/);

					// alert(nword+"="+nwordm+"    "+naword+"="+nawordm);
					// only add a colon,if the next word is not ")",":","-","&"
					// and the word after the next is not "-","&","("
					if (nwordm == null && nawordm == null) {
						addcolon = true;
					}
				}
				gc.f.spaceNextWord = true;
				gc.f.forceCaps = true;
			}

			gc.o.appendSpaceIfNeeded();
			gc.o.appendWord(number);

			// clear the flags (for the colon-handling after volume,part
			// added (flawed implementation, but it works i guess)
			// and disc,even if no digit followed (and thus no colon was
			gc.f.resetSeriesNumberStyleFlags();
			gc.f.resetContext();
			if (addcolon) {
				gc.o.appendWord(":");     // if there is no colon already present,add a colon
				gc.f.forceCaps = true;
				gc.f.colon = true;
			} else {
				gc.f.forceCaps = false;
				gc.f.number = true;
			}
			return mb.log.exit(true);
		}
		return mb.log.exit(false);
	};

	/**
	 * Correct vs.
	 **/
	this.doVersusStyle = function() {
		mb.log.enter(this.GID, "doVersusStyle");
		if (!gc.re.VERSUSSTYLE) {
			gc.re.VERSUSSTYLE = "vs";
		}
		if (gc.i.matchCurrentWord(gc.re.VERSUSSTYLE)) {
			mb.log.debug('Found VersusStyle, cw: #cw');

			// capitalize the last word, if forceCaps was
			// set, else leave it like it is.
			gc.o.capitalizeLastWord();

			if (!gc.f.openingBracket) {
				gc.o.appendSpace();
			}
			gc.o.appendWord("vs");
			gc.o.appendWord(".");
			if (gc.i.isNextWord(".")) {
				gc.i.nextIndex(); // skip trailing (.)
			}
			gc.f.resetContext();
			gc.f.forceCaps = true;
			gc.f.spaceNextWord = true;
			return mb.log.exit(true);
		}
		return mb.log.exit(false);
	};

	/**
	 * Handle "Vol","Vol.","Volume" -> ", Volume"
	 **/
	this.doVolumeNumberStyle = function() {
		mb.log.enter(this.GID, "doVolumeNumberStyle");
		if (!gc.re.VOLUMENUMBERSTYLE) {
			gc.re.VOLUMENUMBERSTYLE = /^(volumes|volume)$/i;
		}
		if (gc.i.matchCurrentWord(gc.re.VOLUMENUMBERSTYLE) && gc.i.hasMoreWords()) {
			mb.log.debug('Found VolumeNumberStyle, cw: #cw');
			if (this.doSeriesNumberStyle("Volume")) {
				gc.f.volume = true;
				return mb.log.exit(true);
			}
		}
		return mb.log.exit(false);
	};

	/**
	 * Handle "Pt","Pt.","Part" -> ", Part"
	 **/
	this.doPartNumberStyle = function() {
		mb.log.enter(this.GID, "doPartNumberStyle");
		if (!gc.re.PARTNUMBERSTYLE) {
			gc.re.PARTNUMBERSTYLE = /^(parts|part)$/i;
		}
		if (gc.i.matchCurrentWord(gc.re.PARTNUMBERSTYLE) && gc.i.hasMoreWords()) {
			mb.log.debug('Found possible PartNumberStyle, cw: #cw');
			if (this.doSeriesNumberStyle("Part")) {
				gc.f.part = true;
				return mb.log.exit(true);
			}
		}
		return mb.log.exit(false);
	};

	/**
	 * Do the common work for handleVolume, handlePart
	 **/
	this.doSeriesNumberStyle = function(seriesType) {
		mb.log.enter(this.GID, "doSeriesNumberStyle");

		// from next position on, skip spaces and dots.
		var pos = gc.i.getPos();
		var len = gc.i.getLength();
		var wi = pos+1, si = wi;
		while ((wi < len-1) &&
			   (gc.i.getWordAtIndex(wi).match(gc.re.SPACES_DOTS) != null)) {
			wi++;
		}
		if (si != wi) {
			mb.log.debug('Skipped spaces & dots, index: $->$', si, wi);
		}

		var w = (gc.i.getWordAtIndex(wi) || "");
		mb.log.debug('Attempting to match number/roman numeral, $', w);

		// only do the conversion if ...,(volume|part) is followed
		// by a digit or a roman number
		if (w.match(gc.re.SERIES_NUMBER)) {

			// if no other punctuation char present
			if (gc.i.getPos() >= 1 && !gc.u.isPunctuationChar(gc.o.getLastWord())) {

				// check if there was a hypen (+whitespace) before,and drop it.
				var droppedwords = false;
				while (gc.o.getLength() > 0 &&
					  (gc.o.getLastWord() || "").match(/ |-/i)) {
					gc.o.dropLastWord();
					droppedwords = true;
				}

				// force capitalization of the last word,
				// because we are starting a new styleguideline
				// specialcase (or sentence).
				gc.o.capitalizeLastWord(true);
				gc.o.appendWord(",");

			// capitalize last word before punctuation char.
			} else {
				var pos = gc.o.getLength()-2;
				gc.o.capitalizeWordAtIndex(pos, true);
			}

			// check if we have to add a colon (SubTitleStyle)
			var addcolon = false;
			if (wi < gc.i.getLength()-2) {
				var nword = gc.i.getWordAtIndex(wi+1);
				var naword = gc.i.getWordAtIndex(wi+2);
				var nwordm = nword.match(/[\):\-&,\/]/);
				var nawordm = naword.match(/[\(:\-&,\/]/);

				// alert(nword+"="+nwordm+"    "+naword+"="+nawordm);
				// only add a colon,if the next word is not [ ) : - & / , ]
				// and the word after the next is not [ ) : - & / , ]
				if (nwordm == null && nawordm == null) {
					addcolon = true;
				} else if (seriesType.match(/part|parts/i) &&
						   (nword.match(/,/) || naword.match(/&|-|,|\d+/))) {
					seriesType = "Parts"; // make multiple parts
				}
			}

			// append the current seriestype to output.
			gc.o.appendSpaceIfNeeded();
			gc.o.appendWord(seriesType);

			// add space, and number
			gc.o.appendSpace();
			gc.o.appendWord(w);
			gc.f.resetContext();

			// if there is no colon already present,add a colon
			if (addcolon) {
				gc.o.appendWord(":");
				gc.f.forceCaps = true;
				gc.f.spaceNextWord = true;
				gc.f.colon = true;
			} else {
				gc.f.spaceNextWord = false;
				gc.f.forceCaps = true;
				gc.f.number = true;
			}
 			gc.i.setPos(wi);
			return mb.log.exit(true);
		}
		return mb.log.exit(false);
	};

	/**
	 * correct cd{n},disc{n},disk{n},disque{n} terms
	 **/
	this.doDiscNumberStyle = function() {
		mb.log.enter(this.GID, "doDiscNumberStyle");
		if (!gc.re.DISCNUMBERSTYLE) {
			gc.re.DISCNUMBERSTYLE = /^(Cd|Disk|Discque|Disc)([^\s\d]*)(\s*)(\d*)/i;
		}
		var matcher = null;
		var w = gc.i.getCurrentWord();
		if (!(gc.f.isInsideBrackets() && gc.f.colon) && // do not convert xxx (disc 1: cd) to "...: disc"
			!gc.i.isFirstWord() && // do not convert "cd.." to "Disc..."
			gc.i.hasMoreWords() && // do not convert "cd.." to "Disc..."
			(matcher = w.match(gc.re.DISCNUMBERSTYLE)) != null) {

			// test for disc/disk and variants
			// If first word is not one of "Cd","Disk","Disque","Disc" but i.e. Discography,give up.
			if (matcher[2] != "") {
				return mb.log.exit(false);
			}

			// check if a number is part of the disc title,i.e. Cd2,has to
			// be expanded to Cd-space-2
			mb.log.debug('Attempting to correct DiscNumberStyle, #cw');
			if (matcher[4] != "") {
				var np = matcher[4];
				np = np.replace("^0",""); // delete leading '0',e.g. disc 02 -> disc 2
				mb.log.debug('Expanding #cw to disc $', np);
				gc.i.insertWordsAtIndex(gc.i.getPos()+1, [" ", np]);
					// add space before the number
					// add numeric part
			}

			// from next position on, skip spaces and dots.
			var pos = gc.i.getPos();
			var len = gc.i.getLength();
			var wi = pos+1, si = wi;
			while ((wi < len-1) &&
				   (gc.i.getWordAtIndex(wi).match(gc.re.SPACES_DOTS) != null)) {
				wi++;
			}
			if (si != wi) {
				mb.log.debug('Skipped spaces & dots, index: $->$', si, wi);
			}

			// test for number, or roman numeral
			w = (gc.i.getWordAtIndex(wi) || "");
			mb.log.debug('Attempting to match number/roman numeral $, or bonus_disc', w);
			if (w.match(gc.re.SERIES_NUMBER) || gc.i.getWordAtIndex(pos-2) == "bonus") {
				// delete hypen,or colon if one occurs before
				// disc: e.g. Releasename - Disk1
				// disc: Releasename,Volume 2: cd 1
				var lw = gc.o.getLastWord();
				if (lw == "-" || lw == ":") {
					mb.log.debug('Dropping last word $', lw);
					gc.o.dropLastWord();
				}
				gc.o.appendSpaceIfNeeded();
				if (!gc.f.isInsideBrackets()) {
					// if not inside brackets,open up a new pair.
					mb.log.debug('Opening an new set of brackets');
					gc.i.insertWordAtEnd(")");
					gc.i.updateCurrentWord("(");
					this.doOpeningBracket();
				}
				gc.o.appendWord("disc");

				gc.f.resetContext();
				gc.f.openingBracket = false; // reset bracket flag set by handler
				gc.f.spaceNextWord = false;
				gc.f.forceCaps = false;
				gc.f.number = false;
				gc.f.disc = true;
				return mb.log.exit(true);
			}
		}
		return mb.log.exit(false);
	};

	/**
	 * Detect featuring,f., ft[.], feat[.] and add parentheses as needed.
	 * keschte		2005-11-10		added ^f\.$ to cases
	 * 								which are added converted to feat.
	 * ---------------------------------------------------
	 **/
	this.doFeaturingArtistStyle = function() {
		mb.log.enter(this.GID, "doFeaturingArtistStyle");
		if (!gc.re.FEAT) {
			gc.re.FEAT = /^featuring$|^f$|^ft$|^feat$/i;
			gc.re.FEAT_F = /^f$/i; // match word "f"
		}
		if (gc.i.matchCurrentWord(gc.re.FEAT)) {
			// special case (f.), have to check if next word is a "."
			if ((gc.i.getCurrentWord().match(gc.re.FEAT_F)) &&
				!gc.i.isNextWord(".")) {
				mb.log.debug('Matched f, but next character is not a "."...');
				return mb.log.exit(false);
			}

			// only try to convert to feat. if there are
			// enough words after the keyword
			if (gc.i.getPos() < gc.i.getLength()-2) {

				if (!gc.f.openingBracket && !gc.f.isInsideBrackets()) {
					mb.log.debug('Matched feat., but previous word is not a closing bracket.');

					if (gc.f.isInsideBrackets()) {
						// close open parentheses before the feat. part.
						var closebrackets = new Array();
						while (gc.f.isInsideBrackets()) {
							// close brackets that were opened before
							var cb = gc.f.popBracket();
							gc.o.appendWord(cb);
							if (gc.i.getWordAtIndex(gc.i.getLength()-1) == cb) {
								gc.i.dropLastWord();
								// get rid of duplicate bracket at the end (will be
								// added again by closeOpenBrackets if they wern't
								// closed before (e.g. using feat.)
							}
						}
					}

					// handle case:
					// Blah ft. Erroll Flynn Some Remixname remix
					// -> pre-processor added parentheses such that the string is:
					// Blah ft. erroll flynn Some Remixname (remix)
					// -> now there are parentheses needed before remix, we can't
					//    guess where the artist name ends, and the remixname starts
					//    though :]
					// Blah (feat. Erroll Flynn Some Remixname) (remix)
					var pos = gc.i.getPos();
					var len = gc.i.getLength();
					for (var i = pos; i < len; i++) {
						if (gc.i.getWordAtIndex(i) == "(") {
							break;
						}
					}

					// we got a part, but not until the end of the string
					// close feat. part, and add space to next set of brackets
					if (i != pos && i < len-1) {
						mb.log.debug('Found another opening bracket, closing feat. part');
						gc.i.insertWordsAtIndex(i, [")", " "]);
					}
					gc.i.updateCurrentWord("(");
					this.doOpeningBracket();
				} else {
					gc.o.appendWord(" ");
				}

				// gc.o.appendSpaceIfNeeded();
				gc.o.appendWord("feat.");

				gc.f.resetContext();
				gc.f.forceCaps = true;
				gc.f.openingBracket = false;
				gc.f.spaceNextWord = true;
				gc.f.slurpExtraTitleInformation = true;
				gc.f.feat = true;
				if (gc.i.isNextWord(".")) {
					gc.i.nextIndex();  // skip trailing (.)
				}
				return mb.log.exit(true);
			}
		}
		return mb.log.exit(false);
	};

	// exit constructor
	mb.log.exit();
}
GcHandler.prototype = new GcHandler;
