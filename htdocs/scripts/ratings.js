MusicBrainz.RatingsUpdater = function()
{

	this.initialise = function()
	{
		var entities_to_rate = getElementsByTagAndClassName("ul", "star-rating");
		for (var i = 0; i < entities_to_rate.length; i++) {
			var links = entities_to_rate[i].getElementsByTagName("a");
			for (var j = 0; j < links.length; j++) {
				connect(links[j], "onclick", this, this.rate);
				//links[j].href = "#";
			}
		}
	};
	
	this.rate = function(ev)
	{
		ev.stop();
		var link = ev.target();
		var t = link.id.split("::");
		var entitytype = t[1];
		var entityid = t[2];
		var rating = t[3];

		var url = "/bare/rate.html?entity_type=" + entitytype + "&entity_id=" + entityid 
				+ "&rating=" + rating + "&json=1";
		var d = loadJSONDoc(url);
		d.addCallback(bind(this.updateRatingStars, this, entitytype, entityid));
		//d.addErrback(bind(this.showError, this, entitytype, entityid));
		return false;
	}

	this.updateRatingStars = function(entitytype, entityid, newRatingInfo)
	{
		// Global rating
		var rating = $("RATING::"+entitytype+"::"+entityid);
		rating.style.width = newRatingInfo.rating/5*100+'%';
		
		// Votes
		var totalVotes = $("VOTES-RATING::"+entitytype+"::"+entityid);
		if (totalVotes) {
			totalVotes.innerHTML = newRatingInfo.rating_count;
		}

		// User rating
		var userRating = $("USER-RATING::"+entitytype+"::"+entityid);
		if (userRating) {
			userRating.innerHTML = newRatingInfo.user_rating;
		}
	}

	this.showError = function(entitytype, entityid)
	{
		/*
		var tagthis =
			A({"id": "tagthis", "class": entitytype+"::"+entityid, "href": "/show/"+entitytype+"/tags.html?id="+entityid+"&showform=1"},
				"Tag this "+entitytype);
		replaceChildNodes("tagform", P({}, tagthis), DIV({"class": "ajaxSelectLoading"}, "Error while loading the tag list."));
		connect(tagthis, "onclick", this, this.loadForm);
		*/
	}

};

var ratingseditor = new MusicBrainz.RatingsUpdater();
mb.registerPageLoadedAction(new MbEventAction("ratingseditor", "initialise", "Init ratings editor"));
