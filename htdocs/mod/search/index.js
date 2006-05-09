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
	 * 
	 */	
	this.setupForm = function() {
		var field, container, s, div;
		if ((this.formref = mb.ui.get("AdvancedEditSearch")) != null) 
		{
			var isreset = this.formref["isreset"].value == "1";
			var fields = ["mod_status", "automod", "mod_type", "moderator_type", 
						  "voter_type", "vote_cast", "artist_type", "orderby", "object_id",
						  "mod_language", "minid" ];
		
			for (var i=0; i<fields.length; i++) 
			{
				var fieldname = fields[i];
				if ((field = this.formref[fieldname]) != null &&
					(container = mb.ui.get("id_"+fieldname)) != null)
				{
					
					// get content of label TD
					var type = container.parentNode.parentNode.firstChild.innerHTML;
					type = type.replace(/<[^>]*>/ig, "");
					type = type.replace(/[^a-z]/ig, ""); // only accept chars a-z

					div = document.createElement("div");
					div.style.marginBottom = "5px";
					div.style.paddingTop = "2px";
					div.style.fontSize = "11px";
				
					s = [];
					s.push('<div id="selected_');
					s.push(fieldname);
					s.push('">No filters set.</div>');
					div.innerHTML = s.join("");
					
					container.parentNode.insertBefore(div, container);
					container.style.marginBottom = "5px";

					s = [];
					s.push('<a href="#"  id="toggle_'+fieldname+'" onclick="');
					s.push('advancedEditSearch.toggleField(');
					s.push("'id_"); 
					s.push(fieldname);
					s.push("'");
					s.push('); return false;" title="Show '+type+' filter">');
					s.push('<img style="margin-left: 4px; margin-top: 4px" src="/images/es/maximize.gif" alt="" /></a>');

					td = document.createElement("td");
					td.innerHTML = s.join("");
					td.style.padding = "0px";
					
					var tr = container.parentNode.parentNode;
					tr.insertBefore(td, tr.firstChild.nextSibling);
					
					if (field)
					{
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
				var td = '<td style="font-size: 12px; padding: 0px">';
				var ws0 = '<tr>'+td;
				var ws = '<tr><td style="padding: 0px; padding-top: 2px; padding-right: 2px">'
					   + '<img src="/images/tdicon.gif" alt="" /></td>' + td;
				var we = '</td></tr>'; 

				filter.push('<table style="border-collapse: collapse;">');
				if (s.length > 0) {
					for (var i=0; i<s.length; i++) {
						tmp = ws.replace("trclass", (i % 2 == 0 ? "even" : "odd"));
						tmp = tmp.replace("tdicon", "misc/bullet");
						filter.push(tmp);
						filter.push(s[i]); 
						filter.push(we);
					}
					
				} else {
					filter.push(ws0);
					filter.push("No filters set.");
				}
				filter.push(we);
				filter.push('</table>');
				
				var out = [];
				out.push('<table style="border-collapse: collapse"><tr valign="top" style="padding: 0px;"><td style="padding: 0px; width: 300px">');
				out.push(filter.join(""));
				out.push('</td><td style="padding: 0px;">');
				out.push('<a href="javascript: advancedEditSearch.clearFilter(\''+fieldname+'\');">Clear&nbsp;filter&nbsp;&raquo;</a>');
				out.push('</td></tr></table>');				
				
				// alert(out.join("\n"));
				obj.innerHTML = out.join("");
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

