function ARSearch() {

	// ----------------------------------------------------------------------------
	// register class/global id
	// ----------------------------------------------------------------------------
	this.CN = "ARSearch";
	this.GID = "arsearch";
	mb.log.enter(this.CN, "__constructor");

	// ----------------------------------------------------------------------------
	// member variables
	// ----------------------------------------------------------------------------
	this.eventMode = "";
	this.busy = false;
	this.theDropdown = null;
	this.currentIndex = 0;
	this.currChar = null;
	this.charsArr = new Array();
	this.theSubstr = null;
	this.lastChar = "";
	this.objTimeout = new Array();
	this.lastFocusObj = null;
	this.searchTimeOut = 0;
	this.searchFindNext = false;
	this.searchFindNextAsc = true;

	// ----------------------------------------------------------------------------
	// member functions
	// ----------------------------------------------------------------------------

	/**
	 * Document Me!
	 *
	 * @param e
	 */
	this.handleKeyPressed = function(e) {
		mb.log.enter(this.GID, "handleKeyPressed");
		this.eventMode = (e) ? ((e.eventPhase) ? "W3C" : "NN4") : ((window.event) ? "IE" : "unknown");

		// lets try some netscape 4 support, just for fun.
		if (this.eventMode == "NN4") {
			document.captureEvents(Event.KEYDOWN);
		}
		var event = (this.eventMode == "IE" ? window.event : e);
		var keyCode = (this.eventMode == "IE" ? event.keyCode : event.which);
		var theObj = (this.eventMode == "IE" ? event.srcElement : event.target);
		this.theDropdown = this.getDropDown(theObj);
		var retval = this.handleKeyCode(keyCode);
		mb.log.exit();
		return retval;
	};

	/**
	 * Document Me!
	 *
	 * @param keyCode
	 * @param btnClicked
	 */
	this.handleKeyCode = function(keyCode, btnClicked) {
		mb.log.enter(this.GID, "handleKeyCode");
		if (btnClicked == null) btnClicked = false;
		var retval;
		var inputFocus = this.inputHasFocus();
		var selectFocus = this.selectHasFocus();

		mb.log.debug("keyCode=$, focus on=$", keyCode, (inputFocus ? "Input" : selectFocus ? "Dropdown" : "none"));

		if (! (this.theDropdown == null || this.theDropdown.options == null || keyCode == null)) {
			this.currChar = String.fromCharCode(keyCode);
			this.currChar = (this.currChar != null ? this.currChar.toLowerCase() : "");
			this.searchFindNext = false;
			// window.status = keyCode;
			if (keyCode == 8 || keyCode == 46) { // 46:DELETE, 8:BACKSPACE
				if (this.charsArr.length > 1) { // pop one element from
					this.updateObjTimeout(this.theDropdown);
					this.currChar = "";
					this.currOp = "BACKTRACE";
					this.charsArr.pop(); // the search string
					this.theSubstr = this.charsArr.join("");
					this.search();
					if (keyCode == 46) this.updateStats(this.theDropdown, false, true);
					retval = true;
				} else {
					this.theDropdown.selectedIndex = 0;
					this.updateStats(this.theDropdown, true); // reset if query = ""
					retval = true;
				}

			} else if (keyCode == 27) { // ESC=reset substring
				this.charsArr = new Array(); // and start from scratch
				this.currChar = "";
				this.currOp = "RESET";
				this.theDropdown.selectedIndex = 0;
				this.updateStats(this.theDropdown, true);
				mb.log.debug("", true);
				retval = false;

			} else if ((btnClicked && keyCode == 39) ||
					   (selectFocus && keyCode == 39) ||
					   (inputFocus && keyCode == 40)) { // 39:ARROW_RIGHT, 40:ARROW_DOWN
				this.updateObjTimeout(this.theDropdown);
				this.currChar = "FINDNEXT";
				this.searchFindNextAsc = true;
				this.searchFindNext = true; // dropdown list.
				this.currentIndex = this.theDropdown.selectedIndex;
				this.search();
				retval = false;

			} else if ((btnClicked && keyCode == 37) ||
					   (selectFocus && keyCode == 37) ||
					   (inputFocus && keyCode == 38)) { // 37:ARROW_LEFT, ARROW_UP:38
				this.updateObjTimeout(this.theDropdown);
				this.currChar = "FINDNEXT";
				this.searchFindNext = true;
				this.searchFindNextAsc = false;
				this.currentIndex = this.theDropdown.selectedIndex;
				this.search();
				retval = false;

			} else if ((("abcdefghijklmnopqrstuvwxyz ").indexOf(this.currChar) > -1)) {
				this.checkObjTimeOut(this.theDropdown);
				this.charsArr[this.charsArr.length] = this.currChar;
				this.theSubstr = this.charsArr.join("");
				this.currOp = "ALPHANUM";
				this.lastChar = this.currChar;
				this.search();
				retval = inputFocus;

			} else {
				mb.log.debug("No update required.");
				retval = true;
			}
		} else {
			mb.log.error("No reference to dropdown found.");
			retval = true;
		}
		mb.log.exit();
		return retval;
	};

	/**
	 * Document Me!
	 *
	 * @param theObj
	 */
	this.checkObjTimeOut = function(theObj) {
		mb.log.enter(this.GID, "checkObjTimeOut");
		this.theDropdown = this.getDropDown(theObj);
		if (this.theDropdown != null) {
			var lastEvent = this.objTimeout[this.theDropdown.id];
			var now = new Date().getTime();
			lastEvent = (lastEvent != null ? lastEvent : 0);
			if ((now - lastEvent) > 3000) this.updateStats(theObj, true);
			mb.log.debug("obj: $, last event: $", this.objToString(theObj), (now-lastEvent)+"[ms]");
			this.updateObjTimeout(theObj);
		} else {
			mb.log.error("theObj is invalid reference: $", this.objToString(theObj));
		}
		mb.log.exit();
	};

	/**
	 * Document Me!
	 *
	 * @param theObj
	 */
	this.updateObjTimeout = function(theObj) {
		mb.log.enter(this.GID, "updateObjTimeout");
		this.theDropdown = this.getDropDown(theObj);
		if (this.theDropdown != null) {
			this.objTimeout[this.theDropdown.id] = new Date().getTime();
		} else {
			mb.log.error("theObj is invalid reference: $", this.objToString(theObj));
		}
		mb.log.exit();
	};

	/**
	 * Document Me!
	 *
	 * @param theObj
	 */
	this.getDropDown = function(theObj) {
		mb.log.enter(this.GID, "getDropDown");
		var el, elid = null;
		if (theObj != null &&  theObj.id != null) {
			var theName = theObj.id;
			var nameSplit = theName.split("_");
			if (nameSplit[0] == "attr" && (nameSplit[1] == "instrument" || nameSplit[1] == "vocal")) {
				var lastSplit = nameSplit[nameSplit.length-1];
				if (lastSplit == "substr" || lastSplit == "findprev" || lastSplit == "findnext" || lastSplit == "remove" ) {
					nameSplit.pop(); // loose last part of id
					elid = nameSplit.join("_");
					el = document.getElementById(elid);
				} else {
					el = theObj;
				}
			} else {
				mb.log.debug("Object is not of the type attr_instrument or attr_vocal");
			}
		} else {
			mb.log.error("theObj is invalid reference: $", this.objToString(theObj));
		}

		if (el == null) {
			mb.log.error("Could not get reference to DropDown with id: $", elid);
		}
		mb.log.exit();
		return el;
	};

	/**
	 * Document Me!
	 *
	 * @param theObj
	 */
	this.getInputField = function(theObj) {
		mb.log.enter(this.GID, "getInputField");
		this.theDropdown = this.getDropDown(theObj);
		if (this.theDropdown != null) {
			var inputElemId = this.theDropdown.id + "_substr";
			var inputElem = document.getElementById(inputElemId);
			if (inputElem != null) {
				return inputElem;
			} else {
				mb.log.error("Did not find inputElem with id=$", inputElemId);
			}
		} else {
			mb.log.error("theObj is invalid reference: $", this.objToString(theObj));
		}
		mb.log.exit();
		return null;
	};

	/**
	 * Document Me!
	 */
	this.inputHasFocus = function() {
		mb.log.enter(this.GID, "inputHasFocus");
		var retval = ((this.lastFocusObj != null) &&
					  (this.lastFocusObj.id != null) &&
					  (this.lastFocusObj.id.match(/attr_(instrument|vocal)_\d+_substr/i) != null));
		mb.log.exit();
		return retval;
	};

	/**
	 * Document Me!
	 */
	this.selectHasFocus = function() {
		mb.log.enter(this.GID, "selectHasFocus");
		var retval = ((this.lastFocusObj != null) &&
					  (this.lastFocusObj.id != null) &&
					  (this.lastFocusObj.id.match(/attr_(instrument|vocal)_\d+/i) != null));
		mb.log.exit();
		return retval;
	};

	/**
	 * Document Me!
	 *
	 * @param theObj
	 */
	this.updateStats = function(theObj, bReset, bOverride) {
		mb.log.enter(this.GID, "updateStats");
		mb.log.debug("theObj: $, bReset: $", this.objToString(theObj), bReset==true ? "true" : "false");
		bReset = (bReset == null ? false : bReset);
		bOverride = (bOverride == null ? false : bOverride);
		if (bReset) {
			this.theSubstr = "";
			this.charsArr = new Array();
		}
		this.updateDisplay(theObj, bReset, bOverride);
		if (bReset) {
			this.currentIndex = 0;
			this.theDropdown = null;
		}
		mb.log.exit();
	};

	/**
	 * Document Me!
	 *
	 * @param theObj
	 */
	this.updateDisplay = function(theObj, bReset, bOverride) {
		mb.log.enter(this.GID, "updateDisplay");
		var inputElem = this.getInputField(theObj);
		if (inputElem != null) {
			this.theSubstr = (this.theSubstr == null ? "" : this.theSubstr);
			if ((!this.inputHasFocus() || bOverride) || bReset) inputElem.value = this.theSubstr;
			mb.log.debug("active: $, string: $", this.inputHasFocus(), this.theSubstr);
		} else {
			mb.log.error("theObj is invalid reference: $", this.objToString(theObj));
		}
		mb.log.exit();
	};


	/**
	 * Document Me!
	 *
	 * @param theObj
	 */
	this.handleFocus = function(theObj) {
		mb.log.enter(this.GID, "handleFocus");
		var inputElem = this.getInputField(theObj);
		if (inputElem != null) {
			this.lastFocusObj = theObj;
			if (inputElem.value == "Search...") inputElem.value = "";
			this.theSubstr = (inputElem.value != null ? inputElem.value : "");
			this.charsArr = this.theSubstr.split("");
			this.updateStats(theObj, false);
			mb.log.debug("Initialized search string: $, focusObj: $", this.theSubstr, this.objToString(this.lastFocusObj));
		} else {
			mb.log.error("theObj is invalid reference: $, input: $", this.objToString(theObj), this.objToString(inputElem));
		}
		mb.log.exit();
	};


	/**
	 * Document Me!
	 *
	 * @param theObj
	 */
	this.objToString = function(theObj) {
		return (theObj == null || theObj.id == null ? "null" : theObj.id);
	};


	/**
	 * Document Me!
	 *
	 * @param theObj
	 */
	this.findPrev = function(theObj) {
		mb.log.enter(this.GID, "findPrev");
		this.theDropdown = this.getDropDown(theObj);
		if (this.theDropdown != null && this.theDropdown.options != null) {
			this.handleKeyCode(37, true);
		} else {
			mb.log.error("theObj is invalid reference: $", this.objToString(theObj));
		}
		mb.log.exit();
	};


	/**
	 * Document Me!
	 *
	 * @param theObj
	 */
	this.findNext = function(theObj) {
		mb.log.enter(this.GID, "findNext");
		this.theDropdown = this.getDropDown(theObj);
		if (this.theDropdown != null && this.theDropdown.options != null) {
			this.handleKeyCode(39, true);
		} else {
			mb.log.error("theObj is invalid reference: $", this.objToString(theObj));
		}
		mb.log.exit();
	};


	/**
	 * Search theObj.options for an element that
	 * has theSubstr as a substring and select
	 * first found occurence, else select index 0
	 *
	 * @param hasWrapped
	 */
	this.search = function(hasWrapped) {
		mb.log.enter(this.GID, "search");

		if (this.theDropdown == null) {
			mb.log.error("this.theDropdown = null");
		} else {

			if (this.theSubstr == null || this.theSubstr == "") {
				mb.log.error("this.theSubstr is empty/null");
			} else {

				clearTimeout(this.searchTimeOut);
				if (this.busy) { // wait until interrupt was detected and busy was reset
					this.interrupted = true;
					this.searchTimeOut = setTimeout("arsearch.search()", 10);
				}
				var foundMatch = false;
				var hasMatched = false;
				var strWords = this.theSubstr.split(" ");
				var regexStr =  strWords.join("[^ ]* \\b");
				var re = new RegExp("\\b"+regexStr, "i");
				var i_min = 0;
				var i_max = this.theDropdown.options.length - 1;
				var i = (this.searchFindNext ? this.currentIndex : i_min);

				// print some debug information about the next search turn.
				mb.log.debug("" + (hasWrapped ? "2nd run" : "1st run") + "---------------------------------------------------------------------------");
				mb.log.debug("  Q: $, re=$", this.theSubstr, re);
				mb.log.debug("  OP: $, CHAR: $, LAST: $", this.currOp, this.currChar, this.lastChar);
				mb.log.debug("  findnext: $ ($), index: $, value: $",
					this.searchFindNext,
					this.searchFindNextAsc ? "asc" : "desc",
					this.currentIndex,
					this.currentIndex != -1 ? this.theDropdown.options[this.currentIndex].text : ""
				);

				// continue until search is interrupted
				this.interrupted = false;
				while (!this.interrupted) {
					if (this.searchFindNextAsc && i == i_max) {
						// if ascending search, stop at maximum
						break;
					}
					if (!this.searchFindNextAsc && i == i_min) {
						// if descending search, stop at minimum
						break;
					}
					i += (this.searchFindNextAsc ? 1 : -1); // if ascending search, +1, else +(-1)
					if (!(this.searchFindNext && i == this.currentIndex)) {
						var probe = this.theDropdown.options[i].text;
						var m = re.exec(probe);
						if (m != null) {
							hasMatched = true;
							if (this.searchFindNext) {
								if ((this.searchFindNextAsc && i > this.currentIndex) ||
									(!this.searchFindNextAsc && i < this.currentIndex)) {
									foundMatch = true; // if we are looking for the next occurence of a substring
									break; // and the index is bigger than the previous match, end search successful.
								}
							} else {
								foundMatch = true; // if we are looking for a new string and
								break; // it matched, end search successful.
							}
						}
					} else {
						hasMatched = true; // if no other entry was matched, remember current entry as the one that has matched.
					}
				}

				// log what caused the loop termination, what has happened.
				mb.log.debug("  this.interrupted: $, hasMatched: $, foundMatch: $, index: $",
					this.interrupted,
					hasMatched,
					foundMatch,
					i
				);

				if (!this.interrupted) { // if search was not interrupted
					if (foundMatch && i != 0) { // if foundMatch, select index, else 0
						this.theDropdown.selectedIndex = i;
					} else { // we have not found a valid match.
						if (this.searchFindNext && !hasWrapped) {
							this.busy = false; // reset busy flag.
							this.currentIndex = (this.searchFindNextAsc ? i_min : i_max);
							mb.log.debug("  => We need to wrap, searching again...");
							this.searchTimeOut = setTimeout("arsearch.search(true)", 10);
							mb.log.exit();
							return;
						} else {
							this.theDropdown.selectedIndex = 0;
						}
					}
					this.currentIndex = this.theDropdown.selectedIndex;
				}
				this.busy = false; // reset busy flag.
				this.updateStats(this.theDropdown);
			}
		}
		mb.log.exit();
	};


	/**
	 * @param theObj
	 */
	this.removeAttribute = function(theObj) {
		mb.log.enter(this.GID, "removeAttribute");
		this.theDropdown = this.getDropDown(theObj);
		if (this.theDropdown != null) {
			var nameSplit = this.theDropdown.name.split("_");
			var attr = nameSplit[1];
			var index = parseInt(nameSplit[2]);
			if (index < 1) return; // do not remove element '0'
			var elemParent = document.getElementById(attr);
			if (elemParent) {
				var elemItem = document.getElementById(this.theDropdown.name + "_item");
				if (elemItem) {
					// remove dropdown, previous button, input field, next button and remove button
					var items = new Array("", "_findprev", "_substr", "_findnext", "_remove");
					for (var i=0; i<items.length; i++) {
						var childId = 'attr_' + attr + "_" + index + "" + items[i];
						var elem = document.getElementById(childId);
						if (elem != null) {
							try {
								elemItem.removeChild(elem);
							} catch (e) {
								mb.log.debug("Could not removing id: $ from $", childId, elemItem.id);
							}
						} else {
							mb.log.error("Did not find node to delete: $", childId);
						}
						if (items[i] == "_remove" && index > 1) {
							var elemBtn = document.getElementById("attr_" + attr + "_" + (index-1) + items[i]);
							if (elemBtn) elemBtn.style.display = "inline";
								// hide all remove buttons but the lowest one
								// (to prevent the removal of a button from the
								//  middle of the list)
						}
					}
				}
				try {
					elemParent.removeChild(elemItem);
				} catch (e) {
					mb.log.error("Could not remove id: $, from parent: $", elemItem.id, elemParent.id);
				}
			} else {
				mb.log.error("Did not find parent; "+this.objToString(theObj));
			}
		} else {
			mb.log.error("theObj is invalid reference: $", this.objToString(theObj));
		}
		mb.log.exit();
	};

	/**
	 * @param attr
	 */
	this.addAttribute = function(attr) {
		mb.log.enter(this.GID, "addAttribute");

		var parent = document.getElementById(attr);
		var elements = document.getElementsByName('attr_' + attr + "_0");
		if (elements && parent) {
			var attrElement = elements[0];
			if (attrElement) {
				var index = this.findAttrIndex(attr);

				// do not add element '0' again
				if (index != 0) {
					mb.log.debug("Adding new index: $ to $", index, this.objToString(attrElement));

					// clone dropdown, previous button, input field, next button and remove button
					var items = new Array("", "_findprev", "_substr", "_findnext", "_remove");
					var pId = 'attr_' + attr + "_" + index + "_item";
					var divElem = document.createElement("div");
					divElem .setAttribute("id", pId);
					divElem .className = "ar-attribute-item";
					parent.appendChild(divElem);
					for (var i=0; i<items.length; i++) {
						var childId = 'attr_' + attr + "_0" + items[i];
						var elem = document.getElementById(childId);
						if (elem != null) {
							var newNodeId = "attr_" + attr + "_" + index + items[i];
							var newNode = elem.cloneNode(true);
							if (newNode != null) {
								newNode.setAttribute("id", newNodeId);
								newNode.setAttribute("name", newNodeId);
								divElem.appendChild(newNode);
								if (items[i] == "_substr") {
									newNode.value = "Search...";
								}
								if (items[i] == "_remove") {
									if (index > 1) {
										// hide remove button of the previous
										// dropdown (to prevent the removal of a button from
										//  the middle of the list)
										var elemBtn = document.getElementById("attr_" + attr + "_" + (index-1) + items[i]);
										if (elemBtn) elemBtn.style.display = "none";
									}
									newNode.style.display = "inline";
								}
							} else {
								mb.log.error("new node with id: $ could not be cloned!", newNodeId);
							}
						} else {
							mb.log.error("elem with id: $ not found!", childId);
						}
					}
				}
			}
		}
		mb.log.exit();
	};

	/**
	 * @param attr
	 */
	this.findAttrIndex = function(attr) {
		mb.log.enter(this.GID, "findAttrIndex");
		var index;
		for(index = 1;; index++) {
			var list = document.getElementsByName('attr_' + attr + "_" + index);
			if (list.length == 0) {
				break;
			}
		}
		mb.log.exit();
		return index;
	};


