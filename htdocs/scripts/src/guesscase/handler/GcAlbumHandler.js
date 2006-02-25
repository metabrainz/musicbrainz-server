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
 * Album specific GuessCase functionality
 **/
function GcAlbumHandler() {
	mb.log.enter("GcAlbumHandler", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "GcAlbumHandler";
	this.GID = "gc.album";

	/**
	 * Guess the albumname given in string is, and
	 * returns the guessed name.
	 *
	 * @param	is		the inputstring
	 * @returns os		the processed string
	 **/
	this.process = function(is) {
		mb.log.enter(this.GID, "process");
		is = this.stripInformationToOmit(is);
		is = this.preProcessCommons(is);
		is = this.preProcessTitles(is);
		is = this.runVinylChecks(is);
		var ow = gc.i.splitWordsAndPunctuation(is);
		var nw = this.prepExtraTitleInfo(ow);
		gc.o.init();
		gc.i.init(is, nw);
		while (!gc.i.isIndexAtEnd()) {
			this.processWord();
		}
		var os = this.getOutput();
		return mb.log.exit(os);
	};

	/**
	 * Delegate function which handles words not handled
	 * in the common word handlers.
	 *
	 * » Handles DiscNumberStyle (DiscNumberWithNameStyle)
	 * » Handles FeaturingArtistStyle
	 * » Handles VersusStyle
	 * » Handles VolumeNumberStyle
	 * » Handles PartNumberStyle
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
GcAlbumHandler.prototype = new GcHandler;