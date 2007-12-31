
function showNote

function toggleNoteText(editid)
{
	var noteBlock = document.getElementById(addNoteLink.id.replace(/-addnote.*/,"-noteblock"));
	var noteText = document.getElementById(addNoteLink.id.replace(/-addnote.*/,"-notetext"));
	
	if (noteBlock && noteText)
	{
		var otherAddNoteLink = null;
		if (addNoteLink.id.matches(/-top$/))
			otherAddNoteLink = document.getElementById(addNoteLink.id.replace(/-
	
		if (addnoteLink.innerHTML == "Add note")
		{
			// show the note block
			noteBlock.style["display"] = "table-row";
			addNoteLink.innerHTML = "Del note";
			if (addNoteLink.id.matches(/-addnote-top/))
				var document.getElementById(addNoteLink
			// set cursor focus to note textarea
			noteBox.focus();
		}
		else if (addnoteLink.innerHTML == "Del note")
		{
			// hide the note block
			noteBlock.style["display"] = "none";
			addnoteLink.innerHTML = "Add note";
			// erase contents of note textarea
			noteBox.value = "";
		}
	}
}
