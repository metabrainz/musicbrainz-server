/*----------------------------------------------------------------------------\
|                              Musicbrainz.org                                |
|                 Copyright (c) 2007 Dane Barney (jugdish)                    |
|                 Copyright (c) 2008 Aurelien Mino (murdos)                   |
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
\----------------------------------------------------------------------------*/

function
JSVoting ()
{

   // ----------------------------------------------------------------------------
   // register class/global id
   // ----------------------------------------------------------------------------
   this.CN = "JSVoting";
   this.GID = "jsvoting";
   mb.log.enter (this.CN, "__constructor");

   // ----------------------------------------------------------------------------
   // member variables
   // ----------------------------------------------------------------------------
   this.addnote_msg = "Add note";
   this.delnote_msg = "Del note";

   // ----------------------------------------------------------------------------
   // member functions
   // ----------------------------------------------------------------------------

   /**
   * Go through all the notes of the current page
   * and add the toggle link and change vote handler.
   */
   this.initialise = function () {
      mb.log.enter (this.CN, "initialise");
	
	var votecells = mb.ui.getByClassName("vote", mb.ui.get("content-td"), "td");
	for (var i = 0; i < votecells.length; i++) {
		var inputs = mb.ui.getByTag("input", votecells[i]);
		for (var j = 0; j < inputs.length; j++) {
			inputs[j].onclick = function onclick(event) {
				return jsvoting.captureVoteChange(this);
			};
		}
		this.setVoteColor(votecells[i]);
	}

      mb.log.exit ();
   };

   /**
   * Toggle display of user new edit note.
   */
   this.toggleNoteText = function (editid) {
	var addNoteLink, otherAddNoteLink;
	var noteBlock, noteText;

	if (editid == null) 
	{
		// Single edit review page ( from comp/showmoddetail)
		addNoteLink = mb.ui.get("addnote-top");
		otherAddNoteLink = mb.ui.get("addnote-bottom");
		noteBlock = mb.ui.get("noteblock");
		noteText = mb.ui.get("notetext");
	} 
	else 
	{
		// Multiple edits review page ( from comp/showmod)
		var baseId = "rowid"+editid+"-";
		addNoteLink = mb.ui.get(baseId+"addnote");
		otherAddNoteLink = null;
		noteBlock = mb.ui.get(baseId+"noteblock");
		noteText = mb.ui.get(baseId+"notetext");
	}
		
	if (noteBlock && noteText)
	{
		if (addNoteLink.innerHTML == this.addnote_msg)
		{
			// show the note block
				mb.ui.setDisplay(noteBlock, true);
				addNoteLink.innerHTML = this.delnote_msg;
				// set cursor focus to note textarea
				noteText.focus();
			}
			else if (addNoteLink.innerHTML == this.delnote_msg)
			{
				// hide the note block
				mb.ui.setDisplay(noteBlock, false);
				addNoteLink.innerHTML = this.addnote_msg;
				// erase contents of note textarea
				noteText.value = "";
			}

			if (otherAddNoteLink != null)
			{
				otherAddNoteLink.innerHTML = addNoteLink.innerHTML;
			}
		}
        
        // Hack for inline edits
        if(window.parent && mb.ui.get("RelatedModsBox", window.parent.document))
        {
            var iframe = mb.ui.getByTag("iframe", mb.ui.get("RelatedModsBox", window.parent.document))[0];
            if (window.parent.resizeFrameAsRequired && iframe)
            {
                window.parent.resizeFrameAsRequired(iframe);
            }
        }
   };

   /**
   * Change listener on radio input buttons.
   */
   this.captureVoteChange = function (el) {
	var results;
	if (el.name && (results = el.name.match(/^rowid([0-9]+)$/))) {
		this.updateVoteColor(el);
	}
   };

   /**
   * Find related cell vote and set its color.
   */
   this.updateVoteColor = function (input) {
	var ancestor = input;
	while (ancestor.className != "vote" && ancestor.parentNode)
		ancestor = ancestor.parentNode;
	if (ancestor.className == "vote")
		this.setVoteColor(ancestor);
   };

   /**
   * Set cell color according to selected vote.
   */
   this.setVoteColor = function (cell) {
	var inputs = mb.ui.getByTag("input", cell);
	var bgColor = "white";
	for (var i = 0; i < inputs.length; i++) {
		if (inputs[i].checked) {
			switch (inputs[i].value) {
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
			inputs[i].parentNode.style["borderColor"] = "white";
	}
	cell.style["backgroundColor"] = bgColor;
   };

   // exit constructor
   mb.log.exit ();
}


// register class...
var jsvoting = new JSVoting ();
mb.registerDOMReadyAction (new MbEventAction (jsvoting.GID, "initialise", "Setting up jsvoting functions"));
