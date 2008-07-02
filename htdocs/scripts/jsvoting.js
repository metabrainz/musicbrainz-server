
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
