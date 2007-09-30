/**
 * Base class for the funcationality used on the editing
 * pages of the MusicBrainz project.
 **/
function EditSuite() {

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "EditSuite";
	this.GID = "es";
	mb.log.enter(this.CN, "__constructor");

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------
	this.modules = [];
	this.loadModuleError = false;

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Register an external module
	 **/
	this.registerModule = function(mod) {
		mb.log.enter(this.GID, "registerModule");
		if (!this.loadModuleError) {
			if (mod.getModID) {
				var ref = (mod.getModID() || "");
				if (ref != "") {
					mb.log.debug("$ (es.$)", mod.CN, ref);
					if (mod.setupModule) {
						mod.setupModule();
					}
					if (mod.isVisible) {
						this.modules.push(mod);
					}
				} else {
					this.loadModuleError = true;
					mb.log.error('Module $ did return "" as a reference!', mod.CN);
				}
			} else {
				mb.log.error('Module $ does not define getModuleRef', mod.CN);
				this.loadModuleError = true;
			}
		}
		mb.log.exit();
		return mod;
	};

	/**
	 * Returns the list of registered modules
	 **/
	this.getRegisteredModules = function() {
		return this.modules;
	};

	/**
	 * Returns the list of registered modules
	 **/
	this.getModule = function(id) {
		var m = null;
		for (var i=0;i<this.modules.length; i++) {
			if ((m = this.modules[i]).getModID() == id)	{
				break;
			}
			m = null;
		}
		return m;
	};

	/**
	 * Returns the list of registered modules
	 **/
	this.getDisplayedModules = function() {
		return this.modules;
	};


	/**
	 * Todo:
	 * doReleaseName, doArtistName,doTrackName,doSortNameCopy,doSortNameGuess
	 * doSwapFields,doUseCurrent,doUseSplit,doArtistAndTrackName

	 * Guess field=fname using the guessArtist routine GuessCase object
	 **/
	this.guessArtistField = function(fname) {
		mb.log.enter(this.GID, "guessArtistField");
		fname = (fname || "artist");
		var f;
		if ((f = es.ui.getField(fname)) != null) {
			var ov = f.value, nv = ov;
			if (!mb.utils.isNullOrEmpty(ov)) {
				mb.log.info("Guessing artist field, input: $", ov);
				if ((nv = es.gc.guessArtist(ov)) != ov) {
					es.ur.addUndo(es.ur.createItem(f, "Guess artist", ov, nv));
					f.value = nv;
					es.ui.resetSelection();
				} else {
					mb.log.info("Guess yielded same result, nothing to do.");
				}
			} else {
				mb.log.info("Field value is null or empty, nothing to do.");
			}
		} else {
			mb.log.error("Did not find the field: $", fname);
		}
		mb.log.exit();
	};

	/**
	 * Guess field=fname using the guessRelease routine GuessCase object
	 **/
	this.guessReleaseField = function(fname, mode) {
		mb.log.enter(this.GID, "guessReleaseField");
		fname = (fname || "release");
		var f;
		if ((f = es.ui.getField(fname)) != null) {
			var ov = f.value, nv = ov;
			if (!mb.utils.isNullOrEmpty(ov)) {
				mb.log.info("Guessing release field, input: $", ov);
				mb.log.debug("* mode: $", mode);
				if ((nv = es.gc.guessRelease(ov, mode))  != ov) {
					es.ur.addUndo(es.ur.createItem(f, "Guess release ("+es.gc.getMode()+")", ov, nv));
					f.value = nv;
					es.ui.resetSelection();
				} else {
					mb.log.info("Guess yielded same result, nothing to do.");
				}
			} else {
				mb.log.info("Field value is null or empty, nothing to do.");
			}
		} else {
			mb.log.error("Did not find the field: $", fname);
		}
		mb.log.exit();
	};


	/**
	 * Guess field=fname using the guessTrack routine GuessCase object
	 **/
	this.guessTrackField = function(fname, mode) {
		mb.log.enter(this.GID, "guessTrackField");
		var f;
		if ((f = es.ui.getField(fname)) != null) {
			var ov = f.value, nv = ov;
			if (!mb.utils.isNullOrEmpty(ov)) {
				mb.log.info("Guessing track field, input: $", ov);
				mb.log.debug("* mode: $", mode);
				if ((nv = es.gc.guessTrack(ov, mode))  != ov) {
					es.ur.addUndo(es.ur.createItem(f, "Guess track ("+es.gc.getMode()+")", ov, nv));
					f.value = nv;
					es.ui.resetSelection();
				} else {
					mb.log.info("Guess yielded same result, nothing to do.");
				}
			} else {
				mb.log.info("Field value is null or empty, nothing to do. $", ov);
			}
		} else {
			mb.log.error("Did not find the field: $", fname);
		}
		mb.log.exit();
	};

	/**
	 * Guess all fields in the form.
	 **/
	this.guessAllFields = function() {
		mb.log.enter(this.GID, "guessAllFields");
		var f, fields = es.ui.getEditTextFields();
		var value, name, cn;
		for (var j=0; j<fields.length; j++) {
			f = fields[j];
			value = (f.value || "");
			name = (f.name || "");
			cn = (f.className || "");
			if (!cn.match(/hidden/i)) {
				if (!mb.utils.isNullOrEmpty(value)) {
					mb.log.scopeStart("Guessing next field: "+name);
					this.guessByFieldName(name);
				} else {
					mb.log.info("Field is empty, name: $", name);
				}
			}
		}
		mb.log.exit();
	};

	/**
	 * Determine fieldtype by it's name, and apply
	 * the corresponding guess function.
	 **/
	this.guessByFieldName = function(name, mode) {
		mb.log.enter(this.GID, "guessByFieldName");
		if (name.match(es.ui.re.TRACKFIELD_NAME)) {
			this.guessTrackField(name, mode);

		} else if (name.match(es.ui.re.RELEASEFIELD_NAME)) {
			this.guessReleaseField(name, mode);

		} else if (name.match(es.ui.re.ARTISTFIELD_NAME)) {
			this.guessArtistField(name);

		} else if (name.match(es.ui.re.ARTISTSORTNAMEFIELD_NAME)) {
			var artistField = name.replace("sort", "");
			this.guessArtistSortnameField(artistField, name);

		} else if (name.match(es.ui.re.LABELSORTNAMEFIELD_NAME)) {
			var labelField = name.replace("sort", "");
			this.guessLabelSortnameField(labelField, name);

		} else {
			mb.log.warning("Unhandled name: $", name);
		}
		mb.log.exit();
	};

	/**
	 * Copy value from the artist field to the sortname field
	 **/
	this.copySortnameField = function(artistId, sortnameId) {
		mb.log.enter(this.GID, "copySortnameField");
		var fa,fsn;
		if ((fa = es.ui.getField(artistId)) != null &&
			(fsn = es.ui.getField(sortnameId)) != null) {
			var ov = fsn.value;
			var nv = fa.value;
			if (nv != ov) {
				fsn.value = nv;
				es.ur.addUndo(es.ur.createItem(fsn, 'sortnamecopy', ov, nv));
				es.ui.resetSelection();
			} else {
				mb.log.info("Destination is same as source, nothing to do.");
			}
		} else {
			mb.log.error("Did not find the fields: $, $", artistId, sortnameId);
		}
		mb.log.exit();
	};

	/**
	 * Guess artist sortname using the guessSortName routine GuessCase object
	 **/
	this.guessArtistSortnameField = function(artistId, sortnameId) {
		mb.log.enter(this.GID, "guessArtistSortnameField");
		var fa,fsn;
		if ((fa = es.ui.getField(artistId)) != null &&
			(fsn = es.ui.getField(sortnameId)) != null) {
			var av = fa.value, ov = fsn.value, nv = ov;
			if (!mb.utils.isNullOrEmpty(av)) {
				mb.log.info("fa: $, fsn: $, value: $", fa.name, fsn.name, fa.value);
				if ((nv = es.gc.guessArtistSortname(av))  != ov) {
					es.ur.addUndo(es.ur.createItem(fsn, 'sortname', ov, nv));
					fsn.value = nv;
					es.ui.resetSelection();
				} else {
					mb.log.info("Guess yielded same result, nothing to do.");
				}
			} else {
				mb.log.info("Artist name is empty, nothing to do.");
			}
		} else {
			mb.log.error("Did not find the fields: $, $", artistId, sortnameId);
		}
		mb.log.exit();
	};

	/**
	 * Guess label sortname using the guessSortName routine GuessCase object
	 **/
	this.guessLabelSortnameField = function(labelId, sortnameId) {
		mb.log.enter(this.GID, "guessLabelSortnameField");
		var fa,fsn;
		if ((fa = es.ui.getField(labelId)) != null &&
			(fsn = es.ui.getField(sortnameId)) != null) {
			var av = fa.value, ov = fsn.value, nv = ov;
			if (!mb.utils.isNullOrEmpty(av)) {
				mb.log.info("fa: $, fsn: $, value: $", fa.name, fsn.name, fa.value);
				if ((nv = es.gc.guessLabelSortname(av))  != ov) {
					es.ur.addUndo(es.ur.createItem(fsn, 'sortname', ov, nv));
					fsn.value = nv;
					es.ui.resetSelection();
				} else {
					mb.log.info("Guess yielded same result, nothing to do.");
				}
			} else {
				mb.log.info("Label name is empty, nothing to do.");
			}
		} else {
			mb.log.error("Did not find the fields: $, $", artistId, sortnameId);
		}
		mb.log.exit();
	};

	/**
	 * Swap value of field f1,f2 and update fs
	 **/
	this.swapFields = function() {
		mb.log.enter(this.GID, "swapFields");
		var f1,f2,fs;
		var fn1 = (arguments[0] || "search");
		var fn2 = (arguments[1] || "trackname");
		var fns = (arguments[2] || "swapped");
		if (((f1 = es.ui.getField(fn1)) != null) &&
			((f2 = es.ui.getField(fn2)) != null) &&
			((fs = es.ui.getField(fns)) != null)) {
			var newswap = (1 - fs.value); // hidden var which holds if fields were swapped
			var f1v = f1.value;
			var f2v = f2.value;
			es.ur.addUndo(es.ur.createItemList(
							  es.ur.createItem(f2, 'swap', f2v, f1v),
							  es.ur.createItem(f1, 'swap', f1v, f2v),
							  es.ur.createItem(fs, 'swap', fs.value, newswap)));
			f1.value = f2v;
			f2.value = f1v;
			fs.value = newswap;
		} else {
			mb.log.error("Did not find the fields: $,$,$", fn1, fn2, fns);
		}
		mb.log.exit();
	};

	// register the modules.
	es = this; // set global EditSuite var
	es.ui 			= this.registerModule(new EsUiModule());

	// these are the modules which provide an user interface
	es.gc 			= this.registerModule(new GuessCase());
	es.ur 			= this.registerModule(new EsUndoModule());
	es.qf 			= this.registerModule(new EsQuickFunctions());
	es.fr 			= this.registerModule(new EsFieldResizer());
	es.sr 			= this.registerModule(new EsSearchReplace());
	es.tp 			= this.registerModule(new EsTrackParser());
	es.cfg 			= this.registerModule(new EsConfigModule());
	gc = es.gc; // set global GuessCase var

	// modules which do not have
	// an user interface element
	es.modnote 		= this.registerModule(new EsModNoteModule());
	es.changeartist	= this.registerModule(new EsChangeArtistModule());

	// exit constructor
	mb.log.exit();
}