/*----------------------------------------------------------------------------\
|                              Musicbrainz.org                                |
|                     Copyright (c) 2005 Stefan Kestenholz                    |
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
|-----------------------------------------------------------------------------|
| This script was adapted from trac (http://www.edgewall.com/trac/)           |
\----------------------------------------------------------------------------*/

function addWikiFormattingToolbar(textarea) {
	if ((typeof(document["selection"]) == "undefined") && 
		(typeof(textarea["setSelectionRange"]) == "undefined")) {
		return;
	}
	
	var toolbar = document.createElement("div");
	toolbar.className = "wikitoolbar";

	/**
	 * Adds a button to the toolbar
	 */
	function addButton(id, title, fn) {
		var a = document.createElement("a");
		a.href = "#";
		a.id = id;
		a.title = title;
		a.onclick = function() { try { fn() } catch (e) { } return false };
		// a.tabIndex = 400;
		toolbar.appendChild(a);
		var i = new Image();
		i.src = "/images/wikitoolbar/bg.png";
		a.style.backgroundImage.src = i.src;
	}

	/**
	 * Performs an action with the text of the textarea
	 */
	function encloseSelection(prefix, suffix) {
		textarea.focus();
		var start, end, sel, scrollPos, subst;
		if (typeof(document["selection"]) != "undefined") {
			sel = document.selection.createRange().text;
		} else if (typeof(textarea["setSelectionRange"]) != "undefined") {
			start = textarea.selectionStart;
			end = textarea.selectionEnd;
			scrollPos = textarea.scrollTop;
			sel = textarea.value.substring(start, end);
		}
		if (sel.match(/ $/)) { 
			// exclude ending space char, if any
			sel = sel.substring(0, sel.length - 1);
			suffix = suffix + " ";
		}
		subst = prefix + sel + suffix;
		if (typeof(document["selection"]) != "undefined") {
			var range = document.selection.createRange().text = subst;
			textarea.caretPos -= suffix.length;
		} else if (typeof(textarea["setSelectionRange"]) != "undefined") {
			textarea.value = textarea.value.substring(0, start) + subst +
											 textarea.value.substring(end);
			if (sel) {
				textarea.setSelectionRange(start + subst.length, start + subst.length);
			} else {
				textarea.setSelectionRange(start + prefix.length, start + prefix.length);
			}
			textarea.scrollTop = scrollPos;
		}
	}

	// register the actions on the toolbar
	addButton("strong", "Bold text: '''Example'''", function() {
		encloseSelection("'''", "'''");
	});
	addButton("em", "Italic text: ''Example''", function() {
		encloseSelection("''", "''");
	});
	addButton("heading", "Heading: == Example ==", function() {
		encloseSelection("\n== ", " ==\n", "Heading");
	});
	addButton("link", "Link: [http://www.example.com/ Example]", function() {
		encloseSelection("[", "]");
	});
	addButton("hr", "Horizontal rule: ----", function() {
		encloseSelection("\n----\n", "");
	});
	textarea.parentNode.insertBefore(toolbar, textarea);
}


/** 
 * Wrapper class for the setup function
 * which helps setting up the wiki toolbar
 * in the normal musicbrainz onDOMReady
 * chain of handlers. 
 */
function WikiToolBar() {

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "WikiToolBar";
	this.GID = "wikitoolbar";
	mb.log.enter(this.CN, "__constructor");

	/**
	 * Add the toolbar to all <textarea> elements on the page 
	 * with the class "wikitext"
	 */
	this.setup = function() {
		var re = /\bwikitext\b/;
		var textareas = document.getElementsByTagName("textarea");
		for (var i = 0; i < textareas.length; i++) {
			var textarea = textareas[i];
			if (textarea.className && re.test(textarea.className)) {
				addWikiFormattingToolbar(textarea);
			}
		}	
	};

	// exit constructor
	mb.log.exit();
}

// instantiate, and setup the form.
var wikitoolbar = new WikiToolBar();
mb.registerDOMReadyAction(
	new MbEventAction(wikitoolbar.GID, 'setup', "Setup Wiki TOolbar")
);
