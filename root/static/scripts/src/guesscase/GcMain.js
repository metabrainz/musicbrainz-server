SORTNAME STUFF

When adding an artist and guessing the sortname, the guess will be "Bar, The", for any name "Foo Bar" where Foo contains "the", for instance "Matthew Matics" gets "Matics, The".

Same with "los" as with "the", i.e. when adding an artist and guessing the sortname, the guess will be "Bar, Los", for any name "Foo Bar" where Foo contains "los". Possibly also for other articles in other languages?

Selecting an artist type as Group, then entering a name of "Foo Bar", Guess Sortname sets is as "Bar, Foo". For Group artists, it shouldn't do this. -- RodBegbie


http://wiki.musicbrainz.org/SortNameStyleDiscussion

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

	};


	/**
	 * Guess the sortname of a given artist name
	 * @param	 is		the un-processed input string
	 * @returns			the processed string
	 **/
	this.guessArtistSortname = function(is) {
		var os, handler;
		gc.init();
		mb.log.enter(this.GID, "guessArtistSortame");
		if (!gc.artistHandler) {
			gc.artistHandler = new GcArtistHandler();
		}
		handler = gc.artistHandler;
		mb.log.info('Input: $', is);

		// we need to query the handler if the input string is
		// a special case, fetch the correct format, if the
		// returned case is indeed a special case.
		var num = handler.checkSpecialCase(is);
		if (handler.isSpecialCase(num)) {
			os = handler.getSpecialCaseFormatted(is, num);
			mb.log.info('Result after special case check: $', os);
		} else {
			// if it was not a special case, start Guessing
			os = handler.guessSortName(is);
			mb.log.info('Result after guess: $', os);
		}
		gc.restoreMode();
		return mb.log.exit(os);
	};

	/**
	 * Guess the sortname of a given label name
	 * @param	 is		the un-processed input string
	 * @returns			the processed string
	 **/
	this.guessLabelSortname = function(is) {
		var os, handler;
		gc.init();
		mb.log.enter(this.GID, "guessLabelSortame");
		if (!gc.labelHandler) {
			gc.labelHandler = new GcLabelHandler();
		}
		handler = gc.labelHandler;
		mb.log.info('Input: $', is);

		// we need to query the handler if the input string is
		// a special case, fetch the correct format, if the
		// returned case is indeed a special case.
		var num = handler.checkSpecialCase(is);
		if (handler.isSpecialCase(num)) {
			os = handler.getSpecialCaseFormatted(is, num);
			mb.log.info('Result after special case check: $', os);
		} else {
			// if it was not a special case, start Guessing
			os = handler.guessSortName(is);
			mb.log.info('Result after guess: $', os);
		}
		gc.restoreMode();
		return mb.log.exit(os);
	};

