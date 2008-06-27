/*----------------------------------------------------------------------------\
|                              Musicbrainz.org                                |
|                 Copyright (c) 2005 Stefan Kestenholz (g0llum)               |
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

/**
 * SandBoxPage class
 */
function SandBoxPage(id, name, content, table) {

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------
	this.id = id;
	this.name = name;
	this.content = content;
	this.table = table;
}

/**
 * SandBox class
 **/
function SandBox() {

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "SandBox";
	this.GID = "sandBox";
	mb.log.enter(this.CN, "__constructor");

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------
	this.COOKIE_TAB = "SANDBOX_TAB";
	this.pages = [];
	this.tp = new TrackParserTest();

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Tests the split splitWordsAndPunctuation function.
	 */
	this.testSplit = function() {
		mb.log.setLevel(mb.log.DEBUG);
		mb.log.scopeStart("Handling click on 'Test Split' function.");
		var ov = mb.ui.get("splittesttext").value;
		mb.log.info("Attempting to split: $", ov);
		var nv = gc.i.splitWordsAndPunctuation(ov);
		mb.log.info("Split value: $", nv);
		mb.log.scopeEnd();
	};

	/**
	 * Handles a click on the Set Fields Count button
	 */
	this.onSetFieldCountClicked = function() {
		mb.log.scopeStart("Handling click on 'setFieldCount' function.");
		this.setFieldCount(true);
		mb.log.scopeEnd();
	};

	/**
	 * Adjusts the number of displayed fields on the add release forms.
	 *
	 * @param interactive	in interactive mode, the form fields
	 *						are initialised, else not.
	 */
	this.setFieldCount = function(interactive) {
		var obj, tr, cn, lastRow, parentNode;
		if ((obj = mb.ui.get("numberOfFieldsSize")) != null) {

			var numberOfFields = obj.value;
			var id, trs = document.getElementsByTagName("tr");
			var template = [], removefields = [];
			for (i=0; i<trs.length; i++) {
				tr = trs[i], cn = (tr.className || "");
				if (tr != null) {
					if (cn == "field") {
						template.push(tr);
					} else if (cn == "fieldclone") {
						removefields.push(tr);
					} else if (cn == "lastfield") {
						lastRow = tr;
					}
				}
			}
			for (i=0; i<removefields.length; i++) {
				tr = removefields[i];
				parentNode = tr.parentNode;
				parentNode.removeChild(tr);
			}

			if (template.length > 0) {
				parentNode = lastRow.parentNode;
				for (i=1; i<numberOfFields; i++) {
					for (var j=0; j<template.length; j++) {
						var n,k;
						var f = f = es.ui.getForm();
						var node = template[j].cloneNode(true);
						node.className = "fieldclone";
						var nid = i;

						var isva = f["artistname0"] != null;
						var vaoffset = isva ? 1 : 0;
						var tnprefix = isva ? "" : "Track ";

						var trackindex = 1 + vaoffset;
						var tracklengthindex = 2 + vaoffset;
						var buttonsindex = 3 + vaoffset;

							// handle number
						if ((n = node.childNodes[0])) {
							f = n.firstChild;
							if (f && f.nodeValue) {
								n.removeChild(f);
								n.appendChild(document.createTextNode(tnprefix+(nid+1)+":"));
							}
						}

						// handle track/artist fields
						if ((n = node.childNodes[trackindex])) {

							// remove toolbox icon, will be re-inserted when the
							// form is setup.
							n.removeChild(n.childNodes[1]);

							f = n.firstChild;
							if (f.name) {
								f.value = "";
								f.name = f.name.replace(/\d+$/, nid);
								es.ui.getForm()[f.name] = f; // register field in form
							} else {
								mb.log.warning("Track field $ does not define name", f);
							}
						}

						// handle tracklength fields
						if ((n = node.childNodes[tracklengthindex])) {
							f = n.firstChild;
							if (f) {
								if (f.name) {
								f.value = "?:??";
								f.name = f.name.replace(/\d+$/, nid);
								es.ui.getForm()[f.name] = f; // register field in form
								} else {
									mb.log.warning("Tracklength field $ does not define name", f);
								}
							}
						}

						// handle buttons, and hidden fields
						if ((n = node.childNodes[buttonsindex])) {
							for (k=0; k<n.childNodes.length; k++) {
								f = n.childNodes[k];
								if (f.nodeName == "INPUT") {
									if (f.value && !f.value.match(/\d+/)) {
										f.value = ""; // needs to be "" to be initialised
									}
									if (f.id) {
										f.id = f.id.replace(/\d+($|\|)/g, nid+"$1");
									}
									if (f.name) {
										f.name = f.name.replace(/\d+$/, nid);
										es.ui.getForm()[f.name] = f; // register field in form
									}
								}
							}
						}
						parentNode.insertBefore(node, lastRow);
					}
				}
				if (interactive) es.ui.setupFormFields();
			}
		}
	};


	/**
	 * Writes the sandbox UI to the document
	 *
	 **/
	this.writeUI = function() {
		mb.log.enter(this.CN, "writeUI");
		mb.log.scopeStart("Writing Sandbox UI");
		this.pages = [];
		var obj, i, page, s = [];

		// insert jsunit test launchers
		if ((obj = mb.ui.get("insert::jsunittests")) != null) {

			var loc = document.location.href;
			loc = loc.split("sandbox\.html")[0];
			var tests = [
				["run/all.html", "Run All tests"],
				["run/artistname.html", "Run Tests for the <b>Artist Name</b> routines"],
				["run/sortname.html", "Run Tests for the <b>Artist Sortname</b> routines"],
				["run/albumname.html", "Run Tests for the <b>Release Title</b> routines"],
				["run/trackname.html", "Run Tests for the <b>Track Name</b> routines"],
				["run/titlestring.html", "Run Tests for the <b>Word Capitalization</b> routines"]
			];

			s.push("<em>You need to disable the pop-up blocker to run the tests!</em>");
			s.push('<ul style="padding-left: 10px">');
			for (var i=0; i<tests.length; i++) {
				var t = tests[i];
				s.push('<li>');
				s.push('<a href="javascript:; //" ');
				s.push('onClick="window.open(\'run.html?testpage='+loc+t[0]+'&autorun=true\',\'\',\'width=800,height=350,status=no,resizable=yes,scrollbars=yes\'); return false;');
				s.push('">'+t[1]+'</a>');
				s.push(' &nbsp; ')
				s.push('[ <a target="_blank" href="'+t[0]+'">View tests</a> ]');
				s.push('</li>');
			}
			s.push('</ul>');
			obj.innerHTML = s.join("");
		}

		// insert single artist release trackparser tests
		if ((obj = mb.ui.get("insert::insert_tp_sa")) != null) {
			obj.innerHTML = this.tp.getUI(false);
		} else {
			mb.log.error("insert::insert_tp_sa not found!");
		}

		// insert various artist release trackparser tests
		if ((obj = mb.ui.get("insert::insert_tp_va")) != null) {
			obj.innerHTML = this.tp.getUI(true);
		} else {
			mb.log.error("insert::insert_tp_va not found!");
		}

		// get sandboxpage tables from document
		var pagecounter = 0, id, tables = document.getElementsByTagName("table");
		var pageRE = /sandboxpage::/;
		for (i=0; i<tables.length; i++) {
			obj = tables[i];
			id = (obj.id || "");
			if (id.match(pageRE)) {
				id = id.replace(pageRE, "");
				s = [];
				s.push('<table class="formstyle" style="margin-top: 20px">');
				s.push(obj.innerHTML);
				s.push('</table>');
				var p = new SandBoxPage("t"+(pagecounter++), id, s.join(""), obj);
				this.pages.push(p);
				mb.log.info("Added sandbox page: $, name: $", p.id, p.name);
			}
		}

		// write sandbox menu-tabs
		s = [];
		s.push('<div class="sandbox">');
		s.push('  <div class="tab-row">');
		for (i=0; i<this.pages.length; i++) {
			page = this.pages[i];
			s.push('<h1 class="tab" ');
			s.push('id="'+this.getTabId(page.id)+'"><a href="#">');
			s.push(page.name);
			s.push('</a></h1>');
		}
		s.push('  </div>');

		// write sandbox page placeholder
		s.push('<div id="sandbox-tab-page" class="tab-page">');
		s.push('  <div id="writeroot" />');
		s.push('</div>');
		s.push('</div>');

		// insert sandbox UI into the dom.
		if ((obj = mb.ui.get("insert::sandboxui")) != null) {
			obj.innerHTML = s.join("");

			// attach event handlers to the menu
			for (i=0; i<this.pages.length; i++) {
				page = this.pages[i];
				var tabid = this.getTabId(page.id);
				if ((obj = mb.ui.get(tabid)) != null) {
					obj.firstChild.id = page.id;
					obj.firstChild.onclick= function onclick(event) { sandBox.selectTab(this.id); };
				} else {
					mb.log.error("Tabid: $ not found!", tabid);
				}
				page.table.parentNode.removeChild(page.table); // remove stub table from document
			}

			// get currently selected tab from cookie
			var st = mb.cookie.get(this.COOKIE_TAB);
			this.selectedTab = ((st || "").match(/t\d/) ? st : "t0");
			this.selectTab(this.selectedTab, true);

		} else {
			mb.log.error("insert::sandboxui not found!");
		}

		// write debug UI
		mb.log.exit();
	};

	/**
	 * Handles a click on one of the tabs
	 *
	 * @param tid 	the tab id.
	 * @param init	true if the form fields should be setup, else not.
	 */
	this.selectTab = function(tid, init) {
		if (!init) {
			mb.log.scopeStart("Handling Click on tab...");
		}
		mb.log.enter(this.CN, "selectTab");
		var obj,i,page, id;

		// hiding current tab
		if (this.currentTab) {
			id = this.getTabId(this.currentTab);
			if ((obj = mb.ui.get(id)) != null) {
				obj.className = "tab";
				mb.log.info("Hidden current tab: $", id);
			} else {
				mb.log.error("Did not find tab: $", id);
			}
		}

		// looking for selected tab, and showing it
		id = this.getTabId(tid);
		if ((obj = mb.ui.get(id)) != null) {
			obj.className = "tab selected";
		} else {
			mb.log.error("Did not find tab: $", id);
		}

		// loop through the tabs, and find the content
		// to be displayed.
		for (i=0; i<this.pages.length; i++) {
			page = this.pages[i];
			if (tid == page.id) {
				if ((obj = mb.ui.get("writeroot")) != null) {
					obj.innerHTML = page.content;
					if (!init) {
						es.ui.setupFormFields();
					}
				}
				this.currentTab = page.id;
				mb.cookie.set(this.COOKIE_TAB, this.currentTab, 365);
				mb.log.info("Selected current tab: $", this.currentTab);
			}
		}
		mb.log.exit();
		if (!init) {
			mb.log.scopeEnd();
		}
	}

	/**
	 * Returns the full id of a given tab
	 *
	 * @param id 	the changeable part of the tab id.
	 * @return		the fully qualified tab id.
	 */
	this.getTabId = function(id) {
		return "sandbox::tab::"+id;
	};

}

// register class...
var toolBoxId = null;
var sandBox = new SandBox();
mb.registerDOMReadyAction(
	new MbEventAction(sandBox.GID, "writeUI", "Setting up sandbox")
);