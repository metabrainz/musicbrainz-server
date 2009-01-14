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
| $Id: ar-frontend.js 8026 2006-07-02 21:58:02Z keschte $
\----------------------------------------------------------------------------*/

function QuickSearch() {

	/**
	 * Handles a click on the old search checkbox.
	 */
	this.onOldSearchToggle = function(el) {
		var types = ["artist", "release", "track", "label"];
		for (type in types) {
			if ((obj = mb.ui.get("id_qs_"+types[type]+"_form")) != null) {
				obj.action = el.checked ? "/search/oldsearch.html" : "/search/textsearch.html";
			}
		}
		mb.cookie.set("id_oldsearch_checkbox", el.checked ? "1" : "0");
	};


	/**
	 * Initialise the quicksearch
	 */
	this.init = function() {
		var obj;
		if ((obj = mb.ui.get("id_oldsearch_checkbox")) != null) {
			var cv = mb.cookie.get("id_oldsearch_checkbox")
			obj.checked = (cv == "1");
			this.onOldSearchToggle(obj);
			obj.style.display = "";
			obj.onclick = function onclick(ev) {
				quickSearch.onOldSearchToggle(this);
			};
		}

		if ((obj = mb.ui.get("id_qs_artist")) != null) {
			obj.onkeydown = function (ev) {
				if (window.event && window.event.keyCode == 13) { this.form.submit(); }
			};
		}
		if ((obj = mb.ui.get("id_qs_release")) != null) {
			obj.onkeydown = function (ev) {
				if (window.event && window.event.keyCode == 13) { this.form.submit(); }
			};
		}
		if ((obj = mb.ui.get("id_qs_track")) != null) {
			obj.onkeydown = function (ev) {
				if (window.event && window.event.keyCode == 13) { this.form.submit(); }
			};
		}
		if ((obj = mb.ui.get("id_qs_track")) != null) {
			obj.onkeydown = function (ev) {
				if (window.event && window.event.keyCode == 13) { this.form.submit(); }
			};
		}
		if ((obj = mb.ui.get("id_qs_editor")) != null) {
			obj.onkeydown = function (ev) {
				if (window.event && window.event.keyCode == 13) { this.form.submit(); }
			};
		}

	}
};

quickSearch = new QuickSearch();
quickSearch.init();