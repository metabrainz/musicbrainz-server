/* @author Edward Hieatt, edward@jsunit.net */


// document me!
// ----------------------------------------------------------------------------
function jsUnitTestSuite() {
	this.isjsUnitTestSuite = true;
	this.testPages = Array();
	this.pageIndex = 0;
}

// document me!
// ----------------------------------------------------------------------------
jsUnitTestSuite.prototype.addTestPage = function (pageName)	{
	this.testPages[this.testPages.length] = pageName;
}

// document me!
// ----------------------------------------------------------------------------
jsUnitTestSuite.prototype.addTestSuite = function (suite)	{
	for (var i = 0; i < suite.testPages.length; i++)
		this.addTestPage(suite.testPages[i]);
}

// document me!
// ----------------------------------------------------------------------------
jsUnitTestSuite.prototype.containsTestPages = function ()	{
	return this.testPages.length > 0;
}

// document me!
// ----------------------------------------------------------------------------
jsUnitTestSuite.prototype.nextPage = function ()	{
	return this.testPages[this.pageIndex++];
}

// document me!
// ----------------------------------------------------------------------------
jsUnitTestSuite.prototype.hasMorePages = function ()	{
	return this.pageIndex < this.testPages.length;
}

// document me!
// ----------------------------------------------------------------------------
jsUnitTestSuite.prototype.clone = function () {
	var clone = new jsUnitTestSuite();
	clone.testPages = this.testPages;
	return clone;
}

//if (xbDEBUG.on) {
//	xbDebugTraceObject('window', 'jsUnitTestSuite');
//}
