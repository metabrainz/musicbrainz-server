MusicBrainz.LangSelect = function()
{

	this.initialise = function()
	{
		connect('toggle_lang_lists', 'onclick', this, this.reloadOptions);
	};
	
	this.reloadOptions = function(ev)
	{
		var sel;
		sel = $('id_script_new');
		var script_curr = sel.options[sel.selectedIndex].value;
		sel = $('id_language_new');
		var language_curr = sel.options[sel.selectedIndex].value;
		var expand_lists = 1 - document.getElementsByName('expand_lists')[0].value;
		var d = loadJSONDoc('/edit/albumlanguage/getlists.html?expand_lists='+expand_lists+'&language_curr='+language_curr+'&script_curr='+script_curr);
		d.addCallback(this.fillOptions);
		ev.stop();
		return false;
	};

	this.fillOptions = function(doc)
	{
		var sel, curr, i;
		
		sel = $('id_script_new');
		curr = sel.options[sel.selectedIndex].value;
		sel.options.length = 0;
		for (i = 0; i < doc.scripts.length; i++) {
			var opt = OPTION({value: doc.scripts[i][0]}, doc.scripts[i][1]);
			if (doc.scripts[i][0] == curr) {
				opt.selected = 'selected';
			}
			sel.appendChild(opt);
		}

		sel = $('id_language_new');
		curr = sel.options[sel.selectedIndex].value;
		sel.options.length = 0;
		for (i = 0; i < doc.languages.length; i++) {
			var opt = OPTION({value: doc.languages[i][0]}, doc.languages[i][1]);
			if (doc.languages[i][0] == curr) {
				opt.selected = 'selected';
			}
			sel.appendChild(opt);
		}

		$('toggle_lang_lists').value = doc.expand_lists ? 'Show reduced lists' : 'Show full lists';
		document.getElementsByName('expand_lists')[0].value = doc.expand_lists;
	}
	
}

var langselect = new MusicBrainz.LangSelect();
mb.registerDOMReadyAction(new MbEventAction("langselect", "initialise", "Init MusicBrainz.LangSelect"));
