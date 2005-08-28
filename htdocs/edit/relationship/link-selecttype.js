	function hideAll() {
		if (attributeDivs == null || attributeDivs.length == 'undefined') return;
		for  (var i=0; i<attributeDivs.length; i++) {
			var lr = attributeDivs[i];
			if (lr != null) {
				showDiv(lr, 0);
				showDiv(lr + "-desc", 0);
			}
		}
	}

	function showDiv(id,show) {
		var obj = document.getElementById(id);
		if (obj) obj.style.display = (show == 1 ? "block" : "none");
	}

	function handleKeyDown() {
	}

	function linkTypeChanged() {
		var selection = document.linkselect.linktypeid.value;
		var sp = selection.split("|");
		var attrs = sp[1];
		var p;
		hideAll();
		if (attrs == "") {
			showDiv('attributes', 0);
		} else {
			showDiv('attributes', 1);
			var pairs = attrs.split(" ");
			for(p in pairs) {
				var kv = pairs[p].split('=');
				if (kv[0] != "") {
					showDiv(kv[0], 1);
					showDiv(kv[0] + "-desc", 1);
				}
			}
		}
		var link_desc = document.getElementById('link_desc');
		if (link_desc) {
			var textNode = link_desc.firstChild;
			if (sp[2] != "") {
				textNode.data = "" + sp[2];
				link_desc.setAttribute("className", "linkdesc");
			} else {
				if (wasFormSubmitted) {
					textNode.data = "Error: Please select a subtype of the currently selected link type. The selected link type is only used for grouping sub-types.";
					link_desc.setAttribute("className", "linkerrorslim");
				}
			}
		}
	}

	function findAttrIndex(attr) {
		var elements, index;
		for(index = 1;; index++) {
			elements = document.getElementsByName('attr_' + attr + "_" + index);
			if (elements.length > 0) continue;
			else return index;
		}
	}

	function addAttribute(attr) {
		var elements = document.getElementsByName('attr_' + attr + "_0");
		if (elements) {
			var attrElement = elements[0];
			if (attrElement) {
				var index = findAttrIndex(attr);
				var newNode = attrElement.cloneNode(true);
				newNode.setAttribute("name", "attr_" + attr + "_" + index);
				var parent = document.getElementById(attr);
				if (parent) {
					parent.appendChild(document.createElement("BR"));
					parent.appendChild(newNode);      
				} 
			} 
		}
	}
	linkTypeChanged();

	function myOnFocus() { /* do nothing */ }
	function myOnBlur() {/* do nothing */ }


