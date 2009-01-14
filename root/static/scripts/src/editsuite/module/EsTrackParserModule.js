/*----------------------------------------------------------------------------\
|                              Musicbrainz.org                                |
|                 Copyright (c) 2005 Stefan Kestenholz (keschte)              |
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
| $Id$
\----------------------------------------------------------------------------*/

/**
 * Track Parser module
 *
 **/
function EsTrackParser() {
	mb.log.enter("EsTrackParser", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "EsTrackParser";
	this.GID = "es.tp";

	// ----------------------------------------------------------------------------
	// register module
	// ---------------------------------------------------------------------------
	this.getModID = function() { return "es.tp"; };
	this.getModName = function() { return "Track parser"; };

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------
	this.CFG_ISVA = this.getModID()+".isVA";
	this.CFG_PARSETIMESONLY = this.getModID()+".timesonly";
	this.CFG_RELEASETITLE = this.getModID()+".releasetitle";
	this.CFG_TRACKNUMBER = this.getModID()+".tracknumber";
	this.CFG_VINYLNUMBERS = this.getModID()+".vinylnumbers";
	this.CFG_TRACKTIMES = this.getModID()+".tracktimes";
	this.CFG_FILLTRACKTIMES = this.getModID()+".filltracktimes";
	this.CFG_STRIPBRACKETS = this.getModID()+".stripbrackets";
	this.CFG_COLLAPSETEXTAREA = this.getModID()+".collapsetextarea";


	this.CONFIG_LIST = [
		new EsModuleConfig(this.CFG_RELEASETITLE,
						 false,
			 			 "Set release title from first line",
		 				 "The First line is handled as the release title, which is filled "+
		 				 "into the release title field. The tracks are expected to start from line 2."),
		new EsModuleConfig(this.CFG_TRACKNUMBER,
						 true,
						 "Tracknames start with a number",
						 "This setting attempts to find lines between lines which have a track "+
						 "number and parses ExtraTitleInformation, which is added to the previous track."),
		new EsModuleConfig(this.CFG_VINYLNUMBERS,
						 false,
						 "Enable vinyl track numbers",
						 "Characters which are used for numbering of the tracks may include "+
						 "alphanummeric characters (0-9, a-z) (A1, A2, ... C, D...)."),
		new EsModuleConfig(this.CFG_TRACKTIMES,
						 true,
						 "Detect track times",
						 "The line is inspected for an occurence of numbers separated by a colon. "+
						 "If such a value is found, the track time is read and stripped from the track "+
						 "title. Round parentheses surrounding the time are removed as well."),
		new EsModuleConfig(this.CFG_FILLTRACKTIMES,
						 true,
						 "Fill in track times",
						 "Fill in the track times from the detected values above. If this box is "+
						 "not activated, the track time fields will not be modified."),
		new EsModuleConfig(this.CFG_STRIPBRACKETS,
						 true,
						 "Remove text in brackets [...]",
						 "If this checkbox is activated, text in square brackets "+
						 "(usually links to other pages) is stripped from the titles."),
		new EsModuleConfig(this.CFG_COLLAPSETEXTAREA,
						 false,
						 "Resize textarea automatically",
						 "If this checkbox is activated, the textarea is enlarged "+
						 "if it has the keyboard focus, and collapsed again when the focus is lost.")

	];

	this.TRACKSAREA = this.getModID()+".tracksarea"; // name,id of trackParser textarea

	// buttons
	this.BTN_SWAP = "BTN_TP_SWAP";
	this.BTN_PARSE = "BTN_TP_PARSE";
	this.BTN_PARSETIMES = "BTN_TP_PARSETIMES";

	// td for the warnings
	this.WARNINGTR = "TP_WARNINGTR";
	this.WARNINGTD = "TP_WARNINGTD";

	this.RE_TrackNumber = /^[\s\(]*[0-9\.]+(-[0-9]+)?[\.\)\s]+/g;
	this.RE_TrackNumberVinyl = /^[\s\(]*[0-9a-z]+[\.\)\s]+/gi;
	this.RE_TrackTimes = /\(?[0-9]+[:,.][0-9]+\)?/gi;
	this.RE_RemoveParens = /\(|\)/g;
	this.RE_StripSquareBrackets = /\[.*\]/gi;
	this.RE_StripTrailingListen = /\s\s*(listen(music)?|\s)+$/gi;
	this.RE_StripListenNow = /listen now!/gi;
	this.RE_StripAmgPick = /amg pick/gi;
	this.RE_VariousSeparator = /[\s\t]+[-\/]*[\s\t]+/gi;

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
 	 * Override this method for initial configuration (register buttons etc.)
	 **/
	this.setupModuleDelegate =  function() {
		es.ui.registerButtons(
			new EsButton(this.BTN_PARSE, "Parse all", "Fill in the artist and track titles with values parsed from the textarea", this.getModID()+".onParseClicked()"),
			new EsButton(this.BTN_PARSETIMES, "Parse times", "Fill in the track times only with values parsed from the textarea", this.getModID()+".onParseClicked(true)"),
			new EsButton(this.BTN_SWAP, "Swap titles", "If the artist and track titles are mixed up, click here to swap the fields", this.getModID()+".onSwapArtistTrackClicked()"));
	};

	/**
	 * Prepare code for this module.
	 *
	 * @returns raw html code
	 **/
	this.getModuleHtml = function() {
		var s = [];
		s.push(this.getModuleStartHtml({x: true}));
		s.push('<table cellspacing="0" cellpadding="0" class="moduletable">');
		s.push('<tr>');
		s.push('<td colspan="2">');
		s.push('<textarea name="'+this.TRACKSAREA+'" rows="8" cols="90" id="'+this.TRACKSAREA+'" ');
		s.push('  wrap="off" style="width: 97%; font-family: Arial,Helvetica, Verdana; font-size: 11px; overflow: auto" ');
		s.push('></textarea>');
		s.push('</td></tr>');
		s.push('<tr valign="top" id="'+this.WARNINGTR+'" style="display: none">');
		s.push('<td colspan="2" style="padding: 2px; color: red; font-size: 11px" id="'+this.WARNINGTD+'"><small>');
		s.push('</small></td></tr>');
		s.push('<tr valign="top">');
		s.push('<td><div style="margin-bottom: 2px">');
		s.push(es.ui.getButtonHtml(this.BTN_PARSE));
		s.push('</div><div style="margin-bottom: 2px"/>');
		s.push(es.ui.getButtonHtml(this.BTN_PARSETIMES));
		s.push('</div><div style="margin-bottom: 2px"/>');
		s.push(es.ui.getButtonHtml(this.BTN_SWAP));
		s.push('</div></td><td><small>');
		s.push(this.getConfigHtml());
		s.push('</small></td>');
		s.push('</tr></table>');
		s.push(this.getModuleEndHtml({x: true}));
		s.push(this.getModuleStartHtml({x: false, dt: 'Collapsed'}));
		s.push(this.getModuleEndHtml({x: false}));
		return s.join("");
	};


	/**
	 * Setup the textarea resizing, if the user chooses to have it.
	 **/
	this.onModuleHtmlWrittenDelegate = function() {
		if (this.isConfigTrue(this.CFG_COLLAPSETEXTAREA)) {
			var	el = mb.ui.get(es.tp.TRACKSAREA);
			el.onfocus = function onfocus(el) {
				es.tp.handleFocus();
			};
			el.onblur = function onblur(el) {
				es.tp.handleBlur();
			};
			el.rows = 2;
		}
	};


	/**
	 * Prepare code for this module.
	 *
	 * @returns raw html code
	 **/
	this.handleFocus = function(state) {
		clearTimeout(this.resizeTimeout);
		var	el = mb.ui.get(es.tp.TRACKSAREA);
		if (state) {
			el.rows = 20;
		} else {
			this.resizeTimeout = setTimeout("es.tp.handleFocus(1)", 100);
		}
	};

	/**
	 * Prepare code for this module.
	 *
	 * @returns raw html code
	 **/
	this.handleBlur = function(state) {
		var	el = mb.ui.get(es.tp.TRACKSAREA);
		clearTimeout(this.resizeTimeout);
		if (state) {
			el.rows = 2;
		} else {
			this.resizeTimeout = setTimeout("es.tp.handleBlur(1)", 100);
		}
	};

	/**
	 * Parse button clicked, process text in textarea
	 **/
	this.onParseClicked = function(timesOnly) {
		//mb.log.scopeStart("Handling click on Parse button");
		mb.log.enter(this.GID, "onParseClicked");
		timesOnly = (timesOnly || false);
		this.setConfigValue(this.CFG_PARSETIMESONLY, timesOnly);
		this.parseNow();
		es.ui.setDisabled(this.BTN_SWAP, false);
		mb.log.exit();
		//mb.log.scopeEnd();
	};

	/**
	 * Swap all the artist/track fields
	 **/
	this.onSwapArtistTrackClicked = function() {
		mb.log.scopeStart("Handling click on Swap button");
		mb.log.enter(this.GID, "onSwapArtistTrackClicked");
		if (this.isConfigTrue(this.CFG_ISVA)) {
			var aArr = es.ui.getArtistFields();
			var tArr = es.ui.getTrackNameFields();
			if (aArr && tArr && aArr.length == tArr.length) {
				for (var i=0; i<aArr.length; i++) {
					var temp = aArr[i].value;
					aArr[i].value = tArr[i].value;
					tArr[i].value = temp;
				}
			}
		}
		mb.log.exit();
		mb.log.scopeEnd();
	};

	/**
	 * Check the DOM for the artistname0 field, if found
	 * set VA mode.
	 **/
	this.checkVAMode = function() {
		mb.log.enter(this.GID, "checkVAMode");
		if (this.isUIAvailable()) {
			this.setVA(es.ui.getField("tr0_artistname", true) != null);
			if (!this.isConfigTrue(this.CFG_ISVA)) {
				es.ui.setDisabled(this.BTN_SWAP, false); // disable the swap button
			} else {
				es.ui.setDisabled(this.BTN_SWAP, true); // disable the swap button
			}
		}
		mb.log.exit();
	};
	mb.registerDOMReadyAction(new MbEventAction(this.GID, "checkVAMode", "Setting various artists mode"));

	/**
	 * set VA mode (true|false)
	 **/
	this.setVA = function(flag) {
		mb.log.enter(this.GID, "setVA");
		mb.log.trace("New VA mode: $", flag);
		this.setConfigValue(this.CFG_ISVA, flag);
		mb.log.exit();
	};

	/**
	 * Show the warning s
	 **/
	this.showWarning = function(s) {
		var obj;
		if (s) {
			if ((obj = mb.ui.get(this.WARNINGTR)) != null) {
				obj.style.display = "";
			}
			if ((obj = mb.ui.get(this.WARNINGTD)) != null) {
				obj.innerHTML += "<b>&middot;</b> " + s + "<br/>";
			}
		} else {
			if ((obj = mb.ui.get(this.WARNINGTR)) != null) {
				obj.style.display = "none";
			}
			if ((obj = mb.ui.get(this.WARNINGTD)) != null) {
				obj.innerHTML = "";
			}
		}
	};

	/**
	 * Parse the track titles out of the textarea
	 **/
	this.parseNow = function(forceVA) {
		mb.log.enter(this.GID, "parseNow");
		if (forceVA) {
			this.setVA(forceVA);
		} else {
			this.checkVAMode();
		}
		var obj = null;
		var tracks = new Array();
		this.showWarning(); // clear warning
		if ((obj = mb.ui.get(this.TRACKSAREA)) != null) {
			var text = obj.value;
			var lines = text.split("\n");
			var number, title, artistName;
			var si = 0;
			var releaseTitle = "";
			if (this.isConfigTrue(this.CFG_RELEASETITLE)) {
				releaseTitle = lines[0];
				mb.log.info("Release Title: $", releaseTitle);
				si++;
			}
			var s, counter = 1;
			var swapArtistTrackWarning = true;
			for (var i=si; i<lines.length; i++) {
				title = lines[i];

				// AMG specific tweaks
				title = title.replace(this.RE_StripListenNow, ""); // Listen now!
				title = title.replace(this.RE_StripAmgPick, ""); // AMG pick

				// get rid of whitespace
				title = mb.utils.trim(title);
				mb.log.trace("Parsing line: $", title);

				if (title != "") {
					// get track number from string, and replace
					var foundNumber = false;
					var isVinyl = false;
					var re = this.RE_TrackNumber;
					if (this.isConfigTrue(this.CFG_VINYLNUMBERS)) {
						re = this.RE_TrackNumberVinyl;
						isVinyl = true;
					}
					number = title.match(re);
					if (number != null) {
						mb.log.debug("Checking number, found: $ (vinyl: $)", number[0], isVinyl);
						foundNumber = true;
						if (this.isConfigTrue(this.CFG_TRACKNUMBER)) {
							// only replace leading number if user configured
							// to do so. we need the startWithNumber flag
							// to check for extratitleinformation though
							title = title.replace(re, "");
						}
					}
					number = counter; // use internal counter value.

					// get track time from string, and replace
					var time = "";
					if (this.isConfigTrue(this.CFG_TRACKTIMES)) {
						time = title.match(this.RE_TrackTimes);
						if (time != null) {
							time = mb.utils.trim(time[0]);
							mb.log.debug("Checking time, found: $", time);
							time = time.replace(this.RE_RemoveParens, "");
						}
						title = title.replace(this.RE_TrackTimes, "");
					}

					// lets see if we have to strip square brackets
					if (this.isConfigTrue(this.CFG_STRIPBRACKETS)) {
						s = title.replace(this.RE_StripSquareBrackets, ""); // remove [*]
						if (s != title) {
							mb.log.debug("Stripped brackets");
							title = s;
						}
					}

					// amazon specific tweaks
					s = title.replace(this.RE_StripTrailingListen, ""); // remove trailing "Listen"
					if (s != title) {
						mb.log.debug("Stripped trailing 'Listen'");
						title = s;
					}

					// if VA, get artist from string, and remove from title
					artistName = "";
					if (this.isConfigTrue(this.CFG_ISVA)) {
						if (!this.isConfigTrue(this.CFG_TRACKNUMBER) || foundNumber) {
							mb.log.debug("Looking for Artist/Track split");
							// we want to look for extratitleinformation, if
							// * is configured that tracks start with numbers
							// * and current line does not start with a number.

							// alert(title+" --- "+title.match(vaRE));
							if (title.match(this.RE_VariousSeparator)) {
								var parts = title.split(this.RE_VariousSeparator);
								artistName = mb.utils.trim(parts[0]);
								mb.log.debug("Found artist: $", artistName);

								if (swapArtistTrackWarning && artistName.match(/\(|\)|remix/gi)) {
									this.showWarning("Track "+counter+": Possibly Artist/Tracknames swapped: Parentheses in Artist name!");
									swapArtistTrackWarning = false;
								}
								parts[0] = ""; // set artist element empty, such that first iteration is run in the loop.
								while (!parts[0].match(/\S/g)) {
									parts.splice(0,1); // remove all empty elements
								}
								if (parts.length > 1) {
									this.showWarning("Track "+counter+": Possibly wrong split of Artist and Trackname:<br/>&nbsp; ["+parts.join(",")+"]");
								}
								title = parts.join(" ");
							}
						}
					}

					// get rid of whitespace
					title = mb.utils.trim(title);

					// if we expect tracknumbers, and current line starts with a number,
					// or if we handle all lines as a new title, add to tracks
					if (!this.isConfigTrue(this.CFG_TRACKNUMBER) || foundNumber) {
						// add to tracks list.
						tracks[tracks.length] = {
							artist : artistName,
							title  : title,
							time   : time,
							feat   : []
						};
						counter++;
						mb.log.debug("Added track: $", counter);

					} else if (tracks.length>0) {
						mb.log.debug("Analyzing string for ExtraTitleInformation: $", title);

						// else try to analyze current information to
						// add to track per SG5 (discogs parsing)
						var  x = title.split(" - ");
						if (x[0].match(/remix|producer|mixed/i) == null) {
							if (x.length > 1) {
								x.splice(0,1);
								title = x.join("");
								title = title.replace(/\s*,/g, ","); // remove spaces before ","
								title = title.replace(/^\s*/g, ""); // remove leading
								title = title.replace(/[ \s\r\n]*$/g, ""); // remove trailing
								title = title.replace(/(.*), The$/i, "The $1"); // re-order "Name, The"->"The Name"

								if (title != "") {
									tracks[tracks.length-1].feat.push(title);
								}
							}
						}
					}
				}
			}
			mb.log.scopeStart("Parsed the following fields");
			for (i=0; i<tracks.length; i++) {
				var track = tracks[i];
				if (track.feat.length > 0) {
					track.title += " (feat. "+track.feat.join(", ")+")";
				}
				mb.log.info("no: $, title: $, time: $ (artist: $)",
							 mb.utils.leadZero(i+1), track.title, track.time,
							 track.artist);
			}
			this.fillFields(releaseTitle, tracks);
		}
		mb.log.exit();
	};

	/**
	 * Update the value of a field, and add the change to the Undo stack.
	 **/
	this.fillField = function(field, newvalue) {
		mb.log.enter(this.GID, "fillField");
		if (field != null && newvalue != null) {
			es.ur.addUndo(es.ur.createItem(field, 'trackparser', field.value, newvalue));
			field.value = newvalue;
		}
		mb.log.exit();
	};

	/**
	 * Lookup the fields, and fill them accordingly
	 **/
	this.fillFields = function(releasetitle, tracks) {
		var i,j,field,fields,newvalue;
		mb.log.enter(this.GID, "fillFields");

		if (!this.isConfigTrue(this.CFG_PARSETIMESONLY)) {
			// find, and fill releasename field
			if (this.isConfigTrue(this.CFG_RELEASETITLE)) {
				field = es.ui.getReleaseNameField();
				this.fillField(field, releasetitle);
			}

			// find, and fill all artistname fields
			i=0;
			fields = es.ui.getArtistFields();
			for (j=0; j<fields.length; j++) {
				field = fields[j];
				if (tracks[i] && tracks[i].artist) {
					this.fillField(field, tracks[i].artist);
					i++;
				}
			}

			// find, and fill all track name fields
			i=0;
			fields = es.ui.getTrackNameFields();
			for (j=0; j<fields.length; j++) {
				field = fields[j];
				if (tracks[i] && tracks[i].title) {
					this.fillField(field, tracks[i].title);
					i++;
				}
			}
		}

		// find, and fill all track time fields
		if (this.isConfigTrue(this.CFG_PARSETIMESONLY)
				? true
				: this.isConfigTrue(this.CFG_FILLTRACKTIMES)) {
			i=0;
			fields = es.ui.getTrackTimeFields();
			for (j=0; j<fields.length; j++) {
				field = fields[j];
				if (tracks[i] && tracks[i].time) {
					this.fillField(field, tracks[i].time);
					i++;
				}
			}
		}
		mb.log.exit();
	};

	// exit constructor
	mb.log.exit();
}

// register prototype of module superclass
try {
	EsTrackParser.prototype = new EsModuleBase;
} catch (e) {
	mb.log.error("EsTrackParser: Could not register EsModuleBase prototype");
}