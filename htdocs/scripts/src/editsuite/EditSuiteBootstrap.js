/**
 * Load, and write the EditSuite UI
 *
 * @globals es, gc	sets the global variables
 *					es=EditSuite
 *					gc=GuessCase
 **/

mb.log.scopeStart("Loading the EditSuite object");
mb.log.enter("editsuite.js", "__init");
try {
	new EditSuite();
	var obj;
	if ((obj = mb.ui.get("editsuite-noscript")) != null) {
		obj.className = "";
		obj.innerHTML = es.cfg.getConfigureLinkHtml();
	}
	if ((obj = mb.ui.get("editsuite-content")) != null) {
		es.ui.writeUI(obj, null);
	}
} catch (ex) {
	mb.log.error("Error while initalising EditSuite! ex: $", (ex.message || "?"));
	mb.log.error(mb.log.getStackTrace());
	es = null;
	gc = null;
}

// exit method.
mb.log.exit();


