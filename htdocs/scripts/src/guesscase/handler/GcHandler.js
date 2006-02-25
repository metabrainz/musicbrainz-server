/*----------------------------------------------------------------------------\
|                              Musicbrainz.org                                |
|                 Copyright (c) 2005 Stefan Kestenholz (g0llum)               |
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
|-----------------------------------------------------------------------------|
| 2005-11-10 | First version                                                  |
\----------------------------------------------------------------------------*/

/**
 * Base class of the type specific handlers
 *
 * @see GcArtistHandler
 * @see GcAlbumHandler
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
	// member functions
	// ---------------------------------------------------------------------------

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
			if (this.doColon()) {
			} else if (this.doAmpersand()) {
			} else if (this.doLineStop()) {
			} else if (this.doHyphen()) {
			} else if (this.doPlus()) {
			} else if (this.doComma()) {
			} else if (this.doPeriod()) {
			} else if (this.doAsterix()) {
			} else if (this.doDiamond()) {
			} else if (this.doSlash()) {
			} else if (this.doDoubleQuote()) {
			} else if (this.doSingleQuote()) {
			} else if (this.doOpeningBracket()) {
			} else if (this.doClosingBracket()) {
			} else if (this.doDigits()) {
			} else if (this.doAcronym()) {
			} else {
				this.doWord();
			}
		}
		gc.i.nextIndex();
		mb.log.exit();
	};

	/**
	 * Delegate function for Artist/Album/Track specific handlers
	 **/
	this.doWord = function() {
		/* override me */
	};

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
			gc.f.forceCaps = true;
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
			gc.f.forceCaps = true;
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
			gc.o.capitalizeLastWord();
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
			gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: true});
			gc.f.resetContext();
			if (gc.getMode().isSentenceCaps()) {
				gc.f.forceCaps = false; // don't capitalize next word after hyphen in sentence mode.
			} else {
				gc.f.forceCaps = true;
			}
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
			gc.f.forceCaps = true;
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
			gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: true});
			gc.f.resetContext();
			gc.f.forceCaps = true;
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
			mb.log.debug('Consumed #cw, space before: $, after: $', a, b);
			if (a && !b) {
				// preserve whitespace before, and if it's a "Word 'Text in Quotes'"
				// set forceCaps=true
				mb.log.debug('Found opening singlequote.', a, b);
				gc.o.appendSpace();
				gc.f.forceCaps = true;
				gc.f.openedSingleQuote = true;
			} else  if (!a && b) {
				if (gc.f.openedSingleQuote) {
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
			// do not force capitalization (else Rollin' on,the On gets capitalized.
			gc.f.resetContext();
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
			
			gc.f.forceCaps = true;
			gc.o.capitalizeLastWord(); // force caps on last word

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
			gc.o.capitalizeLastWord(); // capitalize the last word
			if (gc.f.isInsideBrackets()) {
				gc.f.popBracket();
				gc.f.slurpExtraTitleInformation = false;
			}
			gc.f.resetContext();
			gc.f.forceCaps = true;
			gc.f.spaceNextWord = true;
			gc.o.appendCurrentWord();
			return mb.log.exit(true);
		}
		return mb.log.exit(false);
	};

	/**
	 * Deal with commas.			(,)
	 * commas can mean two things: a sentence pause,or a number split. We
	 * need context to guess which one it's meant to be,thus the digit
	 * triplet checking later on. Multiple commas are removed.
	 **/
	this.doComma = function() {
		mb.log.enter(this.GID, "doComma");
		if (!gc.re.COMMA) {
			gc.re.COMMA = ",";
		}
		if (gc.i.matchCurrentWord(gc.re.COMMA)) {
			mb.log.debug('Handled #cw');
			if (gc.o.getLastWord() != ",") {
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
					gc.o.capitalizeLastWord(); // just a normal, boring old period
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
			// e.g. Albumname cd 4 -> Albumname (disc 4)
			// but  Albumname cd 4 the name -> Albumname (disc 4: The Name)
			var addcolon = false;
			if (gc.f.disc || gc.f.part || gc.f.volume) {
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
					} else if (gc.f.part && naword.match(/&|-/)) {
						gc.o.setWordAtIndex(gc.o.getLength()-1, "Parts"); // make multiple parts
					}
				}
				gc.f.disc = false;		// clear the flags (for the colon-handling after volume,part
				gc.f.part = false; 		// and disc,even if no digit followed (and thus no colon was
				gc.f.volume = false; 	// added (flawed implementation, but it works i guess)
				gc.f.spaceNextWord = true;
				gc.f.forceCaps = true;
			}
			gc.o.appendSpaceIfNeeded();
			gc.o.appendWord(number);
			gc.f.forceCaps = false;
			gc.f.number = true;
			if (addcolon) {
				gc.o.appendWord(":");     // if there is no colon already present,add a colon
				gc.f.forceCaps = true;
				gc.f.colon = true;
			}
			return mb.log.exit(true);
		}
		return mb.log.exit(false);
	};

	/**
	 * Pre-process to find any lowercase_bracket word that needs to be put into parantheses.
	 * starts from the back and collects words that belong into
	 * the brackets: e.g.
	 * My Track Extended Dub remix => My Track (extended dub remix)
	 * My Track 12" remix => My Track (12" remix)
	 **/
	this.prepExtraTitleInfo = function(w) {
		mb.log.enter(this.GID, "prepExtraTitleInfo");
		var len = w.length-1, wi = len;
		var handlePreProcess = false;
		var isDoubleQuote = false;
		while (((w[wi] == " ") || // skip whitespace
			   (w[wi] == '"' && (w[wi-1] == "7" || w[wi-1] == "12")) || // vinyl 7" or 12"
			   ((w[wi+1] || "") == '"' && (w[wi] == "7" || w[wi] == "12")) ||
			   (gc.u.isPrepBracketWord(w[wi]))) &&
				wi >= 0) {
			handlePreProcess = true;
			wi--;
		}
		mb.log.debug("Preprocess: $ ($<--$)", handlePreProcess, wi, len);

		// Down-N-Dirty (lastword = dirty)
		// Dance,Dance,Dance (lastword = dance) get matched by the preprocessor,
		// but are a single word which can occur at the end of the string.
		// therefore, we don't put the single word into parens.
		var nextWord = (w[wi+1] || "");
		if ((wi == len-1) &&
			(gc.u.isPrepBracketSingleWord(nextWord))) {
			mb.log.debug('Word found, but its a <i>singleword</i>: $', nextWord);
			handlePreProcess = false;
		}
		if (handlePreProcess && wi > 0 && wi < w.length-1) {
			wi++; // increment to last word that matched.
			var nw = w.slice(0,wi);
			if (nw[wi-1] == "(") { nw.pop(); }
			if (nw[wi-1] == "-") { nw.pop(); }
			nw[nw.length] = "(";
			nw = nw.concat(w.slice(wi,w.length));
			nw[nw.length] = ")";
			w = nw;
			mb.log.debug('Processed ExtraTitleInfo: $', w);
		}
		return mb.log.exit(w);
	};


	/**
	 * Replace unicode special characters with their ascii equivalent
	 * * this function is run before all guess types (artist|album|track)
	 * g0llum		2005-11-10		first version
	 **/
	this.preProcessCommons = function(is) {
		mb.log.enter(this.GID, "preProcessCommons");
		if (!gc.re.PREPROCESS_COMMONS) {
			gc.re.PREPROCESS_COMMONS = [
				new GcFix("D.J. -> DJ", /(\b|^)D\.?J\.?(\s|\)|$)/i, "DJ" ),
				new GcFix("M.C. -> MC", /(\b|^)M\.?C\.?(\s|\)|$)/i, "MC" ),

				// http://unicode.e-workers.de/wgl4.php
				// http://www.cs.sfu.ca/~ggbaker/reference/characters/
				// single quotes

				new GcFix("Backtick &#x0060;", "\u0060", "'"),
				new GcFix("Opening single-quote &#x2018;", "\u2018", "'"),
				new GcFix("Closing single-quote &#x2019;", "\u2019", "'"),
 				new GcFix("Prime &#x2023;", "\u2023", "'"),
				new GcFix("Acute accent &#x0301;", "\u0301", "'"),
				new GcFix("Grave accent &#x0300;", "\u0300", "'"),

				// double quotes
				new GcFix("Opening double-quote &#x201C;", "\u201C", "\""),
				new GcFix("Closing double-quote &#x201D;", "\u201D", "\""),

				// hyphens
				new GcFix("Soft hyphen &#x00AD;", "\u00AD", "-"),
				new GcFix("Closing Hyphen &#x2010;", "\u2010", "-"),
				new GcFix("Non-breaking hyphen &#x2011;", "\u2011", "-"),
				new GcFix("En-dash &#x2013;", "\u2013", "-"),
				new GcFix("Em-dash &#x2014;", "\u2014", "-"),
				new GcFix("hyphen bullet &#x2043;", "\u2043", "-"),
				new GcFix("Minus sign &#x2212;", "\u2212", "-"),

				// ellipsis
				new GcFix("Ellipsis &#x2026;", "\u2026", "...")
			];
		}
		var os = this.runFixes(is, gc.re.PREPROCESS_COMMONS);
		mb.log.debug('After: $', os);
		return mb.log.exit(os);
	};

	/**
	 * Take care of mis-spellings that need to be fixed before
	 * splitting the string into words.
	 * * this function is run before album and track guess types (not for artist)
	 * g0llum		2005-11-10		first version
	 **/
	this.preProcessTitles = function(is) {
		mb.log.enter(this.GID, "preProcessTitles");
		if (!gc.re.PREPROCESS_FIXLIST) {
			gc.re.PREPROCESS_FIXLIST = [
				new GcFix("acapella variants, prepare for postprocess", /(\b|^)a\s?c+ap+el+a(\b)/i, "a_cappella" ), // make a cappella one word, it is expanded in post-processing
				new GcFix("re-mix -> remix", /(\b|^)re-mix(\b)/i, "remix" ),
				new GcFix("remx -> remix", /(\b|^)remx(\b)/i, "remix" ),
				new GcFix("re-mixes -> remixes", /(\b|^)re-mixes(\b)/i, "remixes" ),
				new GcFix("re-make -> remake", /(\b|^)re-make(\b)/i, "remake" ),
				new GcFix("re-makes -> remakes", /(\b|^)re-makes(\b)/i, "remakes" ),
 				new GcFix("re-edit variants, prepare for postprocess", /(\b|^)re-?edit(\b)/i, "re_edit" ),
				new GcFix("RMX -> remix", /(\b|^)RMX(\b)/i, "remix" ),
				new GcFix("alt.take -> alernate take", /(\b|^)alt[\.]? take(\b)/i, "alternate take"),
				new GcFix("instr. -> instrumental", /(\b|^)instr\.?(\b)/i, "instrumental"),
				new GcFix("altern. -> alternate", /(\b|^)altern\.?(\s|\)|$)/i, "alternate" ),
				new GcFix("orig. -> original", /(\b|^)orig\.?(\s|\)|$)/i, "original" ),
				new GcFix("Extendet -> extended", /(\b|^)Extendet(\b)/i, "extended" ),
				new GcFix("extd. -> extended", /(\b|^)ext[d]?\.?(\s|\)|$)/i, "extended" ),
				new GcFix("aka -> a.k.a.", /(\b|^)aka(\b)/i, "a.k.a." ),
				new GcFix("/w -> ft. ", /(\s)[\/]w(\s)/i, "ft." ),
				new GcFix("f. -> ft. ", /(\s)f\.(\s)/i, "ft." ),

				// Handle Part/Volume abbreviations
				new GcFix("Pt. -> Part", /(\b|^)Pt\.?()/i, "Part" ),
				new GcFix("Pts. -> Parts", /(\b|^)Pts\.()/i, "Parts" ),
				new GcFix("Vol. -> Volume", /(\b|^)Vol\.()/i, "Volume" ),

				// Get parts out of brackets
				// Name [Part 1] -> Name, Part 1
				// Name (Part 1) -> Name, Part 1
				// Name [Parts 1] -> Name, Parts 1
				// Name (Parts 1-2) -> Name, Parts 1-2
				// Name (Parts x & y) -> Name, Parts x & y
				new GcFix("(Pt) -> , Part", /((,|\s|:|!)+)([\(\[])?\s*(Part|Pt)[\.\s#]*((\d|[ivx]|[\-&\s])+)([\)\]])?(\s|$)/i, "Part $5" ),
				new GcFix("(Pts) -> , Parts", /((,|\s|:|!)+)([\(\[])?\s*(Parts|Pts)[\.\s#]*((\d|[ivx]|[\-&\s])+)([\)\]])?(\s|$)/i, "Parts $5" ),
				new GcFix("(Vol) -> , Volume", /((,|\s|:|!)+)([\(\[])?\s*(Volume|Vol)[\.\s#]*((\d|[ivx]|[\-&\s])+)([\)\]])?(\s|$)/i, "Volume $5" )
			];
		}
		var os = this.runFixes(is, gc.re.PREPROCESS_FIXLIST);
		mb.log.debug('After pre: $', os);
		return mb.log.exit(os);
	};

	/**
	 * Collect words from processed wordlist and apply minor fixes that
	 * aren't handled in the specific function.
	 **/
	this.runPostProcess = function(is) {
		mb.log.enter(this.GID, "runPostProcess");
		if (!gc.re.POSTPROCESS_FIXLIST) {
			gc.re.POSTPROCESS_FIXLIST = [
				new GcFix("a_cappella outside brackets", /(\b|^)A_cappella(\b)/, "A Cappella"),
				new GcFix("a_cappella inside brackets", /(\b|^)a_cappella(\b)/, "a cappella"),
				new GcFix("re_edit inside brackets", /(\b|^)Re_edit(\b)/, "re-edit"),
				new GcFix("whitespace in R&B", /(\b|^)R\s*&\s*B(\b)/i, "R&B"),
				new GcFix("[live] to (live)", /(\b|^)\[live\](\b)/i, "(live)"),
				new GcFix("Djs to DJs", /(\b|^)Djs(\b)/i, "DJs"),
				new GcFix("a.k.a. lowercase", /(\b|^)a.k.a.(\b)/i, "a.k.a.")
			];
		}
		var os = this.runFixes(is, gc.re.POSTPROCESS_FIXLIST);
		if (is != os) {
			mb.log.debug('After postfixes: $', os); is = os;
		}
		os = this.runVinylChecks(is);
		if (is != os) {
			mb.log.debug('After vinylchecks: $', os);
		}
		return mb.log.exit(os);
	};

	/**
	 * Iterate through the list array and apply the fixes to string is
	 **/
	this.runFixes = function(is, list) {
		mb.log.enter(this.GID, "runFixes");
		var matcher = null;
		var len = list.length;
		for (var i=0; i<len; i++) {
			var f = list[i];
			if (f instanceof GcFix) {
				var fixName = "Replaced " + f.getName();  // name
				var find = f.getRe(); // regular expression/string
				var replace = f.getReplace(); // replace
				// mb.log.debug('Fix type: $', typeof(find)=='string' ? 'string':'regexp');
				if (typeof(find) == 'string' && is.indexOf(find) != -1) {
					mb.log.debug('Applying fix: $ (replace: $)', fixName, replace);
					is = is.replace(find, replace);
				} else if ((matcher = is.match(find)) != null) {
					// get reference to first set of parantheses
					var a = matcher[1]; 
					a = (mb.utils.isNullOrEmpty(a) ? "" : a);

					// get reference to last set of parantheses
					var b = matcher[matcher.length-1];  
					b = (mb.utils.isNullOrEmpty(b) ? "" : b);

					//compile replace string
					var rs = [a,replace,b].join("");
					is = is.replace(find, rs);

					// debug output
					mb.log.debug("Applying fix: $ ...", fixName);
					mb.log.trace("* matcher[$]: $, replace: $, matcher[$]: $ --> $", 1, a, replace, matcher.length-1, b, rs);
					mb.log.trace("* matcher: $", matcher);
					mb.log.trace("After fix: $", is);
				} else {
					// mb.log.debug('Fix $ did not match', fixName);
				}
			} else {
				mb.log.error("Expected GcFix object($/$), got: $", i, len, (f?f.nodeName:"null"));
			}
		}
		return mb.log.exit(is);
	};

	/**
	 * Take care of (bonus],(bonus track)
	 **/
	this.stripInformationToOmit = function(is) {
		mb.log.enter(this.GID, "stripInformationToOmit");
		if (!gc.re.PREPROCESS_STRIPINFOTOOMIT) {
			gc.re.PREPROCESS_STRIPINFOTOOMIT = [
				new GcFix("Trim 'bonus (track)?'", /[\(\[]?bonus(\s+track)?s?\s*[\)\]]?$/i, ""),
				new GcFix("Trim 'retail (version)?'", /[\(\[]?retail(\s+version)?\s*[\)\]]?$/i, "")
			];
		}
		var os = is, list = gc.re.PREPROCESS_STRIPINFOTOOMIT;
		for (var i=list.length-1; i>=0; i--) {
			var matcher = null;
			var listItem = list[i];
			var fixName = "Replaced " + listItem.getName();  // name
			var find = listItem.getRe(); // regular expression/string
			var replace = listItem.getReplace(); // replace
			if ((matcher = os.match(find)) != null) {
				os = os.replace(find, replace);
				mb.log.debug("Done fix: $", fixName);
			}
		}
		if (is != os) {
			mb.log.debug('After strip info: $', os);
		}
		return mb.log.exit(os);
	};

	/**
	 * Look for, and convert vinyl expressions
	 * * look only at substrings which start with ' '  OR '('
	 * * convert 7',7'',7",7in,7inch TO '7"_' (with a following SPACE)
	 * * convert 12',12'',12",12in,12inch TO '12"_' (with a following SPACE)
	 * * do NOT handle strings like 80's
	 * Examples:
	 *  Original string: "Fine Day (Mike Koglin 12' mix)"
	 *  	Last matched portion: " 12' "
	 *  	Matched portion 1 = " "
	 *  	Matched portion 2 = "12'"
	 *  	Matched portion 3 = "12"
	 *  	Matched portion 4 = "'"
	 *  	Matched portion 5 = " "
	 *  Original string: "Where Love Lives (Come on In) (12"Classic mix)"
	 *  	Last matched portion: "(12"C"
	 *  	Matched portion 1 = "("
	 *  	Matched portion 2 = "12""
	 *  	Matched portion 3 = "12"
	 *  	Matched portion 4 = """
	 *  	Matched portion 5 = "C"
	 *  Original string: "greatest 80's hits"
	 * 		Match failed.
	 **/
	this.runVinylChecks = function(is) {
		mb.log.enter(this.GID, "runVinylChecks");
		if (!gc.re.VINYL) {
			gc.re.VINYL = /(\s+|\()((\d+)[\s|-]?(inch\b|in\b|'+|"))([^s]|$)/i;
		}
		var matcher = null, os = is;
		if ((matcher = is.match(gc.re.VINYL)) != null) {
			var mindex = matcher.index;
			var mlenght  = matcher[1].length + matcher[2].length + matcher[5].length; // calculate the length of the expression
			var firstPart = is.substring(0,mindex);
			var lastPart = is.substring(mindex+mlenght,is.length); // add number
			var parts = new Array(); // compile the vinyl designation.
			parts[parts.length] = firstPart;
			parts[parts.length] = matcher[1]; // add matched first expression (either ' ' or '('
			parts[parts.length] = matcher[3]; // add matched number,but skip the in,inch,'' part
			parts[parts.length] = '"'; // add vinyl doubleqoute
			parts[parts.length] = (matcher[5] != " " && matcher[5] != ")" && matcher[5] != "," ? " " : ""); // add space after ",if none is present and next character is not ")" or ","
			parts[parts.length] = matcher[5]; // add first character of next word / space.
			parts[parts.length] = lastPart; // add rest of string
			os = parts.join("");
		}
		return mb.log.exit(is);
	};

	/**
	 * Correct vs.
	 **/
	this.doVersusStyle = function() {
		mb.log.enter(this.GID, "handleVersus");
		if (!gc.re.VERSUSSTYLE) {
			gc.re.VERSUSSTYLE = "vs";
		}
		if (gc.i.matchCurrentWord(gc.re.VERSUSSTYLE)) {
			mb.log.debug('Found VersusStyle, cw: #cw');
			gc.o.capitalizeLastWord();
			if (!gc.f.openingBracket) {
				gc.o.appendSpace();
			}
			gc.o.appendWord("vs");
			gc.o.appendWord(".");
			if (gc.i.isNextWord(".")) {
				gc.i.nextIndex(); // skip trailing (.)
			}
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
		if (w.match(gc.re.SERIES_NUMBER)) {
			// only do the conversion if ...,(volume|part) is followed
			// by a digit or a roman number
			if (gc.i.getPos() >= 2 && !gc.u.isPunctuationChar(gc.o.getLastWord())) {
				// if no other punctuation char present
				while (gc.o.getLength() > 0 &&
					  (gc.o.getLastWord() || "").match(/ |-/i)) {
					// check if there was a hypen (+whitespace) before,and drop it.
					gc.o.dropLastWord();
				}
				gc.o.capitalizeLastWord(); // capitalize last word before comma.
				gc.o.appendWord(",");
			} else {
				// capitalize last word before punctuation char.
				gc.o.capitalizeWordAtIndex(gc.o.getLength()-2);
			}

			gc.o.appendSpaceIfNeeded();
			gc.o.appendWord(seriesType);
			gc.f.number = true;
			gc.f.spaceNextWord = false;
			gc.f.forceCaps = true;

			// check if we have to add a colon (SubTitleStyle)
			var addcolon = false;
			if (wi < gc.i.getLength()-2) {
				var nword = gc.i.getWordAtIndex(wi+1);
				var naword = gc.i.getWordAtIndex(wi+2);
				var nwordm = nword.match(/[\):\-&\/]/);
				var nawordm = naword.match(/[\(:\-&\/]/);
				// alert(nword+"="+nwordm+"    "+naword+"="+nawordm);
				// only add a colon,if the next word is not ")",":","-","&","/"
				// and the word after the next is not "-","&","(","/"
				if (nwordm == null && nawordm == null) {
					addcolon = true;
				} else if (seriesType == "Part" && naword.match(/&|-/)) {
					gc.o.setWordAtIndex(gc.o.getLength()-1, "Parts"); // make multiple parts
				}
			}
			// add space, and number
			gc.o.appendSpace();
			gc.o.appendWord(w);
			if (addcolon) {
				gc.o.appendWord(":");     // if there is no colon already present,add a colon
				gc.f.forceCaps = true;
				gc.f.spaceNextWord = true;
				gc.f.number = false;
				gc.f.colon = true;
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
				// disc: e.g. Albumname - Disk1
				// disc: Albumname,Volume 2: cd 1
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
	 * Detect featuring,f., ft[.], feat[.] and add parantheses as needed.
	 * g0llum		2005-11-10		added ^f\.$ to cases
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
			if (!gc.f.openingBracket) {
				mb.log.debug('Matched feat., but previous word is not a closing bracket.');
				if (gc.f.isInsideBrackets()) {
					// close open parantheses before the feat. part.
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
				// -> pre-processor added parantheses such that the string is:
				// Blah ft. erroll flynn Some Remixname (remix)
				// -> now there are parantheses needed before remix, we can't
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
			}
			gc.o.appendWord("feat.");
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
		return mb.log.exit(false);
	};

	// exit constructor
	mb.log.exit();
}
GcHandler.prototype = new GcHandler;