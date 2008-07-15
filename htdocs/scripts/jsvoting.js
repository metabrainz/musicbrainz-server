
function toggleNoteText(editid)
{
	var addNoteLink, otherAddNoteLink;
	var noteBlock, noteText;

	if (editid == null) 
	{
		// Single edit review page ( from comp/showmoddetail)
		addNoteLink = document.getElementById("addnote-top");
		otherAddNoteLink = document.getElementById("addnote-bottom");
		noteBlock = document.getElementById("noteblock");
		noteText = document.getElementById("notetext");
	} 
	else 
	{
		// Multiple edits review page ( from comp/showmod)
		var baseId = "rowid"+editid+"-";
		addNoteLink = document.getElementById(baseId+"addnote");
		otherAddNoteLink = null;
		noteBlock = document.getElementById(baseId+"noteblock");
		noteText = document.getElementById(baseId+"notetext");
	}
		
	if (noteBlock && noteText)
	{
		if (addNoteLink.innerHTML == "Add note")
		{
			// show the note block
			noteBlock.style["display"] = "table-row";
			addNoteLink.innerHTML = "Del note";
			// set cursor focus to note textarea
			noteText.focus();
		}
		else if (addNoteLink.innerHTML == "Del note")
		{
			// hide the note block
			noteBlock.style["display"] = "none";
			addNoteLink.innerHTML = "Add note";
			// erase contents of note textarea
			noteText.value = "";
		}

		if (otherAddNoteLink != null)
		{
			otherAddNoteLink.innerHTML = addNoteLink.innerHTML;
		}
	}
}


function captureVoteChange(input) {
	var results;
	if (input.name && (results = input.name.match(/^rowid([0-9]+)$/))) {
		var n = input.id.match(/approve/) ? document.getElementById(input.id.replace(/approve/,"cancel")) : (input.id.match(/cancel/) ? document.getElementById(input.id.replace(/cancel/,"approve")) : null);
		if (n) n.checked = false;
		updateVoteColor(input);
	}
}

function updateVoteColor(input) {
	var ancestor = input;
	while (ancestor.className != "vote" && ancestor.parentNode)
		ancestor = ancestor.parentNode;
	if (ancestor.className == "vote")
		setVoteColor(ancestor);
}

function setVoteColor(cell) {
	var inputs = cell.getElementsByTagName("input");
	var bgColor = "white";
	for (var i = 0; i < inputs.length; i++) {
		if (inputs[i].checked) {
			switch (inputs[i].value) {
				case "approve":
					bgColor = "#00a650";
					inputs[i].parentNode.style["borderColor"] = "white";
					break;
				case "yes":
					bgColor = "#eeffee";
					inputs[i].parentNode.style["borderColor"] = "#88ff88";
					break;
				case "no":
					bgColor = "#ffeeee";
					inputs[i].parentNode.style["borderColor"] = "#ff8888";
					break;
				case "abs":
					bgColor = "#ffffcc";
					inputs[i].parentNode.style["borderColor"] = "#eeee66";
					break;
				case "cancel":
					bgColor = "#ff0000";
					inputs[i].parentNode.style["borderColor"] = "white";
					break;
			}
		} else
			inputs[i].parentNode.style["borderColor"] = "transparent";
	}
	cell.style["backgroundColor"] = bgColor;
}
