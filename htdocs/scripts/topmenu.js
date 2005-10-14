var mm_status = "load";		// load|init|ready
var mm_closeTO = null; // timeout reference for menu close-time
var mm_openTO = null; // timeout reference for menu open-time
var mm_offsetLeft = 157; // offset of the menu from the left border
var mm_mmLeaveTimeout = 500; // the time that elapses until the dropdown is
							 // closed after leaving a mainmenu item. this
							 // timeout is restarted when re-entering another
							 // mainmenu item.
var mm_ddLeaveTimeout = 500; // the time that elapses until the dropdown is
							 // closed after leaving a dropdown item. this
							 // timeout gets reset when re-entering another
							 // dropdown.
var MM_COOKIE_SIDEBAR = "sidebar"; // side bar cookie name

// mm_activateDropdown()
// ------------------------------------------------------------------
// This function gets called whenever the submenu with id=dd
// has to assume a different state. When opening the submenu
// it calls itself with waited=true, such that the small time
// of 20 [ms] elapses before opening the menu (this is modelled
// after dropdown menu's in GUIs.
// If dd is omitted, all dropdown elements are hidden. The same
// happens if the mouse leaves a dropdown menu without clicking
// any link - a timeout occurs and this function is called 
// without arguments.
function mm_activateDropdown(dd, waited) {
	if (mm_status == "init") return; // not ready, return
	var id = (dd == null ? "" : dd);
	if (id != "" && waited == null) {
		clearTimeout(mm_openTO);
		clearTimeout(mm_closeTO);
		mm_openTO = setTimeout("mm_activateDropdown('"+id+"', true)", 20);
	} else {
		clearTimeout(mm_openTO);
		if (mm_status == "load") {
			mm_status = "init";
			mm_sublist = new Array();
			var obj;
			// for all items of the mainmenu, find the offsetLeft
			// position (origin + x pixels) and move the dropdown
			// menu's to the same location.
			for (var j=0; j<mm_items.length; j++) { 
				var mName = mm_items[j][0];
				if ((obj = document.getElementById(mName)) != null) {
					mm_items[j][3] = obj;
					var mPos = mm_offsetLeft + obj.offsetLeft;
					if ((obj = document.getElementById(mName+"_sub")) != null) {
						obj.style.left = ""+mPos+"px";
						mm_items[j][4] = obj;
					}
				}
			}
			mm_status = "ready";
		}

		// Some browsers force iframes to be at the top of the
		// z-index stack, which means that the submenus fall
		// behind the iframe (e.g. Konqueror does this).
		// It's clunky, but what we therefore do is to hide
		// the "related moderations" iframe whenever the menu
		// is open.
		var e = document.getElementById("RelatedModsBox");
		if (e) e.style.display = (id == "" ? "block" : "none")

		// update display (mainmenu item css / dropdown menu)
		for (var j=0; j<mm_items.length; j++) { 
			var mName = mm_items[j][0];
			var isCurr = (mName == id);

			// set the correct hover class 
			var cn = mm_items[j][3].className;
			mm_items[j][3].className = 
				(isCurr ? (cn.indexOf("hover") == -1 ? cn+"hover" : cn)
						: (cn.replace("hover", ""))
				);

			// show the submenu 
			mm_items[j][4].style.display = (isCurr ? "block" : "none");
		}
	}
}

// mm_toggleSideBar()
// ------------------------------------------------------------------
// - hides the side navigation bar to free up some screen
//   real estate. This function works as a toggle if show
//   is omitted, but can be set directly when providing
//   the parameter.
//
// Note: The display attribute of TD-elements should be "table-cell"
// according to W3C, but many browsers fail to handle this 
// (whereas using "block" seems to be OK in just about all cases).
function mm_toggleSideBar(show) {
	var elem = document.getElementById("sidebar-td");
	if (!elem) return;
	if (show == null) {
		if (elem.style.display != "") show = true;
		else show = false;
	}
	if (elem) {
		elem.style.display = (show ? "" : "none");
		elem.style.width = (show ? "140px" : "0px");
		// forcing the size of the td upon
		// redisplaying it helps.
	}
	if ((elem = document.getElementById("content-td")) != null) {
		elem.style.width = "100%";
	}
	if ((elem = document.getElementById("sidebar-toggle-show")) != null) {
		elem.style.display = (show ? "none" : "inline");
	}
	if ((elem = document.getElementById("sidebar-toggle-hide")) != null) {
		elem.style.display = (show ? "inline": "none");
	}
	// set a persistent cookie for the next 365 days.
	setCookie(MM_COOKIE_SIDEBAR, (show ? "1" : "0"), 365);
}

