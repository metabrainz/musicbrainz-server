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

function LuceneSearch() {

	this.types = ["a", "r", "t"];
	this.active = true;
	this.querySyntaxRE = /[:\?\!~\[\]\{\}\(\)\+]/g;

	/**
	 * @param el	the dropdown element
	 */
	this.onTextFieldChanged = function(el) {
		if (el) {
			var obj, value = el.value || "";
			if ((obj = mb.ui.get("id_querysyntax")) != null && value != "") {
				var flag = (value.match(this.querySyntaxRE) != null);
				obj.style.display = flag ? "" : "none";
			}
		}
	};

	/**
	 * @param el	the dropdown element
	 */
	this.onTypeChanged = function(el) {
		if (el) {
			this.setOptionsByType(el);
		}
	};

	/**
	 * loop through all the types, and select the active one.
	 *
	 * @param obj	the dropdown element
	 */
	this.setOptionsByType = function(obj) {
		if (obj) {
			var type = obj.options[obj.selectedIndex].value.substr(0,1);
			for (var i=0; i<this.types.length; i++) {
				var currType = this.types[i];
				if ((obj = mb.ui.get("id_type_"+currType)) != null) {
					obj.style.display = (currType == type && this.active ? "" : "none");
				}
			}
		}
	};

	/**
	 * Initialise the Advanced Search functions.
	 */
	this.init = function() {
		var obj;
		if ((obj = mb.ui.get("id_query")) != null) {
			obj.onkeyup = function onkeyup(event) {
				luceneSearch.onTextFieldChanged(this);
			}
			this.onTextFieldChanged(obj);
		}

		if ((obj = mb.ui.get("id_type")) != null) {
			obj.onchange = function onclick(event) {
				luceneSearch.onTypeChanged(this);
			}
			this.setOptionsByType(obj);
		}
	};
};

var luceneSearch = new LuceneSearch();
luceneSearch.init();
