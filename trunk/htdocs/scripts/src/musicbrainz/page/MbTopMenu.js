/*----------------------------------------------------------------------------\
|                              Musicbrainz.org                                |
|                 Copyright (c) 2005 Stefan Kestenholz (keschte)              |
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
|                                                                             |
| $Id$
\----------------------------------------------------------------------------*/

/**
 * MbTopMenu is the class which handles the dropdown
 * menu functionality.
 *
 * @constructor
 **/
function MbTopMenu() {
	mb.log.enter("MbTopMenu", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "MbTopMenu";
	this.GID = "mb.topmenu";

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------

	/** load|init|ready, and open|closed **/
	this.status = "load",

	/** timer object which keeps track of the timeouts **/
	this.timer = new MbTopMenuTimer();

	/** offset of the menu from the left border **/
	this.OFFSET_LEFT = 157;

	/** Event types **/
	this.MENUITEM_CLICKED = "MENUITEM_CLICKED";
	this.MENUITEM_OVER = "MENUITEM_OVER";
	this.MENUITEM_OUT = "MENUITEM_OUT";
	this.CLICK_CLICKED = "CLICK_CLICKED";
	this.CLICK_OVER = "CLICK_OVER";
	this.CLICK_OUT = "CLICK_OUT";
	this.DROPDOWN_OVER = "DROPDOWN_OVER";
	this.DROPDOWN_OUT = "DROPDOWN_OUT";

	/** The list of menu items **/
	this.items = [];

	/** The configuration options from the userprefs **/
	this.type = "both";
	this.trigger = "mouseover";
	this.isClickAllowed = false;
	this.displayedDropDown = null;

	/**
	 * Hashes which allow to retrieve the menuitems
	 * with hash-values, rather than searching through lists
	 * m: mainmenu elements (td)
	 * ml: mainmenu URLs
	 * sm: submainmenu elements (div)
	 **/
	this.h = { m : [], ml : [], sm : [] };

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Initialise the topmenu with the given UserPreferences.
	 *
 	 * @param trigger: mouseover(default)|click
 	 * @param type: both(default)|dropdownonly|staticonly
	 * @param items the list of menu items
	 */
	this.init = function(ty, tr, items) {
		if (tr && tr.match(/mouseover|click/i)) {
			this.trigger = tr.toLowerCase();
		}
		if (ty && ty.match(/both|dropdownonly|staticonly/i)) {
 			this.type = ty.toLowerCase();
 		}
		this.items = items;
	};

	/**
	 * Returns if dropdowns are enabled
	 * @returns {Boolean} true, if types is either both|dropdownonly
	 */
	this.isDropDownEnabled = function() {
		return this.type.match(/both|dropdownonly/i);
	};

	/**
	 * Returns if the onMouseOver handler may open the dropdowns
	 * @returns {Boolean} true, if the menu is triggered by mouseover
	 */
	this.allowMouseTrigger = function() {
		return ((this.isDropDownEnabled()) &&
			    (this.trigger == "mouseover"));
	};

	/**
	 * Returns if the onClick handler may open the dropdowns
	 * @returns {Boolean} true, if the menu is opened by click
	 */
	this.allowClickTrigger = function() {
		return ((this.isDropDownEnabled()) &&
			    (this.trigger == "click"));
	};

	/**
	 * Handle an event
	 * @param el the element which triggered the event
	 * @param ev the even type.
	 */
	this.handleEvent = function(el, ev) {
		// window.status = ("handleEvent :: "+el.id+" "+ev+" "+this.trigger+" "+this.type+" "+this.status);
		mb.log.enter(this.GID, "handleEvent");
		var id, returncode = true;
		if (this.status == "load") {
			// lazy initialise
			this.setupEvents();
		}
		if (this.status == "ready") {
			ev = (ev || "");
			id = (el.id || "");
			id = id.split(".")[0];
			if (id != "" && ev != "") {
				mb.log.debug("id: $, ev: $, allow click: $", id, ev, this.isClickAllowed);
				if (ev == this.MENUITEM_OVER) {
					this.timer.activateMenuItem(id, true);

				} else if (ev == this.MENUITEM_OUT) {
					this.timer.activateMenuItem(id, false);

				} else if (ev == this.MENUITEM_CLICKED) {
					if (this.isClickAllowed) {
						var url = null;
						if ((url = this.h.ml[id]) != null) {
							try {
								mb.log.debug("Menu item selected: $", url);
								document.location.href = url;
							} catch (e) {
								mb.log.error("Caught exception: $", e);
							}
						}
					}
				} else if (ev == this.CLICK_OVER) {
					this.isClickAllowed = false;
					this.timer.clear();

				} else if (ev == this.CLICK_OUT) {
					this.isClickAllowed = true;
					this.timer.clear();

				} else if (ev == this.CLICK_CLICKED) {
					if (this.allowClickTrigger()) {
						this.timer.clear();
						if (this.displayedDropDown) {
							this.hideDisplayedDropDown();
						} else {
							this.openDropdown(id);
						}
					}
					returncode = false;

				} else if (ev == this.DROPDOWN_OVER) {
					this.timer.hasEnteredSubMenu();

				} else if (ev == this.DROPDOWN_OUT) {
					this.timer.hasLeftSubMenu();

				} else {
					// unhandled
				}
			}
		}
		mb.log.exit();
		return returncode;
	};

	/**
	 * Add/Remove hover to css class depending on flag.
	 */
	this.activateMenuItem = function(id, flag) {
		if (flag) {
			if (this.allowMouseTrigger()) {
				// mouseOver mode, open dropdown
				this.timer.clear();
				this.openDropdown(id);
			} else if (this.displayedDropDown != null) {
				// onClick mode, and another dropdown is visible
				// means activate this one, and disable other one.
				this.timer.clear();
				this.openDropdown(id);
			}
		} else {
			mb.topmenu.hideDisplayedDropDown();
		}
	};


	/**
	 * Add/Remove hover to css class depending on flag.
	 */
	this.mouseOver = function(id, flag) {
		mb.log.enter(this.GID, "mouseOver");
		mb.log.trace("id: $, flag: $", id, flag);
		var obj = null;
		if ((obj = this.h.m[id]) != null) {
			var cn = obj.className;
			if (flag && cn.indexOf("hover") == -1) obj.className = cn+"hover";
			else if (!flag && cn.indexOf("hover") != -1)  obj.className = cn.replace("hover", "");
		}
		mb.log.exit();
	};

	/**
	 * Add/Remove hover to css class depending on flag.
	 */
	this.hideDisplayedDropDown = function() {
		mb.log.enter(this.GID, "hideDisplayedDropDown");
		mb.log.debug("Current: $", this.displayedDropDown);
		if (this.displayedDropDown) {
			var obj = null;
			if ((obj = this.h.sm[this.displayedDropDown]) != null) {
				obj.style.display = "none"; // hide displayed dropdown
			}
		}
		this.hideRelatedModsIframe(false);
		this.displayedDropDown = null;
		mb.log.exit();
	};

	/**
	 * Add/Remove hover to css class depending on flag.
	 */
	this.openDropdown = function(id) {
		mb.log.enter(this.GID, "openDropdown");
		mb.log.debug("Opening: $", id);
		var obj = null;
		this.hideDisplayedDropDown();
		if ((obj = this.h.sm[id]) != null) {
			this.hideRelatedModsIframe(true);
			obj.style.display = "block"; // hide old dropdown
			this.displayedDropDown = id;
		}
		mb.log.exit();
	};

	/**
	 * Some browsers force iframes to be at the top of the
	 * z-index stack, which means that the submenus fall
	 * behind the iframe (e.g. Konqueror does this).
	 * It's clunky, but what we therefore do is to hide
	 * the "related moderations" iframe whenever the menu
	 * is open.
	 */
	this.hideRelatedModsIframe = function(flag) {
		var obj = null;
		if ((obj = mb.ui.get("RelatedModsBox")) != null) {
			obj.style.display = (flag ? "none" : "block");
			// better hide, no page relayout then.
		}
	};

	/**
	 * Setup all the events, and the dropdown menues.
	 */
	this.setupTopMenu = function() {
		mb.log.enter(this.GID, "setupTopMenu");
		mb.log.debug("Status: $", this.status);
		if (this.status == "load") {
			this.status = "init";
			var obj, oName, mName, mOffsetLeft, j;
			var len = this.items.length;
			// for all items of the mainmenu, find the offsetLeft
			// position (origin + x pixels) and move the dropdown
			// menu's to the same location.
			mb.log.debug("Setting up $ items...", len);
			for (j=len-1; j >=0; j--) {
				mName = this.items[j][0];
				oName = mName+".mouseover";
				if ((obj = mb.ui.get(oName)) != null) {
					this.h.m[mName] = obj;
					mOffsetLeft = obj.offsetLeft;

					// inititalising menuitem-TD
					obj.onmouseover = function(event) {
						try {
							return mb.topmenu.handleEvent(this, mb.topmenu.MENUITEM_OVER);
						} catch (e) {
							try {
								mb.log.error("Caught error, e: $", e);
							} catch (e) { /* give up */ }
						}
						return true;

					};
					obj.onmouseout = function(event) {
						try {
							return mb.topmenu.handleEvent(this, mb.topmenu.MENUITEM_OUT);
						} catch (e) {
							try {
								mb.log.error("Caught error, e: $", e);
							} catch (e) { /* give up */ }
						}
						return true;
					};
					obj.onclick = function(event) {
						try {
							return mb.topmenu.handleEvent(this, mb.topmenu.MENUITEM_CLICKED);
						} catch (e) {
							try {
								mb.log.error("Caught error, e: $", e);
							} catch (e) { /* give up */ }
						}
						return true;
					};

					// inititalising icon (click-trigger)
					oName = mName+".click";
					if ((obj = mb.ui.get(oName)) != null) {
						obj.href = "javascript:; // Click to open submenu";

						// loose focus-border on IE
						obj.onfocus = function(event) { this.blur(); };

						// mouseover event
						obj.onmouseover = function(event) {
							try {
								return mb.topmenu.handleEvent(this, mb.topmenu.CLICK_OVER);
							} catch (e) {
								try {
									mb.log.error("Caught error, e: $", e);
								} catch (e) { /* give up */ }
							}
							return true;
						};

						// mouseout event
						obj.onmouseout = function(event) {
							try {
								return mb.topmenu.handleEvent(this, mb.topmenu.CLICK_OUT);
							} catch (e) {
								try {
									mb.log.error("Caught error, e: $", e);
								} catch (e) { /* give up */ }
							}
							return true;
						};

						// onclick event
						obj.onclick = function(event) {
							try {
								return mb.topmenu.handleEvent(this, mb.topmenu.CLICK_CLICKED);
							} catch (e) {
								try {
									mb.log.error("Caught error, e: $", e);
								} catch (e) { /* give up */ }
							}
							return true;
						};
					} else {
						mb.log.debug("Object $ not found...", oName);
					}

					// inititalising submenu
					oName = mName+".submenu";
					if ((obj = mb.ui.get(oName)) != null) {
						var mPos = this.OFFSET_LEFT + mOffsetLeft;
						obj.style.left = ""+mPos+"px";
						this.h.sm[mName] = obj;
						obj.onmouseover = function(event) {
							try {
								mb.topmenu.handleEvent(this, mb.topmenu.DROPDOWN_OVER)
							} catch (e) {
								try {
									mb.log.error("Caught error, e: $", e);
								} catch (e) { /* give up */ }
							}
							return true;
						}
						obj.onmouseout = function(event) {
							try {
								return mb.topmenu.handleEvent(this, mb.topmenu.DROPDOWN_OUT)
							} catch (e) {
								try {
									mb.log.error("Caught error, e: $", e);
								} catch (e) { /* give up */ }
							}
							return true;
						}
					} else {
						mb.log.debug("Object $ not found...", oName);
					}
				} else {
					mb.log.debug("Object $ not found...", oName);
				}
			}
			this.status = "ready";
		}
		mb.log.debug("Status: $", this.status);
		mb.log.exit();
	};

	/**
	 * This function is called from /comp/topmenu. It expects a this.items
	 * array where each entry is an array of [name, url, displayed title]
	 * It builds the list of orange/violet topmenu entries. The item which
	 * corresponds to selmenu is highlighted.
	 * ------------------------------------------------------------------
	 * Note 1: The css-class of the elements is set depending
	 * of the order of the item in the menu:
	 * * rightmost item gets class "right"
	 * * if selected, add "selected" to class
	 * e.g. either "selected" or "rightselected"
	 * Note 2: Gecko browsers disable the eventhandlers in the
	 * mm_* namespace before disallowing the events to fire, this
	 * results in JavaScript errors during the transition to another page
	 * - just catch the errors quietly.
	 */
	this.writeUI = function(selmenu) {
		var s = [];
		s.push('<table cellspacing="0" cellpadding="0" border="0"><tr>');
		for (var i=0; i<this.items.length; i++) {
			var name = this.items[i][0];
			var url = this.items[i][1];
			var title = this.items[i][2];
			this.h.ml[name] = url;

			// build css
			var cn = (selmenu == name ? 'selected' : '');
			cn = (cn != '' ? 'class="'+cn+'"' : '');

			s.push('<td nowrap ' + cn);
			s.push('id="'+name+'.mouseover" ');
			s.push('><a ');
			s.push('title="'+title+'" ');
			s.push('href="'+url+'">'+title+'</a>');
			if (this.allowClickTrigger()) {
				s.push('<a ');
				s.push('id="'+name+'.click" ');
				s.push('><img style="padding-left: 3px;" src="http://musicbrainz.org/images/dropdown.gif" alt="" border="0"></a>');
			}
			s.push('</td>');
		}
		s.push('<td class="mainmenuright">&nbsp</td></tr></table>');
		s = s.join("");
		document.write(s);
	};

	// exit constructor
	mb.log.exit();
};