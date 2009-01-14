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
 * Models a multiple-part item of the Undo/Redo stack
 **/
function EsUndoItemList() {
	mb.log.enter("EsUndoItemList", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "EsUndoItemList";

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------
	var args = arguments[0];
	this._list = [];
	for (var i=0;i<args.length; i++) {
		if (args[i] instanceof EsUndoItem) {
			this._list.push(args[i]);
		}
	}

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------
	this.getList = function() {
		return this._list;
	};
	this.iterate = function() {
		this._cnt = 0;
	};
	this.getNext = function() {
		return this._list[this._cnt++];
	};
	this.hasNext = function() {
		return this._cnt < this._list.length;
	};
	this.toString = function() {
		var s = [this.CN];
		s.push(" [");
		s.push(this.getList().join(", "));
		s.push("]");
		return s.join("");
	};

	// exit constructor
	mb.log.exit();
}