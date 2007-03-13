/*----------------------------------------------------------------------------\
|                              Musicbrainz.org                                |
|                 Copyright (c) 2005 Stefan Kestenholz (keschte)              |
|-----------------------------------------------------------------------------|
| This software is provided "as is", without warranty of any kind, express or |
| implied, including  but not limited  to the warranties of  merchantability, |
| fitness for a particular purpose and noninfringement. In no event shall the |
| authors or  copyright  holders be  liable for any claim,  damages or  other |
| liability, whether  in an  action of  contract, tort  or otherwise, arising |
| from,  out of  or in  connection with  the software or  the  use  or  other |
| dealings in the software.                                                   |
| - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - |
| GPL - The GNU General Public License    http://www.gnu.org/licenses/gpl.txt |
| Permits anyone the right to use and modify the software without limitations |
| as long as proper  credits are given  and the original  and modified source |
| code are included. Requires  that the final product, software derivate from |
| the original  source or any  software  utilizing a GPL  component, such  as |
| this, is also licensed under the GPL license.                               |
|                                                                             |
| $Id$
\----------------------------------------------------------------------------*/

function ARFrontEnd() {

	// ----------------------------------------------------------------------------
	// register class/global id
	// ----------------------------------------------------------------------------
	this.CN = "ARFrontEnd";
	this.GID = "arfrontend";
	mb.log.enter(this.CN, "__constructor");

	// ----------------------------------------------------------------------------
	// member variables
	// ----------------------------------------------------------------------------
	this.form = null;
	this.typeDropDownName = null;
	this.typeDropDown = null;
	this.isurlform = false;
	this.isready = false;
	this.formsubmitted = null;

	// ----------------------------------------------------------------------------
	// member functions
	// ----------------------------------------------------------------------------

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
				if (lr != "") {
					mb.ui.setDisplay(lr, false);
					mb.ui.setDisplay(lr+ "-desc", false);
				}
			}
		} else {
			// addcc.html, addurl.html pages do not specify this.
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
				mb.log.error("could not find hidden field int_formsubmitted");
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

		// hide the notice, which is displayed for browsers
		// which have javascript turned off.
		var obj;
		if ((obj = mb.ui.get("relationshipNoScript")) != null) {
			obj.style.display = "none";
		}

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

						// add handler which clears the default value upon focus.
						if (this.isurlform.value == 1) {
							var urlfield;
							if ((urlfield = this.form.url) != null) {
								urlfield.onfocus = function(event) { if (this.value == "http://") this.value = ""; }
								urlfield.onblur = function(event) { if (this.value == "") this.value = "http://"; }
								urlfield.onchange = function(event) { arfrontend.guessTypeFromURL(this); }
								urlfield.onkeyup = function(event) { arfrontend.guessTypeFromURL(this); }
							} else {
								mb.log.error("Field url not found in form!");
							}
						}
					} else {
						mb.log.error("Could not find the hidden field int_isurlform");
					}
				} else {
					mb.log.error("Could not find the DropDown given by int_typedropdown $", this.typeDropDownName);
				}

				var swapval, elcs, elss;
				if ((swapval = this.form.swapval) == null &&
					(elcs = mb.ui.get("arEntitiesSwap-Client")) != null &&
					(elss = mb.ui.get("arEntitiesSwap-Server")) != null) {
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
			if (v.match(/[./]amazon\./i)) {
				site = "amazon asin";

				// determine tld, asin from url, and build standard format [1],
				// if both were found. There used to be another [2], but we'll
				// stick to the new one for now.
				//
				// [1] "http://www.amazon.<tld>/gp/product/<ASIN>"
				// [2] "http://www.amazon.<tld>/exec/obidos/ASIN/<ASIN>"

				var tld = "", asin = "";
				if ((m = v.match(/amazon\.([a-z\.]+)\//)) != null) {
					tld = m[1];
				}
				if ((m = v.match(/\/([A-Z0-9]{10})(?:[/?]|$)/)) != null) {
					asin = m[1];
				}
				if (tld != "" && asin != "") {
					field.value = "http://www.amazon." + tld + "/gp/product/" + asin;
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
					mb.ui.setDisplay("relationshipAttributes", false);
				} else {
					mb.ui.setDisplay("relationshipAttributes", true);
					var p, pairs = attrs.split(" ");
					for(p in pairs) {
						var kv = pairs[p].split('=');
						if (kv[0] != "") {
							mb.ui.setDisplay(kv[0], true);
							mb.ui.setDisplay(kv[0] + "-desc", true);
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
			var leftTD = document.getElementById("arEntitiesSwap-TD0");
			var rightTD = document.getElementById("arEntitiesSwap-TD1");
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
