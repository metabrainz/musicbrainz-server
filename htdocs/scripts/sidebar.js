mb.log.scopeStart("Configuring sidebar...");
mb.log.enter("sidebar.js", "__init");
if (mb.ui && mb.sidebar) {
	var obj;
	if ((obj = mb.ui.get("sidebar-togglecell")) != null) {
		obj.innerHTML = mb.sidebar.getUI();
	}
	mb.sidebar.init(); 
}
mb.log.exit();

