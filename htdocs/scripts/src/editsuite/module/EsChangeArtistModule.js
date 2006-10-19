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
 * Moderation Note Resizer
 *
 * Resize TextArea based on the amount of text (soft and hard wraps)
 * inspired by: http://tuckey.org/textareasizer
 */
function EsChangeArtistModule() {
	mb.log.enter("EsChangeArtistModule", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "EsChangeArtistModule";
	this.GID = "es.changeartist";

	// ----------------------------------------------------------------------------
	// register module
	// ---------------------------------------------------------------------------
	this.getModID = function() { return "es.changeartist"; };
	this.getModName = function() { return "Change artist functions"; };

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------
	this.guessBothWarning = "",

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Use the initial value (reset)
	 **/
	this.useCurrent = function() {
		mb.log.enter(this.GID, "useCurrent");

		// if we got all the input and hidden fields, update
		// field values from the hidden fields
		var fs,ft,fos,fot;
		if (((fs = es.ui.getField('search')) != null) &&
			((fos = es.ui.getField('orig_artname')) != null) &&
			((ft = es.ui.getField('trackname')) != null) &&
			((fot = es.ui.getField('orig_track')) != null)) {

			var sa = fos.value; // new artist value
			var st = fot.value; // new track value
			es.ur.addUndo(es.ur.createItemList(
							es.ur.createItem(fs, 'usecurrent', fs.value, sa),
							es.ur.createItem(ft, 'usecurrent', ft.value, st)));
			fs.value = sa;
			ft.value = st;
		} else {
			mb.log.error("Did not find the fields! $,$,$,$", fs,ft,fos,fot);
		}
		mb.log.exit();
	};

	/**
	 * Use the split that was guessed on the server side
	 **/
	this.useSplit = function() {
		mb.log.enter(this.GID, "useSplit");

		// if we got all the input and hidden fields, update
		// field values from the hidden fields
		var fs,ft,fsa, fst;
		if (((fs = es.ui.getField('search')) != null) &&
			((ft = es.ui.getField('trackname')) != null) &&
			((fsa = es.ui.getField('split_artname')) != null) &&
			((fst = es.ui.getField('split_track')) != null)) {
			var sa = fsa.value; // new artist value
			var st = fst.value; // new track value
			es.ur.addUndo(es.ur.createItemList(
							es.ur.createItem(fs, 'usesplit', fs.value, sa),
							es.ur.createItem(ft, 'usesplit', ft.value, st)));
			fs.value = sa;
			ft.value= st;
		} else {
			mb.log.error("Did not find the fields! $,$,$,$", fs,ft,fsa,fst);
		}
		mb.log.exit();
	};

	/**
	 * Guess artist and trackname, take care of (feat.) thingies.
	 **/
	this.guessBoth = function(artistField, trackField) {
		mb.log.enter(this.GID, "guessBoth");
		var f, fa,ft;
		artistField = (artistField || "search");
		trackField = (trackField || "trackname");

		if (((fa = es.ui.getField(artistField)) != null) &&
			((ft = es.ui.getField(trackField)) != null)) {

			// we got references to the fields, do the thingies.
			var ov = { artist: fa.value, track: ft.value };
			var cv = { artist: fa.value, track: ft.value }; // redeclaration needed, because
														// object = by ref, not by value.
			if (!mb.utils.isNullOrEmpty(ov.artist) &&
				!mb.utils.isNullOrEmpty(ov.track)) {

				// dump the current values
				mb.log.debug("Trying to guess artist & trackname ");
				mb.log.debug("* Artist (original): $", cv.artist);
				mb.log.debug("* Track (original): $", cv.track);

				// check for swapped fields.
				if (cv.track.match(/\sfeat/i) && cv.artist.match(/\smix/i)) {
					if (this.guessBothWarning != cv.track+"|"+cv.artist) {
						alert("Please swap artist / trackname fields. they are most likely wrong.");
						this.guessBothWarning = cv.track+"|"+cv.artist;
						return;
					}
				}
				if (cv.artist != "") {
					cv.artist = gc.guessArtist(cv.artist);
				}
				if (cv.track != "") {
					cv.track = gc.guessTrack(cv.track);
				}

				// dump values after first guess
				mb.log.scopeStart("After first guess");
				mb.log.debug("* Artist (guessed): $", cv.artist);
				mb.log.debug("* Track (guessed): $", cv.track);

				// match ft, featuring feat if not last word of searchname
				var i = -1;
				var a = cv.artist.toLowerCase(); // initialise search string to artist name
				i = (a.match(/\s\(feat[\.]?[^$]?/i) ? a.indexOf("(feat") : i);
				i = (a.match(/\sFeat[\.]?[^$]?/i) ? a.indexOf("feat") : i);
				i = (a.match(/\sFt[\.]?[^$]/i) ? a.indexOf("ft") : i);
				i = (a.match(/\sFeaturing[^$]/i) ? a.indexOf("featuring") : i);
				if (i != -1) {
					var addBrackets = (a.charAt(i) != "(");
					cv.track = cv.track + (addBrackets ? " (" : "") +
							   cv.artist.substring(i, cv.artist.length) +
							  (addBrackets ? ")" : "");
					cv.artist = cv.artist.substring(0, i);
					mb.log.scopeStart("Found feat at position: "+i);
					mb.log.debug("Artist (-feat): $", cv.artist);
					mb.log.debug("Track (+feat): $", cv.track);
					if (cv.artist != "") {
						cv.artist = gc.guessArtist(cv.artist);
					}
					if (cv.track != "") {
						cv.track = gc.guessTrack(cv.track);
					}
					mb.log.scopeStart("After second guess");
					mb.log.debug("Artist (final): $", cv.artist);
					mb.log.debug("Track (final): $", cv.track);
				}

				// update fields, and undo stack if the respective
				// value has changed.
				var changed = {
					artist: (ov.artist != cv.artist ? es.ur.createItem(fa, 'guessboth', ov.artist, cv.artist) : null),
					track: (ov.track != cv.track ? es.ur.createItem(ft, 'guessboth', ov.track, cv.track) : null)
				};
				if (changed.artist && !changed.track) {
					// Artist Name has changed
					fa.value = cv.artist;
					es.ur.addUndo(changed.artist);
				} else if (!changed.artist && changed.track) {
					// Track Name has changed
					ft.value = cv.track;
					es.ur.addUndo(changed.track);
				} else {
					// Artist Name and Track Name have changed
					fa.value = cv.artist;
					ft.value = cv.track;
					es.ur.addUndo(es.ur.createItemList(changed.artist, changed.track));
				}
				mb.log.scopeStart("After guess both");
				mb.log.info("* Artist: $", cv.artist);
				mb.log.info("* Track: $", cv.track);
			} else {
				mb.log.info("Field values are empty, skipped");
			}
		} else {
			mb.log.error("Did not find the fields! $,$", artistField, trackField);
		}
		mb.log.exit();
	};

	// exit constructor
	mb.log.exit();
}
