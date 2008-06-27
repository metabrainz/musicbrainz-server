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
  * Models a onload/ondomready event.
  *
  **/
function MbEventAction(object, method, description) {
	mb.log.enter("MbEventAction", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN	= "MbEventAction";
	this.GID = "";

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------
	var _object = object;
	var _method = method;
	var _description = description;

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Returns the name of the object.
	 *
	 */
	this.getObject = function() {
		return _object;
	};

	/**
	 * Returns the name of the method
	 *
	 */
	this.getMethod = function() {
		return _method;
	};

	/**
	 * Returns a description of this EventAction
	 *
	 */
	this.getDescription = function() {
		return _description;
	};

	/**
	 * Returns a string representation of this object
	 *
	 */
	this.toString = function() {
		var s = [];
		s.push(this.CN);
		s.push(" [");
		s.push(_description);
		s.push(", ");
		s.push(this.getCode());
		s.push("]");
		return s.join("");
	}

	/**
	 * Returns the object._m string to eval.
	 *
	 */
	this.getCode = function() {
		var s = [];
		s.push(_object);
		s.push(".");
		s.push(_method);
		s.push("()");
		return s.join("");
	}


	// exit constructor
	mb.log.exit();
}