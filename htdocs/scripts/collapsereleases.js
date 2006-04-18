
mb.log.scopeStart("Collapsing release tables...");


var obj,list = mb.ui.getByTag("table");
for (var i=0;i<list.length; i++) {
	var t = list[i];
	var id = (t.id || "");
	if (id.match(/tracks::\d+/i)) {
		// go through all the TR's of the table
		/*
		var rows = mb.ui.getByTag("tr", t);
		for (var j=0;j<rows.length; j++) {
			if (rows[j].className.match(/track|discid|summary/i)) {
				rows[j].style.display = "none";
			}
		}
		if ((obj = mb.ui.get(id.replace("tracks", "releaselinks"))) != null) {
			obj.style.display = "none";
		}
		if ((obj = mb.ui.get(id.replace("tracks", "releaseevents"))) != null) {
			obj.style.display = "none";
		}		
		*/
		
		var elid = id.replace("tracks", "link");
		var el;
		if ((el = mb.ui.get(elid)) != null) {
			var parent = el.parentNode;
			var a = document.createElement("a");
			a.href = "javascript:; // Toggle release";
			a.id = id.replace("tracks", "expand");
			a.style.padding = "0px";
			a.style.margin = "0px";
			a.style.marginLeft = "2px";
			a.style.marginRight = "4px";
			a.onfocus = function onfocus(event) { this.blur(); };
			a.onclick = function onclick(event) { toggleRelease(this); };
			var img = document.createElement("img");
			img.src = "/images/plus.gif";
			img.style.padding = "0px";
			img.style.margin = "0px";
			img.style.marginTop = "2px";
			img.alt = "Toggle release";
			img.border = 0;
			a.appendChild(img);
			parent.insertBefore(a, el);

		} else {
			mb.log.debug("Element $ not found", elid);
		}
	}
}

function toggleRelease(el) {
	if (el) {
		var imgplus = new Image(); imgplus.src = "/images/plus.gif";
		var imgminus = new Image(); imgminus.src = "/images/minus.gif";
	
		alert(el.firstChild);
	
		var obj, img = el.firstChild;
		var display = "";
		if (img.src.match("plus")) {
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
		var t,tid = this.id.replace("expand", "tracks");
		if ((t = mb.ui.get(tid)) != null) {
			var rows = mb.ui.getByTag("tr", t);
			for (var j=0;j<rows.length; j++) {
				if (rows[j].className.match(/track|discid|summary/i)) {
					rows[j].style.display = display;
				}
			}
		} else {
			mb.log.debug("Element $ not found", tid);
		}
	} else {
		alert("el is null");
	}
}

//toggleRelease(mb.ui.get("expand::82274"));