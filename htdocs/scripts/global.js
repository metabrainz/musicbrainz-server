/* arrayprototype.js
 * by Peter Belesis. v1.0 000516
 * Copyright (c) 2000 Peter Belesis. All Rights Reserved.
 * Originally published and documented at http://www.dhtmlab.com/
 * License to use is granted if and only if this entire copyright notice
 * is included.
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */
if (Array.prototype.push && ([0].push(true)==true)) Array.prototype.push = null;
if (Array.prototype.splice && typeof([0].splice(0)) == "number") Array.prototype.splice = null;
if(!Array.prototype.shift) {
	Array.prototype.shift = function() {
		firstElement = this[0];
		this.reverse();
		this.length = Math.max(this.length-1,0);
		this.reverse();
		return firstElement;
	};
}
if(!Array.prototype.unshift) {
	Array.prototype.unshift = function() {
		this.reverse();
		for(var i=arguments.length-1;i>=0;i--) {
			this[this.length] = arguments[i];
		}
		this.reverse();
		return this.length;
	};
}
if(!Array.prototype.push) {
	Array.prototype.push = function() {
		for (var i=0;i<arguments.length;i++) {
			this[this.length] = arguments[i];
		};
		return this.length;
	};
}
if(!Array.prototype.pop) {
	Array.prototype.pop = function() {
	    lastElement = this[this.length-1];
		this.length = Math.max(this.length-1,0);
	    return lastElement;
	};
}
if(!Array.prototype.splice) {
	Array.prototype.splice = function(ind,cnt){
        if (arguments.length == 0) return ind;
        if (typeof ind != "number") ind = 0;
        if (ind < 0) ind = Math.max(0,this.length + ind);
        if (ind > this.length) {
            if (arguments.length > 2) {
           		ind = this.length;
            } else {
            	return [];
            }
        }
        if (arguments.length < 2) {
       		cnt = this.length-ind;
       	}
        cnt = (typeof cnt == "number") ? Math.max(0,cnt) : 0;
        removeArray = this.slice(ind, ind+cnt);
        endArray = this.slice(ind+cnt);
        this.length = ind;
        var i;
        for (i=2;i<arguments.length;i++) {
            this[this.length] = arguments[i];
        }
        for (i=0;i<endArray.length;i++) {
            this[this.length] = endArray[i];
        }
        return removeArray;
    };
}



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
// @param 		[lifetime]  Number of days the cookie expires (null: end of current session)
// @param 		[path]     	Path where the cookie is valid (default: "/")
// @param 		[domain]   	Domain where the cookie is valid
//            				(default: domain of calling document)
// @param 		[secure]   	Boolean value indicating if the cookie
//							transmission requires a	secure transmission
function setCookie(name, value, lifetime, path, domain, secure) {
	if (path == null) path = "/";
    var expires = null;
	if (lifetime) {
		var endtimeMillis = new Date().getTime();
		endtimeMillis += parseInt(lifetime)*24*60*60*1000;
		expires = new Date(endtimeMillis);
	}
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


// ----------------------------------------------------------------------------
// userAgent()
//
// stores most important user agent types into
// the ua object.
function userAgent() {
    var id = navigator.userAgent.toLowerCase();
    this.major = stringToNumber(navigator.appVersion);
    this.minor = parseFloat(navigator.appVersion);
    this.nav  = (
      			 (id.indexOf('mozilla') != -1) && 
      			 (
      			  (id.indexOf('spoofer')==-1) && 
      			  (id.indexOf('compatible') == -1)
      			 )
      			);

    this.nav2 = (this.nav && (this.major == 2));
    this.nav3 = (this.nav && (this.major == 3));
    this.nav4 = (this.nav && (this.major == 4));
	
	this.nav5 =	(this.nav && (this.major == 5));
	this.nav6 = (this.nav && (this.major == 5));
	this.gecko = (this.nav && (this.major >= 5));

    this.ie   = (id.indexOf("msie") != -1);
    this.ie3  = (this.ie && (this.major == 2));
    this.ie4  = (this.ie && (this.major == 3));
    this.ie5  = (this.ie && (this.major == 4));

    this.opera = (id.indexOf("opera") != -1);
    this.nav4up = this.nav && (this.major >= 4);
    this.ie4up  = this.ie  && (this.major >= 4);
}
var ua = new userAgent();

// getElementPageTop() --
// because of different dom implementations
// this is needed to get the exact pixel
// location of an element
function getElementPageTop(el) {
	var y = 0;
	if (ua.nav4) return el.pageY;
	if (ua.ie4up) {
		while (el.offsetParent != null) {
			y += el.offsetTop;
			el = el.offsetParent;
		}
		y += el.offsetTop;
		return y;
	}
	if (ua.mac && ua.ie5) {
		return stringToNumber(document.body.currentStyle.marginTop);
	}
	if (ua.gecko) {
		while (el.offsetParent != null) {
			y += el.offsetTop;
			el = el.offsetParent;
		}
		y += el.offsetTop;
		return y;							    
	}
	return -1;
}

// getElementLeft() --
function getElementLeft(el) {
	if (ua.nav4) return (el.left);
	else if (ua.ie4up) return (el.style.pixelLeft);
	else if (ua.gecko) return stringToNumber(el.style.left);
}


// stringToNumber() --
// A version of parseInt that returns 0 if there is 
// NaN returned, or number is part of a string, like 100px.
function stringToNumber(s) {
	return parseInt(("0" + s), 10);
}


// eof
