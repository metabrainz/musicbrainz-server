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
 * GcModes class
 *
 **/
function GcModes() {
	mb.log.enter("GcModes", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "GcModes";
	this.GID = "es.gc.modes";

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------

	// language constants
	this.EN = "en"; // English=Default
	this.FR = "fr"; // French
	this.IT = "it"; // Italian

	// special modes language constants
	this.XX = "xx"; // Sentence
	this.XC = "XC"; // Classical

	// id of the dropdown element
	this.MODES_DROPDOWN = "GC_MODES_DROPDOWN";

	// prepare the list of title guess case modes.
	this.MODES_INDEX = 0;
	this.MODES_LIST = [
		  new GcModeDefault(this)
		, new GcModeSentence(this)
		, new GcModeFrench(this)
		, new GcModeClassical(this)
	];
	this.ARTIST_MODE = new GcModeArtist(this);

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Factory method, returns the DefaultMode object.
	 **/
	this.getDefaultMode = function() {
		mb.log.enter(this.GID, "getDefaultMode");
		if (!this.DEFAULT_MODE) {
			this.DEFAULT_MODE = this.MODES_LIST[0];
		}
		return mb.log.exit(this.DEFAULT_MODE);
	};

	/**
	 * Factory method, returns ArtistMode object
	 **/
	this.getArtistMode = function() {
		mb.log.enter(this.GID, "getArtistMode");
		return mb.log.exit(this.ARTIST_MODE);
	};

	/**
	 * Returns the GcMode from a given ID,
	 * or null if it does not exist.
	 **/
	this.getModeFromID = function(modeID, quiet) {
		mb.log.enter(this.GID, "getModeFromID");
		var mode = null;
		for (var i=0;i<this.MODES_LIST.length; i++) {
			mode = this.MODES_LIST[i];
			if (mode) {
				if (mode.getID() != modeID) {
					mode = null;
				} else {
					break; // mode found.
				}
			}
		}
		mb.log.debug('Id: $, mode: $', modeID, (mode || "not found"));
		return mb.log.exit(mode);
	};

	/**
	 * Handle a user request to change the GuessCase mode
	 **/
	this.onModeChanged = function(el) {
		mb.log.scopeStart("Handle selection on the Mode Dropdown");
		mb.log.enter(this.GID, "onModeChanged");
		if ((el && el.options) &&
			(el.id == this.MODES_DROPDOWN)) {
			var si = el.selectedIndex;
			var modeID = el.options[si].value;
			if (modeID != "") {
				mb.log.debug('New ModeId: $', modeID);
				if (modeID != es.gc.getMode().getID()) {
					es.gc.setMode(modeID);
					mb.cookie.set(es.gc.COOKIE_MODE, modeID, 365);
					mb.log.debug('Changed mode to: $', modeID);
					this.updateUI();
				} else {
					mb.log.debug('No mode change required...');
				}
			}
		} else {
			mb.log.error("Unsupported element: $", (el.name || "?"));
		}
		mb.log.exit();
		mb.log.scopeEnd();
	};

	/**
	 * Return the modechange dropdown
	 * @param id	the id of the dropdown element
	 * @param mod	the module which implements the onModeChanged event
	 * @param sm	the selectedMode (if none is given, the mode
	 *			    of the GuessCase object is used.
	 **/
	this.getDropdownHtml = function(id, mod, sm) {
		mb.log.enter(this.GID, "getDropdownHtml");
		id = (id || this.MODES_DROPDOWN);
		mod = (mod || this.GID);
		sm = (sm || es.gc.getMode());
		mb.log.debug("Id: $, Mod: $, Sm: $", id, mod, sm);

		// loop throught modes list, and render each
		// option.
		var ev = mod + '.onModeChanged(this)';
		var smid = sm.getID(), m, mid, s = [];
		s.push('<select id="'+id+'" onChange="'+ev+'">');
		for (var i=0; i<this.MODES_LIST.length; i++) {
			m = this.MODES_LIST[i];
			if (m != null) {
				mid = m.getID();
				s.push('<option value="');
				s.push(mid);
				s.push('" ');
				s.push((smid == mid ? 'selected' : ''));
				s.push('>');
				s.push(m.getName());
				s.push('</option>');
			} else {
				s.push('<option value="">---------------------</option>');
			}
		}
		s.push('</select>');
		s = s.join("");
		return mb.log.exit(s);
	};

	/**
	 * set the text explaining the current mode, once for the expanded and
	 * for the collapsed mode
	 **/
	this.updateUI = function(mode) {
		mb.log.enter(this.GID, "updateUI");
		var m = es.gc.getMode();
		var obj;
		// update selected index.
		// if ((obj = mb.ui.get(this.MODES_DROPDOWN)) != null) {
		//	obj.selectedIndex = m.getIndex();
		// }
		// update description texts.
		if ((obj = mb.ui.get(es.gc.getModID()+"-text-collapsed")) != null) {
			obj.innerHTML = m.getDescription();
		}
		if ((obj = mb.ui.get(es.gc.getModID()+"-text-expanded")) != null) {
			obj.innerHTML = m.getDescription();
		}
		mb.log.exit();
	};

	/**
	 * Gets the currently selected element from the
	 * mode dropdown, and updates the mode.
	 **/
	this.useModeFromUI = function() {
		mb.log.enter(this.GID, "useModeFromUI");
		var obj;
		if ((obj = mb.ui.get(this.MODES_DROPDOWN)) != null) {
			var modeID = obj.options[obj.selectedIndex].value;
			if (modeID != "") {
				es.gc.setMode(modeID);
			}
		} else {
			mb.log.error("Unsupported element: $", this.MODES_DROPDOWN);
		}
		mb.log.exit();
	};

	// exit constructor
	mb.log.exit();
}