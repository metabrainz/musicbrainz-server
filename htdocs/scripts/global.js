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

////////////////////////////////////////////////////////////////////////////////
