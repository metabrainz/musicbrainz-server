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

MusicBrainz.JSVoting = function()
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
   this.delnote_msg = "Delete note";

   this.vote_inputs = {
    "yes": new Array(),
    "no": new Array(),
    "abs": new Array(),
    "novote": new Array()
   };

   // ----------------------------------------------------------------------------
   // member functions
   // ----------------------------------------------------------------------------

   /**
   * Go through all the notes of the current page
   * and add the toggle link and change vote handler.
   */
   this.initialise = function () {
     mb.log.enter (this.CN, "initialise");

	 // Set up "ALL VOTES" controls if flag is here
	 var showAllVotes = ($("JSVoting::ShowAllVotes") && $("JSVoting::ShowAllVotes").value == 1);
	 if (showAllVotes) {
	 
	 	var voteTypes = ["Yes=yes", "No=no", "Abs=abs", "None=novote"];

	 	vote_display = function(vote_type) {
			var voteName, voteValue;
			[voteName, voteValue] = vote_type.split('=');
			return TD(null, 
					LABEL({'for': 'rowidOverride-'+voteValue},
					 INPUT({'type': 'radio', 'name': 'rowidOverride', 'id': 'rowidOverride-'+voteValue, 'value': voteValue}),
					 BR(), voteName
					)
			);
		 }
		
		var	allVotesTR = TR({'class': 'showedit', 'id': 'votechoice-override'},
			TD(),
			TD({'align': 'right'}, STRONG("ALL VOTES:")),
			TD({'class': 'vote'},
				TABLE({'class': 'votechoice votechoice4'},
					TR(null, map(vote_display, ["Yes=yes", "No=no", "Abs=abs", "None=novote"]))
				)
			)
		);
		insertSiblingNodesBefore(getFirstElementByTagAndClassName('tr', null, $("editlist")), allVotesTR);

	 }

	 // Iterate over all votes radio inputs in order to:
	 // 1. connect to each one a handler for "onclick" signal
	 // 2. store all inputs in vote_inputs to access them easily later
	 // 3. set initial color according to current vote
     var votecells = getElementsByTagAndClassName("td", "vote", $("content-td"));
	 for (var i = 0; i < votecells.length; i++) {
		var inputs = votecells[i].getElementsByTagName("input");
		for (var j = 0; j < inputs.length; j++) {
            if (inputs[j].type != "radio") continue;

            var results;
            if (results = inputs[j].id.match(/^rowid([0-9]+)-(.*)$/)) {
				connect(inputs[j], "onclick", this, this.captureVoteChange);
				
				// Store in vote_inputs
                if (results[2] in this.vote_inputs) {
                    this.vote_inputs[results[2]].push(inputs[j]);
                }
            } else if (inputs[j].id.match(/^rowidOverride-(.*)$/)) {
                inputs[j].checked = false;
				connect(inputs[j], "onclick", this, this.captureAllVotesChange);
            }
		}
		// Set initial color
		this.setVoteColor(votecells[i]);
	}

      setDisplayForElement("", $("votechoice-override"));
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
		// Single edit review page (from comp/showmoddetail)
		addNoteLink = $("addnote-top");
		otherAddNoteLink = $("addnote-bottom");
		noteBlock = $("noteblock");
		noteText = $("notetext");
	} 
	else 
	{
		// Multiple edits review page (from comp/showmod)
		var baseId = "rowid"+editid+"-";
		addNoteLink = $(baseId+"addnote");
		otherAddNoteLink = null;
		noteBlock = $(baseId+"noteblock");
		noteText = $(baseId+"notetext");
	}
		
	if (noteBlock && noteText)
	{
		if (addNoteLink.innerHTML == this.addnote_msg)
		{
				// show the note block
				setDisplayForElement("", noteBlock);
				addNoteLink.innerHTML = this.delnote_msg;
				// set cursor focus to note textarea
				noteText.focus();
			}
			else if (addNoteLink.innerHTML == this.delnote_msg)
			{
				// hide the note block
				hideElement(noteBlock);
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
        if(window.parent && window.parent.document.getElementById("RelatedModsBox"))
        {
            var iframe = window.parent.document.getElementById("RelatedModsBox").getElementsByTagName("iframe")[0];
            if (window.parent.resizeFrameAsRequired && iframe)
            {
                window.parent.resizeFrameAsRequired(iframe);
            }
        }
   };

   /**
   * Change listener on radio input buttons.
   */
   this.captureVoteChange = function (ev) {
    var el = ev.target();
	var results;
	if (el.name && (results = el.name.match(/^rowid([0-9]+)$/))) {
		this.updateVoteColor(el);
	}
   };

   /**
   * Change listener on change all votes radio input buttons.
   */
   this.captureAllVotesChange = function (ev) {
    var el = ev.target();
	var results;
	if (results = el.id.match(/^rowidOverride-(.*)$/)) {
        var type = results[1];
        for ( var i = 0; i < this.vote_inputs[type].length; i++ ) {
            var input =  this.vote_inputs[type][i];
            input.checked = true;
            this.updateVoteColor(input);
        }
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
var jsvoting = new MusicBrainz.JSVoting ();
mb.registerDOMReadyAction (new MbEventAction (jsvoting.GID, "initialise", "Setting up jsvoting functions"));
