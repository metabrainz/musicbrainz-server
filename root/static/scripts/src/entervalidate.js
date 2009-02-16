
/**
 * Relationship Object
 * capsulates all the properties for a RelationShipType instance
 *
 **/
function Relationship(rel) {
	this.CN = "Relationship";
	this.GID = "rel";

	// no relationship parameter given
	if (rel == null) rel = {};

	// put parameters into member variables
	this.nodeid = rel.nodeid ? rel.nodeid : "*";
	this.typeid = rel.typeid ? rel.typeid : 0;
	this.mp = rel.mp ? rel.mp : 0;
	this.begindate = rel.begindate ? rel.begindate : '';
	this.enddate = rel.enddate ? rel.enddate : '';
	this.attr = rel.attr ? rel.attr : [];
	this.entitytype = rel.rtype ? rel.rtype : null;
	this.entity = {};
	this.entity.id = rel.rid ? rel.rid : null;
	this.entity.name = rel.rname ? rel.rname : null;
	this.entity.resolution = "";

	// entity methods
	this.getEntityType = function() { return this.entitytype; };
	this.getEntity = function() { return this.entity; };
	this.getEntityId = function() { return this.entity.id; };
	this.getEntityName = function() { return this.entity.name; };
	this.getEntityResolution = function() { return this.entity.resolution; };

	this.setEntityType = function(v) { this.entitytype = v; };
	this.setEntity = function(v) { this.entity = v; };

	// relationship methods
	this.getNodeId = function() { return this.nodeid; };
	this.getTypeId = function() { return this.typeid; };
	this.setNodeId = function(v) { this.nodeid = v; };
	this.setTypeId = function(v) { this.typeid = v; };

	// attribute methods
	this.isModPending = function() { return this.mp; };
	this.getBeginDate = function() { return this.begindate; };
	this.getEndDate = function() { return this.enddate; };
	this.isModPending = function() { return this.mp; };
	this.getAttributeList = function() { return this.attr; };
	this.setBeginDate = function(v) { this.begindate = v; };
	this.setEndDate = function(v) { this.enddate = v; };
	this.setModPending = function(v) { this.mp = v; };

	// returns the RelationShipType object corresponding to
	// this.typeid, or null if it does not exist
	this.getType = function() {
		return rel_types[this.typeid];
	};

	// stores the edit/visible state of the relationship
	this.editstate = false;
	this.setEditState = function(f) { this.editstate = f; }
	this.getEditState = function() { return this.editstate; }

	// Returns the phrase from the RelationShipType object
	// or null, if the object does not exist.
	this.getPhrase = function() {
		var rt, phrase = null;
		if ((rt = this.getType()) != null) {
			phrase = rt.phrase;
		}
		return phrase;
	};

	// we need to collect the different attributes by their type
	// currently known types are: instrument|vocal|additional|guest
	//
	// loop through all the relationship attributes, given as a flat array,
	// and either find them in the toplevel list, or in the list of
	// children for the elements which possess children.
	//
	// for example attr: [83, 194] corresponds to:
	//
	// ROOT
	// |- [ ] additional (1)
	// |- vocal (3)
	// |-   [ ] ...
	// |- instrument (14)
	// |-   [x] Double Bass / Contrabass (83)
	// |-   [ ] ...
	// |- [x] guest (194)
	this.getAttributesByType = function() {
		mb.log.enter(this.GID, "getAttributesByType");
		if (!this.attr_by_type) {
			var temp = [];
			if (this.attr && this.attr.length > 0) {
				for (var k = this.attr.length-1; k >= 0; k--) {
					var id = this.attr[k];
					var found = false;

					// find attribute by id in global attribute list
					var gattr_id = id;
					var gattr = rel_attrs[gattr_id];

					// if its a simple value (additional, guest)
					// else find the value in the children of the attributes
					if (gattr) {
						temp[gattr.name] = gattr.name;
						found = true;
						mb.log.trace("Simple: id: $, name: $", gattr_id, gattr.name);

					} else {
						// else go through the list of top-level attributes and
						// find one that contains a children with id=id.
						for (var l=rel_attrs.list.length-1; l >=0; l--) {
							gattr_id = rel_attrs.list[l];
							gattr = rel_attrs[gattr_id];
							if (gattr) {
								// if the current attribute type has children,
								// retrieve the child by it's id and
								// store the name of the selected item into
								// the category (instrument|vocal)
								if (gattr.children) {
									var cattr = gattr.children[id];
									if (cattr) {
										if (temp[gattr.name] == null) {
											temp[gattr.name] = [];
										}
										found = true;
										temp[gattr.name].push(cattr.name);
										mb.log.trace("Child: id: $, category: $, name: $", id, gattr.name, cattr.name);
									}
								}
							}
						}
					}
					if (!found) {
						mb.log.error("attribute id: $ does not exist!", id);
					}
				}
			}
			this.attr_by_type = temp;
		}
		mb.log.exit();
		return this.attr_by_type;
	};

	// get attributes for the current relationship by name, if it
	// is defined, else null.
	// The return type can either be a number, and array of 0..n
	// values, or null.
	this.getAttribute = function(type) {
		mb.log.enter(this.GID, "getAttribute");
		var attrs = this.getAttributesByType();
		var value = null;
		if (attrs) {
			value = attrs[type];
		}
		mb.log.trace("type: $, value: $", type, value);
		mb.log.exit();
		return value;
	}

	// we got a phrase like "performed {additional} {guest} {instrument} on"
	// split each phrase into a list of words,
	// and replace each {additional}, {guest} etc. with the attribute given
	// if there are more than one (e.g. for instruments, join each by "," and append
	// the last one by "and" if there are more than 2 instruments, else join
	// them by "and".
	this.getDisplayPhrase = function() {
		mb.log.enter(this.GID, "getDisplayPhrase");
		var retval, rt;
 		if ((rt = this.getType()) != null) {
			var phrase = rt.phrase;
			var parr = phrase.split(" ");
			for (var j=0; j<parr.length; j++) {
				var word = parr[j];
				if (word.match(/^\{[^\}]+\}$/)) {
					// some attributes are spelled as an ajective (additional|additionally) in
					// the phrase, handle that case too.
					var type = word.replace(/\{|\}/g, "");
					type = type.replace(/ly$/i, "");
					var value = this.getAttribute(type);
					var replace = "";

					// if the attribute exists in the list of attributes
					// of this relationship
					if (value) {
						if (mb.utils.isArray(value)) {
							replace = "";
							if (value.length == 1) {
								replace = value[0];
							} else if (value.length == 2) {
								replace = value.join(" and ");
							} else {
								// append last element with "and", and join
								// the rest with commas.
								replace = "and "+value[value.length-1];
								delete value[value.length-1];
								replace = value.join(", ") + replace;
							}
						} else {
							// else use word from the phrase, without
							// the curly brackets.
							replace = word.replace(/\{|\}/g, "");
						}
						mb.log.trace("Type $ defined... value: $, replace: $", type, value, replace);
					} else {
						mb.log.trace("Type $ not defined, removed from phrase", type);
					}
					phrase = phrase.replace(word, replace);
				}
			}
			retval = phrase.replace(/(\s+)on$/, "");
		} else {
			retval = "RelationShipType id="+this.typeid+" not found!";
		}
		mb.log.exit();
		return retval;
	};

	// returns all the hidden fields of this Relationship for the
	// display state (e.g. no form fields)
	// nodeid: [number] - the id of the relationship, if it exists
	// typeid: [number] - one of the relationship types
	// mp: [number 0|1] - if the current relationship has a pending moderation
	// rid: [number]
	// rname: [string]
	// rtype: [string: artist|album|url]
	// begindate: [datestring]
	// enddate: [datestring]
	// attr: [array]
	this.getDisplayHiddenFields = function(type, index, subindex) {
		mb.log.enter(this.GID, "getDisplayHiddenFields");
		var s = [];

		// relationship
		s.push(this.getHiddenField(type, "nodeid", this.getNodeId(), index, subindex));
		s.push(this.getHiddenField(type, "typeid", this.getTypeId(), index, subindex));

		// entity
		s.push(this.getHiddenField(type, "rtype", this.getEntityType(), index, subindex));
		s.push(this.getHiddenField(type, "rid", this.getEntityId(), index, subindex));
		s.push(this.getHiddenField(type, "rname", this.getEntityName(), index, subindex));
		s.push(this.getHiddenField(type, "rresolution", this.getEntityResolution(), index, subindex));

		s.push(this.getHiddenField(type, "begindate", this.getBeginDate(), index, subindex));
		s.push(this.getHiddenField(type, "enddate", this.getEndDate(), index, subindex));
		for (var i=0; i<this.attr.length; i++) {
			s.push(this.getHiddenField(type, "attr", this.attr[i], index, subindex, i));
		}
		mb.log.exit();
		return s.join("");
	};

	// returns all the hidden fields of this Relationship for the
	// edit state (e.g. fields which are not editable)
	this.getEditHiddenFields = function(type, index, subindex) {
		mb.log.enter(this.GID, "getEditHiddenFields");
		var s = [];

		// relationship
		s.push(this.getHiddenField(type, "nodeid", this.getNodeId(), index, subindex));

		// entity
		s.push(this.getHiddenField(type, "rtype", this.getEntityType(), index, subindex));
		s.push(this.getHiddenField(type, "rid", this.getEntityId(), index, subindex));
		s.push(this.getHiddenField(type, "rname", this.getEntityName(), index, subindex));
		s.push(this.getHiddenField(type, "rresolution", this.getEntityResolution(), index, subindex));

		mb.log.exit();
		return s.join("");
	};

	// returns the html code for a hidden field
	this.getHiddenField = function(type, name, value, index, subindex, subseq) {
		mb.log.enter(this.GID, "getHiddenField");
		var s = [];
		s.push('<input type="hidden" name="');
		s.push(this.getFieldName(type, name, index, subindex, subseq));
		s.push('" value="');
		s.push(value);
		s.push('" />');
		mb.log.exit();
		return s.join("");
	};

	// returns the field name build from the index,
	// the fieldname name and the sequence number subindex
	this.getFieldName = function(type, name, index, subindex, subseq) {
		mb.log.enter(this.GID, "getFieldName");
		subindex = (subindex != null ? subindex : 0);
		subseq = (subseq != null ? subseq : -1);
		var fn = "";
		if (type == 'album_rel') {
			fn = "al_rel"+index+"_"+name;
		} else if (type == 'track_rel') {
			fn = "tr"+index+"_rel"+subindex+"_"+name;
		} else {
			mb.log.error("unhandled type: $", type);
			mb.log.error("  other parameters: name: $, index: $, subindex: $, subseq: $", name, index, subindex, subseq);
		}
		if (subseq != -1) {
			fn += subseq;
		}
		mb.log.exit();
		return fn;
	};

	// returns a string representation of this Relationship
	this.toString = function() {
		return "Relationship [id="+this.nodeid+", type="+this.getPhrase()+"]";
	};
}


