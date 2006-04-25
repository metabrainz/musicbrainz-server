function CollapseRelease() {
	
	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "CollapseRelease";
	this.GID = "collapserelease";
	mb.log.enter(this.CN, "__constructor");

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
					a.onclick = function onclick(event) { collapserelease.toggle(this); };
					
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
	this.toggle = function(el) {
		mb.log.enter(this.CN, "toggle");
		if (el) {
			var imgplus = new Image(); 
			imgplus.src = "/images/es/maximize.gif";
			var imgminus = new Image(); 
			imgminus.src = "/images/es/minimize.gif"; 

			var obj, img = el.firstChild;
			var display = "";
			if (img.src.match("maximize")) {
				img.src = imgminus.src;
				display = "";
			} else {
				img.src = imgplus.src;
				display = "none";
			}
			if ((obj = mb.ui.get(el.id.replace("expand", "releaselinks"))) != null) {
				obj.style.display = display;
			}
			if ((obj = mb.ui.get(el.id.replace("expand", "releaseevents"))) != null) {
				obj.style.display = display;
			}				
			var t,tid = el.id.replace("expand", "tracks");
			if ((t = mb.ui.get(tid)) != null) {
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

	// exit constructor
	mb.log.exit();
}


// register class...
var collapserelease = new CollapseRelease();
mb.registerDOMReadyAction(
	new MbEventAction(collapserelease.GID, "setupReleases", "Initialising CollapseRelease")
);

//toggleRelease(mb.ui.get("expand::82274"));


//	<script type="text/javascript">
//		document.writeln('<input type="checkbox" name="check" onchange="document.forms.BatchOp.AlbumId<% $releaseid %>.value = this.form.check.checked ? \'on\' : \'\';" <% $tagchecked ? " CHECKED" : "" %>>');
//	</script>
//	<noscript>
