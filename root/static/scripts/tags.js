MusicBrainz.TagsEditor = function()
{

	this.initialise = function()
	{
		var tagthis = $("tagthis");
		if (!tagthis)
			return;
		connect(tagthis, "onclick", this, this.loadForm);
	};
	
	this.loadForm = function(ev)
	{
		ev.stop();
		var tagthis = $("tagthis");
		var t = tagthis.className.split("::");
		var entitytype = t[0];
		var entityid = t[1];

		disconnectAll(tagthis);
		replaceChildNodes("tagform",
			DIV({"class": "ajaxSelectLoading"},
				IMG({"src": "/images/loading-small.gif"}),
				" Loading..."
			)
		);
		
		var url = "/show/tag/rawtags.html?entitytype=" + entitytype + "&entityid=" + entityid;
		var d = loadJSONDoc(url);
		d.addCallback(bind(this.showForm, this, entitytype, entityid));
		d.addErrback(bind(this.showError, this, entitytype, entityid));
		return false;
	}

	this.showForm = function(entitytype, entityid, doc)
	{
		var tags = new Array();
		if (doc.tags.length) {
			for (var i = 0; i < doc.tags.length; i++) {
				tags.push(doc.tags[i].name);
			}
		}
		tags = tags.join(", ");
		replaceChildNodes("tagform",
			FORM({"action": "/show/"+entitytype+"/tags.html", "method": "post"},
				"Tag this "+entitytype+":", BR(),
				TEXTAREA({"name": "newtags", "rows": "4", "cols": "40"}, tags), BR(),
				'Tags are comma separated. Only word characters, space and - are allowed. See ',
				STRONG({}, IMG({'src': '/images/icon/wikidocs.gif', 'class': 'entityicon'}),
				           A({'href': '/doc/FolksonomyTaggingSyntax', 'title': 'Wiki page: FolksonomyTaggingSyntax'}, 'tag syntax')),
				' for details.', BR(),
				INPUT({"type": "submit", "value": "Tag"}),
				INPUT({"type": "hidden", "name": "update", "value": "1"}),
				INPUT({"type": "hidden", "name": "id", "value": entityid})
			)
		);
	}

	this.showError = function(entitytype, entityid)
	{
		var tagthis =
			A({"id": "tagthis", "class": entitytype+"::"+entityid, "href": "/show/"+entitytype+"/tags.html?id="+entityid+"&showform=1"},
				"Tag this "+entitytype);
		replaceChildNodes("tagform", P({}, tagthis), DIV({"class": "ajaxSelectLoading"}, "Error while loading the tag list."));
		connect(tagthis, "onclick", this, this.loadForm);
	}

};

var tagseditor = new MusicBrainz.TagsEditor();
mb.registerPageLoadedAction(new MbEventAction("tagseditor", "initialise", "Init tags editor"));
