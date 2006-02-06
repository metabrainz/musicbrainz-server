// ----------------------------------------------------------------------------
// ar_hideAll()
// --  Hide all of the attributeDivs.
//
function ar_hideAll() {
	if (attributeDivs == null || attributeDivs.length == 'undefined') return;
	for  (var i=0; i<attributeDivs.length; i++) {
		var lr = attributeDivs[i];
		if (lr != null) {
			ar_showDiv(lr, 0);
			ar_showDiv(lr + "-desc", 0);
		}
	}
}

// ----------------------------------------------------------------------------
// ar_showDiv()
// --  Sets the display attributed of the the div
//     with id=id to the show (true|false)
//
function ar_showDiv(id,show) {
	var obj = document.getElementById(id);
	if (obj) obj.style.display = (show == 1 ? "block" : "none");
}

// ----------------------------------------------------------------------------
// ar_typeChanged()
// --  Sets the description of the current selected element
//     from the dropdown list.
//
function ar_typeChanged() {
	if (document.linkselect.isurlform.value == 0) {
		var selection = document.linkselect.linktypeid.value;
		var sp = selection.split("|");
		var attrs = sp[1];
		var p;
		ar_hideAll();
		if (attrs == "") {
			ar_showDiv('attributes', 0);
		} else {
			ar_showDiv('attributes', 1);
			var pairs = attrs.split(" ");
			for(p in pairs) {
				var kv = pairs[p].split('=');
				if (kv[0] != "") {
					ar_showDiv(kv[0], 1);
					ar_showDiv(kv[0] + "-desc", 1);
				}
			}
		}
		var relationship_desc = document.getElementById('relationship_desc');
		if (relationship_desc) {
			if (sp[2] != "") {
				relationship_desc.innerHTML = "" + sp[2];
				relationship_desc.setAttribute("className", "linkdesc");
			} else if (selection == "||") {
				relationship_desc.innerHTML = "";
			} else {
				var tempStr = (wasFormSubmitted ? "Error: " : "") + 
					"Please select a subtype of the currently selected " +
					"relationship type. The selected relationship type is " +
					"only used for grouping sub-types.";
				relationship_desc.innerHTML = tempStr;
				if (wasFormSubmitted) relationship_desc.setAttribute("className", "linkerrorslim");
			}
		}
	}
}

// ----------------------------------------------------------------------------
// ar_typeChangedURL()
// --  Finds the offset of the attribute attr index.
//
function ar_typeChangedURL() {
	if (document.linkselect.isurlform.value == 1) {
		var selection = document.linkselect.linktype.value;
		var sp = selection.split("|");
		var relationship_desc = document.getElementById('relationship_desc');
		if (relationship_desc) {
			if (sp[2] != "") {
				relationship_desc.innerHTML = "" + sp[2];
				relationship_desc.setAttribute("className", "linkdesc");
			} else if (selection == "||") {
				relationship_desc.innerHTML = "";
			} else {
				var tempStr = (wasFormSubmitted ? "Error: " : "") + 
					"Please select a subtype of the currently selected " +
					"relationship type. The selected relationship type is " +
					"only used for grouping sub-types.";
				relationship_desc.innerHTML = tempStr;
				if (wasFormSubmitted) relationship_desc.setAttribute("className", "linkerrorslim");
			}
		}
	}
}

function myOnFocus() { /* this is called from the onFocus handler of the date attributes, but is not handled on the relationship forms */ }
function myOnBlur() {/* this is called from the onBlur handler of the date attributes, but is not handled on the relationship forms */ }

// ----------------------------------------------------------------------------
// ar_swapElements()
// -- swap the contents of the first and the second element
//    which are going to be related to each other.
//    (saves a server roundtrip)
function ar_swapElements(theBtn) {
	var theForm = theBtn.form;
	if (theForm == null || theForm.link0 == null || theForm.link1) {
		var leftTD = document.getElementById("arlinkswap-link0-td");
		var rightTD = document.getElementById("arlinkswap-link1-td");
		var leftVAL = theForm.link0.value;
		var rightVAL = theForm.link1.value;
		if (leftTD != null && rightTD != null &&
			leftVAL != "" && rightVAL != "") {
			var tmp = leftTD.innerHTML;
			leftTD.innerHTML = rightTD.innerHTML;
			rightTD.innerHTML = tmp;
			tmp = theForm.link0.value;
			theForm.link0.value = theForm.link1.value
			theForm.link1.value = tmp;
		}
	}
}

// ----------------------------------------------------------------------------
// ar_initSwap()
// -- checks for the divs containing the client/server side
//    variants of the swap elements html, and enables the
//    client side behavior if it is supported (=javascript available)
//
function ar_initForm() {
	var elClientside = document.getElementById("swap-clientside");
	var elServerside = document.getElementById("swap-serverside");
	if (elClientside && elServerside) {
		elClientside.style.display = "block";
		elServerside.style.display = "none";
	}
	ar_typeChanged(); // initialise form for add.html, edit.html
	ar_typeChangedURL(); // initialise form for addurl.html
}
ar_initForm(); // initialise 

