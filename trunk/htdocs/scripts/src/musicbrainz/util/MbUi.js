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

/**
 * Global user interface functions
 *
 */
function MbUI() {
	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "MbUI";
	this.GID = "mb.ui";
	this.SPLITSEQ = "::";

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Wrapper for getElementById method.
	 *
	 * @param	name	the html entity name.
	 **/
	this.get = function(id, parent) {
		mb.log.enter(this.GID, "get");
		var el, nn;
		if (id) {
			parent = (parent || document);
			if (parent.getElementById) {
				el = parent.getElementById(id);
				nn = (el && el.nodeName ? el.nodeName : "?");
				mb.log.trace("Querying element id: $, el: $", id, nn);
			} else {
				mb.log.error("Element parent $ does not support getElementById!", parent);
			}
		} else {
			mb.log.error("Required parameter $ was null", "id");
		}
		return mb.log.exit(el);
	};

	/**
	 * Wrapper for getElementsByTagName method.
	 *
	 * Returns the child elements of object parent
	 * with name equal to name.
	 *
	 * @param	parent	parent object, or document if not given
	 * @param	tag		the html entity type.
	 **/

	this.getByTag = function(tag, parent) {
		mb.log.enter(this.GID, "getByTag");
		var list = [];
		if (tag) {
			parent = (parent || document);
			if (parent.getElementsByTagName) {
				list = parent.getElementsByTagName(tag);
				mb.log.trace("Querying elements with tag: $, parent: $, length: $", tag, (parent.nodeName || parent), list.length);
			} else {
				mb.log.error("Element parent $ does not support getElementsByTagName!", parent);
			}
		} else {
			mb.log.error("Required parameter $ was null", "tag");
		}
		return mb.log.exit(list);
	};

	/**
	 * Wrapper for getElementsByTagName method.
	 *
	 * Returns the child elements of object parent
	 * with name equal to name.
	 *
	 * @param	parent	parent object, or document if not given
	 * @param	name	the html entity name.
	 **/

	this.getByName = function(name, parent) {
		mb.log.enter(this.GID, "getByName");
		var list = [];
		if (name) {
			parent = (parent || document);
			if (parent.getElementsByName) {
				list = parent.getElementsByName(name);
				mb.log.trace("Querying elements with name: $, parent: $, length: $", name, (parent.nodeName || parent), list.length);
			} else {
				mb.log.error("Element parent $ does not support getElementsByName!", parent);
			}
		} else {
			mb.log.error("Required parameter $ was null", "name");
		}
		return mb.log.exit(list);
	};

	/**
	 * Updates the display style for the given element
	 **/
	this.setDisplay = function(el, flag) {
		mb.log.enter(this.GID, "get");
		if (mb.utils.isString(el)) {
			var obj;
			if ((obj = this.get(el)) == null) {
				mb.log.error("Could not find element with id: $", el);
			}
			el = obj;
		}
		if (el) {
			el.style.display = (flag ? "" : "none");
		} else {
			mb.log.error("Required parameter el is null!");
		}
		return mb.log.exit(el);
	};


	/**
	 * Returns the offset from the top edge of the screen
	 **/
	this.getOffsetTop = function(el) {
		mb.log.enter(this.GID, "getOffsetTop");
		if (mb.utils.isString(el)) {
			var obj;
			if ((obj = this.get(el)) == null) {
				mb.log.warning("Could not find element with id: $", el);
			}
			el = obj;
		}
		var elo = el;
		var o = -1;
		if (el) {
			if (mb.ua.nav4) {
				o = el.pageY;
			} else if (mb.ua.ie4up || mb.ua.gecko) {
				o = 0;
				while (el.offsetParent != null) {
					o += el.offsetTop;
					el = el.offsetParent;
				}
				o += el.offsetTop;
			} else if (mb.ua.mac && mb.ua.ie5) {
				o = stringToNumber(document.body.currentStyle.marginTop);
			}
		} else {
			mb.log.warning("Element el is null!");
		}
		mb.log.debug("el: $, top: $", elo, o);
		return mb.log.exit(o);
	};

	/**
	 * Returns the offset from the left edge of the screen
	 **/
	this.getLeft = function(el) {
		mb.log.enter(this.GID, "getLeft");
		var o = 0;
		if (mb.ua.nav4) {
			o = el.left;
		} else if (mb.ua.ie4up) {
			o = el.style.pixelLeft;
		} else if (mb.ua.gecko) {
			o = stringToNumber(el.style.left);
		}
		mb.log.debug("left: $", o);
		return mb.log.exit(o);
	};

	/**
	 * Returns the offset from the left edge of the screen
	 **/
	this.fbBoxCounter = 0;
	this.setupFeedbackBoxes = function() {
		mb.log.enter(this.GID, "setupFeedbackBoxes");
		var div, cn, id, list = mb.ui.getByTag("div");
		for (var i=0;i<list.length; i++) {
			div = list[i];
			cn = (div.className || "");
			if (cn.match(/^feedbackbox info/i)) {
				this.fbBoxCounter++;

			    var span, spans = mb.ui.getByTag("span", div);
				var spanHeader, spanText;
				for (var j=0;j<spans.length; j++) {
					span = spans[j];
					id = (span.id || "");
					if (id == "header") spanHeader = span;
					if (id == "text") spanText = span;
				}
				if (spanHeader && spanText) {
					id = "feedbackBox"+this.fbBoxCounter;
					var a = document.createElement("a");
					a.id = id+"|toggle";
					a.href = "javascript:; // Toggle box";
					a.className = "readmore";
					a.onfocus = function onfocus(event) { this.blur() };
					a.onclick = function onclick() {
						var obj;
						var id = this.id.split(mb.ui.SPLITSEQ)[0];
						if ((obj = mb.ui.get(id)) != null) {
							var flag = (obj.style.display == "none");
							this.firstChild.nodeValue = (flag ? "Close" : "Read more");
							mb.ui.setDisplay(obj, flag);
						} else {
							mb.log.warning("Did not find: $", this.id);
						}
						return false;
					};
					a.appendChild(document.createTextNode("Read more"));
					var parent = spanHeader.parentNode;
					parent.appendChild(a);
					spanText.id = id;
					spanText.style.display = "none";
				}
			}
		}
		return mb.log.exit();
	};

	/**
	 * Returns the offset from the left edge of the screen
	 **/
	this.setupPopupLinks = function() {
		mb.log.enter(this.GID, "setupPopupLinks");
		var a,id,href,list = mb.ui.getByTag("a");
		for (var i=0;i<list.length; i++) {
			a = list[i];
			title = (a.title || "");
			href = (a.href || "");
			if (title.match(/^POPUP/i) && href != "") {
				
				// add ispopup=1 to url, such that /comp/header_small is used.
				if (href.match(/ispopup/) == null) {
					if (href.match(/\&/) != null) {
						href += "&amp;ispopup=1";
					} else {
						href += "?ispopup=1";
					}
				}
				a.id = title + mb.ui.SPLITSEQ + href + mb.ui.SPLITSEQ + i; // add running number to make this unique.
				a.title = title.split(mb.ui.SPLITSEQ)[1];
				a.onclick = function (event) {
					mb.ui.clickPopupLink(this);
					return false;
				};
				mb.log.debug("id: $, href: $, onclick: $", a.id, a.href, a.onclick);
			}
		}
		return mb.log.exit();
	};

	/**
	 * Returns the offset from the left edge of the screen
	 **/
	this.clickPopupLink = function(el) {
		var id, href;
		if (el) {
			id = (el.id || "");
			if (id.match(/^POPUP/i)) {
				id = id.split(mb.ui.SPLITSEQ);
				var t = id[1];
				var w = id[2];
				var h = id[3];
				var href = id[4];
				var win = window.open(href, t, 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width='+w+',height='+h);
			}
		}
		return false;
	};

	/**
	 * Returns the offset from the left edge of the screen
	 **/
	this.setupKeyboardFocus = function() {
		mb.log.enter(this.GID, "setupKeyboardFocus");
		var el,list = mb.ui.getByTag("input");
		var focusid;
		// lookup hidden field which defines the field to be focussed
		if ((el = mb.ui.get("ONLOAD::focusfield")) != null) {
			// if focusfield hidden field was found,
			// find field and set focussed.
			if ((focusid = el.value) != null) {
				if ((el = mb.ui.get(focusid)) != null && el.focus) {
					el.focus();
				}
			} else {
				mb.log.warning("ONLOAD::focusfield has no value!");
			}
		} else {
			mb.log.debug("ONLOAD::focusfield not found.");
		}
		return mb.log.exit();
	};

	this.getEntityLink = function(type, id, name) {
		type = type == "album" ? "release" : type;
		s = [];
		type = type.toLowerCase();
		s.push('<span class="link'+type+'-icon" title="'+name+'">');
		s.push('<a href="/show/');
		s.push(type);
		s.push('/?');
		s.push(type);
		s.push('id=');
		s.push(id);
		s.push('" class="linkentity-strong">');
		s.push(name);
		s.push('</a>');
		s.push('</span>');
		return s.join("");
	};

	this.getLabelLink = function(id, name, resolution) {
		resolution = (resolution  != null ? resolution : "");
		var s = [];
		s.push(mb.ui.getEntityLink('label', id, name));
		if (!mb.utils.isNullOrEmpty(resolution)) {
			s.push(' (');
			s.push(resolution);
			s.push(')');
		}
		return s.join("");
	};

}

