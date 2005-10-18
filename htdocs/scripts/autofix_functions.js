
var afFunc = {

	// ----------------------------------------------------------------------------
	// resizeTextFields()
	// -- add/remove amount from size attribute on edit fields in
	//    the form.
	resizeTextFields : function(amount) {
		var fields = afCommons.getEditTextFields();
		if (amount == null || amount == 'undefined') {
			var max = 0;
			for (fi in fields) {
				var lx = fields[fi].value.length;
				if (lx > max) max = lx;
			}
			for (fi in fields) {
				fields[fi].size = (max < 50 ? 50 : max); // + parseInt((max/50.0)*20);
			}
		} else {
			for (fi in fields) {
				if (fields[fi].size + amount > 1) {
					fields[fi].size += amount;
				}
			}
		}
	}
};



// ***********************************************************************
// handler functions for all the different kind of
// and permutation of fields.
//   * artist
//   * album
//   * artist, track
//   * artist, sortname
// ***********************************************************************

// ----------------------------------------------------------------------------
// doArtistName()
// -- Apply fix to the Artist Name field with name=theID
function doArtistName(theForm, fid) {
	if (fid == null) fid = 'artist';
	var theField = afCommons.getField(fid);
	var oldvalue = theField.value;
	var newvalue = af_artistNameFix(oldvalue);
	if (newvalue != oldvalue) {
		theField.value = newvalue;
		afUndo.addUndo([theField, af_mode, oldvalue, newvalue]);
	}
	afCommons.resetSelection();
}

// ----------------------------------------------------------------------------
// doAlbumName()
// -- Apply fix to the Album Name field with name=fid
function doAlbumName(theForm, fid) {
	if (fid == null) fid = 'album';
	var theField = afCommons.getField(fid);
	var oldvalue = theField.value;
	var newvalue = af_albumNameFix(theField.value);
	if (newvalue != oldvalue) {
		theField.value = newvalue;
		afUndo.addUndo([theField, af_mode, oldvalue, newvalue]);
	}
	afCommons.resetSelection();
}

// ----------------------------------------------------------------------------
// doTrackName()
// -- Apply fix to the Track Name field with name=fid
function doTrackName(theForm, fid) {
	var theField = afCommons.getField(fid);
	var oldvalue = theField.value;
	var newvalue = af_trackNameFix(theField.value);
	if (newvalue != oldvalue) {
		theField.value = newvalue;
		afUndo.addUndo([theField, af_mode, oldvalue, newvalue]);
	}
	afCommons.resetSelection();
}

// ----------------------------------------------------------------------------
// doSortNameCopy()
// -- Copy value from the artist field to the sortname field
function doSortNameCopy(theForm, theArtistID, theSortID) {
	var theArtistField = afCommons.getField(theArtistID);
	var theSortnameField = afCommons.getField(theSortID);
	var oldvalue = theSortnameField.value;
	var newvalue = theArtistField.value;
	if (newvalue != oldvalue) {
		theSortnameField.value = newvalue;
		afUndo.addUndo([theSortnameField, 'sortnamecopy', oldvalue, newvalue]);
	}
	afCommons.resetSelection();
}

// ----------------------------------------------------------------------------
// doSortNameGuess()
//  -- Guess artist sortname using the artistNameGuessSortName routine in autofix.js
function doSortNameGuess(theForm, theArtistID, theSortID) {
	var theArtistField = afCommons.getField(theArtistID);
	var theSortnameField = afCommons.getField(theSortID);
	var artistValue = theArtistField.value;
	var newvalue = theSortnameField.value; var oldvalue = theSortnameField.value;
	newvalue = artistNameGuessSortName(artistValue);
	if (newvalue != oldvalue) {
		theSortnameField.value = newvalue;
		afUndo.addUndo([theSortnameField, 'sortname', oldvalue, newvalue]);
	}
	afCommons.resetSelection();
}

// ----------------------------------------------------------------------------
// doSwapFields()
// -- Swap artist name and track name fields
function doSwapFields(theForm) {
	if (theForm != null) {
		if (theForm.search && theForm.trackname && theForm.swapped) {
			var newSwapped = 1 - theForm.swapped.value; // hidden var which holds if fields were swapped
			var switchTempVar = theForm.search.value; // remember field for swap operation
			afUndo.addUndo([[theForm.trackname, 'swap', theForm.trackname.value, theForm.search.value],
						[theForm.search, 'swap', theForm.search.value, theForm.trackname.value],
						[theForm.swapped, 'swap', theForm.swapped.value, newSwapped]
					   ]);
			theForm.search.value = theForm.trackname.value;
			theForm.trackname.value = switchTempVar;
			theForm.swapped.value = newSwapped;
		}
	}
}

// ----------------------------------------------------------------------------
// doUseCurrent()
// -- Use the initial value (reset)
function doUseCurrent(theForm) {
	if (theForm != null) {
		if (theForm.search != null && theForm.orig_artname != null &&
			theForm.trackname != null && theForm.orig_track != null) {
			afUndo.addUndo([[theForm.trackname, 'usecurrent', theForm.trackname.value, theForm.orig_track.value],
					    [theForm.search, 'usecurrent', theForm.search.value, theForm.orig_artname.value]
					   ]);
			theForm.trackname.value = theForm.orig_track.value;
			theForm.search.value = theForm.orig_artname.value;
		}
	}
}

