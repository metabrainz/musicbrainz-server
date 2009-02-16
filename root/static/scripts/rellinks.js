function RelLinks()
{

	this.CN = "RelLinks";
	this.GID = "rellinks";

	this.initialise = function()
	{
		this.createButton = BUTTON(null, 'Create relationship');
		connect(this.createButton, 'onclick', this, this.create);

		cancelButton = BUTTON({}, 'Cancel');
		connect(cancelButton, 'onclick', this, this.cancel);

		this.typeSelect = SELECT(null,
			OPTION({'value': 'artist'}, 'Artist'),
			OPTION({'value': 'album'}, 'Release'),
			OPTION({'value': 'track'}, 'Track'),
			OPTION({'value': 'label'}, 'Label')
		);
		this.type1 = 'artist';
		connect(this.typeSelect, 'onchange', this, this.changeType);

		this.targetSelect = SELECT({},
			OPTION({'value': 'release'}, 'Release'),
			OPTION({'value': 'tracks'}, 'Tracks'));

		this.nameInput = INPUT({'style': 'width: 200px;'});
		this.ajaxSelectId = jsselect.registerAjaxSelect(this.nameInput, this.type1, function(e) { rellinks.setEntity(e) });

		/*this.titleDiv = DIV({'class': 'ajaxSelectTitle'}, 'Relate to …');*/
		this.popup = DIV({'style': 'display:none; position:absolute; z-index:100;', 'class': 'ajaxSelect'},
			/*this.titleDiv,*/
			DIV({'style': 'padding: 5px;'},
				this.typeSelect, ' ', this.nameInput),
			DIV({'class': 'ajaxSelectButtonBox'},
				this.targetSelect, ' ', this.createButton, ' ', cancelButton));
		insertSiblingNodesAfter('overDiv', this.popup);

		var spans = getElementsByTagAndClassName('span', 'RELATE_TO_LINK');
		for (var i = 0; i < spans.length; i++) {
			var span = spans[i];
			var d = span.id.split('::');
			var link = A({'href': '#'}, 'Relate to …');
			connect(link, 'onclick', this, partial(this.showPopup, d[1], d[2]));
			replaceChildNodes(span, ' | ', link);
		}

	};

	this.showPopup = function(id, type, event)
	{
		if (this.popup.style.display != "none") {
			this.cancel()
		}
		else {
			this.id0 = id;
			this.id1 = null;
			this.type0 = type;
			var element = event.src();
			var pos = getElementPosition(element);
			pos.y += getElementDimensions(element).h + 3;
			setElementPosition(this.popup, pos);
			setDisplayForElement(this.type0 == 'album' ? '' : 'none', this.targetSelect);
			showElement(this.popup);
			/*this.titleDiv.innerHTML = "Relate this " + (type == "album" ? "release" : type) + " to …"*/
			this.createButton.disabled = true;
		}
		event.stop();
		return false;
	};

	this.create = function(event)
	{
		if (this.type0 && this.type1 && this.id0 && this.id1) {
			var url = "/edit/relationship/add.html?";
			var usetracks = this.type0 == 'album' && this.targetSelect.selectedIndex == 1;
			if (this.type0 < this.type1) {
				url += "link0=" + this.type0 + "=" + this.id0 + "&link1=" + this.type1 + "=" + this.id1 + "&returnto=0";
				if (usetracks) {
					url += "&usetracks=0";
				}
			}
			else {
				url += "link0=" + this.type1 + "=" + this.id1 + "&link1=" + this.type0 + "=" + this.id0 + "&returnto=1";
				if (usetracks) {
					url += "&usetracks=1";
				}
			}
			window.location.href = url;
		}
	}

	this.cancel = function(event)
	{
		hideElement(this.popup);
	}

	this.setEntity = function(entity)
	{
		this.id1 = entity.id;
		this.nameInput.value = entity.name;
		this.createButton.disabled = false;
	}

	this.changeType = function(event)
	{
		var el = event.src();
		this.type1 = el.options[el.selectedIndex].value;
		jsselect.selects[this.ajaxSelectId].entitytype = this.type1;
	}

}

var rellinks = new RelLinks();
mb.registerDOMReadyAction(new MbEventAction("rellinks", "initialise", "Init RelLinks"));
