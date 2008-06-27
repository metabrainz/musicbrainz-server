/*----------------------------------------------------------------------------\
|                              Musicbrainz.org                                |
|                     Copyright (c) 2005 Stefan Kestenholz                    |
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
\----------------------------------------------------------------------------*/

function AdvancedEditSearch() {

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "AdvancedEditSearch";
	this.GID = "advancedEditSearch";
	mb.log.enter(this.CN, "__constructor");

	this.formref = null;

	this.imgplus = new Image();
	this.imgplus.src = "/images/es/maximize.gif";
	this.imgminus = new Image();
	this.imgminus.src = "/images/es/minimize.gif";

	/**
	 * Hide all filter types, where no selection has been made.
	 */
	this.setupForm = function() {
		var field, container, s, div;
		if ((this.formref = mb.ui.get("AdvancedEditSearch")) != null) {
			var isreset = this.formref["isreset"].value == "1";
			var fields = ["mod_status", "automod", "mod_type", "moderator_type",
						  "voter_type", "vote_cast", "artist_type", "orderby", "object_id",
						  "mod_language", "minid" ];

			for (var i=0; i<fields.length; i++) {
				var fieldname = fields[i];
				if ((field = this.formref[fieldname]) != null &&
					(container = mb.ui.get("id_"+fieldname)) != null) {

					var type = "";

					// get content of label TD
					var tr = container.parentNode.parentNode;
					var labeltd = null;
					for (var j=0; j<tr.childNodes.length; j++) {
						if ((tr.childNodes[j].tagName || "").toLowerCase() == "td") {
							labeltd = tr.childNodes[j];
							type = labeltd.innerHTML;
							type = type.replace(/<[^>]*>/ig, "");
							type = type.replace(/[^a-z]/ig, ""); // only accept chars a-z
							break;
						}
					}

					if (type != "") {

						// create element which shows the selected items in the toggled state.
						div = document.createElement("div");
						div.style.marginBottom = "5px";
						div.style.paddingTop = "2px";
						div.style.fontSize = "12px";
						s = [];
						s.push('<div id="selected_');
						s.push(fieldname);
						s.push('">');
						s.push(this.getNoFilterText(fieldname));
						s.push('.</div>');
						div.innerHTML = s.join("");
						container.parentNode.insertBefore(div, container);
						container.style.marginBottom = "5px";

						// create element which shows the toggle icon
						var toggletd = document.createElement("td");
						s = [];
						s.push('<a href="#"  id="toggle_');
						s.push(fieldname);
						s.push('" onclick="');
						s.push('advancedEditSearch.toggleField(');
						s.push("'id_");
						s.push(fieldname);
						s.push("'");
						s.push('); return false;" title="Show ');
						s.push(type);
						s.push(' filter">');
						s.push('<img style="margin-left: 4px; margin-top: 4px" src="/images/es/maximize.gif" alt="" /></a>');
						toggletd.innerHTML = s.join("");
						toggletd.style.padding = "0px";
						tr.insertBefore(toggletd, labeltd.nextSibling);

						// create element which allows to reset the filter
						var cleartd = document.createElement("td");
						s = [];
						s.push('<a href="javascript: advancedEditSearch.clearFilter(\'');
						s.push(fieldname);
						s.push('\');">Clear&nbsp;filter&nbsp;&raquo;</a>');
						cleartd.innerHTML = s.join("");
						cleartd.style.padding = "0px";
						tr.appendChild(cleartd);

						if (field) {
							var cv = mb.cookie.get("advsearch::"+fieldname);
							var show = (cv == null || isreset ? false : cv == "1");

							if (field.options) {
								if (!show) {
									var length = field.options.length;
									field.size = (length > 25 ? 25 : length);
								}
								this.updateFilterDesc(field);
								field.onchange = function onchange(event) {
									advancedEditSearch.updateFilterDesc(this);
								};
								field.ondblclick = function ondblclick(event) {
									this.form.submit();
								};

							} else if (field.length) {
								for (var j=0; j<field.length; j++) {
									var fieldj = field[j];
									fieldj.onclick = function onchange(event) {
										advancedEditSearch.updateFilterDesc(this.form[this.name]);
									};
									fieldj.ondblclick = function ondblclick(event) {
										this.form.submit();
									};
								}
								this.updateFilterDesc(field);
							}
							if (!show) {
								container.style.display = "none";
								mb.ui.get("toggle_"+fieldname).checked = false;
							} else {
								container.style.display = "";
								mb.ui.get("toggle_"+fieldname).checked = true;
							}
							this.toggleField("id_"+fieldname, show ? 1 : 0);
						}
					}
				}
			}
		}
	};

	/**
	 * Returns the "no filter set" toggle link.
	 *
	 * @param 	field	the filter type
	 */
	this.getNoFilterText = function(fieldName) {
		var s = [];
		s.push('<a href="#" id="toggle_'+fieldName+'" onclick="');
		s.push('advancedEditSearch.toggleField(');
		s.push("'id_");
		s.push(fieldName);
		s.push("'");
		s.push('); return false;">');
		s.push('No filters set</a>');
		return s.join("");
	};

	/**
	 * Clears the filter given by name.
	 *
	 * @param 	field	the filter type
	 */
	this.clearFilter = function(fieldName) {
		var obj, field = this.formref[fieldName];
		if (field) {
			var s = [];
			if (field.options) {
				field.selectedIndex = -1;
			} else if (field.length) {
				for (var j=0; j<field.length; j++) {
					var fieldj = field[j];
					var label = fieldj.nextSibling;
					var text = (label.innerHTML || "Any");
					fieldj.checked = (text == "Any" ||
									  text == "Oldest first");
				}
			}
			this.updateFilterDesc(field);
			this.toggleField("id_"+fieldName, false);
		}
	};


	/**
	 * Lists the selected value(s) of the given input element
	 *
	 * @param 	field	the filter type
	 */
	this.updateFilterDesc = function(field) {
		var fieldname;
		if (field) {
			var s = [];
			if (field.options) {
				fieldname = field.name
				var opt = field.options;
				for (var i=0; i<opt.length; i++) {
					if (opt[i].selected) {
						s.push(opt[i].text);
					}
				}
			} else if (field.length) {
				for (var j=0; j<field.length; j++) {
					var fieldj = field[j];
					var label = fieldj.nextSibling;
					var text = (label.innerHTML || "Any");

					fieldj.style.marginRight = "5px";
					if (text != "Any") {
						if (fieldj.checked) {
							s.push(text);
						}
					}

					// remember fieldname
					fieldname = fieldname || fieldj.name;
				}
			}

			var obj, tmp;
			if ((obj = mb.ui.get("selected_"+fieldname)) != null) {
				var filter = [];
				var td = '<td style="font-size: 12px; padding: 0px 20px 0px 0px">';
				var ws0 = '<tr>' + td;
				var ws = '<tr class="trclass">' +
						 '<td style="padding: 0px 3px 0px 0px;">' +
					     '<img src="/images/tdicon.gif" alt="" style="vertical-align: top; margin-top: 2px" />' +
					     '</td>' +
					     td;
				var we = '</td></tr>';

				filter.push('<table style="border-collapse: collapse" class="listing">');
				if (s.length > 0) {
					for (var i=0; i<s.length; i++) {
						tmp = ws.replace("trclass", (i % 2 == 0 ? "odd" : "even"));
						tmp = tmp.replace("tdicon", "misc/bullet");
						filter.push(tmp);
						filter.push(s[i]);
						filter.push(we);
					}

				} else {
					filter.push(ws0);
					filter.push(this.getNoFilterText(fieldname));
					filter.push('.');
				}
				filter.push(we);
				filter.push('</table>');

				var s = [];
				s.push('<table style="border-collapse: collapse">');
				s.push('<tr valign="top" style="padding: 0px;">');
				s.push('<td style="padding: 0px; width: 300px">');
				s.push(filter.join(""));
				s.push('</td>');
				s.push('</tr>');
				s.push('</table>');
				obj.innerHTML = s.join("");
			}
		}
	};

	/**
	 * Show/Hide the div containing the input fields for
	 * the filter type given by field.
	 *
	 * @param 	field	the filter type
	 *
	 */
	this.toggleField = function(field, flag) {
		var obj;
		if ((obj = mb.ui.get(field)) != null) {
			if (flag == null) {
				flag = (obj.style.display == "none");
			}
			obj.style.display = (flag ? "" : "none");

			mb.cookie.set("advsearch::"+field.replace("id_", ""), flag ? 1 : 0);
			this.updateToggleIcon(field.replace("id_", "toggle_"), flag ? 1 : 0);
		}

		if ((obj = mb.ui.get(field.replace("id_", "selected_"))) != null) {
			obj.style.display = (!flag ? "" : "none");
		}
	};

	/**
	 * Lists the selected value(s) of the given input element
	 *
	 * @param 	field	the filter type
	 */
	this.updateToggleIcon = function(id, flag) {
		var a, img;
		if ((a = mb.ui.get(id)) != null) {
			a.title = a.title.replace(/$Show|Hide/g, flag ? "Show" : "Hide");
			img = a.firstChild
			img.src = (flag ? this.imgminus.src : this.imgplus.src);
		}
	};

	// exit constructor
	mb.log.exit();
}

// instantiate, and setup the form.
var advancedEditSearch = new AdvancedEditSearch();
mb.registerDOMReadyAction(
	new MbEventAction(advancedEditSearch.GID, 'setupForm', "Setup AdvancedEditSearch form")
);

