MusicBrainz.ReleaseEventEditor = function()
{

	this.initialise = function()
	{
		this.labelEditors = new MusicBrainz.InPlaceLabelEditors("label", "labelname", "orig_labelname");
		this.labelEditors.setup();
	};

};

var releaseeventeditor = new MusicBrainz.ReleaseEventEditor();
mb.registerPageLoadedAction(new MbEventAction("releaseeventeditor", "initialise", "Init release event editor"));
