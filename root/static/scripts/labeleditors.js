MusicBrainz.InPlaceLabelEditors = function(labelPrefix, labelNamePrefix, labelOrigNamePrefix)
{

	this.labelPrefix = labelPrefix;
	this.labelOrigNamePrefix = labelOrigNamePrefix;
	this.labelNamePrefix = labelNamePrefix;

	this.setup = function()
	{
		var inputs = getElementsByTagAndClassName('input', 'labelname');
		for (var i = 0; i < inputs.length; i++) {
			var el = inputs[i];
			var id = el.name.substr(this.labelNamePrefix.length);
			if (document.getElementsByName(this.labelPrefix+id)[0].value) {
				this.makeLabelLink(id);
				var button = IMG({'src': '/images/release_editor/edit-off.gif', 'id': 'labeleditimg' + id});
				connect(button, 'onclick', this, partial(this.editLabel, id));
				replaceChildNodes($("labelcheckbox" + id),
					button,
					INPUT({'type': 'hidden', 'value': '0', 'id': 'labeledit' + id}));
			}
			else {
				jsselect.registerAjaxSelect(el, "label", partial(this.setLabel, id), this);
				var button = IMG({'src': '/images/release_editor/edit-on.gif', 'id': 'labeleditimg' + id});
				connect(button, 'onclick', this, partial(this.editLabel, id));
				replaceChildNodes($("labelcheckbox" + id),
					button,
					INPUT({'type': 'hidden', 'value': '1', 'id': 'labeledit' + id}));
			}
		}
	}

	this.editLabel = function(id, event)
	{
		var edit = $('labeledit'+id);
		if (edit.value == '0') {
			$('labeleditimg'+id).src = '/images/release_editor/edit-on.gif';
			edit.value = '1';
			var input = INPUT({
				'type': 'text',
				'name': this.labelNamePrefix+id,
				'class': 'shorttxtfield labelname',
				'size': '15',
				'maxlength': '255',
				'value': document.getElementsByName(this.labelNamePrefix+id)[0].value
			});
			jsselect.registerAjaxSelect(input, 'label', partial(this.setLabel, id), this);
			replaceChildNodes($('labelinput'+id), input);
		}
		else if (document.getElementsByName(this.labelPrefix+id)[0].value) {
			document.getElementsByName(this.labelNamePrefix+id)[0].value = document.getElementsByName(this.labelOrigNamePrefix+id)[0].value;
			this.makeLabelLink(id);
			$('labeleditimg'+id).src = '/images/release_editor/edit-off.gif';
			edit.value = '0';
		}
	}

	this.makeLabelLink = function(id, entityid, name)
	{
		if (!name)
			name = document.getElementsByName(this.labelNamePrefix+id)[0].value;
		if (!entityid)
			entityid = document.getElementsByName(this.labelPrefix+id)[0].value;
		var s = [];
		s.push('<input type="hidden" name="'+this.labelNamePrefix+id+'" value="'+name+'" />');
		s.push(mb.ui.getLabelLink(entityid, name));
		$('labelinput'+id).innerHTML = s.join("");
	}

	this.setLabel = function(id, entity)
	{
		document.getElementsByName(this.labelPrefix+id)[0].value = entity.id;
		document.getElementsByName(this.labelNamePrefix+id)[0].value = entity.name;
		document.getElementsByName(this.labelOrigNamePrefix+id)[0].value = entity.name;
		this.makeLabelLink(id, entity.id, entity.name);
		$('labeleditimg'+id).src = '/images/release_editor/edit-off.gif';
		$('labeledit'+id).value = '0';
	}

}
