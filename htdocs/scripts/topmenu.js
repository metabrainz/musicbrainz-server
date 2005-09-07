
var mm_sublist = null; // keeps reference of the submenu divs
var mm_closeTO = null; // timeout ref. for menu close-time
var mm_openTO = null; // timeout ref. for menu open-time
var mm_offsetLeft = 142; // offset of the menu from the left border
var mm_mainMenuCloseTimeout = 500;
var mm_subMenuCloseTimeout = 500;
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
			var obj;
			for (var j=0; j<mm_items.length; j++) { // position the menu elements.
				var mName = mm_items[j][0];
				if ((obj = document.getElementById(mName)) != null) {
					var mPos = mm_offsetLeft + obj.offsetLeft;
					if ((obj = document.getElementById(mName+"_sub")) != null) {
						obj.style.left = mPos;
						mm_sublist[mm_sublist.length] = obj;
					}
				}
			}
		}
		id += "_sub";
		for (var i=0; i<mm_sublist.length; i++) {
			var slID = mm_sublist[i].id;
			var found = (id == slID);
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
// - get sidemenu state from cookie and sets the
//   sidemenu visibility.
function mm_onPageLoad() {
	var mode = getCookie(MM_COOKIE_SIDEMENU); // 
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
	document.writeln('<div class="inner" onmouseout="mm_onMouseOut()">');
	for (var i=0; i<mm_items.length; i++) {
		var mName = mm_items[i][0];
		var mURL = mm_items[i][1];
		var mTitle = mm_items[i][2];

		// compile css-class
		// * rightmost item gets class "right"
		// * if selected, add "selected" to class 
		//   e.g. either "selected" or "rightselected"
		var cssClass = (i < mm_items.length-1 ? "" : "right"); 
		cssClass += (selmenu == mName ? 'selected' : ''); 
		cssClass = (cssClass != "" ? 'class="'+cssClass+' "' : '');
		document.write('<a ' + cssClass);
		document.write('onmouseover="mm_onMouseOver(this)" ');
		document.write('onmouseout="mm_onMouseOut(this)" ');
		document.write('title="'+mTitle+'" id="'+mName+'" ');
		document.write('href="'+mURL+'">'+mTitle+'</a>');

		// removed to fit mainmenu into 800x600 
		// screen estate. ' <img src="/images/dropdown.gif" alt="*" border="">'
	}
	document.writeln('</div>');
}

// mm_onMouseOver()
function mm_onMouseOver(elem) {		
	// if (mm_open) mm_showSubmenu(elem.id);
	mm_open = true;
	mm_showSubmenu(elem.id);
}

// onMouseOut
// - triggered when mouse leaves a main menu item
//   (sets a timeout of 2 seconds, then closes the submenu)
function mm_onMouseOut() {
	clearTimeout(mm_closeTO); 
	mm_closeTO = setTimeout("mm_showSubmenu()", mm_mainMenuCloseTimeout);
}

// mm_onClick()
function mm_onClick(elem) {
	mm_open = (!mm_open);
	mm_showSubmenu(mm_open ? elem.id : "");
	return false;
}

// mm_sub_onMouseOver()
// - triggered when mouse enters a submenu (clears the timeouts)
function mm_sub_onMouseOver() {
	clearTimeout(mm_openTO); 
	clearTimeout(mm_closeTO);
}

// mm_sub_onMouseOut()
// - triggered when mouse leaves a submenu 
//   (sets a timeout of 2 seconds, then closes the submenu)
function mm_sub_onMouseOut() {
	clearTimeout(mm_closeTO);
	mm_closeTO = setTimeout("mm_showSubmenu()", mm_subMenuCloseTimeout);
}

