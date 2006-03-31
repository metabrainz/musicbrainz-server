function addWikiFormattingToolbar(textarea) {
	if ((typeof(document["selection"]) == "undefined") && 
		(typeof(textarea["setSelectionRange"]) == "undefined")) {
		return;
	}
	
	var toolbar = document.createElement("div");
	toolbar.className = "wikitoolbar";

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
//	not supported	
//	addButton("code", "Code block: {{{ example }}}", function() {
//		encloseSelection("\n{{{\n", "\n}}}\n");
//	});
	addButton("hr", "Horizontal rule: ----", function() {
		encloseSelection("\n----\n", "");
	});
	textarea.parentNode.insertBefore(toolbar, textarea);
}

// Add the toolbar to all <textarea> elements on the page with the class
// 'wikitext'.
var re = /\bwikitext\b/;
var textareas = document.getElementsByTagName("textarea");
for (var i = 0; i < textareas.length; i++) {
	var textarea = textareas[i];
	if (textarea.className && re.test(textarea.className)) {
		addWikiFormattingToolbar(textarea);
	}
}
