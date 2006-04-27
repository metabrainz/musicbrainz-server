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
	 *
	 */
	this.setupReleases = function() {
		mb.log.enter(this.CN, "setupReleases");
		var obj,list = mb.ui.getByTag("table");
		for (var i=0;i<list.length; i++) {
			var t = list[i];
			var id = (t.id || "");
			if (id.match(/tracks::\d+/i)) {
				
				// go through all the TR's of the table
				var rows = mb.ui.getByTag("tr", t);
				for (var j=0;j<rows.length; j++) {
					if (rows[j].className.match(/track|discid/i)) {
						rows[j].style.display = "none";
					}
				}
				if ((obj = mb.ui.get(id.replace("tracks", "releaselinks"))) != null) {
					obj.style.display = "none";
				}
				if ((obj = mb.ui.get(id.replace("tracks", "releaseevents"))) != null) {
					obj.style.display = "none";
				}		

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
					};
					var img = document.createElement("img");
					img.src = "/images/es/maximize.gif";
					img.className = "toggle";
					img.alt = "Toggle release";
					img.border = 0;
					a.appendChild(img);
					parent.insertBefore(a, el);

				} else {
					mb.log.debug("Element $ not found", elid);
				}
			}
		}
		mb.log.exit();
	};
	
	
	/**
	 *
	 */
	this.toggleAll = function(flag) {
		mb.log.enter(this.CN, "setupReleases");
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
	 *
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
	 * This function replaces the "remove" in the release title
	 * with a checkbox for the BatchOp form.
	 *
	 */
	this.setupReleaseBatch = function() {
		mb.log.enter(this.CN, "showRelease");
		var obj,list = mb.ui.getByTag("table");
		for (var i=0;i<list.length; i++) {
			var t = list[i];
			var id = (t.id || "");
			if (id.match(/tracks::\d+/i)) {	
				
				var tagchecked = false;
				if ((obj = mb.ui.get(id.replace("tracks", "tagchecked"))) != null) {
					tagchecked = obj.value;
				}
				if ((obj = mb.ui.get(id.replace("tracks", "batchop"))) != null) {
					var releaseid = id.replace("tracks::", "");
					
					var input = document.createElement("input");
					input.id = id.replace("tracks", "batchcheckbox");
					input.type = "checkbox";
					input.onchange = function onclick(event) { 
						var batchOpForm = document.forms.BatchOp;
						var releaseid = this.id.replace("batchcheckbox::", "");
						var fieldName = "AlbumId"+releaseid;
						if (batchOpForm) {
							var value = batchOpForm[fieldName].value;
							batchOpForm[fieldName].value = (value == "off" ? "on" : "off");
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
		// inside it, to add the Update button
		if ((obj = mb.ui.get("BatchOp")) != null) {
			if ((obj = obj.firstChild) != null) {
				var input = document.createElement("input");
				input.type = "submit";
				input.name = "submit";
				input.value = "Update";
				obj.appendChild(input);
			}
		}
	};

	// exit constructor
	mb.log.exit();
}


// register class...
var collapsereleases = new CollapseReleases();
mb.registerDOMReadyAction(
	new MbEventAction(collapsereleases.GID, "setupReleases", "Initialising CollapseReleases")
);

mb.registerDOMReadyAction(
	new MbEventAction(collapsereleases.GID, "setupReleaseBatch", "Initialising CollapseReleases")
);


//toggleRelease(mb.ui.get("expand::82274"));


//	<script type="text/javascript">
//		document.writeln('<input type="checkbox" name="check" onchange="document.forms.BatchOp.AlbumId<% $releaseid %>.value = this.form.check.checked ? \'on\' : \'\';" <% $tagchecked ? " CHECKED" : "" %>>');
//	</script>
//	<noscript>
