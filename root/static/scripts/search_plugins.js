function addSearchEngine(name, icon, cat)
{
    if (window.external && ("AddSearchProvider" in window.external))
    {
	// Firefox 2 and IE 7, OpenSearch
	window.external.AddSearchProvider("http://musicbrainz.org/static/search/plugins/opensearch/"+name+".xml");
    }
    else if ((typeof window.sidebar == "object") &&
	     (typeof window.sidebar.addSearchEngine == "function"))
    {
	// Firefox <= 1.5, Sherlock
	window.sidebar.addSearchEngine(
	    "http://musicbrainz.org/static/search/plugins/firefox/" + name + ".src",
	    "http://musicbrainz.org/static/images/" + icon,
	    name,
	    cat
	);
    }
    else
    {
        alert("Sorry, your browser does not support search plugins");
    }
}
