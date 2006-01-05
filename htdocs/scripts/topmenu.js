
var topMenu = {
	// load|init|ready, and open|closed
	status : "load", 		
	timer : { 
		// timeout reference for menu close-time
		close: null,
		// timeout reference for menu open-time
		open: null, 
		// the time that elapses until the dropdown is closed after leaving a mainmenu item. this
		// timeout is restarted when re-entering another mainmenu item.
		leftMenuTime: 500,
		// the time that elapses until the dropdown is closed after leaving a dropdown item. this
		// timeout gets reset when re-entering another dropdown.
		leftSubMenuTime: 500,

		// Set the list of menu items
		// ------------------------------------------------------------------
		reset : function() {
			clearTimeout(this.open); clearTimeout(this.close);
		},
		hasLeftMenu : function() {
			clearTimeout(this.close); 
			this.close = setTimeout(
				"topMenu.hideDisplayedDropDown()", this.leftMenuTime
			);
		},
		hasLeftSubMenu : function() {
			clearTimeout(this.close);
			this.close = setTimeout(
				"topMenu.hideDisplayedDropDown()", this.leftSubMenuTime
			);
		}
	},

	// offset of the menu from the left border
	menuOffsetLeft : 157,

	EV_MAIN_OVER : "EV_MAIN_OVER",
	EV_MAIN_OUT : "EV_MAIN_OUT",
	EV_MAIN_CLICK : "EV_MAIN_CLICK",
	EV_DROPDOWN_CLICK : "EV_DROPDOWN_CLICK",
	EV_DROPDOWN_OVER : "EV_DROPDOWN_OVER",
	EV_DROPDOWN_OUT : "EV_DROPDOWN_OUT", 

	// The list of menu items
	items : [],
	hashes : { menuItems : [], menuLinks : [], submenuItems : [] },

	// Set the list of menu items
 	// ------------------------------------------------------------------
	setItems : function(items) { this.items = items; },

	// The configuration options from the userprefs
	config : { types: "both", trigger: "mouseover" },

	// Configures which type of submenues the user
	// has chosen.
	// ------------------------------------------------------------------
	setConfigType : function(t) {
		if (t && t.match(/both|dropdownonly|staticonly/i)) {
			// config: both(default)|dropdownonly|staticonly
			this.config.types = t.toLowerCase();
		}
	},
	allowDropdowns : function() { return this.config.types.match(/both|dropdownonly/); },

	// Configures the trigger function which activates
	// the dropdown menues.
	// ------------------------------------------------------------------
	setConfigTrigger : function(t) {
		if (t && t.match(/mouseover|click/i)) {
			// config: mouseover|click
			this.config.trigger = t.toLowerCase();
		}
	},

	// Returns if the onMouseOver handler may open the dropdowns
	// ------------------------------------------------------------------
	allowTriggerMouseover : function() { return this.allowDropdowns() && 
												this.config.trigger == "mouseover"; },

	// Returns if the onClick handler may open the dropdowns
	// ------------------------------------------------------------------
	allowTriggerClick : function() { return this.allowDropdowns() && 
											this.config.trigger == "click"; },

	// Clicking on the dropdown icon opens the dropdown menu. 
	// ------------------------------------------------------------------
	handleEvent : function(elem, ev) {
		// window.status = ("handleEvent :: "+elem.id+" "+ev+" "+this.config.trigger+" "+this.config.types+" "+this.status);

		if (this.status == "load") this.handleSetup(); // lazy initialise
		if (this.status == "init") return; // not yet ready, return
		if (arguments.length == 2) {
			if (ev == this.EV_MAIN_OVER) {
				this.handleMouseOver(elem.id, true);
				if (this.allowTriggerMouseover()) {
					// onMouseOver mode
					this.timer.reset();	
					this.activateDropdown(elem.id);
				} else if (this.displayedDropDown != null) {
					// onClick mode, and another dropdown is visible
					// means activate this one, and disable other one.
					this.timer.reset();	
					this.activateDropdown(elem.id);
				}
			} else if (ev == this.EV_MAIN_OUT) {
				this.handleMouseOver(elem.id, false);
				this.timer.hasLeftMenu();
			} else if (ev == this.EV_MAIN_CLICK) {
				var url = null;
				if ((url = this.hashes.menuLinks[elem.id]) != null) {
					try {
						document.location.href = url;
					} catch (e) {}
				}
			} else if (ev == this.EV_DROPDOWN_CLICK) {
				if (this.allowTriggerClick()) {
					this.timer.reset();	
					if (this.displayedDropDown) this.hideDisplayedDropDown();
					else this.activateDropdown(elem.id);
				}
			} else if (ev == this.EV_DROPDOWN_OVER) {
				this.timer.reset();
			} else if (ev == this.EV_DROPDOWN_OUT) {
				this.timer.hasLeftSubMenu();

			} else {
				// unhandled
			}
		}
	},

	// Add/Remove hover to css class depending on flag.
	// ------------------------------------------------------------------
	handleMouseOver : function(id, flag) {
		var obj = null;
		if ((obj = this.hashes.menuItems[id]) != null) {
			var cn = obj.className;
			if (flag && cn.indexOf("hover") == -1) obj.className = cn+"hover";
			else if (!flag && cn.indexOf("hover") != -1)  obj.className = cn.replace("hover", "");
		}
	},

	// Add/Remove hover to css class depending on flag.
	// ------------------------------------------------------------------
	hideDisplayedDropDown : function() {
		if (this.displayedDropDown) {
			var obj = null;
			if ((obj = this.hashes.submenuItems[this.displayedDropDown]) != null) {
				obj.style.display = "none"; // hide displayed dropdown
			}
		}
		this.hideRelatedModsIframe(false);
		this.displayedDropDown = null;
	},

	// Add/Remove hover to css class depending on flag.
	// ------------------------------------------------------------------
	activateDropdown : function(id) {
		var obj = null;
		this.hideDisplayedDropDown();
		if ((obj = this.hashes.submenuItems[id]) != null) {			
			this.hideRelatedModsIframe(true);
			obj.style.display = "block"; // hide old dropdown
			this.displayedDropDown = id;
		}
	},

	// Some browsers force iframes to be at the top of the
	// z-index stack, which means that the submenus fall
	// behind the iframe (e.g. Konqueror does this).
	// It's clunky, but what we therefore do is to hide
	// the "related moderations" iframe whenever the menu
	// is open.
	// ------------------------------------------------------------------
	hideRelatedModsIframe : function(flag) {
		var obj = null;
		if ((obj = document.getElementById("RelatedModsBox")) != null) {			
			obj.style.display = (flag ? "none" : "block");
				// better hide, no page relayout then.
		}
	},

	// Clicking on the dropdown icon opens the dropdown menu. 
	// ------------------------------------------------------------------
	handleSetup : function() {
		if (this.status == "load") {
			this.status = "init";
			var obj, mName, j;
			// for all items of the mainmenu, find the offsetLeft
			// position (origin + x pixels) and move the dropdown
			// menu's to the same location.
			for (j=this.items.length-1; j >=0; j--) { 
				mName = this.items[j][0];
				if ((obj = document.getElementById(mName)) != null) {
					this.hashes.menuItems[mName] = obj;
					var mPos = this.menuOffsetLeft + obj.offsetLeft;
					if ((obj = document.getElementById(mName+"_sub")) != null) {
						obj.style.left = ""+mPos+"px";
						this.hashes.submenuItems[mName] = obj;
					}
				}
			}
			this.status = "ready";
		}
	},

	// This function is called from /comp/topmenu. It expects a this.items 
	// array where each entry is an array of [name, url, displayed title]
	// It builds the list of orange/violet topmenu entries. The item which 
	// corresponds to selmenu is highlighted.
	// ------------------------------------------------------------------
	// Note 1: The css-class of the elements is set depending
	// of the order of the item in the menu:
	// * rightmost item gets class "right"
	// * if selected, add "selected" to class 
	//   e.g. either "selected" or "rightselected"
	// Note 2: Gecko browsers disable the eventhandlers in the
	// mm_* namespace before disallowing the events to fire, this
	// results in JavaScript errors during the transition to another page
	// - just catch the errors quietly.
	writeHtml : function(selmenu) {
		document.writeln('<table cellspacing="0" cellpadding="0" border="0"><tr>');
		for (var i=0; i<this.items.length; i++) {
			var mName = this.items[i][0];
			var mURL = this.items[i][1];
			var mTitle = this.items[i][2];
			this.hashes.menuLinks[mName] = mURL; 

			// build css
			var cssClass = (selmenu == mName ? 'selected' : ''); 
			cssClass = (cssClass != "" ? 'class="'+cssClass+'"' : '');

			var s = [];
			s.push('<td nowrap ' + cssClass);
			s.push('onMouseOver="'+this.getHandler(this.EV_MAIN_OVER)+'" ');
			s.push('onMouseOut="'+this.getHandler(this.EV_MAIN_OUT)+'" ');
			s.push('onClick="'+this.getHandler(this.EV_MAIN_CLICK)+'" ');
			s.push('id="'+mName+'" ');
			s.push('><a ');
			s.push('title="'+mTitle+'" ');
			s.push('href="'+mURL+'">'+mTitle+'</a>');
			if (this.allowTriggerClick()) {
				s.push('<a ');
				s.push('id="'+mName+'" ');
				s.push('href="javascript: void(0); // open submenu" ');
				s.push('onClick="'+this.getHandler(this.EV_DROPDOWN_CLICK)+'" ');
				s.push('><img style="padding-left: 3px" src="/images/dropdown.gif" alt="" border="0"></a>');
			}
			s.push('</td>');
			s = s.join("");
			// alert(s);
			document.write(s);
		}
		document.write('<td class="mainmenuright">&nbsp</td></tr></table>');
	},

	// Returns HTML code for the event handlers, if they
	// are written with document.write
 	// ------------------------------------------------------------------
	getHandler : function(ev) {
		return "try { topMenu.handleEvent(this, '"+ev+"'); } catch (e) { /* fail quietly */ }";
	}
};










		 
var sideBar = {
	COOKIE_SIDEBAR : "sidebar", // side bar cookie name

	// This function works as a toggle if show
	// is omitted, but can be set directly when providing
	// the parameter.	
	// ------------------------------------------------------------------
	// Note: The display attribute of TD-elements should be "table-cell"
	// according to W3C, but many browsers fail to handle this 
	// (whereas using "block" seems to be OK in just about all cases).
	toggle : function(show) {
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
		setCookie(this.COOKIE_SIDEBAR, (show ? "1" : "0"), 365);
	},

	// Draws the sidebar toggle links. 
	// ------------------------------------------------------------------
	writeHtml : function() {
		var states = [
			["hide", "Hide side bar", "minimize.gif"], 
			["show", "Show side bar", "maximize.gif"]
		];
		for (var i=0; i<states.length; i++) {
			var _id = states[i][0];
			var _text = states[i][1];
			var _icon = states[i][2];
			document.write('<table id="sidebar-toggle-'+_id+'" border="0" cellspacing="0" cellpadding="0">');
			document.write('<tr><td>');
			document.write('<a href="javascript: /* toggle side bar */" ');
			document.write('  onClick="try { sideBar.toggle(null); } ');
			document.write('    catch (e) { /* fail quietly */ }" ');
			document.write('  title="'+_text+'">'+_text+'<\/a>');
			document.write('<\/td><td>');
			document.write('<img src="/images/icon/'+_icon+'" alt="">');
			document.write('<\/td><\/tr><\/table>');
		}
	},

	// Gets sidemenu state from cookie and sets the sidemenu visibility.
	// If no value can be obtained from the cookie, assume open state, 
	// else compare cookie value to "1", where 1=open, 0=closed
	// ------------------------------------------------------------------
	// Note: mm_initialiseSideBar could be done in "onload" (as the name 
	// suggests); however instead we do it as soon as both sidemenu-td and 
	// the sidebar toggles are available in the document tree. This way,
	// no flickering of the screen (or appear/reappear oddities) occur,
	// opposite if this function would be called during the onLoad handler.
	// On the other hand it's possible that some browsers may not like this, in
	// which case uncomment the following (and remove the call from comp/sidebar)
	// to do all this during "onload" instead.
	// AddOnLoadAction(mm_initialiseSideBar);
	initialise : function() {
		var mode = getCookie(this.COOKIE_SIDEBAR); // 
		sideBar.toggle((!mode ? "1" : mode) == "1");
	}
};





