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
 * Artist specific GuessCase functionality
 **/
function GcArtistHandler() {
	mb.log.enter("GcArtistHandler", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "GcArtistHandler";
	this.GID = "gc.artist";

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------
	this.UNKNOWN = "[unknown]";
	this.NOARTIST = "[unknown]";

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Guess the artist name given in string is, and
	 * returns the guessed name.
	 *
	 * @param	is		the inputstring
	 * @returns os		the processed string
	 **/
	this.process = function(is) {
		mb.log.enter(this.GID, "process");
		is = gc.artistmode.preProcessCommons(is);
		var w = gc.i.splitWordsAndPunctuation(is);
		gc.o.init();
		gc.i.init(is, w);
		while (!gc.i.isIndexAtEnd()) {
			this.processWord();
			mb.log.debug("Output: $", gc.o._w);
		}
		var os = gc.o.getOutput();
		os = gc.artistmode.runPostProcess(os);
		return mb.log.exit(os);
	};


	/**
	 * Checks special cases of artists
	 * - empty, unknown -> [unknown]
 	 * - none, no artist, not applicable, n/a -> [no artist]
	 **/
	this.checkSpecialCase = function(is) {
		mb.log.enter(this.GID, "checkSpecialCase");
		if (is) {
			if (!gc.re.ARTIST_EMPTY) {
				// match empty
				gc.re.ARTIST_EMPTY = /^\s*$/i;
				// match "unknown" and variants
				gc.re.ARTIST_UNKNOWN = /^[\(\[]?\s*Unknown\s*[\)\]]?$/i;
				// match "none" and variants
				gc.re.ARTIST_NONE = /^[\(\[]?\s*none\s*[\)\]]?$/i;
				// match "no artist" and variants
				gc.re.ARTIST_NOARTIST = /^[\(\[]?\s*no[\s-]+artist\s*[\)\]]?$/i;
				// match "not applicable" and variants
				gc.re.ARTIST_NOTAPPLICABLE = /^[\(\[]?\s*not[\s-]+applicable\s*[\)\]]?$/i;
				// match "n/a" and variants
				gc.re.ARTIST_NA = /^[\(\[]?\s*n\s*[\\\/]\s*a\s*[\)\]]?$/i;
			}
			var os = is;
			if (is.match(gc.re.ARTIST_EMPTY)) {
				return mb.log.exit(this.SPECIALCASE_UNKNOWN);

			} else if (is.match(gc.re.ARTIST_UNKNOWN)) {
				return mb.log.exit(this.SPECIALCASE_UNKNOWN);

			} else if (is.match(gc.re.ARTIST_NONE)) {
				return mb.log.exit(this.SPECIALCASE_UNKNOWN);

			} else if (is.match(gc.re.ARTIST_NOARTIST)) {
				return mb.log.exit(this.SPECIALCASE_UNKNOWN);

			} else if (is.match(gc.re.ARTIST_NOTAPPLICABLE)) {
				return mb.log.exit(this.SPECIALCASE_UNKNOWN);

			} else if (is.match(gc.re.ARTIST_NA)) {
				return mb.log.exit(this.SPECIALCASE_UNKNOWN);
			}
		}
		return mb.log.exit(this.NOT_A_SPECIALCASE);
	};


	/**
	 * Delegate function which handles words not handled
	 * in the common word handlers.
	 *
	 * - Handles VersusStyle
	 *
	 **/
	this.doWord = function() {
		mb.log.enter(this.GID, "doWord");
		mb.log.debug('Guessing Word: #cw');
		if (this.doVersusStyle()) {
		} else if (this.doPresentsStyle()) {
		} else {
			// no special case, append
			gc.o.appendSpaceIfNeeded();
			gc.i.capitalizeCurrentWord();
			mb.log.debug('Plain word: #cw');
			gc.o.appendCurrentWord();
		}
		gc.f.resetContext();
		gc.f.number = false;
		gc.f.forceCaps = false;
		gc.f.spaceNextWord = true;
		return mb.log.exit(null);
	};

	/**
	 * Reformat pres/presents -> presents
	 *
	 * - Handles DiscNumberStyle (DiscNumberWithNameStyle)
	 * - Handles FeaturingArtistStyle
	 * - Handles VersusStyle
	 * - Handles VolumeNumberStyle
	 * - Handles PartNumberStyle
	 *
	 **/
	this.doPresentsStyle = function() {
		if (!this.doPresentsRE) {
			this.doPresentsRE = /^(presents?|pres)$/i;
		}
		if (gc.i.matchCurrentWord(this.doPresentsRE)) {
			gc.o.appendSpace();
			gc.o.appendWord("presents");
			if (gc.i.isNextWord(".")) {
				gc.i.nextIndex();
			}
			return true;
		}
		return false;
	};

	/**
	 * Guesses the sortname for artists
	 **/
	this.guessSortName = function(is) {
		mb.log.enter(this.GID, "guessSortName");
		is = gc.u.trim(is);

		// let's see if we got a compound artist
		var collabSplit = " and ";
		collabSplit = (is.indexOf(" + ") != -1 ? " + " : collabSplit);
		collabSplit = (is.indexOf(" & ") != -1 ? " & " : collabSplit);

		var as = is.split(collabSplit);
		for (var splitindex=0; splitindex<as.length; splitindex++) {
			var artist = as[splitindex];
			if (!mb.utils.isNullOrEmpty(artist)) {
				artist = gc.u.trim(artist);
				var append = "";
				mb.log.debug("Handling artist part: $", artist);

				// strip Jr./Sr. from the string, and append at the end.
				if (!gc.re.SORTNAME_SR) {
					gc.re.SORTNAME_SR = /,\s*Sr[\.]?$/i;
					gc.re.SORTNAME_JR = /,\s*Jr[\.]?$/i;
				}
				if (artist.match(gc.re.SORTNAME_SR)) {
					artist = artist.replace(gc.re.SORTNAME_SR, "");
					append = ", Sr.";
				} else if (artist.match(gc.re.SORTNAME_JR)) {
					artist = artist.replace(gc.re.SORTNAME_JR, "");
					append = ", Jr.";
				}
				var names = artist.split(" ");
				mb.log.debug("names: $", names);

				// handle some special cases, like DJ, The, Los which
				// are sorted at the end.
				var reorder = false;
				if (!gc.re.SORTNAME_DJ) {
					gc.re.SORTNAME_DJ = /^DJ$/i; // match DJ
					gc.re.SORTNAME_THE = /^The$/i; // match The
					gc.re.SORTNAME_LOS = /^Los$/i; // match Los
					gc.re.SORTNAME_DR = /^Dr\.$/i; // match Dr.
				}
				var firstName = names[0];
				if (firstName.match(gc.re.SORTNAME_DJ)) {
					append = (", DJ" + append); // handle DJ xyz -> xyz, DJ
					names[0] = null;
				} else if (firstName.match(gc.re.SORTNAME_THE)) {
					append = (", The" + append); // handle The xyz -> xyz, The
					names[0] = null;
				} else if (firstName.match(gc.re.SORTNAME_LOS)) {
					append = (", Los" + append); // handle Los xyz -> xyz, Los
					names[0] = null;
				} else if (firstName.match(gc.re.SORTNAME_DR)) {
					append = (", Dr." + append); // handle Dr. xyz -> xyz, Dr.
					names[0] = null;
					reorder = true; // reorder doctors.
				} else {
					reorder = true; // reorder by default
				}

				// we have to reorder the names
				var i=0;
				if (reorder) {
					var reOrderedNames = [];
					if (names.length > 1) {
						for (i=0; i<names.length-1; i++) {
							// >> firstnames,middlenames one pos right
							if (i == names.length-2 && names[i] == "St.") {
								names[i+1] = names[i] + " " + names[i+1];
									// handle St. because it belongs
									// to the lastname
							} else if (!mb.utils.isNullOrEmpty(names[i])) {
								reOrderedNames[i+1] = names[i];
							}
						}
						reOrderedNames[0] = names[names.length-1]; // lastname,firstname
						if (reOrderedNames.length > 1) {
							// only append comma if there was more than 1
							// non-empty word (and therefore switched)
							reOrderedNames[0] += ",";
						}
						names = reOrderedNames;
					}
				}
				mb.log.debug('Sorted names: $, append: $', names, append);
				var t = [];
				for (i=0; i<names.length; i++) {
					var w = names[i];
					if (!mb.utils.isNullOrEmpty(w)) {
						// skip empty names
						t.push(w);
					}
					if (i < names.length-1) {
						// if not last word, add space
						t.push(" ");
					}
				}

				// append string
				if (!mb.utils.isNullOrEmpty(append)) {
					t.push(append);
				}
				artist = gc.u.trim(t.join(""));
			}
			if (!mb.utils.isNullOrEmpty(artist)) {
				as[splitindex] = artist;
			} else {
				delete as[splitindex];
			}
		}
		var os = gc.u.trim(as.join(collabSplit));
		mb.log.debug('Result: $', os);
		return mb.log.exit(os);
	};

	// exit constructor
	mb.log.exit();
}
GcArtistHandler.prototype = new GcHandler;