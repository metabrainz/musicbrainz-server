MusicBrainz.TagApply = function()
{
	this.initialise = function()
	{
		var tag= $("tag");
		if (!tag)
			return;
		connect(tag, "onclick", this, this.loadForm);
	};
	
	this.loadForm = function(ev)
	{
		ev.stop();
		var tag= $("tag");
		var t = tag.className.split("::");
		var entitytype = t[0];
		var entityid = t[1];

		var tag = $("rawtags");
		var tags = tag.value;

		disconnectAll(tag);
		replaceChildNodes("toptags",
		    DIV({"class": "ajaxSelectLoading", "style": "display: inline;"},
			IMG({"src": "/images/loading-small.gif"}),
			" Loading..."
		    )
		);
		
		var url = "/show/tag/applytags.html?entitytype=" + entitytype + "&entityid=" + entityid +
		          "&tags=" + encodeURI(tags);
		var d = loadJSONDoc(url);
		d.addCallback(bind(this.showForm, this, entitytype, entityid));
		d.addErrback(bind(this.showError, this, entitytype, entityid));
		return false;
	}

	this.showForm = function(entitytype, entityid, doc)
	{
		var tag= $("toptags");
		var tag_items = new Array();
		var num = 5; 
		if (doc.tags.length < 5)
		{
		    num = doc.tags.length;
		}
		for (var i = 0; i < num; i++) {
			 tag_items.push(A({'href': '/show/tag/?tag=' + doc.tags[i].name, 'title': doc.tags[i].name}, doc.tags[i].name)); 
			 tag_items.push(', ');
		}
		if (doc.tags.length > 5)
		{
		    tag_items.push(A({'href': '/show/' + entitytype + '/tags.html?id=' + entityid, 'title': 'See all tags'}, 'more ...')); 
		}
		else
		{
		    tag_items.pop();
		}

		replaceChildNodes(tag, tag_items);
	}

	this.showError = function(entitytype, entityid)
	{
		var tag= $("toptags");
		if (!tag)
		    return;
		replaceChildNodes(tag, 'Error: Tags could not be submitted.');
		connect(tag, "onclick", this, this.loadForm);
	}
};

var tagapply = new MusicBrainz.TagApply();
mb.registerPageLoadedAction(new MbEventAction("tagapply", "initialise", "Init tagapply"));
