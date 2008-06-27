/*----------------------------------------------------------------------------\
|                              Musicbrainz.org                                |
|                 Copyright (c) 2005 Stefan Kestenholz (g0llum)               |
|-----------------------------------------------------------------------------|
| This software is provided "as is", without warranty of any kind, express or |
| implied, including  but not limited  to the warranties of  merchantability, |
| fitness for a particular purpose and noninfringement. In no event shall the |
| authors or  copyright  holders be  liable for any claim,  damages or  other |
| liability, whether  in an  action of  contract, tort  or otherwise, arising |
| from,  out of  or in  connection with  the software or  the  use  or  other |
| dealings in the software.                                                   |
| - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - |
| GPL - The GNU General Public License    http://www.gnu.org/licenses/gpl.txt |
| Permits anyone the right to use and modify the software without limitations |
| as long as proper  credits are given  and the original  and modified source |
| code are included. Requires  that the final product, software derivate from |
| the original  source or any  software  utilizing a GPL  component, such  as |
| this, is also licensed under the GPL license.                               |
\----------------------------------------------------------------------------*/


/**
 * TestCases class
 **/
function TestCases() {

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------
	this.namesList = [];
	this.functionsList = [];

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Adds a test with name tn, calleable function tn
	 * to this TestCases object.
	 */
	this.addTestCase = function(tn, tc) {
		if (tn && tc) {
			this.namesList.push(tn);
			this.functionsList.push(tc.toFunction(tn));
		}
	};

	/**
	 * Returns the list of test function names of this
	 * TestCases object.
	 */
	this.getFunctionNames = function() {
		return this.namesList;
	};

	/**
	 * Returns the list of test functions of this
	 * TestCases object.
	 */
	this.getFunctions = function() {
		return this.functionsList.join(" \n");
	};
}

/**
 * TestCase class
 **/
