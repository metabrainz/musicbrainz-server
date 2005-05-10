	function linkTypeChanged() {
		var selection = document.linktype.linktype.value;
		var sp = selection.split("|");
		var link_desc = document.getElementById('link_desc');
		if (link_desc) {
			var textNode = link_desc.firstChild;
			if (sp[2] != "") {
				textNode.data = "Description: " + sp[2];
				link_desc.setAttribute("className", "linkdesc");
			} else {
				if (sp[0] != "") {
					textNode.data = "Error: Please select a subtype of the currently selected link type. The selected link type is only used for grouping sub-types.";
					link_desc.setAttribute("className", "linkerror");
				} else {
					textNode.data = "";
					link_desc.setAttribute("className", "linkdesc");
				}
			}
		}
	}
	linkTypeChanged();