// ----------------------------------------------------------------------------
// doUseSplit()
// -- Use the split that was guessed on the server side
function doUseSplit(theForm) {
	if (theForm != null) {
		if (theForm.split_artname != null &&
			theForm.split_track != null) {
			afUndo.addUndo([[theForm.trackname, 'usesplit', theForm.trackname.value, theForm.split_track.value],
						[theForm.search, 'usesplit', theForm.search.value, theForm.split_artname.value]
					   ]);
			theForm.search.value = theForm.split_artname.value;
			theForm.trackname.value= theForm.split_track.value;
		}
	}
}

// ----------------------------------------------------------------------------
// doArtistAndTrackName()
//  -- Guess artist and trackname first, and try to identify
//     common freedb mistakes and fix them
var changeTrackWarningString = "";
function doArtistAndTrackName(theForm) {
	var tnOldValue = theForm.trackname.value;
	var snOldValue = theForm.search.value;
	var tnValue = tnOldValue;
	var snValue = snOldValue;
	if (tnValue.match(/\sfeat/i) && snValue.match(/\smix/i)) {
		if (changeTrackWarningString != tnValue+"|"+snValue) {
			alert("Please swap artist / trackname fields. they are most likely wrong.");
			changeTrackWarningString = tnValue+"|"+snValue;
			return;
		}
	}
	var tnValueFixed = af_trackNameFix(tnValue);
	var snValueFixed = af_artistNameFix(snValue );
	var featIndex = -1;
	var haystack = snValue.toLowerCase();
	// match ft, featuring feat if not last word of searchname.
	featIndex = (snValue.match(/\s\(feat[\.]?[^$]?/i) ? haystack.indexOf("(feat") : featIndex);
	featIndex = (snValue.match(/\sFeat[\.]?[^$]?/i) ? haystack.indexOf("feat") : featIndex);
	featIndex = (snValue.match(/\sFt[\.]?[^$]/i) ? haystack.indexOf("ft") : featIndex);
	featIndex = (snValue.match(/\sFeaturing[^$]/i) ? haystack.indexOf("featuring") : featIndex);
	if (featIndex != -1) {
		var addParens = (snValue.charAt(featIndex) != "(");
		tnValue = tnValue + (addParens ? " (" : "") +
				  snValue.substring(featIndex, snValue.length) +
				  (addParens ? ")" : "");
		snValue = snValue.substring(0, featIndex);
		tnValueFixed = af_trackNameFix(tnValue);
		snValueFixed = af_artistNameFix(snValue);
	}
	theForm.trackname.value = tnValueFixed;
	theForm.search.value = snValueFixed;
	var tnChanged = (tnValueFixed != tnOldValue);
	var snChanged = (snValueFixed != snOldValue);
	var tnUndo = [theForm.trackname, 'guessboth', tnOldValue, tnValueFixed];
	var snUndo = [theForm.search, 'guessboth', snOldValue, snValueFixed];
	if (tnChanged && snChanged) { // Artist Name and Track Name have changed
		afUndo.addUndo([tnUndo, snUndo]);
	} else if (tnChanged) { // Track Name has changed
		afUndo.addUndo(tnUndo);
	} else if (snChanged) { // Artist Name has changed
		afUndo.addUndo(snUndo);
	}
}






// ***********************************************************************
// autofix helper functions
// -- should not be called outside of this script
// ***********************************************************************


// ----------------------------------------------------------------------------
// af_artistNameFix()
// -- Atomic operation, which take the value and applies
//    the current selected autofix operation
// 	  af_mode is ignored, because artistname is not sentence capsed
function af_artistNameFix(theValue) {
	return artistNameFix(theValue);
}

// ----------------------------------------------------------------------------
// af_albumNameFix()
// -- Atomic operation, which take the value and applies
//    the current selected autofix operation
function af_albumNameFix(theValue) {
	if (af_mode == AF_MODE_AUTOFIX) return albumNameFix(theValue);
	else if (af_mode == AF_MODE_SENTENCECAPS) return af_upperCaseFirst(theValue);
}

// ----------------------------------------------------------------------------
// af_trackNameFix()
// -- Atomic operation, which take the value and applies
//    the current selected autofix operation
function af_trackNameFix(theValue) {
	if (af_mode == AF_MODE_AUTOFIX) return trackNameFix(theValue);
	else if (af_mode == AF_MODE_SENTENCECAPS) return af_upperCaseFirst(theValue);
}

// ----------------------------------------------------------------------------
// af_upperCaseFirst()
// -- Uppercases the first character, rest lowercase
function af_upperCaseFirst(theValue) {
	var input_string = trim(theValue.toLowerCase());
	var chars = input_string.split("");
	chars[0] = chars[0].toUpperCase();
	return chars.join("");
}
