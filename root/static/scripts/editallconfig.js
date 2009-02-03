/*----------------------------------------------------------------------------\
|                              Musicbrainz.org                                |
|                 Copyright (c) 2005 Stefan Kestenholz (g0llum)               |
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
\----------------------------------------------------------------------------*/

/**
 * Release Editor decoration
 **/
function ReleaseEditor() {

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "ReleaseEditor";
	this.GID = "ae";

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------

	this._tracks = null;

	this.editartist_off = new Image();
	this.editartist_off.src = "/images/release_editor/edit-off.gif";
	this.editartist_on = new Image();
	this.editartist_on.src = "/images/release_editor/edit-on.gif";

	this.editartist_title_on = "Track artist selected for change, click to retain old value";
	this.editartist_title_off = "Select artist for change";

	this.removetrack_off = new Image();
	this.removetrack_off.src = "/images/release_editor/remove-off.gif";
	this.removetrack_on = new Image();
	this.removetrack_on.src = "/images/release_editor/remove-on.gif";
	this.removetrack_disabled = new Image();
	this.removetrack_disabled.src = "/images/release_editor/remove-disabled.gif";

	this.removetrack_title_on = "Track selected for removal, click to keep the track.";
	this.removetrack_title_off = "Select track for removal";
	this.removetrack_title_disabled = "Track removal disallowed due to attached Disc ID(s).";

	this.removereleaseevent_off = new Image();
	this.removereleaseevent_off.src = "/images/release_editor/remove-off.gif";
	this.removereleaseevent_on = new Image();
	this.removereleaseevent_on.src = "/images/release_editor/remove-on.gif";

	this.removereleaseevent_title_on = "Release event selected for removal, click to keep the event.";
	this.removereleaseevent_title_off = "Select release event for removal";


	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 *
	 **/
	this.getFieldValue = function(field) {
		var f;
		if ((f = es.ui.getField(field)) != null && f.value != null) {
			return f.value;
		}
		return null;
	};

	/**
	 *
	 **/
	this.setFieldValue = function(field, value) {
		var f;
		if ((f = es.ui.getField(field)) != null) {
			f.value = value;
			return true;
		}
		return false;
	};

	/**
	 * Wraps all the items of the array into singlequotes.
	 */
	this.toParamStrings = function(list) {
		mb.log.enter(this.GID, "toParamStrings");
		if (mb.utils.isArray(list)) {
			return "'" + list.join("', '") + "'";
		}
		mb.log.exit();
		return list;
	};

	/**
	 * Construct a field it from the type, index and subindex
	 * blah::blah::blah::blah
	 */
	this.getFieldId = function(type, id, index, subindex) {
		mb.log.enter(this.GID, "getFieldId");
		id = (id != null ? id : "");
		type = (type != null ? type : "");
		index = (index != null ? index : "");
		subindex = (subindex != null ? subindex : "");
		var retval = [type, id, index, subindex].join("::");
		mb.log.exit();
		return retval;
	};

	/**
	 * Initialises the javascript parts of the Release Editor.
	 **/
	this.initialise = function() {
		mb.log.enter(this.GID, "initialise");

		// register javascript validation hook on the submit button
		if ((obj = mb.ui.get("btnContinue")) != null) {
			obj.onclick = function onclick(event) {
				return ae.validateFields(this);
			};
		}

		// override default html configuration with a more dynamic javascript
		// version.
		if ((obj = mb.ui.get("releaseeditor::config")) != null) {
			var s = [];
			s.push('<table cellspacing="2" cellpadding="0" border="0">');

			var artistid, hasmultipletrackartists;
			var editrelationships = this.getFieldValue("v::editrelationships");

			// only do something if artistid and hasmultipleartists field
			// were found.
			if ((artistid = this.getFieldValue("artistid")) != null) {
				if ((hasmultipletrackartists = this.getFieldValue("hasmultipletrackartists")) != null) {

					// draw the checkbox which can be used to toggle track artists
					s.push('<tr><td>');
					s.push('<input name="v::edittrackartists" value="1" type="checkbox" class="checkbox"');
					if (artistid == 1) {
						s.push(' disabled="disabled" ');
						s.push('title="Various Artist releases need to have multiple track artists." ');
					} else {
						s.push('title="Tick this checkbox if you want to specify track artists for the tracks other than the release artist." ');
					}
					s.push(mb.ua.ie ? ' style="margin-top: -3px; margin-left: -3px; margin-right: 1px;" ' : '');
					s.push(hasmultipletrackartists == 1 ? ' checked="checked" ' : '');
					s.push(' onclick="'+this.GID+'.onEditArtistsClicked(this)" ');
					s.push(' />');
					s.push('</td><td>');
					s.push('Show track artists<br/>');
					s.push('</td></tr>');

					// draw the checkbox which can be used to toggle the relationship editors
					// s.push('<tr><td>');
					// s.push('<input name="v::editrelationships" value="1" type="checkbox" class="checkbox" ');
					// s.push(' onclick="'+this.GID+'.onRelEditClicked(this)" ');
					// s.push(editrelationships == 1 ? ' checked="checked" ' : '');
					// s.push(mb.ua.ie ? ' style="margin-top: -3px; margin-left: -3px; margin-right: 1px;" ' : '');
					// s.push('title="Click this checkbox if you want to edit relationships" />');
					// s.push('</td><td>');
					// s.push('Show relationship editors');
					// s.push('</td></tr>');
					s.push('</table>');
					obj.innerHTML = s.join("");

					// if the form field editrelationships is set to '1', show the
					// relationship editors
					// this.showRelationshipEditors(editrelationships == 1);

					// get the release and tracks artistedit checkboxes and
					// decorate with the javascript handler
					var editcheckboxes = [ es.ui.getField("artistedit") ];
					var i, el, tracks = this.getTracks();
					for (i=0; i < tracks; i++) {
						editcheckboxes.push(es.ui.getField("tr"+i+"_artistedit"))
					}

					for (i=0; i < editcheckboxes.length; i++) {
						if ((el = editcheckboxes[i]) != null) {
							var field = (el.name == "artistedit" ? "release_artist" : "track_artist");
							var index = (el.name == "artistedit" ? null : i-1);

							// get the parent node of the checkbox (table cell), and
							// remove the checkbox.
							var td = el.parentNode;
							el.id = this.getFieldId(field, "checkbox", index);
							el.style.display = "none";

							var img = document.createElement("img");
							img.id = this.getFieldId(field, "toggleicon", index);
							img.onclick = function onclick(event) {
								ae.onEditArtistClicked(this);
							};
							img.src = el.checked ? this.editartist_on.src : this.editartist_off.src;
							img.title = el.checked ? this.editartist_title_on : this.editartist_title_off;
							img.style.cursor = "hand";
							td.appendChild(img);

							if (el.checked && index != null) {
								jsselect.registerAjaxSelect(es.ui.getField('tr'+index+'_artistname'), 'artist', partial(function(field, index, img, entity) {
									ae.setArtistDisplay(false, entity, field, index);
									es.ui.getField('tr'+index+'_artistid').value = entity.id;
									es.ui.getField('tr'+index+'_artistname').value = entity.name;
									es.ui.getField('tr'+index+'_artistresolution').value = entity.name;
									img.src = ae.editartist_off.src;
									img.title = ae.editartist_title_off;
								}, field, index, img));
							}

						} else {
							mb.log.error("editcheckboxes "+i+" is null");
						}
					}

					for (i=0; i < tracks; i++) {
						if ((el = es.ui.getField("trackdel"+i)) != null) {

							var field = "trackdel";
							var index = i;

							// get the parent node of the checkbox (table cell), and
							// remove the checkbox.
							var td = el.parentNode;
							el.id = this.getFieldId(field, "checkbox", index);
							el.style.display = "none";

							var img = document.createElement("img");
							img.id = this.getFieldId(field, "toggleicon", index);

							if (el.disabled) {
								img.src = this.removetrack_disabled.src;
								img.title = this.removetrack_title_disabled;
							} else {
								img.onclick = function onclick(event) {
									ae.onRemoveTrackClicked(this);
								};
								img.src = el.checked ? this.removetrack_on.src : this.removetrack_off.src;
								img.title = el.checked ? this.removetrack_title_on : this.removetrack_title_off;
								img.style.cursor = "hand";
							}
							td.appendChild(img);
						}
					}

					// get the release events checkboxes
					var revcheckboxes = [];
					i = 0;
					while ((obj = es.ui.getField("rev_clear-"+(i++))) != null) {
						revcheckboxes.push(obj);
					}

					for (i=0; i < revcheckboxes.length; i++) {
						if ((el = revcheckboxes[i]) != null) {
							var field = "rev_clear-";
							var index = i;

							// get the parent node of the checkbox (table cell), and
							// remove the checkbox.
							var td = el.parentNode;
							el.id = this.getFieldId(field, "checkbox", index);
							el.style.display = "none";

							var img = document.createElement("img");
							img.id = this.getFieldId(field, "toggleicon", index);
							img.onclick = function onclick(event) {
								ae.onRemoveReleaseEventClicked(this);
							};
							img.src = el.checked ? this.removereleaseevent_on.src : this.removereleaseevent_off.src;
							img.title = el.checked ? this.removereleaseevent_title_on : this.removereleaseevent_title_off;
							img.style.cursor = "hand";
							td.appendChild(img);


						} else {
							mb.log.error("revcheckboxes "+i+" is null");
						}
					}

				} else {
					mb.log.error("Did not find the 'hasmultipletrackartists' field");
				}
			} else {
				mb.log.error("Did not find the 'artistid' field");
			}
		} else {
			mb.log.error("Did not find the 'releaseeditor::config' div");
		}

		// walk the list of fields in the current field and setup fields.
		var value, name, el, list = es.ui.getFieldsWalker(es.ui.re.DATEFIELD_CSS, null);
		for (var j=list.length-1; j>=0; j--) {
			el = list[j];
			name = (el.name || "");
			value = (el.value || "");
			mb.log.debug("el: $", name);

			var defvalue = "";
			var title = "";
			if (name.match(/year-/i)) {

				// preset form field with the year date mask, and clear upon
				// receiving the focus
				if (el.disabled) {
					el.title = "Release event is selected for removal";
				} else {
					el.title = "Enter the year here. This value is required if you enter the month and day (e.g. " + new Date().getFullYear() + ")";
				}

			} else if (name.match(/month-/i)) {

				// preset form field with the year date mask, and clear upon
				// receiving the focus
				if (el.disabled) {
					el.title = "Release event is selected for removal";
				} else {
					el.title = "Enter the month here. This value is required if you enter the day (e.g. " + (new Date().getMonth() + 1) + ")";
				}

			} else if (name.match(/day-/i)) {

				// preset form field with the year date mask, and clear upon
				// receiving the focus
				if (el.disabled) {
					el.title = "Release event is selected for removal";
				} else {
					el.title = "Enter the day here (e.g. " + new Date().getDate() + ")";
				}
			}
		}

		this.labelEditors = new MusicBrainz.InPlaceLabelEditors("rev_label-", "rev_labelname-", "rev_labelorigname-");
		this.labelEditors.setup();

	};

	this.getLabelFromInput = function(el) {
		if (el) {
			// we're looking for the label object in the first cell of
			// the current row. if it was found, we'll insert the character
			// for color-blind users and/or non-css browsers to mark the rows
			// which need further attention.
			var found = false, td, label, tr = el.parentNode.parentNode;
			for (var i=0; !found && i<tr.childNodes.length; i++) {
				if ((td = tr.childNodes[i]).nodeName.toLowerCase() == "td") {
					for (var k=0; !found && k<td.childNodes.length; k++) {
						if ((label = td.childNodes[k]).nodeName.toLowerCase() == "label") {
							return label;
						}
					}
				}
			}
		}
	};

	/**
	 *
	 */
	this.validateFields = function(el) {
		mb.log.scopeStart("Handling click on submit button...");
		var id, cn, validated = true;
		if (el) {
			var list = es.ui.getFieldsWalker(es.ui.re.TEXTFIELD_CSS, null);
			for (var j=list.length-1; j>=0; j--) {
				el = list[j];
				id = (el.id || "");
				cn = (el.className || "");

				var label = this.getLabelFromInput(el);
				if (el.value == "") {
					if (el.name.match(/track\d+/) && es.ui.getField("trackdel" + el.name.substr(5)).checked) {
						continue;
					}
					if (el.name.match(/tr\d+_artistname/) && es.ui.getField("trackdel" + el.name.substr(2).split("_")[0]).checked) {
						continue;
					}
					if (!cn.match(/missing/i)) {
						el.className += " missing";
					}
					if (label && label.firstChild.nodeValue.indexOf("[!]") == -1) {
						label.firstChild.nodeValue = label.firstChild.nodeValue.replace(":", " [!]:");
					}
					validated = false;
				} else {
					el.className = cn.replace(/\s+missing/gi, "");
					if (label) {
						label.firstChild.nodeValue = label.firstChild.nodeValue.replace(/ \[!\]/g, "");
					}
				}
				mb.log.debug("Field $, classname: $", id, el.className);
			}
			if (!validated) {
				if ((el = mb.ui.get("validatemessages")) != null) {
					el.style.display = "";
				}
			}

		} else {
			mb.log.error("Element el needs to be provided.");
		}
		mb.log.info("After check: validated=$", validated);
		mb.log.scopeEnd();
		return validated;
	};

	/**
	 *
	 */
	this.getArtistLink = function(id, name, resolution) {
		resolution = (resolution  != null ? resolution : "");
		var s = [];
		s.push(mb.ui.getEntityLink('artist', id, name));
		if (!mb.utils.isNullOrEmpty(resolution)) {
			s.push(' (');
			s.push(resolution);
			s.push(')');
		}
		return s.join("");
	};

	/**
	 * Create a user information box
	 *
	 * @param	subject		subject or empty string
	 * @param	text		not null
	 * @param	drawbox		true*|false
	 **/
	this.getInfoBox = function(subject, text, drawbox) {
		mb.log.enter(this.GID, "getInfoBox");
		var s = "";
		subject = (subject || "");
		drawbox = (drawbox != null ? drawbox : true);
		if (mb.utils.isNullOrEmpty(text)) {
			mb.log.error("Missing parameter text");
		} else {
			s = this.getFeedbackBox(drawbox, 'info', subject, text);
		}
		mb.log.exit();
		return s;
	};

	/**
	 * Create a user warning box
	 *
	 * @param	subject		subject or empty string
	 * @param	text		not null
	 * @param	drawbox		true*|false
	 **/
	this.getWarningBox = function(subject, text, drawbox) {
		mb.log.enter(this.GID, "getWarningBox");
		var s = "";
		subject = (subject || "");
		drawbox = (drawbox != null ? drawbox : true);
		if (mb.utils.isNullOrEmpty(text)) {
			mb.log.error("Missing parameter text");
		} else {
			s = this.getFeedbackBox(drawbox, 'warning', subject, text);
		}
		mb.log.exit();
		return s;
	};

	/**
	 * Create a user feedback box.
	 *
	 * @param 	type	info|warning
	 * @param	text
	 * @param	subject
	 **/
	this.getFeedbackBox = function(drawbox, type, subject, text) {
		mb.log.enter(this.GID, "getFeedbackBox");
		var s = [];
		var boxtype = drawbox ? type : "nobox";
		s.push('<div class="feedbackbox '+boxtype+'">');
		s.push('<img src="/images/es/'+type+'.gif" alt="">');
		if (subject != "") {
			s.push('<span id="header">');
			s.push(subject);
			s.push('</span>');
		}
		s.push('<span id="text">');
		s.push(text);
		s.push('</span>');
		s.push('</div>');
		mb.log.exit();
		return s.join("");
	};

	/**
	 * Returns an icon corresponding to the given entitytype
	 *
	 * @param 	entitytype	one of [artist|release|track|url|unknown]
	 * 						todo: check types?
	 */
	this.getEntityTypeIcon = function(entitytype) {
		var s = [];
		s.push('<img src="/images/entity/'+entitytype+'_small.gif" ');
		s.push('alt="" title="');
		s.push(entitytype == "unknown"
			? "Please choose an entity type for this Relationship"
			: entitytype
		);
		s.push('" />');
		return s.join("");
	};

	/**
	 * Handles a click on the edit release/track artist checkbox.
	 *
	 * @param	el			the toggle icon
	 * @returns	true		action is always allowed
	 *
	 **/
	this.onEditArtistClicked = function(el) {
		var id = (el.id || "");

		// lets see if we got a valid element id
		if (id.match(/(release|track)_artist::toggleicon::\d*/)) {
			id = id.split("::");
			var field = id[0];
			var index = id[2];

			// find checkbox, and toggle it. then, update the toggle
			// icon image to according to the set state.
			var cb = mb.ui.get(this.getFieldId(field, "checkbox", index));
			cb.checked = !cb.checked;
			el.src = cb.checked ? this.editartist_on.src : this.editartist_off.src;
			el.title = cb.checked ? this.editartist_title_on : this.editartist_title_off;

			this.setArtistDisplayFromField(cb.checked, field, index, el);

		} else {
			mb.log.error("Unexpected element id: $", id);
		}
		return true;
	};

	/**
	 * Handles a click on the remove track checkbox.
	 *
	 * @param	el			the toggle icon
	 * @returns	true		action is always allowed
	 *
	 **/
	this.onRemoveTrackClicked = function(el) {
		var id = (el.id || "");

		// lets see if we got a valid element id
		if (id.match(/trackdel::toggleicon::\d*/)) {
			id = id.split("::");
			var field = id[0];
			var index = id[2];

			// find checkbox, and toggle it. then, update the toggle
			// icon image to according to the set state.
			var cb = mb.ui.get(this.getFieldId(field, "checkbox", index));
			cb.checked = !cb.checked;
			el.src = cb.checked ? this.removetrack_on.src : this.removetrack_off.src;
			el.title = cb.checked ? this.removetrack_title_on : this.removetrack_title_off;

		} else {
			mb.log.error("Unexpected element id: $", id);
		}
		return true;
	};

	/**
	 * Handles a click on the remove releaseevent checkbox.
	 *
	 * @param	el			the toggle icon
	 * @returns	true		action is always allowed
	 *
	 **/
	this.onRemoveReleaseEventClicked = function(el) {
		var id = (el.id || "");

		// lets see if we got a valid element id
		if (id.match(/rev_clear-::toggleicon::\d*/)) {
			id = id.split("::");
			var field = id[0];
			var index = id[2];

			// find checkbox, and toggle it. then, update the toggle
			// icon image to according to the set state.
			var cb = mb.ui.get(this.getFieldId(field, "checkbox", index));
			cb.checked = !cb.checked;
			el.src = cb.checked ? this.removereleaseevent_on.src : this.removereleaseevent_off.src;
			el.title = cb.checked ? this.removereleaseevent_title_on : this.removereleaseevent_title_off;

		} else {
			mb.log.error("Unexpected element id: $", id);
		}
		return true;
	};


	/**
	 *
	 */
	this.setArtistDisplayFromField = function(isEditMode, field, index, img) {

		// depending on the field (release_artist|track_artist), find hidden input element
		// which contains the artistid and the artistname
		var e_id, f_id, i_id = (field == "release_artist" ? "artistid" : "tr"+index+"_artistid");
		var e_name, f_name, i_name = (field == "release_artist" ? "artistname" : "tr"+index+"_artistname");
		var e_resolution, f_resolution, i_resolution = (field == "release_artist" ? "artistresolution" : "tr"+index+"_artistresolution");

		// if there are fields which correspond to the given fields,
		// update the release/track artist editor
		if ((f_id = es.ui.getField(i_id)) != null &&
			(e_id = f_id.value) != null &&
			(f_name = es.ui.getField(i_name)) != null &&
			(e_name = f_name.value) != null &&
			(f_resolution = es.ui.getField(i_resolution)) != null &&
			(e_resolution = f_resolution.value) != null) {

			// create entity object, and update the artist editor
			var entity = { id: e_id, name: e_name, resolution: e_resolution };
			ae.setArtistDisplay(isEditMode, entity, field, index, img);

		} else {
			mb.log.error("Could not get field values! id: $, name: $, resolution: $",
				[i_id, f_id, e_id],
				[i_name, f_name, e_name],
				[i_resolution, f_resolution, e_resolution]
			);
		}
	}



	/**
	 * Update release artist fields.
	 *
	 * @param 	id
	 * @param 	name
	 */
	this.setArtistDisplay = function(isEditMode, entity, field, index, img) {

		// get div elements containing the display/hidden form elements
		var displayTD, displayID = this.getFieldId(field, "display", index);
		var fieldsTD, fieldsID = this.getFieldId(field, "fields", index);
		var checkbox, checkboxID = (field == "release_artist" ? "artistedit" : "tr"+index+"_artistedit");

		if ((displayTD = mb.ui.get(displayID)) != null &&
			(fieldsTD = mb.ui.get(fieldsID)) != null &&
			(checkbox = es.ui.getField(checkboxID)) != null) {

			// field names
			var f_id = (field == "release_artist" ? "artistid" : "tr"+index+"_artistid");
			var f_name = (field == "release_artist" ? "artistname" : "tr"+index+"_artistname");
			var f_resolution = (field == "release_artist" ? "artistresolution" : "tr"+index+"_artistresolution");

			var s = [];
			if (isEditMode) {
				s.push('<input type="text" name="'+f_name+'" ');
				s.push('  class="textfield" ');
				s.push('  style="width:'+es.fr.currentWidth+'" ');
				s.push('  value="' + entity.name + '" />');

			} else {
				s.push(ae.getArtistLink(entity.id, entity.name, entity.resolution));
				s.push('<input type="hidden" name="'+f_name+'" value="'+entity.name+'" />');
			}

			// update the display td with either the field, or the artist name.
			displayTD.innerHTML = s.join("");
			if (isEditMode) {
				jsselect.registerAjaxSelect(displayTD.childNodes[0], 'artist', function(entity) {
					ae.setArtistDisplay(false, entity, field, index);
					es.ui.getField(f_id).value = entity.id;
					es.ui.getField(f_name).value = entity.name;
					es.ui.getField(f_resolution).value = entity.resolution;
					img.src = ae.editartist_off.src;
					img.title = ae.editartist_title_off;
				})
			}

			// show the editing fields if we are in editing mode
			fieldsTD.style.display = isEditMode ? "" : "none";

			// update checkbox state isEditMode
			checkbox.checked = isEditMode;

		} else {
			mb.log.error("Could not get TDs! display: $, fields: $", [displayID, displayTD], [fieldsID, fieldsTD]);
		}

	};

	/**
	 * Handles a click on the 'show track artists' checkbox
	 *
	 * @param	el		the checkbox element
	 **/
	this.onEditArtistsClicked = function(el) {
		if (el && !el.disabled) {
			var isEditMode = el.checked;
			var id, obj, tracks = this.getTracks();
			var field = "track_artist";
			for (var index=0; index < tracks; index++) {
				this.setArtistDisplayFromField(false, field, index);
				id = this.getFieldId(field, "tr", index);
				if ((obj = mb.ui.get(id)) != null) {
					obj.style.display = isEditMode ? "" : "none";
				}
			}

			// re-order spacing of form-elements
			this.updateMargins();

			// update the field which defines if the track artists are
			// shown or not.
			this.setFieldValue("hasmultipletrackartists", el.checked ? 1 : 0);

			// if we are showing the track artist fields, they need to be
			// setup (GC button, toolbox)
			if (isEditMode) {
				es.ui.setupFormFields();
			}

			// update tabindex'
			var fields, f = es.ui.getForm();
			var tabindex = 0;
			if ((f != null) &&
				(fields = f.elements) != null) {
				for (var i=0;i<fields.length; i++) {
					f = fields[i];
					var name = f.name || "";
					var cn = f.className || "";
					if (name.match(/track\d+|trackseq\d+|tracklength\d+|tr\d+_artistname/)) {
						f.tabIndex = ++tabindex; // attention: capitalization of tabIndex is important!
					}
				}
			}
		} else {
			mb.log.error("onEditArtistsClicked :: required element el not given!");
		}
	};



	/**
	 * Updates the margins on the trackartists div depending if
	 * the relationship editors are visible or not
	 **/
	this.updateMargins = function() {
		var obj, tracks = this.getTracks();
		var rseVisible = rse.isVisible();

		for (var index=0; index < tracks; index++) {
			var id = this.getFieldId("track", "relationship", index);
			if ((obj = mb.ui.get(id)) != null) {
				obj.className = "tr_artists" + (rseVisible ? "" : "_no_relationships");
			} else {
				mb.log.error("obj "+id+" not found!");
			}
		}
	};

	/**
	 * Handles a click on the 'show relationship editors' checkbox
	 *
	 * @param	el		the checkbox element
	 **/
	this.getTracks = function() {
		mb.log.enter(this.GID, "getTracks");
		if (this._tracks == null) {
			var f;
			if ((f = es.ui.getForm()) != null) {
				var obj, tracks, index;
				obj = es.ui.getField("tracks");
				if (!obj || (this._tracks = obj.value) == null) {
					this._tracks = 0;
					mb.log.error("Did not find the 'tracks' field");
				}
			} else {
				this._tracks = 0;
				mb.log.error("Did not find the form");
			}
		}
		mb.log.exit();
		return this._tracks;
	};


	/**
	 * Handles a click on the 'show relationship editors' checkbox
	 *
	 * @param	el		the checkbox element
	 **/
	this.onRelEditClicked = function(el) {
		if (el && !el.disabled) {
			this.showRelationshipEditors(el.checked);
			this.updateMargins();
		}
	};

	/**
	 * Toggles the visibility of the relationship editors
	 * and initialises them, if they haven't been before.
	 *
	 * @param	flag	visibility, true or false
	 **/
	this.showRelationshipEditors = function(flag) {
		if (flag && !rse.isInitialised()) {
			rse.initialise();
		}
		if (rse.isInitialised()) {
			rse.showUI(flag);
		}
	};


}


// setup ReleaseEditor object, and register callback method
var ae = new ReleaseEditor();
mb.registerPageLoadedAction(new MbEventAction("ae", "initialise", "Init release editor"));