function TestCase(ex, io, oo) {

	// ----------------------------------------------------------------------------
	// member variables
	// ---------------------------------------------------------------------------
	this.expect = ex;
	this.input = io;
	this.output = oo;

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Returns a string representation of this TestCase
	 *
	 */
	this.toString = function() {
		var s = []; s.push("TestCase ['"); s.push(this.expect);
		s.push("','"); s.push(this.input); s.push("','");
		s.push(this.output); s.push("']");
		return s.join("");
	};

	/**
	 * Returns the Test as a registerable function.
	 *
	 */
	this.toFunction = function(name) {
		var s = []; s.push("function "); s.push(name);
		s.push("() {"); s.push(" runTest('"); s.push(name);
		s.push("', '"); s.push(this.expect.replace(/'/g, "\\'"));
		s.push("', '"); s.push(this.input.replace(/'/g, "\\'"));
		s.push("', '"); s.push(this.output.replace(/'/g, "\\'"));
		s.push("'); "); s.push("}");
		return s.join("");
	};
}

/**
 * The list of tests.
 **/
var DEFINED_TESTS = {

	// titleString
	"titlestring" : [
		  new TestCase("Expect Titled", "titledword", "Titledword")
		, new TestCase("Expect Titled", "the", "The")
		, new TestCase("Special case McTitled", "McDonalds", "McDonalds")
		, new TestCase("Special case MacTitled word", "MacNeill", "MacNeill")
		, new TestCase("Special case *not* MacTitled word", "Macceroni", "Macceroni")
	],

	// guessArtist function
	"artistname" : [
		  new TestCase("Expect exact", "my artist the name", "My Artist the Name")
		, new TestCase("Caps DJ, but title word", "Dj someDjname", "DJ Somedjname")
		, new TestCase("Caps DJ and MC, but title word", "Dj someDjname & Mc SomeMcName", "DJ Somedjname & MC Somemcname")

		// acronyms
		, new TestCase("Proper acronym", "A.B. Artistlastname", "A.B. Artistlastname")

		// contraction
		, new TestCase("Handle contractions",
			"we're ev'ry they'll 'round y'all it's they've 'til wat'cha 'em all he'd ev'rybody",
			"We're Ev'ry They'll 'round Y'all It's They've 'til Wat'cha 'em All He'd Ev'rybody")

	],

	// guessSortName function
	"sortname" : [
		  new TestCase("Expect titled", "Madonna", "Madonna")
		, new TestCase("Expect the moved to the end", "The Beatles", "Beatles, The")
		, new TestCase("Expect composite artist/group split", "Bob Marley and the Wailers", "Marley, Bob and Wailers, The")
		, new TestCase("Expect composite artist/artist split", "Geoff Allman and Beth Joiner", "Allman, Geoff and Joiner, Beth")
		, new TestCase("Expect DJ moved to the end", "DJ Ti�sto", "Ti�sto, DJ")
		, new TestCase("Expect Los moved to the end", "Los Lobos", "Lobos, Los")
		, new TestCase("Expect Dr. moved to the end", "Dr. Demento", "Demento, Dr.")
		, new TestCase("Expect Dr., First/Prename handling", "Dr. Harry Klein", "Klein, Harry, Dr.")
		, new TestCase("Expect Jr., First/Prename handling", "Harry Connick, Jr.", "Connick, Harry, Jr.")
		, new TestCase("Expect Sr., O'Titled handling", "Joe J O'Mally, Sr.", "O'Mally, Joe J, Sr.")
		, new TestCase("Expand St.->Saint? currently not", "Rebecca St. James", "St. James, Rebecca")
	],

	// guessAlbum function
	"albumname" : [
		// trim information to omit
		  new TestCase("Handle specialcase", "Untitled", "[untitled]")
		, new TestCase("TrimInformationToOmit", "Test Bonus", "Test")
		, new TestCase("Handle bonus disc", "Test Bonus Cd", "Test (bonus disc)")

		// SubTitleStyle
		, new TestCase("Respect SubTitleStyle", "My title: the subtitle", "My Title: The Subtitle")
		, new TestCase("Proper caps in parantheses", "My title ( the text a capped )", "My Title (The Text a Capped)")

		// Vinyl notation
		, new TestCase("Vinyl handling", "My title 12'' version", "My Title (12\" version)")
		, new TestCase("Vinyl handling", "My title (12-inch version)", "My Title (12\" version)")
		, new TestCase("Number. but not VinylHandler", "My title 12", "My Title 12")

		// Quoted text
		, new TestCase("Do *not* capitalize next word before quoted text", "First The \\\"Quoted\\\" word", "First the \"Quoted\" Word")
		, new TestCase("Do *not* capitalize next word after quoted text", "First \\\"Quoted\\\" The word", "First \"Quoted\" the Word")
		, new TestCase("Handle contractions, and quoted text", "I AIn't wasn't dOn't 'me is quoted' special", "I Ain't Wasn't Don't 'Me Is Quoted' Special")

		// Acronyms
		, new TestCase("Leave acronym intact", "Release A.B.C. Asdf", "Release A.B.C. Asdf")
		, new TestCase("Leave acronym at end intact", "Release 270 A.D.", "Release 270 A.D.")
		, new TestCase("Leave acronym in brackets intact", "Release (A.B.C.) Asdf", "Release (A.B.C.) Asdf")
		, new TestCase("Incomplete acronym, C does not belong", "Release (A.B.C) Asdf", "Release (A.B. C) Asdf")

		// capitalization of words before sentence stops {ticket:1099}
		, new TestCase("Titlecase for On before colon", "Early on: Subtitle 85-92 (disc 1)", "Early On: Subtitle 85-92 (disc 1)")
		, new TestCase("Titlecase for On before comma", "Early on, Volume 1", "Early On, Volume 1")
		, new TestCase("Titlecase for On before hyphen", "Early on - This Is a Track Title", "Early On - This Is a Track Title")

		// Hyphens
		, new TestCase("Hyphens: Leave whitespace intact", "Name 95-96", "Name 95-96")
		, new TestCase("Hyphens: Leave whitespace intact", "Name 95 -96", "Name 95 -96")
		, new TestCase("Hyphens: Leave whitespace intact", "Name 95- 96", "Name 95- 96")

		// VolumeNumberStyle
		, new TestCase("Leave proper VolumeNumberStyle intact", "Name, Volume 1", "Name, Volume 1")
		, new TestCase("Accept other chars than ',' before Volume", "Name! Volume 1", "Name! Volume 1")
		, new TestCase("Accept other chars than ',' before Volume", "Name: Volume 1", "Name: Volume 1")
		, new TestCase("Expand Vol->Volume", "Name, Vol 1", "Name, Volume 1")
		, new TestCase("VolumeNumberStyle in brackets", "I Don't Know Who I Am (Let the War against Music Begin Vol.2)", "I Don't Know Who I Am (Let the War Against Music Begin, Volume 2)")
		, new TestCase("Convert (Volume x) -> , Volume x", "Name (Volume 1)", "Name, Volume 1")
		, new TestCase("Convert (Vol x) -> , Volume x", "Name (Vol 1)", "Name, Volume 1")
		, new TestCase("Convert (Vol. x) -> , Volume x", "Name (Volume. 1)", "Name, Volume 1")
		, new TestCase("Convert Vol.x: Volumetitle -> , Volume x: Volumetitle", "Name Vol.2: Volumetitle", "Name, Volume 2: Volumetitle")

		// DiscNumberStyle
		, new TestCase("Leave proper DiscNumberStyle intact", "Name (disc 1)", "Name (disc 1)")
		, new TestCase("Disc does not trigger conversion", "Name Disc Yada Yada", "Name Disc Yada Yada")
		, new TestCase("Put discX in brackets", "Name CD1", "Name (disc 1)")
		, new TestCase("Put disc_X in brackets", "Name CD 1", "Name (disc 1)")
		, new TestCase("Convert CD inside brackets", "Name (CD 1)", "Name (disc 1)")
		, new TestCase("Convert Disk, drop hyphens", "The Ultimate R&B Release - Disk1", "The Ultimate R&B Release (disc 1)")
		, new TestCase("Convert wrong SubTitleStyle into DiscNumberStyle", "Release Title: DISC 2", "Release Title (disc 2)")
		, new TestCase("Remove colon before DiscNumberStyle", "Release: (disc 2)", "Release (disc 2)")

					// DiscNumberWithNameStyle
		, new TestCase("Leave proper DiscNumberWithNameStyle intact", "Name (disc 1: The name)", "Name (disc 1: The Name)")
		, new TestCase("DiscNumberWithNameStyle", "The Fragile Disc 1 Left", "The Fragile (disc 1: Left)")
		, new TestCase("DiscNumberWithNameStyle", "The Fragile (Disc 1 Left)", "The Fragile (disc 1: Left)")
		, new TestCase("Respect Cd in DiscNumberWithNameStyle name part", "Name (disc 1: Cd Blah)", "Name (disc 1: Cd Blah)")
		, new TestCase("CD->Disc, brackets, SubtitleStyle", "Name (CD 4 the name)", "Name (disc 4: The Name)")
		, new TestCase("CD->Disc, brackets, SubtitleStyle", "Name CD 4 The name", "Name (disc 4: The Name)")
	],

	// guessTrack function
	"trackname" : [
		// Special cases
		  new TestCase("Handle specialcase", "silent track", "[silence]")
		, new TestCase("Handle specialcase", "???", "[unknown]")
		, new TestCase("Handle specialcase", "Untitled track", "[untitled]")
		, new TestCase("Handle specialcase", "Bonus track", "[unknown]")
		, new TestCase("Handle specialcase", "Bonus", "[unknown]")
		, new TestCase("Handle specialcase", "Data Track", "[data track]")

		// capitalization
		, new TestCase("Proper caps", "My TRACK the name", "My Track the Name")
		, new TestCase("Proper caps", "der fremde", "Der Fremde")

		// slashes
		, new TestCase("Slash: Leave whitespace intact", "Slash/Slash", "Slash/Slash")
		, new TestCase("Slash: Leave whitespace intact", "Slash/ Slash", "Slash/ Slash")
		, new TestCase("Slash: Leave whitespace intact", "Slash / Slash", "Slash / Slash")

		// remix style
		, new TestCase("RemixStyle", "My TRACK (Name of the RMX)", "My Track (Name of the remix)")
		, new TestCase("RemixStyle", "My TRACK (Artist 1 & Artist 2 RMX)", "My Track (Artist 1 & Artist 2 remix)")

		// A Capella
		, new TestCase("Correct A Cappella, put into brackets", "My Track Accapela", "My Track (a cappella)")
		, new TestCase("Correct A Cappella inside brackets, make LC", "My Track (Accappella)", "My Track (a cappella)")

		// Extratitleinfo
		, new TestCase("Slurp Extratitleinfo", "My TRACK Extended Dub RMX", "My Track (extended dub remix)")
		, new TestCase("Respect words is do not have ETI context", "Test Dance", "Test Dance")
		, new TestCase("Slurp ETI of isPrepBracketSingleWords if context allows it", "Test Dance Mix", "Test (dance mix)")
		, new TestCase("Respect words is do not have ETI context", "Test Live", "Test Live")
		, new TestCase("Slurp ETI of isPrepBracketSingleWords if context allows it", "Test Live Version", "Test (live version)")

		// feat. style
		, new TestCase("FeaturingArtistStyle", "My TRACK (feat. Artistname)", "My Track (feat. Artistname)")
		, new TestCase("FeaturingArtistStyle", "My TRACK	( feat.	Artistname )", "My Track (feat. Artistname)")
		, new TestCase("FeaturingArtistStyle", "My TRACK	Featuring	Artistname", "My Track (feat. Artistname)")
		, new TestCase("FeaturingArtistStyle", "My TRACK	ft.	Artistname", "My Track (feat. Artistname)")
		, new TestCase("FeaturingArtistStyle", "My TRACK	f. Artistname", "My Track (feat. Artistname)")
		, new TestCase("FeaturingArtistStyle", "My TRACK /w Artistname", "My Track (feat. Artistname)")
		, new TestCase("Not convert F if not followed by a dot", "Wonder of Live (F & W Remix)", "Wonder of Live (F & W remix)")

		// feat. style with remixinfo
		, new TestCase("FeaturingArtistStyle", "My TRACK (house Vocal mix) ft	Artistname", "My Track (House vocal mix) (feat. Artistname)")
		, new TestCase("FeaturingArtistStyle", "My TRACK (house Vocal mix ft	Artistname)", "My Track (House vocal mix feat. Artistname)")

		// PartNumberStyle
		, new TestCase("PartNumberStyle", "Name, Part 1", "Name, Part 1")
		, new TestCase("PartNumberStyle", "Name Pt1", "Name, Part 1")
		, new TestCase("PartNumberStyle", "Name Pt 1", "Name, Part 1")
		, new TestCase("PartNumberStyle", "Name Pt. 1", "Name, Part 1")
		, new TestCase("PartNumberStyle", "Name Pt #1", "Name, Part 1")
		, new TestCase("Convert (Part x) -> , Part x", "Name (Part 1)", "Name, Part 1")
		, new TestCase("Convert (Pt x) -> , Part x", "Name (Pt 1)", "Name, Part 1")
		, new TestCase("Convert (Pt. x) -> , Part x", "Name (Pt. 1)", "Name, Part 1")
		, new TestCase("Convert (Parts 1 & 2) -> , Parts 1 & 2", "Name (Parts 1 & 2)", "Name, Parts 1 & 2")
		, new TestCase("Convert Pt.x: Parttitle -> , Part x: Parttitle", "Name Pt.1: Parttitle", "Name, Part 1: Parttitle")

		// PartNumberStyle + Subtitle
		, new TestCase("Respect correctly formatted PartNumberStyle,SubTitleStyle", "Foo, Part 1: Bar", "Foo, Part 1: Bar")
		, new TestCase("Expand Pt->Part, respect SubTitleStyle", "Foo, Pt. 1: Bar", "Foo, Part 1: Bar")
		, new TestCase("PartNumber-, SubtitleStyle", "Name Pt. 1 The subtitle", "Name, Part 1: The Subtitle")
		, new TestCase("PartNumber-, SubtitleStyle + Numeral", "Name Pt. II The subtitle", "Name, Part II: The Subtitle")
		, new TestCase("PartNumber-, SubtitleStyle + Brackets", "Name Pt. II (The text)", "Name, Part II (The Text)")
		, new TestCase("Remove parantheses, respect SplitTrackstyle", "Foo (Part 1) / Bar", "Foo, Part 1 / Bar")
		, new TestCase("Don not convert this to SubTitltStyle", "Foo, Part 1/ Bar", "Foo, Part 1/ Bar")

		// Multiple Parts
		, new TestCase("Multiple Parts", "Name Pts 1", "Name, Part 1")
		, new TestCase("Multiple Parts", "Name Pts 1 & 2", "Name, Parts 1 & 2")
		, new TestCase("Multiple Parts", "Name Pts 1 - 2", "Name, Parts 1 - 2")
		, new TestCase("Multiple Parts", "Name, Parts 1 & 2", "Name, Parts 1 & 2")
		, new TestCase("Multiple Parts", "Name, Parts 1 - 2", "Name, Parts 1 - 2")
		, new TestCase("Multiple Parts", "Same Beat (Parts 1,2 & 3)", "Same Beat, Parts 1, 2 & 3")
		
		, new TestCase("Won't -> Won't", "I Won'T (Super Duper)", "I Won't (Super Duper)")
	]
};


/**
 * Returns a TestCases object containing the list
 * of TestCase objects for the page.
 **/
function getTestCases(page) {
	var tcs;
	var tcl = new TestCases();
	if ((tcs = DEFINED_TESTS[page]) != null) {
		for (var i=0; i<tcs.length; i++) {
			var testName = page + "" + i;
			tcl.addTestCase(testName, tcs[i]);
		}
	}
	return tcl;
}

/**
 * Returns the value s as an input field

 * @param s
 **/
function displayValue(s) {
	var sr = s.replace(/"/g, "''");
	return '<input value="'+sr+'" size="80" font-family: monospace" />';
}

/**
 * Run the testcase, and output the error if it failed.
 *
 * @param funcName
 * @param msg
 * @param is
 * @param es
 **/
function runTest(funcName, msg, is, es) {
	var r = "";
	mb.log.scopeStart("Attempting to run test...");
	var out = [];
	try {
		eval(testFunc);
		assertEquals(msg, es, r);
		out.push('<div style="border: 1px solid #ABE6A3; padding-bottom: 2px; margin-bottom: 15px; font-size: 12px">');
		out.push('<div style="background: #ABE6A3; padding: 3px; font-weight: bold; margin-bottom: 2px; ">');
		out.push('SUCCESS &raquo; ');
		out.push(msg);
		out.push("</div>");
		out.push('<table style="margin-left: 5px">');
		out.push('<tr style="font-size: 11px"><td nowrap>Input:&nbsp; &nbsp; &nbsp; </td><td width="100%" style="font-family:Courier">');
		out.push(displayValue(is));
		out.push('</td></tr>');
		out.push('<tr style="font-size: 11px"><td nowrap>Result:</td><td style="font-family:Courier">');
		out.push(displayValue(es));
		out.push('</td></tr>');
		out.push('</table>');
		out.push('</div>');
		info(out.join(""));
		mb.log.scopeEnd();

	} catch (ex) {
		out.push('<div style="border: 1px solid #EF6666; padding-bottom: 2px; margin-bottom: 15px">');
		out.push('<div style="background: #EF6666; padding: 3px; font-weight: bold; margin-bottom: 2px; ">');
		out.push('FAILED &raquo; ');
		out.push(msg);
		out.push("</div>");
		out.push('<table style="margin-left: 5px">');
		out.push('<tr style="font-size: 11px"><td nowrap>Input:&nbsp; &nbsp; &nbsp; </td><td width="100%" style="font-family:Courier">');
		out.push(displayValue(is));
		out.push('</td></tr>');
		out.push('<tr style="font-size: 11px"><td nowrap>Expected:</td><td style="font-family:Courier">');
		out.push(displayValue(es));
		out.push('</td></tr>');
		out.push('<tr style="font-size: 11px"><td nowrap>Result:</td><td style="font-family:Courier">');
		out.push(displayValue(r));
		out.push('</td></tr>');
		if (ex.message) {
			out.push('<tr style="font-size: 11px"><td nowrap>Exception:</td><td style="font-family:Courier">');
			out.push(displayValue(ex.message));
			out.push('</td></tr>');
		}
		out.push('<tr style="font-size: 11px; font-family: monospace"><td colspan="2">');
		out.push(mb.log.getMessages().join(""));
		out.push('</td></tr>');
		out.push('</table>');
		out.push('</div>');
		warn(out.join(""));
		mb.log.scopeEnd();
		throw ex;
	}
}

/**
 * Displays the list of test cases
 *
 * @param TN
 **/
function setupTestPage(TN) {
	mb.log.scopeStart("Setting up "+TN.toUpperCase()+" tests...");

	// setup the test functions
	tcl = getTestCases(TN);
	mb.log.info("The List of testcases: <br/><code>&nbsp;  * "+tcl.getFunctions().replace(/\n/g, "<br/>&nbsp;  * ")+"</code>");

	// function check
	mb.log.scopeStart("Making sure the test function works...");
	mb.log.info("Function:  $", testFunc);
	mb.log.info("In:  $", is);
	mb.log.setLevel(mb.log.WARNING);
	eval(testFunc)
	mb.log.setLevel(mb.log.INFO);
	mb.log.info("Out: $", r);

	// write output to page
	mb.log.writeUI();
}
