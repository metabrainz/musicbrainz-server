

/**
 * Common functions of the EditSuite user interface
 **/
function EsUiModule() {
	// ----------------------------------------------------------------------------
	// register class/global id
	// ----------------------------------------------------------------------------
	this.CN = "EsUiModule";
	this.GID = "es.ui";
	mb.log.enter(this.CN, "__constructor");

	// ----------------------------------------------------------------------------
	// register module
	// ----------------------------------------------------------------------------
	this.getModID = function() { return "es.ui"; };
	this.getModName = function() { return "User Interface"; };

	// ----------------------------------------------------------------------------
	// member variables
	// ----------------------------------------------------------------------------
	this.BTN_ALIAS = "BTN_ALIAS";
	this.BTN_ARTIST = "BTN_ARTIST";
	this.BTN_SORTGUESS = "BTN_SORTGUESS";
	this.BTN_SORTCOPY = "BTN_SORTCOPY";
	this.BTN_ALBUM = "BTN_ALBUM";
	this.BTN_TRACK = "BTN_TRACK";
	this.BTN_ALL = "BTN_ALL";
	this.BTN_USESWAP  = "BTN_USESWAP";
	this.BTN_USESPLIT = "BTN_USESPLIT";
	this.BTN_USECURRENT  = "BTN_USECURRENT";
	this.BTN_GUESSBOTH = "BTN_GUESSBOTH";
	this.BTN_CANCEL = "BTN_CANCEL";

	this.BTN_TEXT_NONALBUMTRACKS = 'Guess All Track Names according to Guess Case settings';
	this.BTN_TEXT_ALBUMANDTRACKS = 'Guess Album Name and Track Names according to Guess Case settings';
	this.BTN_TEXT_ALBUMARTISTANDTRACKS = 'Guess Album, Artist and Track Names according to Guess Case settings';

	// guess case mode setting
	this.GC_MODE = null;

	// member variables which store the state of the focussed field
	this.focusField = null;
	this.focusValue = null;

	// holds a reference to the form which the editsuite framework is in.
	this.FORMFIELD_ID = "ES_FORMFIELD_ID";
	this.formRef = null;

	// all the buttons registered under their id
	this.buttonRegistry = [];

	// regular expressions for the fields
	this.re = {
		// names of the different field types.
		ARTISTFIELD : /^(search|artistname|newartistname|newartistalias)/i,
		SORTNAMEFIELD : /^(artistsortname|newartistsortname)/i,
		ALBUMFIELD : /^(newalbumname|albumname|album|name)/i,
		TRACKFIELD : /^(newtrackname|trackname|track)/i,
		TRACKLENGTHFIELD : /tracklength\d+/i,

		// textfield css classes
		TEXTFIELD : /^textfield(\sfocus|\smissing)*$/i,
		RESIZEABLEFIELD : /^textfield(\sfocus|\shidden|\soldvalue|\sheader)*$/i,
		NUMBERFIELD : /^numberfield(\sfocus|\shidden|oldvalue|header)*$/i
	};

	// default size of the fields is 350px
	this.TEXTFIELD_SIZE = 350;
	this.SIZE_PX_FACTOR = 5.7;

	// ----------------------------------------------------------------------------
	// member functions
	// ----------------------------------------------------------------------------

	this.setupModuleDelegate =  function() {
		mb.log.enter(this.GID, "setupModuleDelegate");
		var def = "Guess Case";
		this.registerButtons(
			new EsButton(
				this.BTN_ALIAS, def,
				"Guess Artist Alias according to MusicBrainz Artist Name Guidelines",
				"es.guessArtistField($);"),

			new EsButton(
				this.BTN_ARTIST, def,
				"Guess Artist Name according to MusicBrainz Artist Name Guidelines",
				"es.guessArtistField($);"),

			new EsButton(
				this.BTN_SORTGUESS, "Guess",
				"Guess Sort Name from Artist Name field",
				"es.guessSortnameField($, $);"),

			new EsButton(
				this.BTN_SORTCOPY, "Copy",
				"Copy Sort Name from Artist Name field",
				"es.copySortnameField($, $);"),

			new EsButton(
				this.BTN_ALBUM, def,
				"Guess Album Name according to Guess Case settings",
				"es.guessAlbumField($);"),

			new EsButton(
				this.BTN_TRACK, def,
				"Guess Track Name according to Guess Case settings",
				"es.guessTrackField($)"),

			new EsButton(
				this.BTN_ALL, "Guess All",
				"Guess all fields according to Guess Case settings",
				"es.guessAllFields()"),

			new EsButton(
				this.BTN_USESWAP, "Swap",
				"Swap Artist Name and Track Name fields",
				"es.swapFields($,$,$)"),

			new EsButton(
				this.BTN_USECURRENT, "Use Current",
				"Reset to current Artist Name and Track Name",
				"es.changeartist.useCurrent()"),

			new EsButton(
				this.BTN_USESPLIT, "Split",
				"Use Artist Name and Track Name from split function",
				"es.changeartist.useSplit()"),

			new EsButton(
				this.BTN_GUESSBOTH, "Guess Both",
				"Guess both Artist Name and Track Name",
				"es.changeartist.guessBoth($, $)"),

			new EsButton(
				this.BTN_CANCEL, "Cancel",
				"Return to the previous page",
				"es.ui.cancelForm($)")
		);

		// register formfields method to be run DOM is ready
		mb.registerDOMReadyAction(new MbEventAction(this.GID, "setupFormFields", "Add event handlers on form elements"));
		mb.log.exit();
	};

	/**
	 * Write the html for the EditSuite box.
	 **/
	this.writeUI = function(el, fOpen) {
		mb.log.enter(this.GID, "writeUI");

		// this line is very important. it writes out the hidden field which is used
		// to get a reference to the form the editsuite function is placed in.
		var s = [];
		s.push('<input type="hidden" name="jsProxy" id="'+this.FORMFIELD_ID+'" value="">');

		// write editsuite HTML
		s.push('<div id="editsuite-table" class="editsuite-table">');
		s.push('<table width="100%" border="0" cellspacing="0" cellpadding="0">');

		// retrieve the modules
		var i,m, mods = es.getRegisteredModules();
		for (i=0; i<mods.length; i++) {
			if ((m = mods[i]) != this) {
				s.push(m.getModuleHtml());
			}
		}
		s.push('</table>');
		s.push('</div>');

		var div = document.createElement("div");
		div.innerHTML = s.join("");
		el.appendChild(div);

		// run after document.write fixes.
		for (i=0; i<mods.length-1; i++) {
			if ((m = mods[i]) != this) {
				m.onModuleHtmlWritten();
			}
		}
		mb.log.exit();
	};

	/**
	 * Returns html for the collapse/hide button
	 **/
	this.getHelpButton = function(mod, state) {
		var s = [];
		s.push('<td class="toggle">');
		s.push('<a href="javascript:; // ');
		s.push(state ? "expand" : "collapse");
		s.push('" onClick="');
		s.push(mod.getModID());
		s.push('.setExpanded(');
		s.push(state ? 'true': 'false');
		s.push(')"><img src="/images/es/');
		s.push(state ? 'maximize' : 'minimize');
		s.push('.gif" width="13" height="13" alt="');
		s.push(state ? "Expand " : "Collapse ");
		s.push(mod.getModName());
		s.push('function" border="0"></a>');
		s.push('</td>');
		return s.join("");
	};

	/**
	 * Set the editsuitemode to the selected mode from the dropdown box.
	 **/
	this.registerButtons = function() {
		mb.log.enter(this.GID, "registerButtons");
		for (var i=arguments.length-1; i>=0; i--) {
			var btn = arguments[i];
			if (btn instanceof EsButton) {
				this.buttonRegistry[btn.getID()] = btn;
			}
		}
		mb.log.exit();
	};

	/**
	 * Returns the button html from the registry for button bid
	 **/
	this.getButtonHtml = function(bid) {
		mb.log.enter(this.GID, "getButtonHtml");
		var btn, s = null;
		if (bid != "") {
			if ((btn = this.buttonRegistry[bid]) != null) {
				s = [];
				s.push('<input type="button" class="button" ');
				s.push('id="'+bid+'" ');
				s.push('value="'+btn.getValue()+'" ');
				s.push('title="'+btn.getTooltip()+'" ');
				s.push('onClick="es.ui.onButtonClicked(this);"> ');
				s = s.join("");
			}
		}
		return mb.log.exit(s);
	};

	/**
	 * write a guess case button to the document.
	 **/
	this.writeButton = function() {
		mb.log.enter(this.GID, "writeButton");
		var btn = null, bid = arguments[0];
		if ((btn = this.getButtonHtml(bid)) != null) {
			// replace first occurence of $ with
			// current argument.
			if (arguments.length > 1) {
				for (var i=1; i<arguments.length; i++) {
					btn = btn.replace(/\$/, "'"+arguments[i]+"'");
				}
			}
			document.write(btn);
		} else {
			mb.log.error("Button with id: $ not registered!", id);
		}
		mb.log.exit();
	};

	/**
	 * Setup all the form fields
	 **/
	this.setupFormFields = function() {
		mb.log.enter(es.ui.GID, "setupFormFields");
		var all = mb.ui.getByTag("input");
		var l = all.length;
		var cn, el, log, id, type, name, value;
		var isInputField, hasOnFocus, hasOnBlur, isToolboxEnabled = es.qf.isToolboxEnabled();
		for (var i = 0; i < l; i++) {
			el = all[i];
			id = el.id;
			value = (el.value || "");
			name = (el.name || "noname");
			type = (el.type || "notype");
			cn = (el.className || "");
			log = [];

			// handle tracktime fields
			if (el && type == "text" && cn.match(/textfield|numberfield/)) {
				el.onfocus = function onfocus(event) { es.ui.handleFocus(this); };
				el.onblur = function onblur(event) { es.ui.handleBlur(this); };
			}

			// handle input=text fields
			if (el && type == "text" && cn.match(/textfield/)) {
				// initialise value, else it is null.
				el.style.width = this.TEXTFIELD_SIZE+"px";
				isInputField = !cn.match(/hidden|header|oldvalue/i);

				// handle input text fields which show their focus
				if (isInputField) {
					if (isToolboxEnabled) {
						es.qf.addToolboxIcon(el);
						log.push("toolbox");
					}
				} else {
					// add dummy toolbox icon to maintain spacing and
					// cancel onfocus events on dummy input elements
					el.onfocus = function onfocus(event) { return false; };
					el.onblur = function onblur(event) {};
					if (isToolboxEnabled) {
						es.qf.addToolboxDummy(el);
						log.push("toolbox dummy");
					}
				}
			}

			// let's see if we have a javascript button
			if (el && type == "button" && value == "") {
				var oid = id, btn = null, bid = oid.split(mb.ui.SPLITSEQ)[0];
				if ((btn = es.ui.buttonRegistry[bid]) != null) {
					el.value = btn.getValue(); // set display value
					el.title = btn.getTooltip();
					el.className = "button";
					el.style.display = "inline";
					el.onclick = function onclick(event) {
						es.ui.onButtonClicked(this);
					};
					log.push("Registered: "+bid);
				}
			}

			// dump the log messages, if anything was done.
			if (log.length > 0) {
				mb.log.debug("Handled $, id: $ ("+log.join(", ")+")", type, id||name);
			}
		}
		mb.log.exit();
	};

	/**
	 * Trigger function
	 **/
	this.onButtonClicked = function(el) {
		mb.log.scopeStart("Handling click on button");
		mb.log.enter(this.GID, "onButtonClicked");
		if (el) {
			if (el.id) {
				mb.log.trace("Button $ was clicked", el.id);
				var id = el.id, args = id.split(mb.ui.SPLITSEQ);
				var btn, bid = args[0];
				if ((btn = es.ui.buttonRegistry[bid]) != null) {
					var f = btn.func;
					mb.log.trace("Arguments: $", args);
					// replace arguments in function.
					// (start with index 1, 0 is buttonID
					for (var j=1; j<args.length; j++) {
						f = f.replace(/\$/, "'"+args[j]+"'")
					}
					try {
						eval(f);
					} catch (e) {
						mb.log.error("Caught exception in eval'd code! ex: $, f: $", (e.message || "?"), f);
						mb.log.error(mb.log.getStackTrace());
					}
				} else {
					mb.log.error("Button $ not found in registry!", id);
				}
			} else {
				mb.log.error("Button has no id set!");
			}
			mb.log.trace("Done.");
		} else {
			mb.log.error("Required parameter el is missing.");
		}
		mb.log.exit();
		mb.log.scopeEnd();
	};

	/**
	 * Returns the field which currently has focus.
	 **/
	this.cancelForm = function(url) {
		if (url) {
			document.location.replace(url);
		}
	};

	/**
	 * Returns the field which currently has focus.
	 **/
	this.getFocusField = function() {
		return this.focusField;
	};

	/**
	 * Sets the field which currently has focus.
	 **/
	this.setFocusField = function(field) {
		this.focusField = field;
	};

	/**
	 * Returns the (stored) field value of the focussed field.
	 **/
	this.getFocusValue = function() {
		return this.focusValue;
	};

	/**
	 * Sets the (stored) field value of the focussed field.
	 **/
	this.setFocusValue = function(v) {
		this.focusValue = v;
	};

	/**
	 * Returns the formfield which can be used to obtain a reference to the form.
	 **/
	this.getFormField = function() {
		return mb.ui.get(this.FORMFIELD_ID);
	};

	/**
	 * Return the form the editsuite function is working on.
	 **/
	this.getForm = function() {
		if (!this.formRef) {
			var obj;
			if ((obj = this.getFormField()) != null) {
				this.formRef = obj.form;
			}
		}
		return this.formRef;
	};

	/**
	 * Returns the field named fid in the current form, if
	 **/
	this.getField = function(fid, quiet) {
		quiet = (quiet || false);
		mb.log.enter(this.GID, "getField");
		var f,fr;
		if ((f = this.getForm()) != null) {
			if ((fr = f[fid]) == null) {
				if (!quiet) {
					mb.log.error("Field $ does not exist in form...", fid);
				}
			}
			return mb.log.exit(fr);
		} else {
			mb.log.error("Form f not found!");
		}
		return mb.log.exit(null);
	};

	/**
	 * Resets the selection on the field currently having an active selection
	 **/
	this.resetSelection = function() {
		if(typeof document.selection != 'undefined') {
			// ie support
			try {
				document.selection.empty();
			} catch (e) {}
		} else {
			try {
				if ((this.focusField != null) &&
					(this.focusField.selectionStart != 'undefined')) {
					this.focusField.selectionStart = 0; // mozilla, and other gecko-based browsers.
					this.focusField.selectionEnd = 0; // set cursor at pos 0
				}
			} catch (e) {}
		}
	};

	/**
	 * Remembers the current field the user clicked into and the value when editing started
	 **/
	this.handleFocus = function(field) {
		mb.log.scopeStart("Handling onfocus event on field: "+field.name);
		mb.log.enter(this.GID, "handleFocus");
		var cn = null;
		if (this.focusField) {
			cn = ((cn = this.focusField.className) != null ? cn : "");
			if (cn.indexOf(" focus") != -1) {
				this.focusField.className = cn.replace(/\s+focus/i, "");
			}
		}
		if (field && field.className) {
			if (field.className.indexOf(" focus") == -1) {
				field.className += " focus";
			}
			this.setFocusField(field);
			this.setFocusValue(field.value);

			// update the toolbox position, if it is showing.
			es.qf.updateToolbox(field);

			// if we are editing a tracktime field, and the value is the
			// default NULL value, clear the field for editing.
			if (field.value == "?:??") field.value = "";
		}
		mb.log.exit();
	};

	/**
	 * Checks if its the same field the user started editing and checks
	 * for changes. if the value was changed the edit is saved into the changelog.
	 **/
	this.handleBlur = function(field) {
		mb.log.scopeStart("Handling onblur event on field: "+field.name);
		mb.log.enter(this.GID, "handleBlur");
		var newvalue = field.value;
		var oldvalue = this.getFocusValue();

		// check if we are editing a tracktime field. if no changes were made,
		// reset to "?:??"
		if (oldvalue == "?:??" && newvalue == "") field.value = oldvalue;

		// handle normal blur event (if value changed, add to undo stack)
		if (this.isFocusField(field) && oldvalue != field.value) {
			es.ur.addUndo(es.ur.createItem(field, 'manual', oldvalue, newvalue));
		}
		mb.log.exit();
	};

	/**
	 * Returns true if the given parameter is equal to the focussed field.
	 **/
	this.isFocusField = function(field) {
		return (this.getFocusField() == field);
	};

	/**
	 * Returns all the edit text fields (class="textfield") of the current form.
	 **/
	this.getResizableFields = function() {
		mb.log.enter(this.GID, "getResizableFields");
		var fields = [];
		if (this.getForm()) {
			fields = this.getFieldsWalker(this.re.RESIZEABLEFIELD, null);
		}
		mb.log.exit();
		return fields;
	};

	/**
	 * Returns all the edit text fields (class="textfield") of the current form.
	 **/
	this.getEditTextFields = function() {
		mb.log.enter(this.GID, "getEditTextFields");
		var fields = [];
		if (this.getForm()) {
			fields = this.getFieldsWalker(this.re.TEXTFIELD, null);
		}
		mb.log.exit();
		return fields;
	};

	/**
	 * returns all the artist fields (class="textfield") of the current form.
	 **/
	this.getArtistFields = function() {
		mb.log.enter(this.GID, "getArtistFields");
		var fields = [];
		if (this.getForm()) {
			fields = this.getFieldsWalker(this.re.TEXTFIELD, this.re.ARTISTFIELD);
		}
		mb.log.exit();
		return fields;
	};

	/**
	 * returns the album name field (class="textfield")
	 **/
	this.getAlbumNameField = function() {
		mb.log.enter(this.GID, "getAlbumNameField");
		var fields = [];
		if (this.getForm()) {
			fields = this.getFieldsWalker(this.re.TEXTFIELD, this.re.ALBUMFIELD);
		}
		return (fields[0] || null);
	};

	/**
	 * returns all the edit text fields (class="textfield") of the current form.
	 **/
	this.getTrackNameFields = function() {
		mb.log.enter(this.GID, "getTrackNameFields");
		var fields = [];
		if (this.getForm()) {
			fields = this.getFieldsWalker(this.re.TEXTFIELD, this.re.TRACKFIELD);
		}
		mb.log.exit();
		return fields;
	};

	/**
	 * returns all the time edit fields (class="numberfield") of the current form.
	 **/
	this.getTrackTimeFields = function() {
		mb.log.enter(this.GID, "getTrackTimeFields");
		var fields = [];
		if (this.getForm()) {
			fields = this.getFieldsWalker(this.re.NUMBERFIELD, this.re.TRACKLENGTHFIELD);
		}
		mb.log.exit();
		return fields;
	};

	/**
	 * Iterate over all fields of the form and collect the items matching the selection criteria.
	 **/
	this.getFieldsWalker = function(cnRE, nameRE) {
		var fields = [];
		var f,el;
		if ((f = this.getForm()) != null) {
			for (var i=0; i<f.elements.length; i++) {
				if ((el = f.elements[i]) != null) {
					var cn = (el.className || "");
					var name = (el.name || "");
					var type = (el.type || "");

					// get classname from element, and match against RE (if RE is set)
					var bCN = (cnRE == null || (cnRE != null && cn.match(cnRE)));

					// get element name, and match against RE (if RE is set)
					var bName = (nameRE == null || (nameRE != null && name.match(nameRE)));
					if ((type == "text") && bCN && bName) {
						fields.push(el);
					}
				}
			}
		}
		return fields;
	};

	/**
	 * Sets the element disabled=true.
	 *
	 * @param el	the element
	 * @param flag	if the element should be disabled (true|false)
	 **/
	this.setDisabled = function(el, flag) {
		var obj = null;
		if ((obj = mb.ui.get(el)) != null) {
			if (obj.disabled != null) {
				obj.disabled = flag;
			}
		}
	};

	// exit constructor
	mb.log.exit();
}
// register prototype of module superclass
try {
	EsUiModule.prototype = new EsModuleBase;
} catch (e) {
	mb.log.error("EsUiModule: Could not register EsModuleBase prototype");
}