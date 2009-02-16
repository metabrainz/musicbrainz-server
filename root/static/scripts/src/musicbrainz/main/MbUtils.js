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
 * Global utility functions
 *
 **/
function MbUtils() {

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "MbUtils";
	this.GID = "mb.utils";

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Add a leading string (or 0 if no argument is given)
	 * to numbers < 10.
	 **/
	this.leadZero = function() {
		var n = arguments[0];
		var s = (arguments[1] ? arguments[1] : '0');
		return (n < 10 ? new String(s)+n : n);
	};

	/**
	 * Returns 0 if there is NaN returned, or number
	 * if it's part of a string, like 100px.
	 **/
	this.getInt = function(s) {
		return parseInt(("0" + s), 10);
	};

	/**
	 * Trim whitespace from start and end of the string
	 **/
	this.trim = function(s) {
		if (this.isNullOrEmpty(s)) {
			return "";
		} else {
			return s.replace(/^\s*/, "").replace(/\s*$/, "");
		}
	};

	/**
	 * Returns if the object o is an Array. (copied from dojo framework (dojotoolkit.org))
	 * @param 	o
	 * @returns true, if condition is met
	 */
	this.isArray = function(o) {
		return (o instanceof Array || typeof o == "array");
	};

	/**
	 * Returns if the object o is a Function. (copied from dojo framework (dojotoolkit.org))
	 * @param 	o
	 * @returns true, if condition is met
	 */
	this.isFunction = function(wh) {
		return (o instanceof Function || typeof o == "function");
	};

	/**
	 * Returns if the object o is a String. (copied from dojo framework (dojotoolkit.org))
	 * @param 	o
	 * @returns true, if condition is met
	 */
	this.isString = function(o) {
		return (o instanceof String || typeof o == "string");
	};

	/**
	 * Returns if the object o is a Number. (copied from dojo framework (dojotoolkit.org))
	 * @param 	o
	 * @returns true, if condition is met
	 */
	this.isNumber = function(o) {
		return (o instanceof Number || typeof o == "number");
	};

	/**
	 * Returns if the object o is Boolean. (copied from dojo framework (dojotoolkit.org))
	 * @param 	o
	 * @returns true, if condition is met
	 */
	this.isBoolean = function(o) {
		return (o instanceof Boolean || typeof o == "boolean");
	};

	/**
	 * Returns if the object o is undefined. (copied from dojo framework (dojotoolkit.org))
	 * @param 	o
	 * @returns true, if condition is met
	 */
	this.isUndefined = function(o) {
		return ((o == undefined) && (typeof o == "undefined"));
	};

	/**
	 * Returns true if the given string is null or ""
	 *
	 * @returns  true, if condition is met
	 **/
	this.isNullOrEmpty = function(is) {
		return (!is || is == "");
	};
}
