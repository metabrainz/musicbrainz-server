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

// Tests:
// ---
// Piano concerto "test" in b-flat minor, No. 2 opuss 2
// Test in b minor, No. 2 opuss 2
// Test in b flat minor, No. 2 opuss 2
// Test "Asdf" in Bb major, BWV 12 2. test
// Piano concerto "Test" in A# major No #2 Opus 2 14. murggs

/**
 * Models the "ClassicalMode" GuessCase mode.
 **/
function GcModeClassical(modes) {
	mb.log.enter("GcModeClassical", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "GcModeClassical";
	this.GID = "gc.mode_xc";
	this.setConfig(
		modes, 'Classical', modes.XC,
		  'First word titled, lowercase for <i>most</i> of the other '
		+ 'words. Read the [url]description[/url] for more details.',
		  '/doc/GuessCaseMode/ClassicalMode');

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------
	this.getUpperCaseWords = function() {
		return [
			"bwv", "d", "rv", "j", "hob", "hwv", "wwo", "kv"
		];
	};

	/**
	 * Handle all the classical mode specific quirks.
	 * Note: 	this function is run before release and track guess
	 *   		types (not for artist)
	 **/
	this.preProcessTitles = function(is) {
		mb.log.enter(this.GID, "preProcessTitles");
		if (!gc.re.PREPROCESS_FIXLIST_XC) {
			gc.re.PREPROCESS_FIXLIST_XC = [

				  // correct tone indication.
				, new GcFix("Handle -sharp.", /(\b)(\s|-)sharp(\s)/i, "-sharp")
				, new GcFix("Handle -flat.", /(\b)(\s|-)flat(\s)/i, "-flat")

				  // expand short tone notation. maybe restrict
				  // to uppercase tone only?
				, new GcFix("Expand C# -> C-sharp", /(\s[ACDFG])#(\s)/i, "-sharp")
				, new GcFix("Expand Cb -> C-flat", /(\s[ABCDEG])b(\s)/i, "-flat")

				  // common misspellings
				, new GcFix("adiago (adagio)", "adiago", "adagio")
				, new GcFix("pocco (poco)", "pocco", "poco"),
				, new GcFix("contabile (cantabile)", "contabile", "cantabile")
				, new GcFix("sherzo (scherzo)", "sherzo", "scherzo")
				, new GcFix("allergro (allegro)", "allergro", "allegro")
				, new GcFix("adante (andante)", "adante", "andante")
				, new GcFix("largetto (larghetto)", "largetto", "larghetto")
				, new GcFix("allgro (allegro)", "allgro", "allegro")
				, new GcFix("tocatta (toccata)", "tocatta", "toccata")
				, new GcFix("allegreto (allegretto)", "allegreto", "allegretto")
				, new GcFix("attaca (attacca)", "attaca", "attacca")

				  // detect one word combinations of work numbers and their number
				, new GcFix("split worknumber combination", /(\b)(BWV|D|RV|J|Hob|HWV|WwO|KV)(\d+)(\b|$)/i, "$2 $3")

				  // detect one word combinations of work numbers and their number
				, new GcFix("split op. number combination", /(\b)(Op)(\d+)(\b|$)/i, "$2 $3")
				, new GcFix("split no. number combination", /(\b)(No|N)(\d+)(\b|$)/i, "$2 $3")
			];
		}
		var os = this.runFixes(is, gc.re.PREPROCESS_FIXLIST_XC);
		mb.log.debug('After: $', os);
		return mb.log.exit(os);
	};

	/**
	 * Handle all the classical mode specific quirks.
	 * Note: 	this function is run before release and track guess
	 *   		types (not for artist)
	 **/
	this.runPostProcess = function(is) {
		mb.log.enter(this.GID, "runPostProcess");
		if (!gc.re.POSTPROCESS_FIXLIST_XC) {
			gc.re.POSTPROCESS_FIXLIST_XC = [

				  // correct opus/number
				, new GcFix("Handle Op.", /(\b)[\s,]+(Op|Opus|Opera)[\s\.#]+($|\b)/i, ", Op. " )
				, new GcFix("Handle No.", /(\b)[\s,]+(N|No|Num|Nr)[\s\.#]+($|\b)/i, ", No. " )

				  // correct K. -> KV
				, new GcFix("Handle K. -> KV", /(\b)[\s,]+K[\.\s]+($|\b)/i, ", KV " )

				  // correct whitespace and comma for work catalog
				  // BWV D RV J Hob HWV WwO (Work without Opera) KV
				, new GcFix("Fix whitespace and comma for work catalog", /(\b)[\s,]+(BWV|D|RV|J|Hob|HWV|WwO|KV)\s($|\b)/i, ", $2 " )

				  // correct tone indication
				, new GcFix("Handle -sharp.", /(\b)(\s|-)sharp(\s)/i, "-sharp")
				, new GcFix("Handle -flat.", /(\b)(\s|-)flat(\s)/i, "-flat")
			];
		}
		var os = this.runFixes(is, gc.re.POSTPROCESS_FIXLIST_XC);
		mb.log.debug('After: $', os);
		return mb.log.exit(os);
	};

	/**
	 * Classical mode specific replacements of movement numbers.
	 * - Converts decimal numbers (followed by a dot) to roman numerals.
	 * - Adds a colon before existing roman numerals
	 **/
	this.runFinalChecks = function(is) {
		mb.log.enter(this.GID, "runFinalChecks");
		if (!gc.re.DECIMALTOROMAN) {
			gc.re.DECIMALTOROMAN = /[\s,:\-]+(\d+)\.[\s]+/i;
		}
		var matcher = null
		var os = is;
		if ((matcher = os.match(gc.re.DECIMALTOROMAN)) != null) {
			var mindex = matcher.index;
			var mlenght = matcher[0].length;
			var firstPart = os.substring(0, mindex);
			var lastPart = os.substring(mindex + mlenght, os.length);
			var parts = []; // compile the vinyl designation.

			// strip trailing punctuation from first part, colon is added afterwards.
			firstPart = firstPart.replace(/[\s,:\-\/]+$/gi, "");

			parts.push(firstPart); // add string before the matched part
			parts.push(": "); // add colon
			parts.push(gc.u.convertToRomanNumeral(matcher[1])); // add roman representation.
			parts.push(". "); // add dot after roman numeral
			parts.push(lastPart); // add string after the matched part
			os = parts.join("");
		}

		// add a leading colon to a roman numeral
		// if there is none.
		if (!gc.re.ADD_COLON_TO_ROMAN) {
			gc.re.ADD_COLON_TO_ROMAN = /([^:])\s+([ivx]+)[\s|\.]+/i;
		}
		if ((matcher = os.match(gc.re.ADD_COLON_TO_ROMAN)) != null) {
			var mindex = matcher.index;
			var mlenght = matcher[0].length;
			var firstPart = os.substring(0, mindex);
			var lastPart = os.substring(mindex + mlenght, os.length);
			var parts = []; // compile the vinyl designation.
			parts.push(firstPart); // add string before the matched part
			parts.push(matcher[1]); // re-add the first match that was _not_ a colon.
			parts.push(": "); // add colon
			parts.push(matcher[2]); // re-add roman numeral
			parts.push(". "); // add dot after roman numeral
			parts.push(lastPart); // add string after the matched part
			os = parts.join("");
		}
		return mb.log.exit(os);
	};

	/**
	 * Delegate function for Mode specific word handling.
	 * This is mostly used for context based titling changes.
	 *
	 * @return	false, such that the normal word handling can
	 *			take place for the current word, if that should
	 * 			not be done, return true.
	 **/
	this.doWord = function() {
		mb.log.enter(this.GID, "doWord");

		var ipos = gc.i.getPos();
		var cw = gc.i.getCurrentWord();
		var pw = gc.i.getWordAtIndex(ipos-1);
		var ppw = gc.i.getPreviousWord(ipos-2);
		var opos = gc.o.getLength();
		var foundToneIndication = false;

		// if the current word is one of flat|sharp, and the
		// previous word is a hyphen, title the word before
		// is a tone indication.
		if (cw.match(/flat|sharp/i) && pw == "-") {
			opos = opos-2;
			foundToneIndication = true;

		// if the current word is one of the major|minor variants
		// and the word before the previous is not flat|sharp,
		// the word before is a tone indication.
		} else if (cw.match(/minor|major|minore|maggiore|mineur/i) &&
				   ppw.match(/flat|sharp/) == null) {
			opos = opos-1;
			foundToneIndication = true;

		// if the current word is one of the german variants
		// the word before is a tone indication.
		} else if (cw.match(/Moll|Dur/i)) {
			opos = opos-2;
			gc.f.forceCaps = true;
			foundToneIndication = true;
		}
		if (foundToneIndication) {
			var w = gc.o.getWordAtIndex(opos);
			mb.log.debug('Found tone indication before: $, making word: $ at pos: $ a title.', cw, w, opos);
			gc.o.capitalizeWordAtIndex(opos, true);
		}
		mb.log.exit();
		return false;
	};

	// exit constructor
	mb.log.exit();
}

try {
	GcModeClassical.prototype = new GcMode;
} catch (e) {
	mb.log.error("GcModeClassical: Could not register GcMode prototype");
}