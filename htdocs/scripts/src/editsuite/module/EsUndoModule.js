

/**
 * Undo/Redo module
 **/
function EsUndoModule() {
	mb.log.enter("EsUndoModule", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "EsUndoModule";
	this.GID = "es.ur";

	// ----------------------------------------------------------------------------
	// register module
	// ---------------------------------------------------------------------------
	this.getModID = function() { return "es.ur"; };
	this.getModName = function() { return "Undo/Redo"; };

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------
	this.stack = [];
	this.index = 0;
	this.UNDO_LIST = "UNDO_LIST";
	this.STATUS_EXPANDED = this.getModID() + "-text-expanded";
	this.STATUS_COLLAPSED = this.getModID() + "-text-collapsed";
	this.BTN_UNDO_ALL = "BTN_UNDO_ALL";
	this.BTN_UNDO_ONE = "BTN_UNDO_ONE";
	this.BTN_REDO_ONE = "BTN_REDO_ONE";
	this.BTN_REDO_ALL = "BTN_REDO_ALL";

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Override this method for initial configuration (register buttons etc.)
	 **/
	this.setupModuleDelegate =  function() {
		this.DEFAULT_VISIBLE = true;
		this.DEFAULT_EXPANDED = true;
		es.ui.registerButtons(
			new EsButton(this.BTN_UNDO_ALL, "Undo all", "Undo all changes", "es.ur.undoAllSteps()"),
			new EsButton(this.BTN_UNDO_ONE, "Undo", "Undo the last change", "es.ur.undoStep()"),
			new EsButton(this.BTN_REDO_ONE, "Redo", "Redo the last undid change", "es.ur.redoStep()"),
			new EsButton(this.BTN_REDO_ALL, "Redo all", "Redo all the undone changes", "es.ur.redoAllSteps()"));
	};

	/**
	 * Prepare code for this module.
	 *
	 * @returns raw html code
	 **/
	this.getModuleHtml = function() {
		var s = [];
		var defaulttext = 'Steps 0/0';
		s.push(this.getModuleStartHtml({x: true}));
		s.push(es.ui.getButtonHtml(this.BTN_UNDO_ALL));
		s.push(es.ui.getButtonHtml(this.BTN_UNDO_ONE));
		s.push(es.ui.getButtonHtml(this.BTN_REDO_ONE));
		s.push(es.ui.getButtonHtml(this.BTN_REDO_ALL));
		s.push('<small><span id="'+this.STATUS_EXPANDED+'">'+defaulttext+'</span><small>');
		s.push(this.getModuleEndHtml({x: true}));
		s.push(this.getModuleStartHtml({x: false, dt: defaulttext}));
		s.push(this.getModuleEndHtml({x: false}));
		return s.join("");
	};

	/**
	 * after the html has been written to the document...
	 * Do stuff
	 **/
	this.onModuleHtmlWrittenDelegate = function() {
		es.ui.setDisabled(this.BTN_UNDO_ALL, true); // disable the swap button
		es.ui.setDisabled(this.BTN_UNDO_ONE, true); // disable the swap button
		es.ui.setDisabled(this.BTN_REDO_ONE, true); // disable the swap button
		es.ui.setDisabled(this.BTN_REDO_ALL, true); // disable the swap button
	};

	/**
	 * Factory methods which hide implementation from other classes
	 **/
	this.createItem = function() {
		return new EsUndoItem(arguments);
	};
	this.createItemList = function() {
		return new EsUndoItemList(arguments);
	};

	/**
	 * Adds an undo/redo item to the stack.
	 **/
	this.addUndo = function(undoObj) {
		mb.log.enter(this.GID, "addUndo");
		this.stack = this.stack.slice(0, this.index);
		this.stack.push(undoObj);
		this.index = this.stack.length;

		// updated remembered value (such that leaving the field does
		// not add another UNDO step)
		var f = null;
		var ff = es.ui.getFocusField();
		if (undoObj instanceof EsUndoItemList) {
			// we have multiple undo steps combined
			var undoList = undoObj;
			for (undoList.iterate(); undoList.hasNext();) {
				undoObj = undoList.getNext();
				if (undoObj.getField() == ff) {
					// update remembered value for the focussed field
					es.ui.setFocusValue(undoObj.getNew());
				}
			}
		} else {
			// we have a single undo step
			if (undoObj.getField() == ff) {
				// update remembered value for the focussed field
				es.ui.setFocusValue(undoObj.getNew());
			}
		}
		this.updateUI();
		mb.log.exit();
	};

	/**
	 * Track back one step in the changelog
	 **/
	this.undoStep = function() {
		mb.log.enter(this.GID, "undoStep");
		if (this.stack.length > 0) {
			if (this.index > 0) {
				var undoObj = this.stack[--this.index]; // move pointer, get item
				var f, o;
				if (undoObj instanceof EsUndoItemList) {
					// we have multiple undo steps combined
					mb.log.info("Undoing combined step...");
					for (undoObj.iterate(); undoObj.hasNext();) {
						o = undoObj.getNext(); // undo step of each of the items
						f = o.getField();
						f.value = o.getOld();
						mb.log.debug("* op: $, field: $, value: $", o.getOp(), f.name, f.value);
					}
				} else {
					mb.log.info("Undoing single step...");
					o = undoObj;
					f = o.getField();
					f.value = o.getOld(); // undo single change
					mb.log.debug("* op: $, field: $, value: $", o.getOp(), f.name, f.value);
				}
				this.updateUI();
				es.ui.resetSelection();
			}
		}
		mb.log.exit();
	};

	/**
	 * Re-apply one step which was undone previously
	 **/
	this.redoStep = function(inline) {
		mb.log.enter(this.GID, "redoStep");
		if (this.index < this.stack.length) {
			var undoObj = this.stack[this.index]; // move pointer, get item
			var f,o;
			if (undoObj instanceof EsUndoItemList) {
				// we have multiple undo steps combined
				mb.log.info("Redoing combined step...");
				for (undoObj.iterate(); undoObj.hasNext();) {
					o = undoObj.getNext(); // redo step of each of the items
					f = o.getField();
					f.value.value = o.getNew();
					mb.log.debug("* op: $, field: $, value: $", o.getOp(), f.name, f.value);
				}
			} else {
				mb.log.info("Redoing single step...");
				o = undoObj;
				f = o.getField();
				f.value = o.getNew(); // redo single change
				mb.log.debug("* op: $, field: $, value: $", o.getOp(), f.name, f.value);

			}
			this.index++;
			this.updateUI();
			es.ui.resetSelection();
		}
		mb.log.exit();
	};

	/**
	 * Track back all steps in the changelog
	 **/
	this.undoAllSteps = function() {
		mb.log.enter(this.GID, "undoAllSteps");
		mb.log.info("Undoing $ steps", this.stack.length);
		if (this.stack.length > 0) {
			while(this.index > 0) {
				this.undoStep(true);
			}
		}
		mb.log.exit();
	};

	/**
	 * Re-apply all steps which was undone previously
	 **/
	this.redoAllSteps = function() {
		mb.log.enter(this.GID, "redoAllSteps");
		mb.log.info("Redoing $ steps", (this.stack.length-this.index));
		while (this.index < this.stack.length) {
			this.redoStep(true);
		}
		mb.log.exit();
	};

	/**
	 * Set the state of the buttons and display where the cursor in the
	 * the changelog is at.
	 **/
	this.updateUI = function() {
		var f;
		if ((f = es.ui.getForm()) != null) {
			es.ui.setDisabled(this.BTN_UNDO_ONE, (this.index == 0));
			es.ui.setDisabled(this.BTN_REDO_ONE, (this.index == this.stack.length));
			es.ui.setDisabled(this.BTN_UNDO_ALL, (this.index == 0));
			es.ui.setDisabled(this.BTN_REDO_ALL, (this.index == this.stack.length));
			var obj = null;
			if ((obj = mb.ui.get(this.STATUS_COLLAPSED)) != null) {
				obj.innerHTML = "Steps: "+this.index+"/"+this.stack.length;
			}
			if ((obj = mb.ui.get(this.STATUS_EXPANDED)) != null) {
				obj.innerHTML = "Steps: "+this.index+"/"+this.stack.length;
			}
		}
	};

	// exit constructor
	mb.log.exit();
}

// register prototype of module superclass
try {
	EsUndoModule.prototype = new EsModuleBase;
} catch (e) {
	mb.log.error("EsUndoModule: Could not register EsModuleBase prototype");
}