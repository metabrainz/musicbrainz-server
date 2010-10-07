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
  | $Id: GcTrackHandler.js 9115 2007-05-10 10:53:24Z luks $
  \----------------------------------------------------------------------------*/

/**
 * Track specific GuessCase functionality
 **/
function GcTrackHandler() {

    // ----------------------------------------------------------------------------
    // register class/global id
    // ---------------------------------------------------------------------------
    this.CN = "GcTrackHandler";
    this.GID = "gc.track";

    // ----------------------------------------------------------------------------
    // member functions
    // ---------------------------------------------------------------------------

    /**
     * Guess the trackname given in string is, and
     * returns the guessed name.
     *
     * @param	is		the inputstring
     * @returns os		the processed string
     **/
    this.process = function(is) {
	is = gc.mode.stripInformationToOmit(is);
	is = gc.mode.preProcessCommons(is);
	is = gc.mode.preProcessTitles(is);
	var words = gc.i.splitWordsAndPunctuation(is);
	words = gc.mode.prepExtraTitleInfo(words);
	gc.o.init();
	gc.i.init(is, words);
	while (!gc.i.isIndexAtEnd()) {
	    this.processWord();
	}
	var os = gc.o.getOutput();
	os = gc.mode.runPostProcess(os);
	os = gc.mode.runFinalChecks(os);
	return os;
    };

    /**
     * Detect if UntitledTrackStyle and DataTrackStyle needs
     * to be applied.
     *
     * - data [track]			-> [data track]
     * - silence|silent [track]	-> [silence]
     * - untitled [track]		-> [untitled]
     * - unknown|bonus [track]	-> [unknown]
     **/
    this.checkSpecialCase = function(is) {
	if (is) {
	    if (!gc.re.TRACK_DATATRACK) {
		// data tracks
		gc.re.TRACK_DATATRACK = /^([\(\[]?\s*data(\s+track)?\s*[\)\]]?$)/i;
		// silence
		gc.re.TRACK_SILENCE = /^([\(\[]?\s*(silen(t|ce)|blank)(\s+track)?\s*[\)\]]?)$/i;
		// untitled
		gc.re.TRACK_UNTITLED = /^([\(\[]?\s*untitled(\s+track)?\s*[\)\]]?)$/i;
		// unknown
		gc.re.TRACK_UNKNOWN = /^([\(\[]?\s*(unknown|bonus|hidden)(\s+track)?\s*[\)\]]?)$/i;
		// any number of question marks
		gc.re.TRACK_MYSTERY = /^\?+$/i;
	    }
	    if (is.match(gc.re.TRACK_DATATRACK)) {
		return this.SPECIALCASE_DATA_TRACK;

	    } else if (is.match(gc.re.TRACK_SILENCE)) {
		return this.SPECIALCASE_SILENCE;

	    } else if (is.match(gc.re.TRACK_UNTITLED)) {
		return this.SPECIALCASE_UNTITLED;

	    } else if (is.match(gc.re.TRACK_UNKNOWN)) {
		return this.SPECIALCASE_UNKNOWN;

	    } else if (is.match(gc.re.TRACK_MYSTERY)) {
		return this.SPECIALCASE_UNKNOWN;
	    }
	}
	return this.NOT_A_SPECIALCASE;
    };


    /**
     * Delegate function which handles words not handled
     * in the common word handlers.
     *
     * - Handles FeaturingArtistStyle
     * - Handles VersusStyle
     * - Handles VolumeNumberStyle
     * - Handles PartNumberStyle
     *
     **/
    this.doWord = function() {

	if (this.doFeaturingArtistStyle()) {
	} else if (this.doVersusStyle()) {
	} else if (this.doVolumeNumberStyle()) {
	} else if (this.doPartNumberStyle()) {
	} else if (gc.mode.doWord()) {
	} else {
	    if (gc.i.matchCurrentWord(/7in/i)) {
		gc.o.appendSpaceIfNeeded();
		gc.o.appendWord('7"');
		gc.f.resetContext();
		gc.f.spaceNextWord = false;
		gc.f.forceCaps = false;
	    } else if (gc.i.matchCurrentWord(/12in/i)) {
		gc.o.appendSpaceIfNeeded();
		gc.o.appendWord('12"');
		gc.f.resetContext();
		gc.f.spaceNextWord = false;
		gc.f.forceCaps = false;
	    } else {
		// handle other cases (e.g. normal words)
		gc.o.appendSpaceIfNeeded();
		gc.i.capitalizeCurrentWord();

		gc.o.appendCurrentWord();
		gc.f.resetContext();
		gc.f.spaceNextWord = true;
		gc.f.forceCaps = false;
	    }
	}
	gc.f.number = false;
	return null;
    };
}
GcTrackHandler.prototype = new GcHandler;
