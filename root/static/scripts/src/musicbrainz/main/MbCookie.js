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
function MbCookie() {

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "MbCookie";
	this.GID = "mb.cookie";

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Sets a Cookie with the given name and value.
	 *
	 * @param 		name       	Name of the cookie
	 * @param 		value      	Value of the cookie
	 * @param 		[lifetime]  Number of days the cookie expires (null: end of current session)
	 * @param 		[path]     	Path where the cookie is valid (default: "/")
	 * @param 		[domain]   	Domain where the cookie is valid
	 *           				(default: domain of calling document)
	 * @param 		[secure]   	Boolean value indicating if the cookie
	 *							transmission requires a	secure transmission
	 **/
	this.set = function(name, value, lifetime, path, domain, secure) {
		mb.log.enter(this.GID, "set");
		path = (path || "/");
		var expires = null;
		if (lifetime) {
			var endtimeMillis = new Date().getTime();
			endtimeMillis += parseInt(lifetime)*24*60*60*1000;
			expires = new Date(endtimeMillis);
		}
		var s = [];
		s.push(name + "=" + escape(value));
		s.push(((expires) ? "; expires=" + expires.toGMTString() : ""));
		s.push(((path) ? "; path=" + path : ""));
		s.push(((domain) ? "; domain=" + domain : ""));
		s.push(((secure) ? "; secure" : ""));
		s = s.join("");
		document.cookie = s;
		mb.log.debug("Setting cookie: $", s);
		mb.log.exit();
	};

	/**
	 * Gets the value of the specified cookie.
	 *
	 * @param 		name  		Name of the desired cookie.
	 * @returns 				a string containing value of specified cookie,
	 * 							or null if cookie does not exist.
	 **/
	this.get = function(name) {
		mb.log.enter(this.GID, "get");

		// setup local variables
		var dc = document.cookie;
		var _from, _to, _key = name + "=";

		// find name in document.cookie
		if ((_from = dc.indexOf("; " + _key)) == -1) {
			_from = dc.indexOf(_key);
			if (_from != 0) {
				return mb.log.exit(null);
			}
		} else {
			// skip semicolon and space
			_from += 2;
		}

		// find next semicolon after the found key,
		// else use the full length of the cookie.
		if ((_to = dc.indexOf(";", _from)) == -1) {
			_to = dc.length;
		}

		// get value from _from to the index
		var v = dc.substring(_from + _key.length, _to); // cookie value
		v = unescape(v);
		return mb.log.exit(v);
	};

	/**
	 * Gets the value of the specified cookie.
	 **/
	this.getBool = function(name) {
		mb.log.enter(this.GID, "getBool");
		var cv = this.get(name);
		var f = null;
		if (cv && cv != "null") {
			f = (cv == "1"); // test wheter 0|1
		}
		return mb.log.exit(f);
	};

	/**
	 * Deletes the specified cookie.
	 * @param 		name      	name of the cookie
	 * @param 		[path]    	path of the cookie (must be same as path
	//							used to create cookie)
	 * @param 		[domain]  	domain of the cookie (must be same as domain
	 * 							used to create cookie)
	*/
	this.remove = function(name, path, domain) {
		mb.log.enter(this.GID, "remove");
		if (this.get(name)) {
			path = (path || "/");
			document.cookie = name + "=null" +
				((path) ? "; path=" + path : "") +
				((domain) ? "; domain=" + domain : "") +
				"; expires=Thu, 01-Jan-70 00:00:01 GMT";
			mb.log.debug("Deleted cookie: $", name);
		}
		mb.log.exit();
	};
}
