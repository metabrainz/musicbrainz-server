/*----------------------------------------------------------------------------\
|                              Musicbrainz.org                                |
|                 Copyright (c) 2005 Stefan Kestenholz (keschte)              |
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
|                                                                             |
| $Id$
\----------------------------------------------------------------------------*/

/**
 * Models a GuessCase mode.
 **/
function GcMode(modes, name, lang, desc, url) {
	mb.log.enter("GcMode", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "GcMode";
	this.GID = "gc.mode";

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Set the instance variables.
	 */
	this.setConfig = function(modes, name, lang, desc, url) {
		mb.log.enter(this.GID, "setConfig");
		this._modes = modes;
		this._name = name;
		this._lang = lang;
		this._desc = (desc || "");
		this._url = (url || "");
		this._id = null;
		mb.log.exit();
	};
	this.setConfig(modes, name, lang, desc, url);

	/**
	 * Returns the unique identifier of this mode
	 **/
	this.getID = function() {
		mb.log.enter(this.GID, "getID");
		if (!this._id) {
			var s = (this._name+" "+this._lang).toLowerCase();
			s = s.replace(/\s*/g, "");
			s = s.replace(/\([^\)]*\)/g, "");
			this._id = s;
		}
		return mb.log.exit(this._id);
	};
	this.getName = function() { return this._name; };
	this.getURL = function() { return this._url; };
	this.getLanguage = function() { return this._lang; };

	/**
	 * Returns the type of this mode
	 **/
	this.getDescription = function() {
		mb.log.enter(this.GID, "getDescription");
		var s = this._desc;
		s = s.replace('[url]', '<a href="'+this.getURL()+'" target="_blank">'+this.getName()+' ');
		s = s.replace('[/url]', '</a>');
		return mb.log.exit(s);
	};

	/**
	 * Returns true if the GC script is operating in sentence mode
	 **/
	this.isSentenceCaps = function() {
		mb.log.enter(this.GID, "isSentenceCaps");
		var f = !(this._modes.EN == this.getLanguage());
		mb.log.debug("lang: $, flag: $", this.getLanguage(), f);
		return mb.log.exit(f);
	};

	/**
	 * Returns true if the GC script is operating in sentence mode
	 **/
	this.toString = function() {
		var s = [];
		s.push(this.CN);
		s.push(" [");
		s.push("id: ");
		s.push(this.getID());
		s.push(", SentenceCaps: ");
		s.push(this.isSentenceCaps());
		s.push("]");
		return s.join("");
	};


	// ----------------------------------------------------------------------------
	// mode specific functions
	// ---------------------------------------------------------------------------

	/**
	 * Words which are always written lowercase.
	 * -------------------------------------------------------
	 * tma			2005-01-29		first version
	 * keschte		2005-04-17		added french lowercase characters
	 * keschte		2005-06-14		added "tha" to be handled like "the"
	 **/
	this.getLowerCaseWords = function(lang) {
		return ["a","and","n","an","as","at","but","by","for","in",
				"nor","of","o","on","or","the","to","tha"];
	};
	this.isLowerCaseWord = function(w) {
		mb.log.enter(this.GID, "isLowerCaseWord");
		if (!this.lowerCaseWords) {
			this.lowerCaseWords = gc.u.toAssocArray(this.getLowerCaseWords());
		}
		var f = gc.u.inArray(this.lowerCaseWords,w);
		mb.log.debug("$=$", w, f);
		return mb.log.exit(f);
	}; // lowercase_words

	/**
	 * Words which are always written uppercase.
	 * -------------------------------------------------------
	 * keschte		2005-01-31		first version
	 * various		2005-05-05		added "FM...PM"
	 * keschte		2005-05-24		removed AM,PM because it yielded false positives e.g. "I AM stupid"
	 * keschte		2005-07-10		added uk,bpm
	 * keschte		2005-07-20		added ussr,usa,ok,nba,rip,ny,classical words,hip-hop artists
	 * keschte		2005-10-24		removed AD
	 * keschte		2005-11-15		removed RIP (Let Rip) is not R.I.P.
	 **/
	this.getUpperCaseWords = function() {
		return [
			"dj", "mc", "tv", "mtv", "ep", "lp",
			"ymca", "nyc", "ny", "ussr", "usa", "r&b",
			"bbc", "fm", "bc", "ac", "dc", "uk", "bpm", "ok", "nba",
			"rza", "gza", "odb", "dmx", "2xlc" // artists
		];
	};
	this.getRomanNumberals = function() {
		return ["i","ii","iii","iv","v","vi","vii","viii","ix","x"];
	};
	this.isUpperCaseWord = function(w) {
		mb.log.enter(this.GID, "isUpperCaseWord");
		if (!this.upperCaseWords) {
			this.upperCaseWords = gc.u.toAssocArray(this.getUpperCaseWords());
		}
		if (!this.romanNumerals) {
			this.romanNumerals = gc.u.toAssocArray(this.getRomanNumberals());
		}
		var f = gc.u.inArray(this.upperCaseWords, w);
		if (!f && gc.isConfigTrue(gc.CFG_UC_ROMANNUMERALS)) {
			f = gc.u.inArray(this.romanNumerals, w);
		}
		mb.log.debug("$=$", w, f);
		return mb.log.exit(f);
	}; // uppercase_words

	/**
	 * Pre-process to find any lowercase_bracket word that needs to be put into parentheses.
	 * starts from the back and collects words that belong into
	 * the brackets: e.g.
	 * My Track Extended Dub remix => My Track (extended dub remix)
	 * My Track 12" remix => My Track (12" remix)
	 **/
	this.prepExtraTitleInfo = function(w) {
		mb.log.enter(this.GID, "prepExtraTitleInfo");
		var lastword = w.length-1, wi = lastword;
		var handlePreProcess = false;
		var isDoubleQuote = false;
		while (((w[wi] == " ") || // skip whitespace
			   (w[wi] == '"' && (w[wi-1] == "7" || w[wi-1] == "12")) || // vinyl 7" or 12"
			   ((w[wi+1] || "") == '"' && (w[wi] == "7" || w[wi] == "12")) ||
			   (gc.u.isPrepBracketWord(w[wi]))) &&
				wi >= 0) {
			handlePreProcess = true;
			wi--;
		}
		mb.log.debug("Preprocess: $ ($<--$)", handlePreProcess, wi, lastword);

		// Down-N-Dirty (lastword = dirty)
		// Dance,Dance,Dance (lastword = dance) get matched by the preprocessor,
		// but are a single word which can occur at the end of the string.
		// therefore, we don't put the single word into parens.

		// trackback the skipped spaces spaces, and then slurp the
		// next word, so see which word we found.
		if (wi < lastword) {
			// the word at wi broke out of the loop above,
			// is not extra title info.
			wi++;
			while (w[wi] == " " && wi < lastword) {
				wi++; // skip whitespace
			}

			// if we have a single word that needs to be put
			// in parantheses, consult the list of words
			// were we do not do it, else continue.
			var probe = w[lastword];
			if ((wi == lastword) &&
				(gc.u.isPrepBracketSingleWord(probe))) {
				mb.log.debug("Word: $ which might occur inside brackets, has <strong>not been put into ()</strong>", probe);
				handlePreProcess = false;
			}
			if (handlePreProcess && wi > 0 && wi <= lastword) {
				var nw = w.slice(0, wi);
				if (nw[wi-1] == "(") { nw.pop(); }
				if (nw[wi-1] == "-") { nw.pop(); }
				nw[nw.length] = "(";
				nw = nw.concat(w.slice(wi,w.length));
				nw[nw.length] = ")";
				w = nw;
				mb.log.debug("Processed ExtraTitleInfo: $", w);
			}
		}
		return mb.log.exit(w);
	};


	/**
	 * Replace unicode special characters with their ascii equivalent
	 * Note:	this function is run before all guess types
	 *			(artist|release|track)
	 *
	 * keschte		2005-11-10		first version
	 **/
	this.preProcessCommons = function(is) {
		mb.log.enter(this.GID, "preProcessCommons");
		if (!gc.re.PREPROCESS_COMMONS) {
			gc.re.PREPROCESS_COMMONS = [
				  new GcFix("D.J. -> DJ", /(\b|^)D\.?J\.?(\s|\)|$)/i, "DJ")
				, new GcFix("M.C. -> MC", /(\b|^)M\.?C\.?(\s|\)|$)/i, "MC")

				// http://unicode.e-workers.de/wgl4.php
				// http://www.cs.sfu.ca/~ggbaker/reference/characters/
				// single quotes
				, new GcFix("Opening single-quote &#x2018;", "\u2018", "'")
				, new GcFix("Closing single-quote &#x2019;", "\u2019", "'")

				// weird single quotes.
				, new GcFix("Acute accent &#x0301;", "\u0301", "'")
				, new GcFix("Acute accent &#x00B4;", "\u00B4", "'")
				, new GcFix("Grave accent &#x0300;", "\u0300", "'")
				, new GcFix("Backtick &#x0060;", "\u0060", "'")
				, new GcFix("Prime &#x2023;", "\u2023", "'")

				// double quotes
				, new GcFix("Opening double-quote &#x201C;", "\u201C", "\"")
				, new GcFix("Closing double-quote &#x201D;", "\u201D", "\"")

				// hyphens
				, new GcFix("Soft hyphen &#x00AD;", "\u00AD", "-")
				, new GcFix("Closing Hyphen &#x2010;", "\u2010", "-")
				, new GcFix("Non-breaking hyphen &#x2011;", "\u2011", "-")
				, new GcFix("En-dash &#x2013;", "\u2013", "-")
				, new GcFix("Em-dash &#x2014;", "\u2014", "-")
				, new GcFix("hyphen bullet &#x2043;", "\u2043", "-")
				, new GcFix("Minus sign &#x2212;", "\u2212", "-")

				// ellipsis
				, new GcFix("Ellipsis &#x2026;", "\u2026", "...")
			];
		}
		var os = this.runFixes(is, gc.re.PREPROCESS_COMMONS);
		mb.log.debug('After: $', os);
		return mb.log.exit(os);
	};

	/**
	 * Take care of mis-spellings that need to be fixed before
	 * splitting the string into words.
	 * Note: 	this function is run before release and track guess
	 *   		types (not for artist)
	 *
	 * keschte		2005-11-10		first version
	 **/
	this.preProcessTitles = function(is) {
		mb.log.enter(this.GID, "preProcessTitles");
		if (!gc.re.PREPROCESS_FIXLIST) {
			gc.re.PREPROCESS_FIXLIST = [

				  // trim spaces from brackets.
				  new GcFix("spaces after opening brackets", /(^|\s)([\(\{\[])\s+($|\b)/i, "$2" )
				, new GcFix("spaces before closing brackets", /(\b|^)\s+([\)\}\]])($|\b)/i, "$2" )

				  // remix variants
				, new GcFix("re-mix -> remix", /(\b|^)re-mix(\b)/i, "remix" )
				, new GcFix("re-mix -> remix", /(\b|^)re-mix(\b)/i, "remix" )
				, new GcFix("remx -> remix", /(\b|^)remx(\b)/i, "remix" )
				, new GcFix("re-mixes -> remixes", /(\b|^)re-mixes(\b)/i, "remixes" )
				, new GcFix("re-make -> remake", /(\b|^)re-make(\b)/i, "remake" )
				, new GcFix("re-makes -> remakes", /(\b|^)re-makes(\b)/i, "remakes" )
 				, new GcFix("re-edit variants, prepare for postprocess", /(\b|^)re-?edit(\b)/i, "re_edit" )
				, new GcFix("RMX -> remix", /(\b|^)RMX(\b)/i, "remix" )

				  // extra title information
				, new GcFix("alt.take -> alternate take", /(\b|^)alt[\.]? take(\b)/i, "alternate take")
				, new GcFix("instr. -> instrumental", /(\b|^)instr\.?(\b)/i, "instrumental")
				, new GcFix("altern. -> alternate", /(\b|^)altern\.?(\s|\)|$)/i, "alternate" )
				, new GcFix("orig. -> original", /(\b|^)orig\.?(\s|\)|$)/i, "original" )
				, new GcFix("ver(s). -> version", /(\b|^)vers?\.(\s|\)|$)/i, "version" )
				, new GcFix("Extendet -> extended", /(\b|^)Extendet(\b)/i, "extended" )
				, new GcFix("extd. -> extended", /(\b|^)ext[d]?\.?(\s|\)|$)/i, "extended" )

				  // also known as
				, new GcFix("aka -> a.k.a.", /(\b|^)aka(\b)/i, "a.k.a." )

				  // featuring variant
				, new GcFix("/w -> ft. ", /(\s)[\/]w(\s)/i, "ft." )
				, new GcFix("f. -> ft. ", /(\s)f\.(\s)/i, "ft." )
				, new GcFix("'featuring - ' -> feat", /(\s)featuring -(\s)/i, "feat" )

				  // vinyl
				, new GcFix("12'' -> 12\"", /(\s|^|\()(\d+)''(\s|$)/i, "$2\"" )
				, new GcFix("12in -> 12\"", /(\s|^|\()(\d+)in(ch)?(\s|$)/i, "$2\"" )

				  // combined word hacks, e.g. replace spaces with underscores,
				  // (e.g. "a cappella" -> a_capella), such that it can be handled
				  // correctly in post-processing
				, new GcFix("A Capella preprocess", /(\b|^)a\s?c+ap+el+a(\b)/i, "a_cappella" )
				, new GcFix("OC ReMix preprocess", /(\b|^)oc\sremix(\b)/i, "oc_remix" )

				  // Handle Part/Volume abbreviations
				, new GcFix("Standalone Pt. -> Part", /(^|\s)Pt\.?(\s|$)/i, "Part" )
				, new GcFix("Standalone Pts. -> Parts", /(^|\s)Pts\.(\s|$)/i, "Parts" )
				, new GcFix("Standalone Vol. -> Volume", /(^|\s)Vol\.(\s|$)/i, "Volume" )

				  // Get parts out of brackets
				  // Name [Part 1] -> Name, Part 1
				  // Name (Part 1) -> Name, Part 1
				  // Name [Parts 1] -> Name, Parts 1
				  // Name (Parts 1-2) -> Name, Parts 1-2
				  // Name (Parts x & y) -> Name, Parts x & y
				, new GcFix("(Pt) -> , Part", /((,|\s|:|!)+)([\(\[])?\s*(Part|Pt)[\.\s#]*((\d|[ivx]|[\-,&\s])+)([\)\]])?(\s|:|$)/i, "Part $5")
				, new GcFix("(Pts) -> , Parts", /((,|\s|:|!)+)([\(\[])?\s*(Parts|Pts)[\.\s#]*((\d|[ivx]|[\-&,\s])+)([\)\]])?(\s|:|$)/i, "Parts $5")
				, new GcFix("(Vol) -> , Volume", /((,|\s|:|!)+)([\(\[])?\s*(Volume|Vol)[\.\s#]*((\d|[ivx]|[\-&,\s])+)([\)\]])?(\s|:|$)/i, "Volume $5")
				, new GcFix(": Part -> , Part", /(\b|^): Part(\b)/i, ", part" )
				, new GcFix(": Parts -> , Parts", /(\b|^): Part(\b)/i, ", parts" )
			];
		}
		var os = this.runFixes(is, gc.re.PREPROCESS_FIXLIST);
		mb.log.debug('After pre: $', os);
		return mb.log.exit(os);
	};

	/**
	 * Collect words from processed wordlist and apply minor fixes that
	 * aren't handled in the specific function.
	 **/
	this.runPostProcess = function(is) {
		mb.log.enter(this.GID, "runPostProcess");
		if (!gc.re.POSTPROCESS_FIXLIST) {
			gc.re.POSTPROCESS_FIXLIST = [

				  // see combined words hack in preProcessTitles
				  new GcFix("a_cappella inside brackets", /(\b|^)a_cappella(\b)/, "a cappella")
				, new GcFix("a_cappella outside brackets", /(\b|^)A_cappella(\b)/, "A Cappella")
				, new GcFix("oc_remix", /(\b|^)oc_remix(\b)/i, "OC ReMix")
				, new GcFix("re_edit inside brackets", /(\b|^)Re_edit(\b)/, "re-edit")

				  // TODO: check if needed?
				, new GcFix("whitespace in R&B", /(\b|^)R\s*&\s*B(\b)/i, "R&B")
				, new GcFix("[live] to (live)", /(\b|^)\[live\](\b)/i, "(live)")
				, new GcFix("Djs to DJs", /(\b|^)Djs(\b)/i, "DJs")
				, new GcFix("a.k.a. lowercase", /(\s|^)A\.K\.A\.(\s|$)/i, "a.k.a.")
				, new GcFix("Rock 'n' Roll", /(\s|^)Rock '?n'? Roll(\s|$)/i, "Rock 'n' Roll")
			];
		}
		var os = this.runFixes(is, gc.re.POSTPROCESS_FIXLIST);
		if (is != os) {
			mb.log.debug('After postfixes: $', os); is = os;
		}
		return mb.log.exit(os);
	};

	/**
	 * Iterate through the list array and apply the fixes to string is
	 *
	 * @param is	the input string
	 * @param list	the list of GcFixes object to apply.
	 **/
	this.runFixes = function(is, list) {
		mb.log.enter(this.GID, "runFixes");
		var matcher = null;
		var len = list.length;
		for (var i=0; i<len; i++) {
			var f = list[i];
			if (f instanceof GcFix) {
				var fixName = "Replaced " + f.getName();  // name
				var find = f.getRe(); // regular expression/string
				var replace = f.getReplace(); // replace
				// mb.log.debug('Fix type: $', typeof(find)=='string' ? 'string':'regexp');
				if (typeof(find) == 'string') {

					// iterate through the whole string and replace. there could
					// be multiple occurences of the search string.
					var pos = 0;
					while ((pos = is.indexOf(find, pos)) != -1) {
						mb.log.debug('Applying fix: $ (replace: $)', fixName, replace);
						is = is.replace(find, replace);
					}
				} else if ((matcher = is.match(find)) != null) {
					// get reference to first set of parentheses
					var a = matcher[1];
					a = (mb.utils.isNullOrEmpty(a) ? "" : a);

					// get reference to last set of parentheses
					var b = matcher[matcher.length-1];
					b = (mb.utils.isNullOrEmpty(b) ? "" : b);

					// compile replace string
					var rs = [a,replace,b].join("");
					is = is.replace(find, rs);

					// debug output
					mb.log.debug("Applying fix: $ ...", fixName);
					mb.log.trace("* matcher[$]: $, replace: $, matcher[$]: $ --> $", 1, a, replace, matcher.length-1, b, rs);
					mb.log.trace("* matcher: $", matcher);
					mb.log.trace("After fix: $", is);
				} else {
					// mb.log.debug('Fix $ did not match', fixName);
				}
			} else {
				// if f is null, there is a wrong comma in the list
				// of Gc objects. nothing to be concerned about.
				if (f != null) {
					mb.log.error("Expected GcFix object($/$), got: $", i, len, (f ? f.nodeName:"null"));
				}
			}
		}
		return mb.log.exit(is);
	};

	/**
	 * Take care of (bonus),(bonus track)
	 **/
	this.stripInformationToOmit = function(is) {
		mb.log.enter(this.GID, "stripInformationToOmit");
		if (!gc.re.PREPROCESS_STRIPINFOTOOMIT) {
			gc.re.PREPROCESS_STRIPINFOTOOMIT = [
				new GcFix("Trim 'bonus (track)?'", /[\(\[]?bonus(\s+track)?s?\s*[\)\]]?$/i, ""),
				new GcFix("Trim 'retail (version)?'", /[\(\[]?retail(\s+version)?\s*[\)\]]?$/i, "")
			];
		}
		var os = is, list = gc.re.PREPROCESS_STRIPINFOTOOMIT;
		for (var i=list.length-1; i>=0; i--) {
			var matcher = null;
			var listItem = list[i];
			var fixName = "Replaced " + listItem.getName();  // name
			var find = listItem.getRe(); // regular expression/string
			var replace = listItem.getReplace(); // replace
			if ((matcher = os.match(find)) != null) {
				os = os.replace(find, replace);
				mb.log.debug("Done fix: $", fixName);
			}
		}
		if (is != os) {
			mb.log.debug('After strip info: $', os);
		}
		return mb.log.exit(os);
	};

	/**
	 * Look for, and convert vinyl expressions
	 * * look only at substrings which start with ' '  OR '('
	 * * convert 7',7'',7",7in,7inch TO '7"_' (with a following SPACE)
	 * * convert 12',12'',12",12in,12inch TO '12"_' (with a following SPACE)
	 * * do NOT handle strings like 80's
	 * Examples:
	 *  Original string: "Fine Day (Mike Koglin 12' mix)"
	 *  	Last matched portion: " 12' "
	 *  	Matched portion 1 = " "
	 *  	Matched portion 2 = "12'"
	 *  	Matched portion 3 = "12"
	 *  	Matched portion 4 = "'"
	 *  	Matched portion 5 = " "
	 *  Original string: "Where Love Lives (Come on In) (12"Classic mix)"
	 *  	Last matched portion: "(12"C"
	 *  	Matched portion 1 = "("
	 *  	Matched portion 2 = "12""
	 *  	Matched portion 3 = "12"
	 *  	Matched portion 4 = """
	 *  	Matched portion 5 = "C"
	 *  Original string: "greatest 80's hits"
	 * 		Match failed.
	 **/
	this.runFinalChecks = function(is) {
		mb.log.enter(this.GID, "runFinalChecks");
		if (!gc.re.VINYL) {
			gc.re.VINYL = /(\s+|\()((\d+)[\s|-]?(inch\b|in\b|'+|"))([^s]|$)/i;
		}
		var matcher = null, os = is;
		if ((matcher = is.match(gc.re.VINYL)) != null) {
			var mindex = matcher.index;
			var mlenght  = matcher[1].length + matcher[2].length + matcher[5].length; // calculate the length of the expression
			var firstPart = is.substring(0, mindex);
			var lastPart = is.substring(mindex + mlenght, is.length); // add number
			var parts = []; // compile the vinyl designation.
			parts.push(firstPart);
			parts.push(matcher[1]); // add matched first expression (either ' ' or '('
			parts.push(matcher[3]); // add matched number, but skip the in, inch, '' part
			parts.push('"'); // add vinyl doubleqoute
			parts.push((matcher[5]) != " " && matcher[5] != ")" && matcher[5] != "," ? " " : ""); // add space after ",if none is present and next character is not ")" or ","
			parts.push(matcher[5]); // add first character of next word / space.
			parts.push(lastPart); // add rest of string
			os = parts.join("");
		}
		return mb.log.exit(os);
	};

	/**
	 * Delegate function for Mode specific word handling.
	 * This is mostly used for context based titling changes.
	 *
	 * @return	false, such that the normal word handling can
	 *			take place for the current word, if that should
	 * 			not be done, return true.
	 **/
	this.doWord = function() {
		return false;
	};

	// exit constructor
	mb.log.exit();
}
GcMode.prototype = new GcMode;
