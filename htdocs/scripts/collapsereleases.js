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

function CollapseReleases() {
	
	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "CollapseReleases";
	this.GID = "collapsereleases";
	mb.log.enter(this.CN, "__constructor");


	this.imgplus = new Image(); 
	this.imgplus.src = "/images/es/maximize.gif";
	this.imgminus = new Image(); 
	this.imgminus.src = "/images/es/minimize.gif"; 


	/**
	 * Go through all the releases of the current page
	 * and add the toggle icons. This functionality can
	 * be defined in the page tree using the two
	 * hidden fields:
	 *
	 * ~collapsereleases::defaultcollapse (0|1)
	 * ~collapsereleases::showtoggleicon	(0|1)
	 *
	 */
	this.setupReleases = function() {
		mb.log.enter(this.CN, "setupReleases");
		var obj,list = mb.ui.getByTag("table");
		
		var defaultcollapse = true;
		if ((obj = mb.ui.get("collapsereleases::defaultcollapse")) != null) {
			defaultcollapse = !(obj.value == 0);
		}	
		
		// if we're on the editlist, or editdetail page, there's
		// an option to turn of the collapsing the releases.
		if (showedit) {
			defaultcollapse = showedit.isCollapseReleasesEnabled();
		}
		
		var showtoggleicon = true;
		if ((obj = mb.ui.get("collapsereleases::showtoggleicon")) != null) {
			showtoggleicon = !(obj.value == 0);
		}	
		for (var i=0;i<list.length; i++) {
			var t = list[i];
			var id = (t.id || "");
			if (id.match(/tracks::\d+/i)) {
				
				// go through all the TR's of the table
				var defaultdisplay = (defaultcollapse ? "none" : "");
				var defaultimage =  (defaultcollapse ? "maximize" : "minimize");
				
				var rows = mb.ui.getByTag("tr", t);
				for (var j=0;j<rows.length; j++) {
					if (rows[j].className.match(/track|discid/i)) {
						rows[j].style.display = defaultdisplay;
					}
				}
				if ((obj = mb.ui.get(id.replace("tracks", "releaselinks"))) != null) {
					obj.style.display = defaultdisplay;
				}
				if ((obj = mb.ui.get(id.replace("tracks", "releaseevents"))) != null) {
					obj.style.display = defaultdisplay;
				}		
				
				if (showtoggleicon)
				{
					var elid = id.replace("tracks", "link");
					var el;
					if ((el = mb.ui.get(elid)) != null) {
						var parent = el.parentNode;
						var a = document.createElement("a");
						a.href = "javascript:; // Toggle release";
						a.id = id.replace("tracks", "expand");
						a.className = "toggle";
						a.onfocus = function onfocus(event) { this.blur(); };
						a.onclick = function onclick(event) { 
							var id = this.id.replace("expand", "tracks");
							collapsereleases.showRelease(id); 
							return false;
						};
						var img = document.createElement("img");

						img.src = "/images/es/"+defaultimage+".gif";
						img.className = "toggle";
						img.alt = "Toggle release";
						img.border = 0;
						a.appendChild(img);
						parent.insertBefore(a, el);

						parent.style.cursor = "pointer";
						parent.title = "Toggle release... If you hover the mouse cursor here, it opens automatically.";
						parent.id = id.replace("tracks", "title");					
						parent.onclick = function onclick(event) { 
							var id = this.id.replace("title", "tracks");
							collapsereleases.clearHoverTimeout(id);
							collapsereleases.showRelease(id);
							return true;
						};						
						parent.onmouseover = function onmouseover(event) { 
							var id = this.id.replace("title", "tracks");
							collapsereleases.setHoverTimeout(id);
						};							
						parent.onmouseout = function onmouseout(event) { 
							var id = this.id.replace("title", "tracks");
							collapsereleases.clearHoverTimeout(id);
						};							

					} else {
						mb.log.debug("Element $ not found", elid);
					}
					}
			}
		}
		mb.log.exit();
	};
	
	this.setHoverTimeout = function(id) {
		if (this.timeouts == null) {
			this.timeouts = [];
		}
		var func = "collapsereleases.showRelease('"+id+"', true)";
		this.timeouts[id] = setTimeout(func, 800);
	};
	
	this.clearHoverTimeout = function(id) {
		var ref = this.timeouts[id];
		clearTimeout(ref);
		this.timeouts[id] = null;
	};
	
	/**
	 * Go through all the releases of the current page
	 * and set their toggle status to the flag.
	 *
	 * @param flag	the new state (true|false)
	 */
	this.toggleAll = function(flag) {
		mb.log.enter(this.CN, "toggleAll");
		var list = mb.ui.getByTag("table");
		for (var i=0;i<list.length; i++) {
			var t = list[i];
			var id = (t.id || "");
			if (id.match(/tracks::\d+/i)) {	
				this.showRelease(id, flag);
			}
		}
	};
	
	
	/** 
	 * Set the new toggle status of the release with id
	 *
	 * @param id	the release id
	 * @param flag	the new state (true|false)
	 */
	this.showRelease = function(id, flag) {
		mb.log.enter(this.CN, "showRelease");
		var obj, img, t;
		
		// get reference to image object.
		if ((obj = mb.ui.get(id.replace("tracks", "expand"))) != null) {
			img = obj.firstChild;
		
			if (flag == null) {
				flag = img.src.match("maximize");
			}
			img.src = flag ? this.imgminus.src : this.imgplus.src;
			var display = flag ? "" : "none";
			
			if ((obj = mb.ui.get(id.replace("tracks", "releaselinks"))) != null) {
				obj.style.display = display;
			}
			if ((obj = mb.ui.get(id.replace("tracks", "releaseevents"))) != null) {
				obj.style.display = display;
			}				
			if ((t = mb.ui.get(id)) != null) {
				var rows = mb.ui.getByTag("tr", t);
				for (var j=0;j<rows.length; j++) {
					if (rows[j].className.match(/track|discid/i)) {
						rows[j].style.display = display;
					}
				}
			} else {
				mb.log.debug("Element $ not found", tid);
			}
		} else {
			alert("el is null");
		}
		mb.log.exit();
	};
	
	
	/**
	 * This function replaces the non-javascript variant of the
	 * batchop selection with the checkboxes for the BatchOp form.
	 * The visible fields of the batchop form are added during
	 * this function as well.
	 */
	this.setupReleaseBatch = function() {
		mb.log.enter(this.CN, "setupReleaseBatch");
		var obj,list = mb.ui.getByTag("table");
		for (var i=0;i<list.length; i++) {
			var t = list[i];
			var id = (t.id || "");
			if (id.match(/tracks::\d+/i)) {	
				
				var tagchecked = false;
				if ((obj = mb.ui.get(id.replace("tracks", "tagchecked"))) != null) {
					tagchecked = (obj.value == 1);
				}
				if ((obj = mb.ui.get(id.replace("tracks", "batchop"))) != null) {
					var releaseid = id.replace("tracks::", "");
					
					var input = document.createElement("input");
					input.id = id.replace("tracks", "batchcheckbox");
					input.type = "checkbox";
					input.onclick = function onclick(event) { 
						var releaseid = this.id.replace("batchcheckbox::", "");
						var fieldName = "releaseid"+releaseid;
						var batchOpForm, obj;
						if ((batchOpForm = mb.ui.get("BatchOp")) != null)  {
							if (batchOpForm[fieldName] != null)  {
								var value = batchOpForm[fieldName].value;
								batchOpForm[fieldName].value = (value == "off" ? "on" : "off");
							}
						}
					};			
					obj.innerHTML = "";
					obj.appendChild(input);
					input.checked = tagchecked;
					input.title = tagchecked ?
						"Deactivate this checkbox and click Update to unselect this release from the Batch Operations," :
						"Activate this checkbox and click Update to select this release for Batch Operations.";
				}				
			}
		}

		// get BatchOp form, then container element (div)
		// inside it, to add user interface.
		if ((obj = mb.ui.get("BatchOp")) != null) {
			if ((obj = mb.ui.getByTag("div", obj)[0]) != null) {
			
				// used in /edit/albumbatch/done.html
				if (obj.id == "batchop::removereleases") {
					var el = document.createElement("input");
					el.type = "submit";
					el.name = "submit";
					el.value = "Update";
					obj.appendChild(el);
				
				// used in /show/artist/ and /show/release/?
				} else if (obj.id == "batchop::selectreleases") {
				
					var el = document.createElement("input");
					el.type = "image";
					el.alt = "Batch Edit";
					el.title = "Edit selected release(s) in a batch edit";
					el.src = "/images/batch.gif";
					obj.appendChild(el);
					el.style.border = "0";
					el.style.height = "13px";
					el.style.width = "13px";
									
					el = document.createElement("a");
					el.href = "#";
					el.title = "Edit selected release(s) in a batch edit";
					el.onclick = function onclick(event) { 
						document.forms.BatchOp.submit(); 
						return false;
					};
					obj.appendChild(el);
					el.innerText = "Batch Operation"; 
					el.style.marginLeft = "5px";				
				}
			}
		}
	};

	// exit constructor
	mb.log.exit();
}


// register class...
var collapsereleases = new CollapseReleases();
mb.registerDOMReadyAction(
	new MbEventAction(collapsereleases.GID, "setupReleases", "Setting up release toggle functions")
);
mb.registerDOMReadyAction(
	new MbEventAction(collapsereleases.GID, "setupReleaseBatch", "Setup release batch operations")
);
 
