

/**
 * Base class for all EditSuite modules.
 *
 **/
function EsModuleBase() {

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "EsModuleBase";
	this.GID = "es.base";
	mb.log.enter(this.CN, "__constructor");

	// ----------------------------------------------------------------------------
	// register module
	// ---------------------------------------------------------------------------
	this.getModID = function() { return "es.base"; };
	this.getModName =  function() { return "EsModuleBase"; };
	this.getModKey = function(key) { return this.getModID() + (key || ""); };

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------
	this.CONFIG_LIST = [];
	this.CONFIG_VALUES = [];
	this.CONFIG_CHECKBOX = this.getModKey(".config");
	this.DEFAULT_EXPANDED = false;
	this.DEFAULT_VISIBLE = false;
	this.uiAvailable = false;

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Setup module configuration (register Buttons, etc.)
 	 * Can be implemented by a subclassed Module
 	 **/
 	this.setupModule =  function() {
		mb.log.enter(this.GID, "setupModule");
		this.COOKIE_VISIBLE = this.getModKey(".visible");
		this.COOKIE_EXPANDED = this.getModKey(".expanded");

		// create module configuration
		this.CONFIG_LIST = (!this.CONFIG_LIST ? [] : this.CONFIG_LIST);
		this.CONFIG_VALUES = (!this.CONFIG_VALUES ? [] : this.CONFIG_VALUES);
		this.CONFIG_CHECKBOX = this.getModKey(".config");
		this.configRead = false;

		// hold the visible/expanded state
		this.visible = null;
		this.expanded = null;

		// setup default configuration values.
		for (var i=0; i<this.CONFIG_LIST.length; i++) {
			var cb = this.CONFIG_LIST[i];
			this.setConfigValue(cb.getID(), cb.isDefaultOn());
		}

		// module specific setup...
		this.setupModuleDelegate();
		mb.log.exit();
	};

	/**
	 * Setup module configuration (register Buttons, etc.)
	 *
	 * - Can be implemented by a subclassed Module
	 **/
	this.setupModuleDelegate =  function() {
		// override me
	};

	/**
	 * Get values from the config checkboxes
	 **/
	this.getConfigFromUI = function() {
		mb.log.enter(this.GID, "getConfigFromUI");
		var list = null;
		if ((list = mb.ui.getByName(this.CONFIG_CHECKBOX)) != null) {
			var l = list.length;
			for (var i=0; i<l; i++) {
				var el = list[i];
				this.CONFIG_VALUES[el.id] = el.checked;
				mb.log.debug('$ = $', el.id, el.checked);
			}
		} else {
			mb.log.warning("Config checkboxes $ are null!", this.CONFIG_CHECKBOX);
		}
		this.getConfigFromUIDelegate();
		mb.log.exit();
	};


	/**
	 * Delegate method for additional configuration values
	 * other than the ones handled in getConfigFromUI()
	 * * Can be implemented by a subclassed Module
	 **/
	this.getConfigFromUIDelegate = function() {
		// override me
	};


	/**
	 * Handle a click on the configuration checkboxes
	 * * Default behaviour is to store the change into
	 *   a cookie, but be implemented by a subclassed Module
	 **/
	this.onConfigurationChange = function(el) {
		mb.log.scopeStart("Handling click on config checkbox");
		mb.log.enter(this.GID, "onConfigurationChange");
		var key = el.id, value = el.checked;
		mb.cookie.set(key, (value ? "1" : "0"), 365);
		this.setConfigValue(key, value);
		mb.log.exit();
		mb.log.scopeEnd();
	};

	/**
	 * Set value for a given configuration key.
	 **/
	this.setConfigValue = function(key, value) {
		mb.log.enter(this.GID, "setConfigValue");
		this.CONFIG_VALUES[key] = value;
		mb.log.trace("Set $ = $", key, value);
		mb.log.exit();
	};

	/**
	 * Get value for configuration  key.
	 **/
	this.isConfigTrue = function(key) {
		mb.log.enter(this.GID, "isConfigTrue");
		if (this.CONFIG_VALUES[key] == 'undefined') {
			this.getConfigFromUI();
		}
		var o = (this.CONFIG_VALUES[key] || false);
		mb.log.trace("$=$", key, o);
		return mb.log.exit(o);
	};

	/**
	 * Get value for configuration key.
	 **/
	this.getConfigFromCookie = function(name, defaultOn) {
		mb.log.enter(this.GID, "getConfigFromCookie");
		var cv = mb.cookie.getBool(name);
		var cvDisp = (cv == null ? "null" : cv);
		var f = ((cv != null && cv) ||	// use value from cookie
				 (cv == null && defaultOn));	// else default value
		mb.log.trace('key: $ (default:$ || cookie:$) = $', name, defaultOn, cvDisp, f);
		return mb.log.exit(f);
	};

	/**
 	// Handles a click on the Reset Module link.
 	// Resets the modules visible/expanded state
	 **/
	this.onResetModuleClicked = function() {
		mb.log.scopeStart("Handling click on Reset Module link");
		mb.log.enter(this.GID, "onResetModuleClicked");
		this.resetModule();
		mb.log.exit();
		mb.log.scopeEnd();
	};

	/**
 	// Handles a click on the Reset Module link.
 	// Resets the modules visible/expanded state
	 **/
	this.resetModule = function() {
		mb.log.enter(this.GID, "resetModule");

		// delete all the cookies from the configuration
		mb.log.debug('Deleting configuration values...');
		for (var i=this.CONFIG_LIST.length-1; i>=0; i--) {
			var cb = this.CONFIG_LIST[i];
			mb.cookie.remove(cb.getID());
		}

		// delete cookies
		mb.log.debug('Deleting visible/expanded cookies...');
		mb.cookie.remove(this.COOKIE_VISIBLE);
		mb.cookie.remove(this.COOKIE_EXPANDED);
		this.resetModuleDelegate();

		// update checkboxes to the reset state
		mb.log.debug('Reset visible/expanded state...');
		this.visible = null;
		this.expanded = null;
		this.setVisible(); // reads the default state

		return mb.log.exit();
	};

	/**
 	 * Resets the modules configuration
	 * * Can be implemented by a subclassed Module
	 **/
	this.resetModuleDelegate = function() {
		// override me
	};

	/**
	 * Returns if the current module is displayed
	 **/
	this.isVisible = function() {
		mb.log.enter(this.GID, "isVisible");
		if (this.visible == null) {
			var f = this.getConfigFromCookie(this.COOKIE_VISIBLE, this.DEFAULT_VISIBLE);
			this.visible = f;
		}
		return mb.log.exit(this.visible);
	};

	/**
	 * Sets if the current module is displayed
	 **/
	this.setVisible = function(flag, expand) {
		mb.log.enter(this.GID, "setVisible");
		if (flag != null) {
			this.visible = flag;

			// if expanded state is not set, expand by default
			if (expand || this.expanded == null) {
				if (this.visible) {
					this.setExpanded(true);
				} else {
					es.cfg.updateExpanded(this.getModID(), false);
				}
			}
			mb.log.debug('New state: $', (this.visible ? "visible" : "hidden"));
			mb.ui.setDisplay(this.getModKey("-tr-expanded"), this.visible && this.expanded);

			// store state, and configure checkbox in config module
			if (this != es.cfg) {
				mb.ui.setDisplay(this.getModKey("-tr-collapsed"), this.visible && !this.expanded);
				mb.cookie.set(this.COOKIE_VISIBLE, (this.visible ? "1" : "0"), 365);
				es.cfg.updateVisible(this.getModID(), this.visible);
			}

		} else {
			mb.log.debug('No flag given, reading from cookie/default value...');
			this.setVisible(this.isVisible());
		}
		mb.log.exit();
	};

	/**
	 * Sets if the current module is visible
	 **/
	this.onSetVisibleClicked = function(flag) {
		mb.log.scopeStart("Handling click on Visible checkbox");
		mb.log.enter(this.GID, "onSetVisibleClicked");
		this.setVisible(flag, flag);
		mb.log.exit();
		mb.log.scopeEnd();
	};

	/**
	 * Returns if the current module is expanded
	 **/
	this.isExpanded = function(quiet) {
		mb.log.enter(this.GID, "isExpanded");
		if (this.expanded == null) {
			var f = this.getConfigFromCookie(this.COOKIE_EXPANDED, this.DEFAULT_EXPANDED);
			this.expanded = f;
		}
		return mb.log.exit(this.expanded);
	};

	/**
	 * Sets if the current module is expanded
	 **/
	this.setExpanded = function(flag) {
		mb.log.enter(this.GID, "setExpanded");
		if (flag != null) {
			mb.log.debug('New state: $', (flag ? "expanded" : "collapsed"));
			this.expanded = flag;
			mb.ui.setDisplay(this.getModKey("-tr-expanded"), this.visible && this.expanded);

			// store state, update collapsed TR (for modules other than config)
			// and configure checkbox in config module
			if (this != es.cfg) {
				mb.ui.setDisplay(this.getModKey("-tr-collapsed"), this.visible && !this.expanded);
				mb.cookie.set(this.COOKIE_EXPANDED, (this.expanded ? "1" : "0"), 365);
				es.cfg.updateExpanded(this.getModID(), this.expanded);
			}
		} else {
			mb.log.debug('No flag given, reading from cookie/default value...');
			this.setExpanded(this.isExpanded());
		}
		mb.log.exit();
	};

	/**
	 * Sets if the current module is expanded
	 **/
	this.onSetExpandedClicked = function(flag) {
		mb.log.scopeStart("Handling click on Expanded checkbox");
		mb.log.enter(this.GID, "onSetExpandedClicked");
		this.setExpanded(flag);
		mb.log.scopeEnd();
		mb.log.exit();
	};

	/**
	 * Returns the HTML for the configuration checkboxes.
	 **/
	this.getConfigHtml = function() {
		mb.log.enter(this.GID, "getConfigHtml");
		var s =[];
		for (var i=0; i<this.CONFIG_LIST.length; i++) {
			var cb = this.CONFIG_LIST[i];
			var helpText = cb.getHelpText();
			helpText = helpText.replace("'", "´"); // make sure overlib does not choke on single-quotes.
			s.push('<input type="checkbox" name="');
			s.push(this.CONFIG_CHECKBOX);
			s.push('" id="');
			s.push(cb.getID());
			s.push('" value="on" ');

			// set checked, either from cookie or default value.
			var checked = this.getConfigFromCookie(cb.getID(), cb.isDefaultOn());
			s.push(checked ? ' checked="checked" ' : ' ');
			this.setConfigValue(cb.getID(), checked);

			// register onChange handler
			s.push('onChange="');
			s.push(this.getModID());
			s.push('.onConfigurationChange(this)" '); // module must implement this.
			s.push('>');
			s.push(cb.getDescription());
			s.push('&nbsp; ');
			s.push('[ <a href="javascript:; // help" ');
			s.push('onmouseover="return overlib(\''+helpText+'\');"');
			s.push('onmouseout="return nd();">help</a> ]<br/>');
		}
		return mb.log.exit(s.join(""));
	};

	/**
	 * Returns html for the collapse/hide button
	 **/
	this.getExpandButton = function(state) {
		var s = [];
		var tooltip = [];
		tooltip.push(state ? "Expand" : "Collapse");
		tooltip.push(' '+this.getModName());
		tooltip.push(' module');
		s.push('<td class="toggle">');
		s.push('<a href="javascript:; // ');
		s.push(state ? "expand" : "collapse");
		s.push('" onClick="');
		s.push(this.getModID());
		s.push('.onSetExpandedClicked(');
		s.push(state ? 'true': 'false');
		s.push(')" title="'); // ff expects title="" on a
		s.push(tooltip.join(""));
		s.push('" ><img src="/images/es/');
		s.push(state ? 'maximize' : 'minimize');
		s.push('.gif" width="13" height="13" alt="');
		s.push(tooltip.join("")); // IE expects alt="" on img
		s.push('" style="padding-left: 3px" border="0"></a>');
		s.push('</td>');
		return s.join("");
	};

	/**
	 * Returns html for the close button
	 **/
	this.getCloseButton = function() {
		var s = [];
		var tooltip = [];
		tooltip.push("Close");
		tooltip.push(' '+this.getModName());
		tooltip.push(' module');
		s.push('<td class="toggle">');
		s.push('<a href="javascript:; // close');
		s.push('" onClick="');
		s.push(this.getModID());
		s.push('.onSetVisibleClicked(false)" ');
		s.push('title="'); // ff expects title="" on a
		s.push(tooltip.join(""));
		s.push('"><img src="/images/es/');
		s.push('close.gif" width="13" height="13" alt="');
		s.push(tooltip.join("")); // IE expects alt="" on img
		s.push('" style="padding-left: 3px" border="0"></a>');
		s.push('</td>');
		return s.join("");
	};

	/**
	 * Returns html for the collapsed/expanded TR
	 **/
	this.getModuleStartHtml = function(c) {
		mb.log.enter(this.GID, "getModuleStartHtml");

		var mv = this.isVisible(); // true=no logging in methods
		var mx = this.isExpanded(); // true=no logging in methods
		var rowid = (c.x ? "expanded" : "collapsed");
		var dispCSS = ""; // default is visible
		if (!mv) {
			dispCSS = "none";
		}

		// If module is visible:
		// * Hide tr-expanded for closed state,
		// * and Hide tr-collapsed for expanded state
		if (mv && mx && !c.x) {
			dispCSS = "none";
		}
		if (mv && !mx && c.x) {
			dispCSS = "none";
		}
		// if (mb.log.isDebugMode()) {
		// 	var m = this.getModID()+"-"+rowid;
		// 	var v = (mv || "not found");
		// 	var e = (mx || "not found");
		// 	mb.log.debug("$, Visible: $, Expanded: $, Display: $", m, v, e, dispCSS);
		// }
		var s = [];
		s.push('<tr valign="top" class="editsuite-box-tr" id="');
		s.push(this.getModID());
		s.push('-tr-'+rowid+'" ');
		s.push(dispCSS != "" ? 'style="display: '+dispCSS+'"' : '');
		s.push('>');
		s.push('<td style="width: 130px; font-weight: bold">'+this.getModName()+':</td>');
		s.push('<td>');
		if (!c.x) {
			var t = (c.dt || ""); // get default text from config, else empty.
			if (mb.ua.ie) {
				// layout fix for IE.
				s.push('<div style="padding-top: 2px">');
			}
			s.push('<small><span id="'+this.getModID()+'-text-collapsed">'+t+'</span></small>');
			if (mb.ua.ie) {
				s.push('</div>');
			}
		}
		return mb.log.exit(s.join(""));
	};

	/**
	 * Returns html for the collapsed TR
	 **/
	this.getModuleEndHtml = function(c) {
		mb.log.enter(this.GID, "getModuleEndHtml");
		var s = [];
		s.push('</td>');
		s.push('<td>&nbsp;</td>');
		s.push(this.getExpandButton(!c.x)); // get button != current state
		s.push(this.getCloseButton());
		s.push('</tr>');
		return mb.log.exit(s.join(""));
	};

	/**
	 * Adjust things that can only be done after the html
	 * is written to the document.
	 *
	 * @see EsUiModule#writeUI
	 **/
	this.onModuleHtmlWritten = function() {
		this.uiAvailable = true;
		this.onModuleHtmlWrittenDelegate();
	};
	/**
	 * Calls the module specific function
	 **/
	this.onModuleHtmlWrittenDelegate = function() {
	};

	this.isUIAvailable = function() {
		return this.uiAvailable;
	};

	// leave constructor
	mb.log.exit();
}
EsModuleBase.prototype = new EsModuleBase;