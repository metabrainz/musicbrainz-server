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
| $Id: GcAlbumHandler.js 8548 2006-10-19 07:41:02Z dave $
\----------------------------------------------------------------------------*/

/**
 * Release specific GuessCase functionality
 **/
function GcReleaseHandler() {
	mb.log.enter("GcReleaseHandler", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "GcReleaseHandler";
	this.GID = "gc.release";

	/**
	 * Checks special cases of releases
	 **/
	this.checkSpecialCase = function(is) {
		mb.log.enter(this.GID, "checkSpecialCase");
		if (is) {
			if (!gc.re.RELEASE_UNTITLED) {
				// untitled
				gc.re.RELEASE_UNTITLED = /^([\(\[]?\s*untitled\s*[\)\]]?)$/i;
			}
			if (is.match(gc.re.RELEASE_UNTITLED)) {
				return mb.log.exit(this.SPECIALCASE_UNTITLED);
			}
		}
		return mb.log.exit(this.NOT_A_SPECIALCASE);
	};

	/**
	 * Guess the releasename given in string is, and
	 * returns the guessed name.
	 *
	 * @param	is		the inputstring
	 * @returns os		the processed string
	 **/
	this.process = function(is) {
		mb.log.enter(this.GID, "process");
		is = gc.mode.stripInformationToOmit(is);
		is = gc.mode.preProcessCommons(is);
		is = gc.mode.preProcessTitles(is);
		var words = gc.i.splitWordsAndPunctuation(is);
		words = gc.mode.prepExtraTitleInfo(words);
		gc.o.init();
		gc.i.init(is, words);
		while (!gc.i.isIndexAtEnd()) {
			this.processWord();
			mb.log.debug("Output: $", gc.o._w);
		}
		var os = gc.o.getOutput();
		os = gc.mode.runPostProcess(os);
		os = gc.mode.runFinalChecks(os);
		return mb.log.exit(os);
	};

	/**
	 * Delegate function which handles words not handled
	 * in the common word handlers.
	 *
	 * - Handles DiscNumberStyle (DiscNumberWithNameStyle)
	 * - Handles FeaturingArtistStyle
	 * - Handles VersusStyle
	 * - Handles VolumeNumberStyle
	 * - Handles PartNumberStyle
	 *
	 **/
	this.doWord = function() {
		mb.log.enter(this.GID, "doWord");
		mb.log.debug('Guessing Word: #cw');
		if (this.doDiscNumberStyle()) {
		} else if (this.doFeaturingArtistStyle()) {
		} else if (this.doVersusStyle()) {
		} else if (this.doVolumeNumberStyle()) {
		} else if (this.doPartNumberStyle()) {
		} else if (gc.mode.doWord()) {
		} else {
			// handle normal word.
			gc.o.appendSpaceIfNeeded();
			gc.i.capitalizeCurrentWord();
			mb.log.debug('Plain word: #cw');
			gc.o.appendCurrentWord();
			gc.f.resetContext();
			gc.f.forceCaps = false;
			gc.f.spaceNextWord = true;
		}
		gc.f.number = false;
		return mb.log.exit(null);
	};

	// exit constructor
	mb.log.exit();
}
GcReleaseHandler.prototype = new GcHandler;