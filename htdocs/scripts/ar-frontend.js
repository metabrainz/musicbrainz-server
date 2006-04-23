function ARFrontEnd() {

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "ARFrontEnd";
	this.GID = "arfrontend";
	mb.log.enter(this.CN, "__constructor");

	// member variables
	this.form = null;
	this.typeDropDownName = null;
	this.typeDropDown = null;
	
	this.isurlform = false;
	this.isready = false;
	this.formsubmitted = null;

	/**
	 * Hide all of the divs specified in int_seenattrs.
	 */
	this.hideAll = function() {
		mb.log.enter(this.GID, "hideAll");
		var seenattrs;
		if ((seenattrs = this.form.int_seenattrs) != null) {
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
		mb.log.exit();
	};
	

	/**
	 * Returns if the form submitted flag is set.
	 *
	 */
	this.isFormSubmitted = function() {
		mb.log.enter(this.GID, "isFormSubmitted");
		if (this.formsubmitted == null) {
			var field;
			if ((field = this.form.int_formsubmitted) != null) {
				this.formsubmitted = (field.value || "") == "1";
			} else {
				//alert("could not find hidden field int_formsubmitted");
			}
		}
		mb.log.exit();
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
		mb.log.enter(this.GID, "setupForm");
		if ((this.form = mb.ui.get("LinkSelectForm")) != null) {
			if ((this.typeDropDownName = this.form.int_typedropdown) != null) {
				this.typeDropDownName = (this.typeDropDownName.value || "");
				if ((this.typeDropDown = this.form[this.typeDropDownName]) != null) {
					if ((this.isurlform = this.form.int_isurlform) != null) {
						this.ready = true;

						// register event handlers			
						this.typeDropDown.onkeydown = function(event) { arfrontend.typeChanged(); }
						this.typeDropDown.onchange = function(event) { arfrontend.typeChanged(); }
						
 						// fire event to setup descriptions etc.
						this.typeChanged(); 
						
						this.typeDropDown.onkeydown();

					} else {
						mb.log.error("Could not find the hidden field int_isurlform");
					}
				} else {
					mb.log.error("Could not find the DropDown given by int_typedropdown $", this.typeDropDownName);
				}
				
				//http://www.amazon.com/gp/product/B00006EXLQ/102-6816886-9853762?s=music&v=glance&n=5174

				// add handler which clears the default value upon focus.
				var urlfield;
				if ((urlfield = this.form.url) != null) {
					urlfield.onfocus = function(event) { if (this.value == "http://") this.value = ""; }
					urlfield.onblur = function(event) { if (this.value == "") this.value = "http://"; }
					urlfield.onchange = function(event) { arfrontend.guessTypeFromURL(this); }
					urlfield.onkeyup = function(event) { arfrontend.guessTypeFromURL(this); }
				} else {
					mb.log.error("Field url not found in form!");
				}
				var elcs, elss;
				if ((elcs = mb.ui.get("swap-clientside")) != null &&
					(elss = mb.ui.get("swap-serverside")) != null) {
					elcs.style.display = "block";
					elss.style.display = "none";
				}
			} else {
				mb.log.error("Could not find the hidden field int_typedropdown");
			}		
		} else {
			mb.log.error("could not find the LinkSelectForm");
		}			
		mb.log.exit();
	};
	
	/**
	 * Sets the display attributed of the the div
	 * with id=id to the show (true|false)
	 *
	 */	
	this.guessTypeFromURL = function(field) {
		mb.log.enter(this.GID, "guessTypeFromURL");
		var tdd = this.typeDropDown;
		if (tdd.selectedIndex != 1) {
			var v = (field.value || ""), site = "";
			if (v.match(/\.amazon\./i)) {
				site = "amazon asin";	
				
				// try to chop off stuff from the end of the url.
				var reUS = /(.*\/gp\/product\/[a-z0-9]*).*/i; // http://www.amazon.com/gp/product/<ASIN>
				var reNonUS = /(.*\/exec\/obidos\/ASIN\/[a-z0-9]*).*/i; // http://www.amazon.de/exec/obidos/ASIN/<ASIN>
				
				if (v.match(reUS)) { 
					field.value = v.replace(reUS, "$1");
				} else if (v.match(reNonUS)) { 
					field.value = v.replace(reNonUS, "$1");
				}
				
			} else if (v.match(/\.discogs\./i)) {
				site = "discogs";
			} else if (v.match(/\.wikipedia\./i)) {
				site = "wikipedia";
			} else if (v.match(/musicmoz\./i)) {
				site = "musicmoz";
			} else if (v.match(/(\.|\/)imdb\./i)) {
				site = "internet movie database";
			} else if (v.match(/(\.|\/)myspace\.com/i)) {
				site = "myspace";
			}
			if (site != "") {
				var tddo = this.typeDropDown.options;
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
		mb.log.exit();
	};
	
	/**
	 * Sets the display attributed of the the div
	 * with id=id to the show (true|false)
	 *
	 */
	this.showDiv = function(id, show) {
		mb.log.enter(this.GID, "showDiv");
		var obj = document.getElementById(id);
		if (obj) obj.style.display = (show == 1 ? "block" : "none");
		mb.log.exit();
	};
	
	/**
	 * Sets the description of the current selected element
	 * from the dropdown list.
	 *
	 */
	this.typeChanged = function() {
		mb.log.enter(this.GID, "typeChanged");
		if (this.typeDropDown != null) {
			var selection = this.typeDropDown.value;
			var sp = selection.split("|");
			var attrs = (sp[1] || "");
			var descr = (sp[2] || "");

			if (!this.isurlform != null) {
				this.hideAll();
				if (attrs == "") {
					this.showDiv("attributes", 0);
				} else {
					this.showDiv("attributes", 1);
					var p, pairs = attrs.split(" ");
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
			var el = mb.ui.get("relationshipTypeDesc");
			if (el) {
				if (descr != "") {
					el.innerHTML = "" + descr; 
					el.setAttribute("className", "relationshipTypeDesc");
				} else if (selection == "||") {
					el.innerHTML = "Please select a relationship type";
				} else {
					var tempStr = 	"Please select a subtype of the currently selected " +
									"relationship type. The selected relationship type is " +
									"only used for grouping sub-types.";
					el.innerHTML = tempStr;
					if (this.isFormSubmitted()) {
						el.setAttribute("className", "relationshipTypeError");
					}
				}
			}
		} else {
			mb.log.error("Cannot find the DropDown $ in the form!", this.typeDropDownName);
		}				
		mb.log.exit();
	}


	/**
	 * swap the contents of the first and the second element
	 * which are going to be related to each other.
	 * (saves a server roundtrip)
	 */
	this.swapElements = function(theBtn) {
		mb.log.enter(this.GID, "swapElements");
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
		mb.log.exit();
	}	
	
	// exit constructor
	mb.log.exit();
}

// instantiate, and setup the form.
var arfrontend = new ARFrontEnd();
mb.registerDOMReadyAction(
	new MbEventAction(arfrontend.GID, 'setupForm', "Setup AdvancedRelationship entry form")
);