/**
 * RelationShipsFieldParser class
 * Helper class for parsing the Relationship objects from the hidden fields.
 *
 **/
function RelationShipsFieldParser() {
	this.CN = "RelationShipsFieldParser";
	this.GID = "rsfp";
	this._rel = new Relationship();


	// defined fieldnames
	this.fields = [ "nodeid|0", "mp|0", "rid|1", "rname|1", "rtype|1", "begindate|0", "enddate|0", "attr|0" ];

	// returns the field name build from the index,
	// the fieldname name and the sequence number subindex
	this.getValue = function(required, type, name, index, subindex, subseq) {
		mb.log.enter(this.GID, "getValue");
		var fn = this._rel.getFieldName(type, name, index, subindex, subseq);
		var value = null;
		if ((obj = es.ui.getField(fn, true)) != null) {
			if (obj.value) {
				value = obj.value;
				mb.log.trace("$$=$", fn, required ? "*" : "", value);
				if (obj.parentNode) {
					obj.parentNode.removeChild(obj);
				}
			} else {
				if (required) {
					mb.log.error("Found fn: $, but does not define 'value' property", fn);
				}
			}
		} else {
			if (required) {
				mb.log.error("Did not find fn: $", fn);
			} else {
				mb.log.trace("Did not find fn: $", fn);
			}
		}
		mb.log.exit();
		return value;
	};

	/**
	 *
	 */
	this.loadRelationship = function(type, index, subindex) {
		mb.log.enter(this.GID, "loadRelationship");
		var rel;
		var missing = false, value = null;
		var typeid = this.getValue(false, type, "typeid", index, subindex);
		if (typeid == null) {
			// assume we don't have a relationship defined for
			// index, sequence number subindex, if typeid is missing!
		} else {
			var hash = { "typeid": typeid };
			for (var i = 0; i < this.fields.length; i++) {
				var temp = this.fields[i];
				var cf = temp.split("|")[0];
				var required = (temp.split("|")[1] == "1"); // 1|0, where 1 means that the field is required
				hash[cf] = null;

				// loop 0...n for all attributes
				if (cf == "attr") {
					var attr = [];
					for (var subseq=0; ; subseq++) {
						// subseq parameters needs to be sent because the attributes have an
						// additional increment field.
						// => attr0_0, attr0_1, attr0_2 etc.
						if ((value = this.getValue(required, type, "attr", index, subindex, subseq)) != null) {
							attr.push(value);
						} else {
							break;
						}
					}
					// store array of attributes
					hash[cf] = attr;
				} else {
					// else, try to load value from the hidden input field
					if ((value = this.getValue(required, type, cf, index, subindex)) != null) {
						hash[cf] = value;
					}
				}

				// if the field is required and missing, abort
				if (hash[cf] == null && required) {
					mb.log.error("Required field: $ is missing", cf);
					missing = true;
					break;
				}
			}
			// if no missing field was found, create the relationship object
			// from the hash.
			if (!missing) {
				rel = new Relationship(hash);
			}
			mb.log.trace("type: $, index: $, subindex: $, rel: $", type, index, subindex, rel);
		}
		mb.log.exit();
		return rel;
	};
}




