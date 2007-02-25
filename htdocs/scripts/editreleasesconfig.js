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
			jsselect.registerAjaxSelect(el, 'label', partial(function(id, entity) {
				document.getElementsByName('label' + id)[0].value = entity.id;
				document.getElementsByName('labelname' + id)[0].value = entity.name;
				document.getElementsByName('orig_labelname' + id)[0].value = entity.name;
			}, id));
		}
	};

};

var releaseeventeditor = new ReleaseEventEditor();
mb.registerPageLoadedAction(new MbEventAction("releaseeventeditor", "initialise", "Init release event editor"));
