// resize TextArea based on the amount of text
// (soft and hard wraps) 
//
// inspired by: http://tuckey.org/textareasizer
//
var ntObj = document.getElementById("notetext");
var ntIsGecko = (navigator.userAgent.indexOf("Gecko") != -1);

// only add handlers if there is a "notetext" 
// element in the DOM-tree
if (ntObj) {								
	var ntSplitRE = /\r\n|\r|\n/g; // compile only once.
	var ntCheckedText = "";
	var ntCheckBusy = false;
	var ntRows = 0;

	// recalcRows() --
	// @param strText  	the current text of the textarea
	// @param cols  	the cols="x" property of the textarea
	// @returns 		the number of rows the text in the
	//					textarea occupies currently
	function recalcRows(strText, cols) {
		if (strText == null || strText == 'undefined') return;
		if (cols == null || cols == 'undefined') return;
		var lines = strText.split(ntSplitRE);
		ntRows = 1+lines.length;
		var lineLength;
		for (line in lines) {
			// iterate through all the lines and see
			// if we have to add virtual linewraps
			if ((lineLength = lines[line].length) > cols) {
				ntRows += Math.floor(lineLength*parseFloat(1/cols));
			}
		}
		ntRows = (ntRows < 3 ? 3 : ntRows) + (ntIsGecko ? -1 : 0); 
		// subtract one row for gecko browsers, because
		// they render one to many if set by JS compared
		// to IE and opera.
		return (ntRows); 
	}

	// Anonymous handler function which gets
	// called when an event on the textarea
	// occurs that requires recalculation of the rows.
	var f = function() {
		if (!ntCheckBusy && ntObj && ntCheckedText != ntObj.value) {	
			ntCheckBusy = true;
			ntObj.rows = recalcRows(ntObj.value, ntObj.cols);
			ntCheckedText = ntObj.value;
			ntCheckBusy = false;
			// document.getElementById("asdf").innerHTML = ("wraps: "+ntRows+" rows: "+ntObj.rows);
			// document.getElementById("log").innerHTML = (ntCheckedText);
		}
	}
	ntObj.onblur = f;    // register every possible
	ntObj.onfocus = f;   // event hander such that
	ntObj.onchange = f;  // the check happens on copy+paste,
	ntObj.onkeyup = f;   // page resize and regular typing
	ntObj.onkeydown = f; // in the textarea. (duplicate checks
	ntObj.onresize = f;	 // with same values are skpped)
	f();
}