// mm_DrawToggle()
// ------------------------------------------------------------------
// Draws the sidebar toggle links. 
function mm_DrawToggle() {
	var states = [
		["hide", "Hide side bar", "minimize.gif"], 
		["show", "Show side bar", "maximize.gif"]
	];
	for (si in states) {
		var _id = states[si][0];
		var _text = states[si][1];
		var _icon = states[si][2];
		document.write('<table id="sidebar-toggle-'+_id+'" border="0" cellspacing="0" cellpadding="0">');
		document.write('<tr><td>');
		document.write('<a href="javascript: /* toggle side bar */" ');
		document.write('  onClick="try { mm_toggleSideBar(null); } ');
		document.write('    catch (e) { /* fail quietly */ }" ');
		document.write('  title="'+_text+'">'+_text+'<\/a>');
		document.write('<\/td><td>');
		document.write('<img src="/images/icon/'+_icon+'" alt="">');
		document.write('<\/td><\/tr><\/table>');
	}
}


// mm_initialiseSideBar()
// ------------------------------------------------------------------
// Gets sidemenu state from cookie and sets the sidemenu visibility.
// If no value can be obtained from the cookie, assume open state, 
// else compare cookie value to "1", where 1=open, 0=closed
//
// Note: mm_initialiseSideBar could be done in "onload" (as the name 
// suggests); however instead we do it as soon as both sidemenu-td and 
// the sidebar toggles are available in the document tree. This way,
// no flickering of the screen (or appear/reappear oddities) occur,
// opposite if this function would be called during the onLoad handler.
// On the other hand it's possible that some browsers may not like this, in
// which case uncomment the following (and remove the call from comp/sidebar)
// to do all this during "onload" instead.
// AddOnLoadAction(mm_initialiseSideBar);
function mm_initialiseSideBar() {
	var mode = getCookie(MM_COOKIE_SIDEBAR); // 
	mm_toggleSideBar((!mode ? "1" : mode) == "1");
}


// mm_buildMainMenu()
// ------------------------------------------------------------------
// This function is called from /comp/topmenu. It expects a mm_items 
// array where each entry is an array of [name, url, displayed title]
// It builds the list of orange/violet topmenu entries. The item which 
// corresponds to selmenu is highlighted.
//
// Note 1: The css-class of the elements is set depending
// of the order of the item in the menu:
// * rightmost item gets class "right"
// * if selected, add "selected" to class 
//   e.g. either "selected" or "rightselected"
//
// Note 2: Gecko browsers disable the eventhandlers in the
// mm_* namespace before disallowing the events to fire, this
// results in JavaScript errors during the transition to another page
// - just catch the errors quietly.
function mm_buildMainMenu(selmenu) {
	document.writeln('<table cellspacing="0" cellpadding="0" border="0"><tr>');
	for (var i=0; i<mm_items.length; i++) {
		var mName = mm_items[i][0];
		var mURL = mm_items[i][1];
		var mTitle = mm_items[i][2];

		// build css
		var cssClass = (i < mm_items.length-1 ? "" : "right"); 
		cssClass += (selmenu == mName ? 'selected' : ''); 
		cssClass = (cssClass != "" ? 'class="'+cssClass+'"' : '');
		
		// write <a> tag
		document.writeln('<td ' + cssClass);
		document.write('onmouseover="try { mm_onMouseOver(this); } catch (e) { /* fail quietly */ }" ');
		document.write('onmouseout="try { mm_onMouseOut(this); } catch (e) { /* fail quietly */ }" ');
		document.write('onclick="try { document.location.href = \''+mURL+'\'; } catch (e) { /* fail quietly */ }" ');
		document.write('id="'+mName+'" ');
		document.write('><a ');
		document.write('title="'+mTitle+'" ');
		document.write('href="'+mURL+'">'+mTitle+'</a></td>');
	}
	document.writeln('</tr></table>');
	
}

// mm_onMouseOver()
// ------------------------------------------------------------------
// Hovering over a main-menu element opens the corresponding
// dropdown menu. 
function mm_onMouseOver(elem) {	
	mm_activateDropdown(elem.id);
}

// onMouseOut
// ------------------------------------------------------------------
// - triggered when mouse leaves a main menu item
//   (sets a timeout of mm_mmLeaveTimeout seconds, then closes the submenu)
function mm_onMouseOut() {
	clearTimeout(mm_closeTO); 
	mm_closeTO = setTimeout("mm_activateDropdown()", mm_mmLeaveTimeout);
}

// mm_sub_onMouseOver()
// ------------------------------------------------------------------
// - triggered when mouse enters a submenu (clears the timeouts)
function mm_sub_onMouseOver() {
	clearTimeout(mm_openTO); 
	clearTimeout(mm_closeTO);
}

// mm_sub_onMouseOut()
// ------------------------------------------------------------------
// - triggered when mouse leaves a submenu 
//   (sets a timeout of mm_ddLeaveTimeout seconds, then closes the submenu)
function mm_sub_onMouseOut() {
	clearTimeout(mm_closeTO);
	mm_closeTO = setTimeout("mm_activateDropdown()", mm_ddLeaveTimeout);
}

