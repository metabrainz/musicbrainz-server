function ARFrontEnd() {

	// member variables
	this.typedropdown = null;
	this.isurlform = false;
	this.isready = false;
	this.formsubmitted = null;

	/**
	 * Hide all of the divs specified in int_seenattrs.
	 */
	this.hideAll = function() {
		var seenattrs;
		if ((seenattrs = document.linkselect["int_seenattrs"]) != null) {
			var list = (seenattrs.value || "").split(",");
			for  (var i=0; i<list.length; i++) {
				var lr = list[i];
				this.showDiv(lr, 0);
				this.showDiv(lr+ "-desc", 0);
			}	
		} else {
			// addcc.html addurl do not specify this.
			// alert("could not find hidden field int_seenattrs");
		}
	};
	

	/**
	 * Returns if the form submitted flag is set.
	 *
	 */
	this.isFormSubmitted = function() {
		if (this.formsubmitted == null) {
			var field;
			if ((field = document.linkselect["int_formsubmitted"]) != null) {
				this.formsubmitted = (field.value || "") == "1";
			} else {
				//alert("could not find hidden field int_formsubmitted");
			}
		}
		return this.formsubmitted;
	}
	

	/**
	 * internal fields which drive how the javascript function
	 * interacts with the form elements -->
	 * int_isurlform, value: 0|1
	 * int_typedropdown, value: linktypeid|linktype|license
	 *	 
	 * checks for the divs containing the client/server side
	 * variants of the swap elements html, and enables the
 	 * client side behavior if it is supported (=javascript available)
	 **/
	this.setupForm = function() {	
		if (document.linkselect != null) {
			var dropdownhidden;
			if ((dropdownhidden = document.linkselect["int_typedropdown"]) != null) {
				dropdownhidden = (dropdownhidden.value || "");
				if ((this.typedropdown = document.linkselect[dropdownhidden]) != null) {
					if ((this.isurlform = document.linkselect["int_isurlform"]) != null) {
						this.ready = true;

						// register event handlers			
						this.typedropdown.onkeydown = function(event) { arfrontend.typeChanged(); }
						this.typedropdown.onchange = function(event) { arfrontend.typeChanged(); }

						// fire event to setup descriptions etc.
						this.typeChanged(); 

					} else {
						alert("could not find hidden field int_isurlform");
					}
				} else {
					alert("could not find the dropdown specified by int_typedropdown");
				}

				// add handler which clears the default value upon focus.
				var urlfield;
				if ((urlfield = document.linkselect["url"]) != null) {
					urlfield.onfocus = function(event) { if (this.value == "http://") this.value = ""; }
					urlfield.onblur = function(event) { if (this.value == "") this.value = "http://"; }
					urlfield.onchange = function(event) { arfrontend.guessTypeFromURL(this); }
					urlfield.onkeyup = function(event) { arfrontend.guessTypeFromURL(this); }
				}
				var elcs, elss;
				if ((elcs = mb.ui.get("swap-clientside")) != null &&
					(elss = mb.ui.get("swap-serverside")) != null) {
					elcs.style.display = "block";
					elss.style.display = "none";
				}
			} else {
				alert("could not find the hidden field int_typedropdown");
			}
		} else {
			alert("could not find form document.linkselect!");
		}
	};
	
	/**
	 * Sets the display attributed of the the div
	 * with id=id to the show (true|false)
	 *
	 */	
	this.guessTypeFromURL = function(field) {
		var tdd = this.typedropdown;
		if (tdd.selectedIndex != 1) {
			var v = (field.value || ""), site = "";
			if (v.match(/\.amazon\./i)) {
				site = "amazon asin";	
			} else if (v.match(/\.discogs\./i)) {
				site = "discogs";
			} else if (v.match(/\.wikipedia\./i)) {
				site = "wikipedia";
			} else if (v.match(/musicmoz\./i)) {
				site = "musicmoz";
			} else if (v.match(/\.imdb\./i)) {
				site = "internet movie database";
			}
			if (site != "") {
				var tddo = this.typedropdown.options;
				for (var i=0;i<tddo.length; i++) {
					var value = tddo[i].value.toLowerCase();
					var found = value.indexOf(site) != -1;
					if (found) {
						tdd.selectedIndex = i;
						this.typeChanged();
						break;
					}
				}
			}
		}
	};
	
	/**
	 * Sets the display attributed of the the div
	 * with id=id to the show (true|false)
	 *
	 */
	this.showDiv = function(id, show) {
		var obj = document.getElementById(id);
		if (obj) obj.style.display = (show == 1 ? "block" : "none");
	};
	
	/**
	 * Sets the description of the current selected element
	 * from the dropdown list.
	 *
	 */
	this.typeChanged = function() {
		if (this.typedropdown != null) {
			var selection = this.typedropdown.value;
			var sp = selection.split("|");
			var attrs = (sp[1] || "");
			var descr = (sp[2] || "");

			if (!this.isurlform != null) {
				var p;
				this.hideAll();
				if (attrs == "") {
					this.showDiv('attributes', 0);
				} else {
					this.showDiv('attributes', 1);
					var pairs = attrs.split(" ");
					for(p in pairs) {
						var kv = pairs[p].split('=');
						if (kv[0] != "") {
							this.showDiv(kv[0], 1);
							this.showDiv(kv[0] + "-desc", 1);
						}
					}
				}
			} 
			
			// update description div
			var relDesc = mb.ui.get('relationship_desc');
			if (relDesc) {
				if (descr != "") {
					relDesc.innerHTML = "" + descr;
					relDesc.setAttribute("className", "linkdesc");
				} else if (selection == "||") {
					relDesc.innerHTML = "";
				} else {
					var tempStr = (this.isFormSubmitted() ? "Error: " : "") + 
						"Please select a subtype of the currently selected " +
						"relationship type. The selected relationship type is " +
						"only used for grouping sub-types.";
					relDesc.innerHTML = tempStr;
					if (this.isFormSubmitted()) {
						relDesc.setAttribute("className", "linkerrorslim");
					}
				}
			}
		} else {
			alert("could not find the dropdown "+document.linkselect["int_typedropdown"]+" in form!");
		}
	}


	/**
	 * swap the contents of the first and the second element
	 * which are going to be related to each other.
	 * (saves a server roundtrip)
	 */
	this.swapElements = function(theBtn) {
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
}
var arfrontend = new ARFrontEnd();
arfrontend.setupForm();