/**
 * RelationShipsEditor class.
 *
 **/
function RelationShipsEditor() {

	this.CN = "RelationShipsEditor";
	this.GID = "rse";

	// stores the relationship objects build from the form fields.
	this._initialised = false;
	this._visible = false;
	this._initialising = false;
	this._trackrel = [];
	this._albumrel = [];
	this._rsfp = new RelationShipsFieldParser();

	// possible entities to link to
	this.linkable_entities = [ "Artist", "Album", "Track", "Url" ];

	// walks the fields of the form and sets up the relationship editor functionality.
	this.initialise = function() {
		mb.log.enter(this.GID, "initialise");
		if (!this._initialising) {
			this._initialising = true;

			// declare loop variables
			var cond = true, rel, index, subindex;

			// clear the relationship arrays
			this._albumrel = [];
			this._trackrel = [];

			// try to load all relationships for track index, if loadRelationship
			// returns null, cond is set to false and the loop end-condition
			// is reached.
			for (index = 0; cond; index++) {
				if ((cond = ((rel = this._rsfp.loadRelationship('album_rel', index)) != null))) {
					this._albumrel[index] = rel;
				}
			}

			var tracks = ae.getTracks();
			for (index=0; index < tracks; index++) {
				cond = true;
				this._trackrel[index] = [];

				// try to load all relationships for track index, if loadRelationship
				// returns null, cond is set to false and the loop end-condition
				// is reached.
				for (subindex = 0; cond; subindex++) {
					if ((cond = ((rel = this._rsfp.loadRelationship('track_rel', index, subindex)) != null))) {
						this._trackrel[index][subindex] = rel;
					}
				}
			}
			this.writeUI(tracks);
			this._initialised = true;
		}
		mb.log.exit();
	};

	// remove a relationship
	this.isInitialised = function() {
		return this._initialised;
	};

	// remove a relationship
	this.removeRelationship = function(el, type, index, subindex) {
		mb.log.enter(this.GID, "removeRelationship");
		if (el != null
			&& index != null) {
			// let's see if there is a list for this track.
			var list;
			list = (type == 'album_rel' ? this._albumrel : list);
			list = (type == 'track_rel' ? this._trackrel[index] : list);
			if (list) {
				var obj, id = ae.getFieldId(type, 'newrel', index, subindex);
				if ((obj = mb.ui.get(id)) != null) {
					if (obj.parentNode) {
						obj.parentNode.removeChild(obj);
						if (type == 'album_rel') {
							delete this._albumrel[index];
						} else if (type == 'track_rel') {
							delete this._trackrel[index][subindex];
						} else {
							mb.log.error("unhandled type: $", type);
						}
					} else {
						mb.log.error("object id: $ does not define parentNode", id);
					}
				} else {
					mb.log.error("did not find object id: $", id);
				}
			} else {
				mb.log.error("Did not find relationships, type: $", type);
			}
		}
		mb.log.exit();
		return false;
	};

	// add another relationship
	this.addRelationship = function(el, type, index) {
		mb.log.enter(this.GID, "addRelationship");
		if (el != null
			&& index != null) {
			// let's see if there is a list for this track.
			var list = null, subindex = null;

			if (type == 'album_rel') {
				list = this._albumrel;
				index = list.length;
				subindex = 0;
			} else if (type == 'track_rel') {
				list = this._trackrel[index];
				subindex = list.length;
			}
			if (list != null && subindex != null) {
				var td,tr,tbody = null;
				if ((td = el.parentNode) != null
					&& td.nodeName
					&& td.nodeName.toLowerCase() == "td") {
					if ((tr = td.parentNode) != null
						&& tr.nodeName
						&& tr.nodeName.toLowerCase() == "tr") {
						if ((tbody = tr.parentNode) != null
							&& tbody.nodeName
							&& tbody.nodeName.toLowerCase() == "tbody") {

							// append new relationship to list
							var rel = new Relationship();
							rel.setEditState(true);
							list.push(rel);

							// create the dom elements for the new relationship
							// editor.
							var newtr = document.createElement("tr");
							newtr.setAttribute("id", ae.getFieldId(type, 'newrel', index, subindex));

							var td_cb = document.createElement("td");
							td_cb.setAttribute("width", "18");
							td_cb.innerHTML = "&nbsp;";

							var td_edit = document.createElement("td");
							td_edit.setAttribute("width", "18");
							td_edit.innerHTML = this.getRemoveIcon(type, index, subindex);

							var td_type = document.createElement("td");
							td_type.setAttribute("width", "18");
							td_type.setAttribute("id", ae.getFieldId(type, 'entityicon', index, subindex));
							td_type.innerHTML = ae.getEntityTypeIcon("unknown");

							var td_ui = document.createElement("td");
							td_ui.setAttribute("width", "400");
							td_ui.setAttribute("id", ae.getFieldId(type, 'rel', index, subindex));
							td_ui.innerHTML = this.getEditUI(type, rel, index, subindex);

							// add the checkbox, the delete icon, entity type
							// and the edit ui TD's to the TR.
							newtr.appendChild(td_cb);
							newtr.appendChild(td_edit);
							newtr.appendChild(td_type);
							newtr.appendChild(td_ui);

							// insert new row before the add relationship TR
							tbody.insertBefore(newtr, tr);

							// set attributes (after the TR was added to the dom)
							newtr.valign = "top";
							newtr.style.verticalAlign = "top";
						} else {
							mb.log.error("Unexpected parentNode, expected tbody, got: " + (tbody ? tbody.nodeName : "?"));
						}
					} else {
						mb.log.error("Unexpected parentNode, expected tr, got: " + (tr ? tr.nodeName : "?"));
					}
				} else {
					mb.log.error("Unexpected parentNode, expected td, got: " + (td ? td.nodeName : "?"));
				}
			} else {
				mb.log.error("Did not find relationships for track " + index + "/" + subindex);
			}

		} else {
			mb.log.error("Elements el/index not given, aborting");
		}
		mb.log.exit();
		return false;
	};

	/**
	 * Returns the icon which can be used to remove the newly
	 * created relationship.
	 *
	 * @param type
	 * @param index
	 * @param subindex
	 */
	this.getRemoveIcon = function(type, index, subindex) {
		mb.log.enter(this.GID, "getRemoveIcon");
		var s = [];
		s.push('<a href="#" title="Remove this relationship" ');
		s.push('onClick="return rse.removeRelationship(this, '+ae.toParamStrings([type, index, subindex])+');">');
		s.push('<img src="/images/es/remove.gif" ');
		s.push('alt="" /></a>');
		mb.log.exit();
		return s.join("");
	};

	/**
	 * Update the relationship given by the elements id with
	 * the new type selected in the dropdown.
	 *
	 * @param el	the dropdown
	 */
	this.onRelTypeChanged = function(el) {
		mb.log.enter(this.GID, "onRelTypeChanged");
		if (el && el.options) {
			// test if we have a valid dropdown
			var id = (el.id || "");
			if (id.match(/(album|track)_rel\|newtype\|\d+\|\d+/)) {
				var rel, conf = id.split("|");
				var type, index, subindex;
				if ((type = conf[0]) != null &&
					(index = conf[2]) != null &&
					(subindex = conf[3]) != null &&
					(rel = this.findRelationship(type, index, subindex)) != null) {
					var nt = el.options[el.selectedIndex].value;
					rel.setTypeId(nt);
					this.updateUI(type, rel, index, subindex, true);
				}
			} else {
				mb.log.error("Unexpected element id: $", id);
			}
		} else {
			mb.log.error("Element el: $ does not define options", el);
		}
		mb.log.exit();
	};

	// toggles the edit/display mode of the current relationship editor
	this.updateRelationshipEntity = function(type, index, subindex, entitytype, entity) {
		mb.log.enter(this.GID, "updateRelationshipEntity");

		// due to design constraints, subindex carries the current sequence number
		// of the album relationship (e.g. relationships per entity), move it
		// back to the index.
		if ((rel = this.findRelationship(type, index, subindex)) != null) {
			rel.setEntityType(entitytype);
			rel.setEntity(entity);
			this.updateUI(type, rel, index, subindex, false);
		}
		mb.log.exit();
	};

	// toggles the edit/display mode of the current relationship editor
	this.onToggleEditorClicked = function(type, index, subindex) {
		mb.log.enter(this.GID, "onToggleEditorClicked");
		var rel;
		if ((rel = this.findRelationship(type, index, subindex)) != null) {
			rel.setEditState(!rel.getEditState());
			this.updateUI(type, rel, index, subindex, false);
		}
		mb.log.exit();
		return false;
	};

	/**
	 * Attempt to return the relationship given by index, subindex
	 * and type.
	 *
	 * @param type
	 * @param index
	 * @param subindex
	 * @returns a relationship object, or null.
	 *   if type is 'album_rel', album  relationship index (or null) is returned.
	 *   if type is 'track_rel', track relationship subindex of track index (or null) is returned.
	 **/
	this.findRelationship = function(type, index, subindex) {
		mb.log.enter(this.GID, "findRelationship");
		var rel, list;
		if (type == 'track_rel') {
			list = this._trackrel[index];
			if (list) {
				if ((rel = list[subindex]) == null) {
					mb.log.error("No relationship found at subindex: $", subindex);
				}
			}
		} else if (type == 'album_rel') {
			list = this._albumrel;
			if ((rel = list[index]) == null) {
				mb.log.error("No relationship found at index: $", index);
			}
		} else {
			mb.log.error("unhandled type: $", type);
		}
		mb.log.exit();
		return rel;
	};


	// writes the edit/display UI of the given relationship
	// to the DOM.
	// if the relationship is in editstate (always?) only
	// update the attributes of the relationship.
	this.showUI = function(flag) {
		var id, obj, tracks = ae.getTracks();
		for (var index=0; index < tracks; index++) {
			id = ae.getFieldId("track", "relationship", index);
			if ((obj = mb.ui.get(id)) != null) {
				obj.style.display = flag ? "" : "none";
			}
		}
		id = ae.getFieldId("release", "relationship", "");
		if ((obj = mb.ui.get(id)) != null) {
			obj.style.display = flag ? "" : "none";
		}
		this._visible = flag;
	};

	// remove a relationship
	this.isVisible = function() {
		return this._visible;
	};

	/**
	 * writes the edit/display UI of the given relationship
	 * to the DOM...
	 * - find the relationship editor (td), and update
	 *   it's contents from the relationship. only the attributes
	 *   part is updated if edit_state is true and attronly flag
 	 *   is true.
	 * - find the entity icon container (td), and update
	 *   it's contents from the relationship type.
	 */
	this.updateUI = function(type, rel, index, subindex, attronly) {
		var ui_id = ae.getFieldId(type, attronly ? 'rel_attr' : 'rel', index, subindex);
		var ui_obj;
		if ((ui_obj = mb.ui.get(ui_id)) != null) {
			// udpate editor UI
			var source = (rel.getEditState()
				? this.getEditUI(type, rel, index, subindex, attronly)
				: this.getDisplayUI(type, rel, index, subindex)
			);
			ui_obj.innerHTML = source;
			ui_obj.style.display = (source == "" ? "none" : "");

			// find the entity icon container
			var type_id = ae.getFieldId(type, 'entityicon', index, subindex);
			var type_obj;
			if ((type_obj = mb.ui.get(type_id)) != null) {
				type_obj.innerHTML = ae.getEntityTypeIcon(rel.getEntityType());
			} else {
				mb.log.error("EntityIcon id: $ not found", type_id);
			}
		} else {
			mb.log.error("RelationShipEditorUI id: $ not found", ui_id);
		}
	};

	// writes the relationship editor gui to the corresponing "tr[index]_rel_div" object
	this.writeUI = function(tracks) {
		mb.log.enter(this.GID, "writeUI");
		var items, index, obj;

		if ((obj = mb.ui.get("album_rel_div")) != null) {
			var s = [];
			s.push('<label class="label hidden"></label>');
			s.push('<input class="numberfield hidden" readonly="readonly" />');
			s.push('<div class="float">');
			s.push('<table cellspacing="0" cellpadding="0" border="0" width="435">');

			// loop through all the album relationships
			list = this._albumrel;
			items = list ? list.length : 0;
			for (index=0; index < items; index++) {
				var rel = list[index];
				s.push(this.getRelUI('album_rel', rel, index));
			}
			s.push(this.getAddRelUI('album_rel'));
			s.push('</table>');
			s.push('</div>');
			obj.innerHTML = s.join("");
			obj.style.display = "";
		} else {
			mb.log.error("album_rel_div not found");
		}

		// loop through all the tracks and add their respective
		// relationships
		for (index=0; index < tracks; index++) {
			var list = this._trackrel[index];
			if ((obj = mb.ui.get("tr"+index+"_rel_div")) != null) {
				var s = [];
				s.push('<label class="label hidden"></label>');
				s.push('<input class="numberfield hidden" readonly="readonly" />');
				s.push('<div class="float">');
				s.push('<table cellspacing="0" cellpadding="0" border="0" width="435">');
				var items = list ? list.length : 0;
				if (items) {
					for (var subindex=0; subindex<items; subindex++) {
						var rel = list[subindex];
						s.push(this.getRelUI('track_rel', rel, index, subindex));
					}
				}
				s.push(this.getAddRelUI('track_rel', index));
				s.push('</table>');
				s.push('</div>');
				s.push('<br/>');
				obj.innerHTML = s.join("");
				obj.style.display = "";
			} else {
				mb.log.error("tr_[index]_rel_div not found for track: $", index);
			}
		}
		mb.log.exit();
	}

	// returns a row corresponding to the given relationship rel.
	this.getAddRelUI = function(type, index) {
		mb.log.enter(this.GID, "getAddRelUI");
		index = (index != null ? index : "");
		var s = [];
		var link = '<a href="#" title="Add new relationship" '
				 + 'onClick="return rse.addRelationship(this, '+ae.toParamStrings([type, index])+');" />';
		s.push('<tr>');
		s.push('<td valign="top" width="18">&nbsp;</td>');
		s.push('<td valign="top" width="18">');
		s.push(link);
		s.push('<img src="/images/es/create.gif" border="0" alt="Add new relationship">');
		s.push('</a></td>');
		s.push('<td valign="top" colspan="2">');
		s.push(link);
		s.push('Add new relationship</a></td>');
		s.push('</tr>');
		s.push('<tr><td colspan="4">&nbsp;</td></tr>');
		mb.log.exit();
		return s.join("");
	};

	/**
	 * Returns a row corresponding to the given relationship rel.
	 *
	 * @param rel
	 * @param type
	 * @param index
	 * @param subindex
	 * @param inneronly
	 */
	this.getRelUI = function(type, rel, index, subindex, inneronly) {
		mb.log.enter(this.GID, "getRelUI");

		// validate parameters
		type = (type || "");
		subindex = (subindex || 0);
		inneronly = (inneronly || false);
		retval = null;

		if (!type.match(/track|album/)) {
			mb.log.error("Unhandled type: $", type);
		} else if (rel == null || !rel instanceof Relationship) {
			mb.log.error("Expected Relationship, but got $", rel);
		} else if (parseInt(index) == NaN) {
			mb.log.error("index: $ is invalid, expected number", index);
		} else if (parseInt(subindex) == NaN) {
			mb.log.error("subindex: $ is invalid, expected number", subindex);
		} else {
			var s = [];

			// everything looks ok, continue.
			mb.log.trace("type: $, rel: $, index: $, subindex: $, inneronly: $", type, rel, index, subindex, inneronly);
			if (!inneronly) {
				s.push('<tr ' + (rel.isModPending() ? 'class="mp"' : ''));
				s.push('>');
			}
			s.push('<td valign="top" width="18">');
			s.push('<input type="checkbox" class="checkbox" ');
			if (mb.ua.ie) {
				s.push('style="margin-top: -3px; margin-left: -3px; margin-right: 1px;"');
			}
			s.push('name="');
			s.push(rel.getFieldName(type, 'del', index, subindex));
			s.push('" value="1" ');
			s.push('title="Tick this checkbox to delete this relationship" /></td>');
			s.push('<td valign="top" width="18">');
			s.push('<a href="#" title="Toggle Relationship Editor" ');
			s.push('onClick="return rse.onToggleEditorClicked(');
			s.push(ae.toParamStrings([type, index, subindex]));
			s.push(');" />');
			s.push('<img src="/images/es/edit.gif" border="0" alt="Edit this relationship">');
			s.push('</a></td>');
			s.push('<td valign="top" width="18" id="');
			s.push(ae.getFieldId(type, 'entityicon', index, subindex));
			s.push('">');
			s.push(ae.getEntityTypeIcon(rel.getEntityType()));
			s.push('</td>');
			s.push('<td id="');
			s.push(ae.getFieldId(type, 'rel', index, subindex));
			s.push('">');
			s.push(rel.getEditState()
				? this.getEditUI(type, rel, index, subindex)
				: this.getDisplayUI(type, rel, index, subindex));
			s.push('</td>');
			if (!inneronly) {
				s.push('</tr>');
			}
			retval = s.join("");
		}
		mb.log.exit();
		return retval;
	};

	// returns the normal (un-editable) interface for a relationship
	this.getDisplayUI = function(type, rel, index, subindex) {
		mb.log.enter(this.GID, "getDisplayUI");
		// update state of the relationship
		var s = [];
		s.push('<a target="_blank" href="/show');
		s.push(rel.getEntityType().toLowerCase());
		s.push('.html?');
		s.push(rel.getEntityType().toLowerCase());
		s.push('id=');
		s.push(rel.getEntityId());
		s.push('">');
		s.push(rel.getEntityName());
		s.push('</a>');
		s.push(' - ');
		s.push(rel.getDisplayPhrase());
		s.push('<span style="display: none">');
		s.push(rel.getDisplayHiddenFields(type, index, subindex));
		s.push('</span>');
		mb.log.exit();
		return s.join("");
	};

	// returns the editable interface for a relationship
	this.getEditUI = function(type, rel, index, subindex, attronly) {
		if (attronly == null) attronly = false;
		mb.log.enter(this.GID, "getEditUI");
		var rt, j;
		var s = [];
 		if ((rt = rel.getType()) != null) {
			if (!attronly) {
				s.push('<table border="0" cellspacing="0" cellpadding="0">');
				s.push('<tr valign="top">');
				var hastype = rel.getEntityType() != null;
				var name = rel.getEntityName();
				if (!hastype) {
					s.push('<td nowrap>');
					s.push('<select id="');
					s.push(ae.getFieldId(type, 'entitytype', index, subindex));
					s.push('">');
					for (j=0; j<this.linkable_entities.length; j++) {
						var typej = this.linkable_entities[j];
						s.push('<option value="'+typej+'">');
						s.push(typej);
						s.push('</option>');
					}
					s.push('</select>');
					s.push('</td><td>');
					s.push('<input type="text" id="');
					s.push(ae.getFieldId(type, 'entityquery', index, subindex));
					s.push('" class="entityfield" value="" />');
					s.push('</td><td>');
					s.push('<input type="button" value="Lookup" onClick="ae.onLookupClicked('+ae.toParamStrings([type, index, subindex])+');" />');
					s.push('</td>');
					s.push('<td class="entitywarning" id="');
					s.push(ae.getFieldId(type, 'entitywarning', index, subindex));
					s.push('" nowrap>');
				}
				if (hastype) {
					s.push('<td nowrap>');
					s.push('<a target="_blank" href="/show');
					s.push(rel.getEntityType().toLowerCase());
					s.push('.html?');
					s.push(rel.getEntityType().toLowerCase());
					s.push('id=');
					s.push(rel.getEntityId());
					s.push('">');
					s.push(rel.getEntityName());
					s.push('</a> &nbsp;');
					s.push('</td><td>');
					s.push('<select name="');
					s.push(rel.getFieldName(type, "typeid", index, subindex));
					s.push('" id="');
					s.push(ae.getFieldId(type, "newtype", index, subindex));
					s.push('" onChange="rse.onRelTypeChanged(this)" onKeyUp="rse.onRelTypeChanged(this)">');
					for (j=0; j<rel_types.list.length; j++) {
						var rtj = rel_types[j];
						s.push('<option value="'+j+'"');
						if (j == rel.getTypeId()) s.push(" selected ");
						s.push('>');
						s.push("           ".substring(0, rtj.indent).replace(/ /g, "&nbsp;&nbsp;"));
						s.push(rtj.phrase);
						s.push('</option>');
					}
					s.push('</select>');
				}
				s.push('</td>');
				s.push('</tr>');
				s.push('</table>');
			}

			var hasattr = rt.attr;
			s.push('<div id="');
			s.push(ae.getFieldId(type, 'rel_attr', index, subindex));
			s.push('">');
			if (hasattr != "") {
				s.push('<table border="0" cellspacing="0" cellpadding="0" style="margin-bottom: 4px"><tr valign="top">');
				// use the attributes list of the relationship type
				// to get the list of available attributes for this type.
				var arr = hasattr.split(" ");
				var attrhash = [];
				var attr, id;
				for (j=arr.length-1; j>=0; j--) {
					name = arr[j].split("=")[0];
					// use hashes (by name) in the rel_attrs hash to get the
					// id of the attribute (e.g. "vocal": 3)
					if ((id = rel_attrs[name]) != null) {
						if ((attr = rel_attrs[id]) != null) {
							attrhash[id] = attr;
						} else {
							mb.log.error("Did not find an attribute type with id: "+id);
						}
					} else {
						mb.log.error("Did not find an attribute type with name: "+name);
					}
				}

				// loop through the "displayorder" list of the rel_attrs
				// array to maintain the correct display order. The attributes
				// which are not available for this relationship type are
				// skipped.
				var order = rel_attrs["displayorder"];
				for (j=0; j < order.length-1; j++) {
					id = order[j];
					if ((attr = attrhash[id]) != null) {
						var value = rel.getAttribute(name);
						s.push('<tr>');

						// 1st column: if there are no children, then it's a checkbox :-)
						s.push('<td>');
						if (!attr.children) {
							s.push('<input type="checkbox" class="checkbox" name="" value="1" ');
							if (mb.ua.ie) {
								s.push('style="margin-top: -3px; margin-left: -3px; margin-right: 1px;"');
							}
							if (value) { s.push(' checked="checked" '); }
							s.push(' />');
						}
						s.push('</td>');

						// 2nd column: help icon
						s.push('<td><a href="');
						s.push(rel_attrs_help[attr.name]
								? "http://wiki.musicbrainz.org/"+rel_attrs_help[attr.name]
								: "#");
						s.push('" onmouseover="overlib(\'');
						s.push(attr.desc.replace(/&#39;/g, ""));
						s.push('\')" onmouseout="nd()" target="_blank">');
						s.push('<img src="/images/es/help.gif" border="0" alt="" /></a></td>');
						s.push('<td width="100%" valign="top">');

						// 3rd column: draw dropdown if there are children, or write the name
						// of the attribute
						if (attr.children) {
							var list = attr.children.list;
							if (!value) value = [0];

							for (var vi=0; vi < value.length; vi++) {
								var selectedname = value[vi];
								s.push('<select>');
								for (var li = 0; li < list.length; li++) {
									var childid = list[li];
									var child = attr.children[childid];
									s.push('<option value="'+li+'"');
									if (selectedname == child.name) {
										s.push(" selected ");
									}
									s.push('>');
									s.push("           ".substring(0, child.indent).replace(/ /g, "&nbsp;&nbsp;"));
									s.push(child.name);
									s.push('&nbsp;&nbsp;');
									s.push('</option>');
								}
								s.push('</select>');
							}
						} else {
							s.push(attr.name);
						}
						s.push('</td>');
						s.push('</tr>');
					}
				}
				s.push('</table>');
			}
			s.push('</div>');
			s.push('<span style="display: none">');
			s.push(rel.getEditHiddenFields(type, index, subindex));
			s.push('</span>');
		} else {
			mb.log.error("RelationShipType id: $ not found!", rel.getTypeId());
		}
		mb.log.exit();
		return s.join("");
	};
}
var rse = new RelationShipsEditor();
