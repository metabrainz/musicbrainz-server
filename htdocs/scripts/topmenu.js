
var mm_sublist = null; // keeps reference of the submenu divs
var mm_closeTO = null; // timeout ref. for menu close-time
var mm_openTO = null; // timeout ref. for menu open-time
var mm_offsetLeft = 142; // offset of the menu from the left border
var mm_open = false;
var MM_COOKIE_SIDEMENU = "sidemenu";

// mm_showSubmenu()
// - triggered when mouse enters a main menu item
function mm_showSubmenu(theID, waited) {
	var id = (theID == null ? "" : theID);
	if (id != "" && waited == null) {
		clearTimeout(mm_openTO);
		clearTimeout(mm_closeTO);
		mm_openTO = setTimeout("mm_showSubmenu('"+id+"', true)", 20);
	} else {
		if (id == "") mm_open = false; // after timeout, reset mm_open variable.
		clearTimeout(mm_openTO);
		if (mm_sublist == null) {
			mm_sublist = new Array();
			for (var j=0; j<mm_items.length; j++) { // position the menu elements.
				var mid	= document.getElementById(mm_items[j]);
				var lid = mm_items[j]+"_sub";
				var subdiv = document.getElementById(lid);
				if (subdiv  != null) {
					subdiv.style.left = mm_offsetLeft + mid.offsetLeft;
					mm_sublist[mm_sublist.length] = subdiv;
				}
			}
		}
		for (var i=0; i<mm_sublist.length; i++) {
			var slID = mm_sublist[i].id;
			var found = (id != "" && slID.indexOf(id) != -1);
			mm_sublist[i].style.display = (found ? "block" : "none");
		}
	}
}

// mm_toggleSideMenu()
// - triggered when mouse enters a main menu item
function mm_toggleSideMenu(flag) {
	var setDisplayById = function(id, display) {
		var ele = document.getElementById(id);
		// IE does not like 'table-cell', use 'block'
		if (display == "table-cell" && document.all)
			display = "block";
		if (ele) ele.style.display = display;
	};

	if (flag) {
		setDisplayById("sidemenu-td", "table-cell");
		setDisplayById("sidemenu-coll", "none");
	} else {
		setDisplayById("sidemenu-td", "none");
		setDisplayById("sidemenu-coll", "block");
	}

	setCookie(MM_COOKIE_SIDEMENU, flag ? "1" : "0", null, "/");
}

// mm_onPageLoad()
// - triggered when mouse enters a main menu item
function mm_onPageLoad() {
	var mode = getCookie(MM_COOKIE_SIDEMENU); // get autofix mode from cookie.
	if (mode) mm_toggleSideMenu(mode == "1");
}

// mm_onPageLoad could be done in "onload" (as the name suggests); however
// instead we do it as soon as both sidemenu-td and sidemenu-coll are ready.
// It seems to avoid "appear/disappear" whilst loading.
// On the other hand it's possible that some browsers may not like this, in
// which case uncomment the following (and remove the call from comp/sidebar)
// to do all this during "onload" instead.
// AddOnLoadAction(mm_onPageLoad);

// mm_buildMainMenu()
// - triggered when mouse enters a main menu item
function mm_buildMainMenu(selmenu) {
	document.writeln('<div onMouseOut="mm_onMouseOut()">');
	for (var i=0; i<mm_items.length; i++) {
		var mm = mm_items[i];
		var t = mm.replace("mm_", "");
		var tArr = t.toLowerCase().split("");
		tArr [0] = tArr[0].toUpperCase();
		t = tArr.join("");
		var cssClass = (i < mm_items.length-1 ? "" : "right"); // rightmost item gets class "right"
		cssClass += (selmenu == mm ? 'selected' : ''); // if selected, add "selected" to class -> either "selected" or "rightselected"
		cssClass = (cssClass != "" ? 'class="'+cssClass+' "' : '');
		document.write('<a ' + cssClass);
		document.write('onDblClick="return mm_onDoubleClick(this)" onMouseOver="mm_onMouseOver(this)" ');
		document.write('onClick="return mm_onClick(this)" onFocus="this.blur()" ');
		document.write('title="'+t+' - Click here to open submenu" id="'+mm+'" ');
		document.write('href="javascript: // open sub-menu">'+t
			// +' <img src="/images/dropdown.gif" alt="*" border="">'
			+ '</a>');
	}
}

// mm_onMouseOver()
function mm_onMouseOver(elem) {		
	if (mm_open) mm_showSubmenu(elem.id);
}

// mm_onClick()
function mm_onClick(elem) {
	mm_open = (!mm_open);
	mm_showSubmenu(mm_open ? elem.id : "");
	return false;
}

// mm_onDoubleClick()
function mm_onDoubleClick(elem) {
	document.location.replace(elem.href);
	return true;
}

// onMouseOut
// - triggered when mouse leaves a main menu item
//   (sets a timeout of 2 seconds, then closes the submenu)
function mm_onMouseOut() {
	clearTimeout(mm_closeTO); mm_closeTO = setTimeout("mm_showSubmenu()", 2000);
}

// mm_sub_onMouseOver()
// - triggered when mouse enters a submenu (clears the timeouts)
function mm_sub_onMouseOver() {
	clearTimeout(mm_openTO); clearTimeout(mm_closeTO);
}

// mm_sub_onMouseOut()
// - triggered when mouse leaves a submenu 
//   (sets a timeout of 2 seconds, then closes the submenu)
function mm_sub_onMouseOut() {
	clearTimeout(mm_closeTO); mm_closeTO = setTimeout("mm_showSubmenu()", 2000);
}

