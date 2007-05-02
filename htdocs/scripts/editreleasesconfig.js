getLabelLink = function(id, name, resolution) {
	resolution = (resolution  != null ? resolution : "");
	var s = [];
	s.push(this.getEntityLink('label', id, name));
	if (!mb.utils.isNullOrEmpty(resolution)) {
		s.push(' (');
		s.push(resolution);
		s.push(')');
	}
	return s.join("");
};

getEntityLink = function(type, id, name) {
	s = [];
	type = type.toLowerCase();
	s.push('<span class="link'+type+'-icon" title="'+name+'">');
	s.push('<a href="/show/');
	s.push(type);
	s.push('/?');
	s.push(type);
	s.push('id=');
	s.push(id);
	s.push('" class="linkentity-strong">');
	s.push(name);
	s.push('</a>');
	s.push('</span>');
	return s.join("");
};

function ReleaseEventEditor()
{

	this.CN = "ReleaseEventEditor";
	this.GID = "releaseeventeditor";

	this.initialise = function()
	{
		var inputs = getElementsByTagAndClassName('input', 'labelname');
		for (var i = 0; i < inputs.length; i++) {
			var el = inputs[i];
			var id = el.name.substr(9);
			if (document.getElementsByName('label'+id)[0].value) {
				this.makeLabelLink(id);
				var button = IMG({'src': '/images/release_editor/edit-off.gif', 'id': 'labeleditimg' + id});
				connect(button, 'onclick', this, partial(this.editLabel, id));
				replaceChildNodes($("labelcheckbox" + id),
	   				button,
	   				INPUT({'type': 'hidden', 'value': '0', 'id': 'labeledit' + id}));
			}
			else {
				jsselect.registerAjaxSelect(el, 'label', partial(this.setLabel, id));
				var button = IMG({'src': '/images/release_editor/edit-on.gif', 'id': 'labeleditimg' + id});
				connect(button, 'onclick', this, partial(this.editLabel, id));
				replaceChildNodes($("labelcheckbox" + id),
	   				button,
	   				INPUT({'type': 'hidden', 'value': '1', 'id': 'labeledit' + id}));
			}
		}
	};

	this.editLabel = function(id, event)
	{
		var edit = $('labeledit'+id);
		if (edit.value == '0') {
			$('labeleditimg'+id).src = '/images/release_editor/edit-on.gif';
			edit.value = '1';
			var input = INPUT({
				'type': 'text',
				'name': 'labelname'+id,
				'class': 'shorttxtfield labelname',
				'size': '15',
				'maxlength': '255',
				'value': document.getElementsByName('labelname'+id)[0].value,
			});
			jsselect.registerAjaxSelect(input, 'label', partial(this.setLabel, id));
			replaceChildNodes($('labelinput'+id), input);
		}
		else if (document.getElementsByName('label'+id)[0].value) {
			releaseeventeditor.makeLabelLink(id);
			$('labeleditimg'+id).src = '/images/release_editor/edit-off.gif';
			edit.value = '0';
		}
	}

	this.makeLabelLink = function(id, name)
	{
		if (!name)
			name = document.getElementsByName('labelname'+id)[0].value;
		var s = [];
		s.push('<input type="hidden" name="labelname'+id+'" value="'+name+'" />');
		s.push(getLabelLink(id, name));
		$('labelinput'+id).innerHTML = s.join("");
	}

	this.setLabel = function(id, entity)
	{
		document.getElementsByName('label'+id)[0].value = entity.id;
		document.getElementsByName('labelname'+id)[0].value = entity.name;
		document.getElementsByName('orig_labelname'+id)[0].value = entity.name;
		releaseeventeditor.makeLabelLink(id, entity.name);
		$('labeleditimg'+id).src = '/images/release_editor/edit-off.gif';
		$('labeledit'+id).value = '0';
	}
	
};

var releaseeventeditor = new ReleaseEventEditor();
mb.registerPageLoadedAction(new MbEventAction("releaseeventeditor", "initialise", "Init release event editor"));
