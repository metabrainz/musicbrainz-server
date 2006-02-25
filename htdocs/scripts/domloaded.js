// setup onDomReady for internet exploder
mb.log.scopeStart("Registering DOMContentLoaded callback...");
mb.log.enter("domloaded.js", "__init");

if (document.readyState) {
	mb.log.trace("IE » using document.readyState");
	var s = document.readyState;
	var READYSTATE_INTERACTIVE = "interactive"
	var READYSTATE_COMPLETE = "complete";
	if (s == READYSTATE_INTERACTIVE || s == READYSTATE_COMPLETE) {
		mb.onDomReady();
	} else {
		document.onreadystatechange = function() {
			if (document.readyState == READYSTATE_INTERACTIVE) {
				mb.onDomReady();
			}
		};
	}
}

// for mozilla browser, register DOM loaded event
if (document.addEventListener) {
	document.addEventListener("DOMContentLoaded", mb.onDomReady, null);
	mb.log.trace("Gecko » using document.addEventListener");
}
mb.log.exit();
