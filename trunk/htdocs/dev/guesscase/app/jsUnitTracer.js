/* @author Edward Hieatt, edward@jsunit.net */

// document me!
// ----------------------------------------------------------------------------
function jsUnitTracer() {
	this._traceWindow = null;
	this.TRACE_LEVEL_WARNING = 1;
	this.TRACE_LEVEL_INFO = 2;
	this.TRACE_LEVEL_DEBUG = 3;
	this.popupWindowsBlocked = false;
}

// document me!
// ----------------------------------------------------------------------------
jsUnitTracer.prototype.initialize = function () {
	if (this._traceWindow != null && top.testManager.closeTraceWindowOnNewRun.checked)
		this._traceWindow.close();
	this._traceWindow = null;
}

// document me!
// ----------------------------------------------------------------------------
jsUnitTracer.prototype.finalize = function () {
	if (this._traceWindow!=null) {
		this._traceWindow.document.write('<\/body>\n<\/html>');
		this._traceWindow.document.close();
	}
}

// document me!
// ----------------------------------------------------------------------------
jsUnitTracer.prototype.warn = function () {
	this._trace(arguments[0], arguments[1], this.TRACE_LEVEL_WARNING);
}

// document me!
// ----------------------------------------------------------------------------
jsUnitTracer.prototype.inform = function () {
	this._trace(arguments[0], arguments[1], this.TRACE_LEVEL_INFO);
}

// document me!
// ----------------------------------------------------------------------------
jsUnitTracer.prototype.debug = function () {
	this._trace(arguments[0], arguments[1], this.TRACE_LEVEL_DEBUG);
}

// document me!
// ----------------------------------------------------------------------------
jsUnitTracer.prototype._trace = function (message, value, traceLevel) {
	if (this._getChosenTraceLevel() >= traceLevel) {
		var traceString = message;
		if (value)
			traceString += ': ' + value;
		this._writeToTraceWindow(traceString, traceLevel);
	}
}

// document me!
// ----------------------------------------------------------------------------
jsUnitTracer.prototype._getChosenTraceLevel = function () {
	return eval(top.testManager.traceLevel.value);
}

// document me!
// ----------------------------------------------------------------------------
jsUnitTracer.prototype._writeToTraceWindow = function (traceString, traceLevel) {
	var htmlToAppend = '<p class="jsUnitDefault">' + traceString + '<\/p>\n';
	this._getTraceWindow().document.write(htmlToAppend);
}

// document me!
// ----------------------------------------------------------------------------
jsUnitTracer.prototype._getTraceWindow = function () {
	if (this._traceWindow == null && !this.popupWindowsBlocked) {
		this._traceWindow = window.open('','','width=800, height=350,status=no,resizable=yes,scrollbars=yes');
		if (!this._traceWindow) {
			this.popupWindowsBlocked = true;
		}
		else {
			var resDoc = this._traceWindow.document;
			resDoc.write('<html>\n<head>\n<link rel="stylesheet" href="css/jsUnitStyle.css">\n<link rel="stylesheet" href="css/sandbox.css">\n<title>Tracing - JsUnit<\/title>\n<head>\n<body>');
			resDoc.write('<h2>Test results<\/h2>\n');
		}
	}
	return this._traceWindow;
}

//if (xbDEBUG.on) {
//	xbDebugTraceObject('window', 'jsUnitTracer');
//}
