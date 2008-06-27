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
 * Models one item of the Undo/Redo stack
 **/
function EsUndoItem() {
	mb.log.enter("EsUndoItem", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "EsUndoItem";

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------
	var args = arguments[0];
	this._field = args[0];
	this._op = args[1];
	this._old = args[2];
	this._new = args[3];

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------
	this.getField = function() {
		return this._field;
	};
	this.getOp = function() {
		return this._op;
	};
	this.getOld = function() {
		return this._old;
	};
	this.getNew = function() {
		return this._new;
	};
	this.setField = function(v) {
		this._field = v;
	};
	this.setOp = function(v) {
		this._op = v;
	};
	this.setOld = function(v) {
		this._old = v;
	};
	this.setNew = function(v) {
		this._new = v;
	};
	this.toString = function() {
		var s = [this.CN];
		s.push(" [field=");
		s.push(this.getField().name);
		s.push(", op=");
		s.push(this.getOp());
		s.push(", old=");
		s.push(this.getOld());
		s.push(", new=");
		s.push(this.getNew());
		s.push("]");
		return s.join("");
	};

	// exit constructor
	mb.log.exit();
}