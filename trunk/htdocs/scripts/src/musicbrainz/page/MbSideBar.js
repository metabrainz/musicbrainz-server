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
 * MbSideBar is the class used which maintains the state of the
 * left menubar.
 *
 * @constructor
 */
function MbSideBar() {
	mb.log.enter("MbSideBar", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "MbSideBar";
	this.GID = "mb.sidebar";

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------

	/** Defines the name of the cookie which stores the sidebar state. @type String **/
	this.COOKIE_SIDEBAR = "sidebar";

	/** Name of the div which contains the open link. @type String **/
	this.ID_SHOW = "sidebar-toggle-show";

	/** ID of the div which contains the open link. @type String  **/
	this.ID_HIDE = "sidebar-toggle-hide";

	/** ID of the sidebar TD. @type String  **/
	this.ID_SIDEBAR = "sidebar-td";

	/** ID of the main-content TD. @type String  **/
	this.ID_CONTENT = "content-td";

	/** Defines the states of the sidebar. @type String  **/
	this.STATES = [
		{ id: "hide", title: "Hide side bar", icon: "minimize.gif" },
		{ id: "show", title: "Show side bar", icon: "maximize.gif" }
	];

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Gets sidemenu state from cookie and sets the sidemenu visibility.
	 * If no value can be obtained from the cookie, assume open state,
	 * else compare cookie value to "1", where 1=open, 0=closed
     *
	 * Note: mm_initialiseMbSideBar could be done in "onload" (as the name
	 * suggests); however instead we do it as soon as both sidemenu-td and
	 * the sidebar toggles are available in the document tree. This way,
	 * no flickering of the screen (or appear/reappear oddities) occur,
	 * opposite if this function would be called during the onLoad handler.
	 * On the other hand it's possible that some browsers may not like this, in
	 * which case uncomment the following (and remove the call from comp/sidebar)
	 * to do all this during "onload" instead.
	 * AddOnLoadAction(mm_initialiseMbSideBar);
	 *
	 * @see toggle
	 **/
	this.init = function() {
		mb.log.enter(this.GID, "init");
		var mode = mb.cookie.get(this.COOKIE_SIDEBAR);
		mode = (mode || "1"); // use default=1, or value from cookie
		this.toggle((mode == "1"));
		mb.log.exit();

	};

	/**
	 * This function shows/hides the sidebar. It works in toggle mode if
	 * the parameter show is omitted, but can forced to a given state
	 * when the parameter is provided.
     *
	 * Note: The display attribute of TD-elements should be "table-cell"
	 * according to W3C, but many browsers fail to handle this
	 * (whereas using "block" seems to be OK in just about all cases).
	 *
	 * @param show
	 **/
	this.toggle = function(show) {
		mb.log.enter(this.GID, "toggle");
		var el;
		if ((el = mb.ui.get(this.ID_SIDEBAR)) != null) {
			// use parameter, or check the display style of the element
			show = (show || (el.style.display == "none"));
			if (el) {
				el.style.display = (show ? "" : "none");
				el.style.width = (show ? "140px" : "0px");
			}
			if ((el = mb.ui.get(this.ID_CONTENT)) != null) {
				el.style.width = "100%";
			}
			if ((el = mb.ui.get(this.ID_SHOW)) != null) {
				el.style.display = (show ? "none" : "inline");
			}
			if ((el = mb.ui.get(this.ID_HIDE)) != null) {
				el.style.display = (show ? "inline" : "none");
			}
			// set a persistent, storing the state of the sidebar
			// for 365 days.
			mb.cookie.set(this.COOKIE_SIDEBAR, (show ? "1" : "0"), 365);
		} else {
			mb.log.error("Did not find el: $", this.ID_SIDEBAR);
		}
		mb.log.exit();
	};

	/**
	 * Writes the HTML code for the sidebar toggle
	 * links to the document.
     *
	 * Note: The display attribute of TD-elements should be "table-cell"
	 * according to W3C, but many browsers fail to handle this
	 * (whereas using "block" seems to be OK in just about all cases).
	 *
	 * @return code
	 **/
	this.getUI = function() {
		mb.log.enter(this.GID, "getUI");
		var j, state, s = [];
		for (j=0; j<this.STATES.length; j++) {
			state = this.STATES[j];
			s.push('<table id="sidebar-toggle-');
			s.push(state.id);
			s.push('" border="0" cellspacing="0" cellpadding="0">');
			s.push('<tr><td>');
			s.push('<a href="javascript:; // Toggle side bar" ');
			s.push('onClick="try { mb.sidebar.toggle(null); } ');
			s.push('catch (e) { /* fail quietly */ }" ');
			s.push('title="');
			s.push(state.title);
			s.push('">');
			s.push(state.title);
			s.push('</a>');
			s.push('</td><td>');
			s.push('<img src="http://musicbrainz.org/images/icon/');
			s.push(state.icon);
			s.push('" alt="">');
			s.push('</td></tr></table>');
		}
		mb.log.exit();
		return s.join("");
	};

	// exit constructor
	mb.log.exit();
}