////////////////////////////////////////////////////////////////////////////////

var OnLoadActions = [];

function AddOnLoadAction(func) {
	OnLoadActions[OnLoadActions.length] = func;
}

function OnPageLoad() {
	for (var i=0; i<OnLoadActions.length; ++i)
	{
		var f = OnLoadActions[i];
		f();
	}
}

////////////////////////////////////////////////////////////////////////////////

// ----------------------------------------------------------------------------
// setCookie()
// -- Sets a Cookie with the given name and value.
// @param 		name       	Name of the cookie
// @param 		value      	Value of the cookie
// @param 		[expires]  	Expiration date of the cookie (default: end of current session)
// @param 		[path]     	Path where the cookie is valid (default: "/")
// @param 		[domain]   	Domain where the cookie is valid
//            				(default: domain of calling document)
// @param 		[secure]   	Boolean value indicating if the cookie
//							transmission requires a	secure transmission
function setCookie(name, value, expires, path, domain, secure) {
	if (path == null) path = "/";
	document.cookie= name + "=" + escape(value) +
		((expires) ? "; expires=" + expires.toGMTString() : "") +
		((path) ? "; path=" + path : "") +
		((domain) ? "; domain=" + domain : "") +
		((secure) ? "; secure" : "");
}

// ----------------------------------------------------------------------------
// getCookie()
// -- Gets the value of the specified cookie.
// @param 		name  		Name of the desired cookie.
// @returns 				a string containing value of specified cookie,
// 							or null if cookie does not exist.
function getCookie(name) {
	var dc = document.cookie;
	var prefix = name + "=";
	var begin = dc.indexOf("; " + prefix);
	if (begin == -1) {
		begin = dc.indexOf(prefix);
		if (begin != 0) return null;
	} else begin += 2;
	var end = document.cookie.indexOf(";", begin);
	if (end == -1) end = dc.length;
	return unescape(dc.substring(begin + prefix.length, end));
}

// ----------------------------------------------------------------------------
// deleteCookie()
// -- Deletes the specified cookie.
// @param 		name      	name of the cookie
// @param 		[path]    	path of the cookie (must be same as path
//							used to create cookie)
// @param 		[domain]  	domain of the cookie (must be same as domain
// 							used to create cookie)
function deleteCookie(name, path, domain) {
	if (getCookie(name)) {
		document.cookie = name + "=" +
			((path) ? "; path=" + path : "") +
			((domain) ? "; domain=" + domain : "") +
			"; expires=Thu, 01-Jan-70 00:00:01 GMT";
	}
}

////////////////////////////////////////////////////////////////////////////////

// The purpose of this code is to resize Amazon cover art so that, if
// possible, it isn't scaled (it's displayed at its "natural" size).

function unscale_amazon_image(i)
{
	// Firefox provides naturalWidth/naturalHeight, which tells
	// us how many pixels wide/high the image actually is.
	var w = i.naturalWidth;
	var h = i.naturalHeight;
	if (!w || !h) return;

	// This is the maximum size we'll allow the image to occupy
	var max_w = 200;
	var max_h = 200;

	// If the image is too large, scale it down
	if (w>max_w || h>max_h)
	{
		var scale_w = w/max_w;
		var scale_h = h/max_h;
		if (scale_w > scale_h) { w /= scale_w; h /= scale_w }
		else                   { w /= scale_h; h /= scale_h }
	}

	// Set the image to be exactly whatever size we chose
	i.width = w;
	i.height = h;

	// Adjust the margin-right of the div which is next to this floating
	// image
	var div = find_coverart_div(i);
	if (div) {
		div.style.marginRight = "" + (w+10) + "px";
	}
}

function find_coverart_div(i)
{
	var tr = i.parentNode.nextSibling;
	return(tr);
}

// Called by onload
function scale_coverart()
{
	var ims = document.images;
	for (var i=0; i<ims.length; ++i)
	{
		var img = ims[i];
		if (img.className != 'amazon_coverart') continue;
		if (img.complete) unscale_amazon_image(img);
	}
}
AddOnLoadAction(scale_coverart);

// eof
