

function toggleNoteText(addnoteLink)
{
	var noteBlock = document.getElementById(addnoteLink.id.replace(/-addnote$/,"-noteblock"));
	var noteBox = document.getElementById(addnoteLink.id.replace(/-addnote$/,"-notetext"));
	if (noteBlock && noteBox)
	{
		if (addnoteLink.innerHTML == "Add note")
		{
			// show the note block
			noteBlock.style["display"] = "table-row";
			addnoteLink.innerHTML = "Del note";
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
