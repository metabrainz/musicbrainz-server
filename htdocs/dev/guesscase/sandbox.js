function SandBoxPage(id, name, content, table) {
	this.id = id;
	this.name = name;
	this.content = content;
	this.table = table;
}

// ****************************************************************************
// SandBox class
// ****************************************************************************
function SandBox() {
	this.CN = "sb";

	this.COOKIE_TAB = "SANDBOX_TAB";
	this.pages = [];

	this.tp = new TrackParserTest();

	// Tests the split splitWordsAndPunctuation function.
	// ----------------------------------------------------------------------------
	this.testSplit = function() {
		mb.log.setLevel(mb.log.DEBUG);
		mb.log.scopeStart("Handling click on 'Test Split' function.");
		var ov = document.getElementById("splittesttext").value;
		mb.log.info("Attempting to split: $", ov);
		var nv = gc.io.splitWordsAndPunctuation(ov);
		mb.log.info("Split value: $", nv);
		mb.log.scopeEnd();
	};

	// Writes the sandbox UI to the document
	// ----------------------------------------------------------------------------
	this.onSetFieldCountClicked = function() {
		mb.log.scopeStart("Handling click on 'setFieldCount' function.");
		this.setFieldCount(true);	
		mb.log.scopeEnd();
	};

	// Writes the sandbox UI to the document
	// ----------------------------------------------------------------------------
	this.setFieldCount = function(interactive) {
		var obj, tr, cn, last, parent;
		if ((obj = document.getElementById("numberOfFieldsSize")) != null) {
			var count = obj.value;
			var id, trs = document.getElementsByTagName("tr");
			var template = [], removefields = [];
			for (i=0; i<trs.length; i++) {
				tr = trs[i], cn = (tr.className || "");
				if (tr == null) continue;
				if (cn == "field") {
					template.push(tr);
				} else if (cn == "fieldclone") {
					removefields.push(tr);
				} else if (cn == "lastfield") {
					last = tr;
				}
			}
			for (i=0; i<removefields.length; i++) {
				tr = removefields[i];
				parent = tr.parentNode;
				parent.removeChild(tr);
			}

			if (template.length > 0) {
				parent = last.parentNode;
				for (i=1; i<count; i++) {
					for (var j=0; j<template.length; j++) {
						var n,f,k;
						var node = template[j].cloneNode(true);
						node.className = "fieldclone";
						var nid = i;

						var tnprefix = "Track ";
						var track = 1;
						var tracklength = 2;
						var buttons = 3;

						if ((f = es.ui.getForm()) != null) {
							if (f["artistname0"] != null) {
								tnprefix = "";
								track = 2;
								tracklength = 3;
								buttons = 4;
							}
						}

						// handle number
						if ((n = node.childNodes[0])) {
							f = n.firstChild;
							if (f && f.nodeValue) {
								n.removeChild(f);
								n.appendChild(document.createTextNode(tnprefix+(nid+1)+":"));
							}
						}

						// handle track/artist fields
						if ((n = node.childNodes[track])) {
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
						if ((n = node.childNodes[tracklength])) {
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
						if ((n = node.childNodes[buttons])) {
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
						parent.insertBefore(node, last);
					}
				}
				if (interactive) es.ui.setupFormFields();
			}
		}
	};

	// Writes the sandbox UI to the document
	// ----------------------------------------------------------------------------
	this.writeUI = function() {
		mb.log.scopeStart("Writing Sandbox UI");
		mb.log.enter(this.CN, "writeUI");
		var obj,i,page,s = [];
		this.pages = [];

		// get sandboxpage tables from document
		var pagecounter = 0, id, tables = document.getElementsByTagName("table");
		var pageRE = /sandboxpage\|/;
		for (i=0; i<tables.length; i++) {
			obj = tables[i];
			id = (obj.id || "");
			if (id.match(pageRE)) {
				id = id.replace(pageRE, "");
				s = [];
				s.push('<fieldset class="fieldset">');
				s.push('  <legend>'+id+'</legend>');
				s.push('  <table border="0">');
				s.push(obj.innerHTML);
				s.push('  </table>');
				s.push('</fieldset>');
				var p = new SandBoxPage("t"+(pagecounter++), id, s.join(""), obj);
				this.pages.push(p);
				mb.log.info("Added sandbox page: $, name: $", p.id, p.name);
			}
		}
		s = [];

		// write sandbox menu-tabs
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
		document.write(s.join(""));

		// attach event handlers to the menu
		for (i=0; i<this.pages.length; i++) {
			page = this.pages[i];
			if ((obj = document.getElementById(this.getTabId(page.id))) != null) {
				obj.firstChild.id = page.id;
				obj.firstChild.onclick= function onclick(event) { sandBox.selectTab(this.id); };
			}
			page.table.parentNode.removeChild(page.table); // remove stub table from document
		}

		// get currently selected tab from cookie
		var st = mb.cookie.get(this.COOKIE_TAB);
		this.selectedTab = ((st || "").match(/t\d/) ? st : "t0");
		this.selectTab(this.selectedTab, true);

		// write debug UI
		mb.log.writeUI();
		mb.log.exit();
	};
	// mb.registerDOMLoadedAction(new EventAction("sandBox", "setFieldCount"));



	// Writes the sandbox UI to the document
	// ----------------------------------------------------------------------------
	this.selectTab = function(tid, init) {
		if (!init) {
			mb.log.scopeStart("Handling Click on tab...");
		}
		mb.log.enter(this.CN, "selectTab");
		var obj,i,page, id;

		// hiding current tab
		if (this.currentTab) {
			id = this.getTabId(this.currentTab);
			if ((obj = document.getElementById(id)) != null) {
				obj.className = "tab";
				mb.log.info("Hidden current tab: $", id);
			} else {
				mb.log.error("Did not find tab: $", id);
			}
		}

		// looking for selected tab, and showing it
		id = this.getTabId(tid);
		if ((obj = document.getElementById(id)) != null) {
			obj.className = "tab selected";
		} else {
			mb.log.error("Did not find tab: $", id);
		}

		// loop through the tabs, and find the content
		// to be displayed.
		for (i=0; i<this.pages.length; i++) {
			page = this.pages[i];
			if (tid == page.id) {
				if ((obj = document.getElementById("writeroot")) != null) {
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

	// Returns the full id of a given sandbox element
	// ----------------------------------------------------------------------------
	this.getTabId = function(id) {
		return "sandbox-tab-"+id;
	};

}
var sandBox = new SandBox();