function GcLabelHandler() {

	this.guessSortName = function(is) {
		mb.log.enter(this.GID, "guessSortName");
		is = gc.u.trim(is);

		// let's see if we got a compound label
		var collabSplit = " and ";
		collabSplit = (is.indexOf(" + ") != -1 ? " + " : collabSplit);
		collabSplit = (is.indexOf(" & ") != -1 ? " & " : collabSplit);

		var as = is.split(collabSplit);
		for (var splitindex=0; splitindex<as.length; splitindex++) {
			var label = as[splitindex];
			if (!mb.utils.isNullOrEmpty(label)) {
				label = gc.u.trim(label);
				var append = "";
				mb.log.debug("Handling label part: $", label);

				var words = label.split(" ");
				mb.log.debug("words: $", words);

				// handle some special cases, like The and Los which
				// are sorted at the end.
				if (!gc.re.SORTNAME_THE) {
					gc.re.SORTNAME_THE = /^The$/i; // match The
					gc.re.SORTNAME_LOS = /^Los$/i; // match Los
				}
				var firstWord = words[0];
				if (firstWord.match(gc.re.SORTNAME_THE)) {
					append = (", The" + append); // handle The xyz -> xyz, The
					words[0] = null;
				} else if (firstWord.match(gc.re.SORTNAME_LOS)) {
					append = (", Los" + append); // handle Los xyz -> xyz, Los
					words[0] = null;
				}

				mb.log.debug('Sorted words: $, append: $', words, append);
				var t = [];
				for (i=0; i<words.length; i++) {
					var w = words[i];
					if (!mb.utils.isNullOrEmpty(w)) {
						// skip empty names
						t.push(w);
					}
					if (i < words.length-1) {
						// if not last word, add space
						t.push(" ");
					}
				}

				// append string
				if (!mb.utils.isNullOrEmpty(append)) {
					t.push(append);
				}
				label = gc.u.trim(t.join(""));
			}
			if (!mb.utils.isNullOrEmpty(label)) {
				as[splitindex] = label;
			} else {
				delete as[splitindex];
			}
		}
		var os = gc.u.trim(as.join(collabSplit));



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

	};

	/**
	 * Guesses the sortname for artists
	 **/
	this.guessSortName = function(is) {
		mb.log.enter(this.GID, "guessSortName");
		is = gc.u.trim(is);

		// let's see if we got a compound artist
		var collabSplit = " and ";
		collabSplit = (is.indexOf(" + ") != -1 ? " + " : collabSplit);
		collabSplit = (is.indexOf(" & ") != -1 ? " & " : collabSplit);

		var as = is.split(collabSplit);
		for (var splitindex=0; splitindex<as.length; splitindex++) {
			var artist = as[splitindex];
			if (!mb.utils.isNullOrEmpty(artist)) {
				artist = gc.u.trim(artist);
				var append = "";
				mb.log.debug("Handling artist part: $", artist);

				// strip Jr./Sr. from the string, and append at the end.
				if (!gc.re.SORTNAME_SR) {
					gc.re.SORTNAME_SR = /,\s*Sr[\.]?$/i;
					gc.re.SORTNAME_JR = /,\s*Jr[\.]?$/i;
				}
				if (artist.match(gc.re.SORTNAME_SR)) {
					artist = artist.replace(gc.re.SORTNAME_SR, "");
					append = ", Sr.";
				} else if (artist.match(gc.re.SORTNAME_JR)) {
					artist = artist.replace(gc.re.SORTNAME_JR, "");
					append = ", Jr.";
				}
				var names = artist.split(" ");
				mb.log.debug("names: $", names);

				// handle some special cases, like DJ, The, Los which
				// are sorted at the end.
				var reorder = false;
				if (!gc.re.SORTNAME_DJ) {
					gc.re.SORTNAME_DJ = /^DJ$/i; // match DJ
					gc.re.SORTNAME_THE = /^The$/i; // match The
					gc.re.SORTNAME_LOS = /^Los$/i; // match Los
					gc.re.SORTNAME_DR = /^Dr\.$/i; // match Dr.
				}
				var firstName = names[0];
				if (firstName.match(gc.re.SORTNAME_DJ)) {
					append = (", DJ" + append); // handle DJ xyz -> xyz, DJ
					names[0] = null;
				} else if (firstName.match(gc.re.SORTNAME_THE)) {
					append = (", The" + append); // handle The xyz -> xyz, The
					names[0] = null;
				} else if (firstName.match(gc.re.SORTNAME_LOS)) {
					append = (", Los" + append); // handle Los xyz -> xyz, Los
					names[0] = null;
				} else if (firstName.match(gc.re.SORTNAME_DR)) {
					append = (", Dr." + append); // handle Dr. xyz -> xyz, Dr.
					names[0] = null;
					reorder = true; // reorder doctors.
				} else {
					reorder = true; // reorder by default
				}

				// we have to reorder the names
				var i=0;
				if (reorder) {
					var reOrderedNames = [];
					if (names.length > 1) {
						for (i=0; i<names.length-1; i++) {
							// >> firstnames,middlenames one pos right
							if (i == names.length-2 && names[i] == "St.") {
								names[i+1] = names[i] + " " + names[i+1];
									// handle St. because it belongs
									// to the lastname
							} else if (!mb.utils.isNullOrEmpty(names[i])) {
								reOrderedNames[i+1] = names[i];
							}
						}
						reOrderedNames[0] = names[names.length-1]; // lastname,firstname
						if (reOrderedNames.length > 1) {
							// only append comma if there was more than 1
							// non-empty word (and therefore switched)
							reOrderedNames[0] += ",";
						}
						names = reOrderedNames;
					}
				}
				mb.log.debug('Sorted names: $, append: $', names, append);
				var t = [];
				for (i=0; i<names.length; i++) {
					var w = names[i];
					if (!mb.utils.isNullOrEmpty(w)) {
						// skip empty names
						t.push(w);
					}
					if (i < names.length-1) {
						// if not last word, add space
						t.push(" ");
					}
				}

				// append string
				if (!mb.utils.isNullOrEmpty(append)) {
					t.push(append);
				}
				artist = gc.u.trim(t.join(""));
			}
			if (!mb.utils.isNullOrEmpty(artist)) {
				as[splitindex] = artist;
			} else {
				delete as[splitindex];
			}
		}
		var os = gc.u.trim(as.join(collabSplit));

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

	};
