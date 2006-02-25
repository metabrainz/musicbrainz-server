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
 * Models a GuessCase mode.
 **/
function GcMode(modes, name, lang, desc, url) {
	mb.log.enter("GcMode", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "GcMode";
	this.GID = "gc.mode";

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------
	this._modes = modes;
	this._name = name;
	this._lang = lang;
	this._desc = (desc || "");
	this._url = (url || "");
	this._id = null; 

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Returns the unique identifier of this mode
	 **/
	this.getID = function() {
		if (!this._id) {
			var s = (this._name+" "+this._lang).toLowerCase();
			s = s.replace(/\s*/g, "");
			s = s.replace(/\([^\)]*\)/g, "");
			this._id = s;
		}
		return this._id; 
	};
	this.getName = function() { return this._name; };
	this.getURL = function() { return this._url; };
	this.getLanguage = function() { return this._lang; };

	/**
	 * Returns the type of this mode
	 **/
	this.getDescription = function() {
		var s = this._desc;
		s = s.replace('[url]', '<a href="'+this.getURL()+'" target="_blank">'+this.getName()+' ');
		s = s.replace('[/url]', '</a>');
		return s;
	};

	/**
	 * Returns true if the GC script is operating in sentence mode
	 **/
	this.isSentenceCaps = function() {
		mb.log.enter(this.GID, "isSentenceCaps");
		var f = !(this._modes.EN == this.getLanguage());
		// mb.log.debug("lang: $, flag: $", this.getLanguage(), f);
		return mb.log.exit(f);
	};

	/**
	 * Returns true if the GC script is operating in sentence mode
	 **/
	this.toString = function() {
		var s = [];
		s.push(this.CN);
		s.push(" [");
		s.push("id: ");
		s.push(this.getID());
		// s.push(", description: ");
		// s.push(this.getDescription());
		s.push(", SentenceCaps: ");
		s.push(this.isSentenceCaps());
		s.push("]");
		return s.join("");
	};

	// exit constructor
	mb.log.exit();
}