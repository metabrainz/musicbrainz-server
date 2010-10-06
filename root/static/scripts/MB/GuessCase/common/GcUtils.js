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
| $Id: GcUtils.js 9116 2007-05-10 11:17:55Z luks $
\----------------------------------------------------------------------------*/

/**
 * Utility functions, definitions
 **/
function GcUtils() {
	mb.log.enter("GcUtils", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "GcUtils";
	this.GID = "gc.u";

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	 * Renders an array to an associative array with lowercase keys.
	 **/
	this.toAssocArray = function(a) {
		var t = [];
		try {
			for (var m=0; m<a.length; m++) {
				var curr = a[m].toLowerCase();
				t[curr] = curr;
			}
		} catch (e) {}
		return t;
	};

	/**
	 * Checks if the variable k is in the given array a
	 * returns true,if k is in a,and a[k]=k,and k is no function
	 * of the array (e.g. join,pop etc.)
	 **/
	this.inArray = function(a,k) {
		mb.log.enter(this.GID, "inArray");
		if (a == null || k == null) {
			mb.log.error('One of key/array is null. k: $, a: $', k, a);
			return mb.log.exit(false);
		}
		k = k.toLowerCase();
		var v = (a[k] || null);
		var f = (k != null &&
				 a != null &&
				 v != null &&
				 v == k &&
				 typeof(v) == 'string');
		// mb.log.debug("$=$", k, f);
		return mb.log.exit(f);
	};

	/**
	 * template function for wordlists
	 * -------------------------------------------------------
	 * keschte		2005-10-24		template for a wordlist
	 **/
	this.isSomeWord = function(w) {
		if (!this.someWord) {
			this.someWord = this.toAssocArray([]); // empty array
		}
		return this.inArray(this.someWord,w);
	};


	/**
	 * Words which are *not* converted if they are matched as
	 * a single pre-processor word at the end of the sentence.
	 * -------------------------------------------------------
	 * keschte		2005-05-25		first version
	 * keschte		2005-07-10		added disco
	 * keschte		2005-07-20		added dub
	 **/
	this.getPrepBracketSingleWords = function() {
		return ["acoustic", "album", "alternate", "bonus", "clean", "club", "dance",
				"dirty", "extended", "instrumental", "live", "original", "radio", "take",
				"disc", "mix", "version", "feat", "cut", "vocal", "alternative", "megamix",
				"disco", "video", "dub", "long", "short", "main", "composition", "session",
				"rework", "reworked", "remixed", "dirty", "airplay"];
	};
	this.isPrepBracketSingleWord = function(w) {
		mb.log.enter(this.GID, "isPrepBracketSingleWord");
		if (!this.preBracketSingleWords) {
			this.preBracketSingleWords = this.toAssocArray(this.getPrepBracketSingleWords());
		}
		var f = this.inArray(this.preBracketSingleWords,w);
		mb.log.debug("$=$", w, f);
		return mb.log.exit(f);
	}; // preprocessor_bracket_singlewords

	/**
	 * Words which are written lowercase if in brackets
	 * -------------------------------------------------------
	 * tma			2005-01-29		first version
	 * keschte		2005-01-29		added dub,megamix,maxi
	 * .various		2005-05-09		karaoke
	 * keschte		2005-07-10		added disco,unplugged
	 * keschte		2005-07-10		changed acappella,has its own handling now.
	 *								is handled as 1 word, but is expanded to "a cappella"
	 *								in post-processing
	 * keschte		2005-07-21		added outtake(s),rehearsal,intro,outro
	 * lukas		2007-05-10		added orchestral
	 **/
	this.getLowerCaseBracketWords = function() {
		return ["acoustic", "album", "alternate", "bonus", "clean", "dirty", "disc",
				"extended", "instrumental", "live", "original", "radio", "single",
				"take", "demo", "club", "dance", "edit", "skit", "mix", "remix",
				"version", "reprise", "megamix", "maxi", "feat", "interlude", "dub",
				"dialogue", "cut", "karaoke", "vs", "vocal", "alternative",
				"disco", "unplugged", "video", "outtake", "outtakes", "rehearsal", "intro",
				"outro", "long", "short", "main", "remake", "clubmix",
				"composition", "reinterpreted", "session", "rework", "reworked",
				"remixed", "reedit", "airplay", "a_cappella", "excerpt", "medley",
				"orchestral"];
	};
	this.isLowerCaseBracketWord = function(w) {
		mb.log.enter(this.GID, "isLowerCaseBracketWord");
		if (!this.lowerCaseBracketWords) {
			this.lowerCaseBracketWords = this.toAssocArray(this.getLowerCaseBracketWords());
		}
		var f = this.inArray(this.lowerCaseBracketWords,w);
		mb.log.debug("$=$", w, f);
		return mb.log.exit(f);
	}; // lowercase_bracket_words

	/**
	 * Words which the pre-processor looks for and puts them
	 * into brackets if they arent yet.
	 * -------------------------------------------------------
	 * keschte		2005-05-25		first version
	 **/
	this.isPrepBracketWord = function(w) {
		mb.log.enter(this.GID, "isPrepBracketWord");
		if (!this.prepBracketWords) {
			this.prepBracketWords = this.toAssocArray(
				["cd","disk",'12"','7"', "a_cappella", "re_edit"]
				.concat(this.getLowerCaseBracketWords()));
		}
		var f = this.inArray(this.prepBracketWords,w);
		mb.log.debug("$=$", w, f);
		return mb.log.exit(f);
	}; // preprocessor_bracket_words


	/**
	 * Sequence stop characters
	 * -------------------------------------------------------
	 * keschte		2005-05-24		first version
	 **/
	this.isSentenceStopChar = function(w) {
		mb.log.enter(this.GID, "isSentenceStopChar");
		if (!this.sentenceStopChars) {
			this.sentenceStopChars = this.toAssocArray([
				":",".",";","?","!","/"
			]);
		}
		var f = this.inArray(this.sentenceStopChars,w);
		mb.log.debug("$=$", w, f);
		return mb.log.exit(f);
	}; // sentencestop_chars

	/**
	 * Punctuation characters
	 * -------------------------------------------------------
	 * keschte		2005-05-24		first version
	 **/
	this.isPunctuationChar = function(w) {
		if (!this.punctuationChars) {
			this.punctuationChars = this.toAssocArray([
				":",".",";","?","!",","
			]);
		}
		return this.inArray(this.punctuationChars,w);
	}; // punctuation_chars

	/**
	 * Check if a word w has to be MacTitled http://www.daire.org/names/scotsurs2.html
	 * -------------------------------------------------------
	 **/
	this.getMacTitledWords = function() {
		var nm = ["achallies","achounich","adam","adie","aindra","aldonich","alduie","allan","allister","alonie","andeoir","andrew","angus","ara","aree","arthur","askill","aslan","aulay","auselan","ay","baxter","bean","beath","beolain","beth","bheath","bride","brieve","burie","caa","cabe","caig","caishe","call","callum","calman","calmont","camie","cammon","cammond","canish","cansh","cartney","cartair","carter","cash","caskill","casland","caul","cause","caw","cay","ceallaich","chlerich","chlery","choiter","chruiter","cloy","clure","cluskie","clymont","codrum","coll","colman","comas","combe","combich","combie","conacher","conachie","conchy","condy","connach","connechy","connell","conochie","cooish","cook","corkill","corkindale","corkle","cormack","cormick","corquodale","corry","cosram","coull","cowan","crae","crain","craken","craw","creath","crie","crimmon","crimmor","crindle","cririe","crouther","cruithein","cuag","cuaig","cubbin","cuish","culloch","cune","cunn","currach","cutchen","cutcheon","dade","daniell","david","dermid","diarmid","donachie","donald","donleavy","dougall","dowall","drain","duff","duffie","dulothe","eachan","eachern","eachin","eachran","earachar","elfrish","elheran","eoin","eol","erracher","ewen","fadzean","fall","farquhar","farlane","fater","feat","fergus","fie","gaw","geachie","geachin","geoch","ghee","gilbert","gilchrist","gill","gilledon","gillegowie","gillivantic","gillivour","gillivray","gillonie","gilp","gilroy","gilvernock","gilvra","gilvray","glashan","glasrich","gorrie","gorry","goun","gowan","grath","gregor","greusich","grewar","grime","grory","growther","gruder","gruer","gruther","guaran","guffie","gugan","guire","haffie","hardie","hardy","harold","hendrie","hendry","howell","hugh","hutchen","hutcheon","iain","ildowie","ilduy","ilreach","illeriach","ilriach","ilrevie","ilvain","ilvora","ilvrae","ilvride","ilwhom","ilwraith","ilzegowie","immey","inally","indeor","indoe","innes","inroy","instalker","intyre","iock","issac","ivor","james","kail","kames","kaskill","kay","keachan","keamish","kean","kechnie","kee","keggie","keith","kellachie","kellaigh","kellar","kelloch","kelvie","kendrick","kenzie","keochan","kerchar","kerlich","kerracher","kerras","kersey","kessock","kichan","kie","kieson","kiggan","killigan","killop","kim","kimmie","kindlay","kinley","kinnell","kinney","kinning","kinnon","kintosh","kinven","kirdy","kissock","knight","lachlan","lae","lagan","laghlan","laine of lochbuie","laren","lairish","lamond","lardie","laverty","laws","lea","lean","leay","lehose","leish","leister","lellan","lennan","leod","lergain","lerie","leverty","lewis","lintock","lise","liver","lucas","lugash","lulich","lure","lymont","manus","martin","master","math","maurice","menzies","michael","millan","minn","monies","morran","munn","murchie","murchy","murdo","murdoch","murray","murrich","mutrie","nab","nair","namell","naughton","nayer","nee","neilage","neill","neilly","neish","neur","ney","nicol","nider","niter","niven","nuir","nuyer","omie","omish","onie","oran","o","oull","ourlic","owen","owl","patrick","petrie","phadden","phail","phater","phee","phedran","phedron","pheidiran","pherson","phillip","phorich","phun","quarrie","queen","quey","quilkan","quistan","quisten","quoid","ra","rach","rae","raild","raith","rankin","rath","ritchie","rob","robb","robbie","robert","robie","rorie","rory","ruer","rurie","rury","shannachan","shimes","simon","sorley","sporran","swan","sween","swen","symon","taggart","tary","tause","tavish","tear","thomas","tier","tire","ulric","ure","vail","vanish","varish","veagh","vean","vicar","vinish","vurich","vurie","walrick","walter","wattie","whannell","whirr","whirter","william","intosh","intyre"];
		for (var i=nm.length-1; i>=0; i--) { nm[i] = "mac"+nm[i]; }
		return nm;
	};

	/**
	 * Check if a word w has to be MacTitled http://www.daire.org/names/scotsurs2.html
	 * -------------------------------------------------------
	 * keschte		2005-05-31		first version
	 **/
	this.isMacTitledWord = function(w) {
		mb.log.enter(this.GID, "isMacTitledWord");
		if (!this.macTitledWords) {
			this.macTitledWords = this.toAssocArray(this.getMacTitledWords());
		}
		var f = this.inArray(this.macTitledWords,w);
		mb.log.debug("$=$", w, f);
		return mb.log.exit(f);
	}; // words_mactitled

	/**
	 * Returns the corresponding bracket to a given
	 * one, or null.
	 * -------------------------------------------------------
	 * keschte		2005-05-31		first version
	 **/
	this.getCorrespondingBracket = function(w) {
		mb.log.enter(this.GID, "getCorrespondingBracket");
		if (!this.bracketPairs) {
			var t = [];
			t["("] = ")"; t[")"] = "(";
			t["["] = "]"; t["]"] = "[";
			t["{"] = "}"; t["}"] = "{";
			t["<"] = ">"; t[">"] = "<";
			this.bracketPairs = t;
		}
		var cb = this.bracketPairs[w];
		if (mb.utils.isNullOrEmpty(cb)) {
			mb.log.warning("Did not find bracket for w: $", w);
			return mb.log.exit("");
		}
		return mb.log.exit(cb);
	}; // parenthesis

	/**
	 * Trim leading, trailing and running-line whitespace from the given string
	 **/
	this.trim  = function(is) {
		mb.log.enter(this.GID, "trim");
		if (mb.utils.isNullOrEmpty(is)) {
			mb.log.error("Parameter is was empty!");
			is = "";
		} else if (typeof is != 'string') {
			mb.log.error("Parameter is was not a string!");
			is = "";
		}
		var os = (is.replace(/^\s\s*/,"").replace(/\s\s*$/,"").replace(/([\(\[])\s+/,"$1").replace(/\s+([\)\]])/,"$1").replace(/\s\s*/g," "));
		return mb.log.exit(os);
	};

	/**
	 *  Upper case first letter of word unless it's one of the words in the
	 *     lowercase words array
	 * @param is	the un-processed input string
	 * @returns				the processed string
	 * change log (who,when,what)
	 * -------------------------------------------------------
	 * tma			2005-01-29		first version
	 * keschte		2005-01-30		added cases for McTitled,MacTitled,O'Titled
	 * keschte		2005-01-31		converted loops to associative arrays.
	 **/
	this.titleString = function(is, forceCaps) {
		mb.log.enter(this.GID, "titleString");
		forceCaps = (forceCaps != null ? forceCaps : gc.f.forceCaps);

		if (mb.utils.isNullOrEmpty(is)) {
			mb.log.warning("Required parameter is was empty!", is);
			return mb.log.exit("");
		}

		// get current pointer in word array
		var len = gc.i.getLength();
		var pos = gc.i.getPos();

		// if pos==len, this means that the pointer is beyond
		// the last position in the wordlist, and that the
		// regular processing is done. we're looking at
		// the last word before collecting the output, and
		// have to adjust the pos to the last element of
		// the wordlist again.
		if (pos == len) {
			gc.i.setPos((pos = len-1));
		}

		// let's see what flags we have set
		mb.log.debug('Titling word: $ (pos: $, length: $)', is, pos, len);
		gc.f.dumpRaisedFlags();

		var wordbefore = gc.i.getWordAtIndex(pos-2);
		var os;
		var LC = is.toLowerCase(); // prepare all LC word
		var UC = is.toUpperCase(); // prepare all UC word
		if ((is == UC) &&
			(is.length > 1) &&
			gc.isConfigTrue(gc.CFG_UC_UPPERCASED)) {
			mb.log.debug('Respect uppercase word: $', is);
			os = UC;

		// we got an 'x (apostrophe),keep the text lowercased
		} else if (LC.length == 1 && gc.i.isPreviousWord("'")) {
			os = LC;

		// we got an 's (It is = It's), lowercased
		// we got an 'all (Y'all = You all), lowercased
		// we got an 'em (Them = 'em), lowercase.
		// we got an 've (They have = They've), lowercase.
		// we got an 'd (He had = He'd), lowercase.
		// we got an 'cha (What you = What'cha), lowercase.
		// we got an 're (You are = You're), lowercase.
		// we got an 'til (Until = 'til), lowercase.
		// we got an 'way (Away = 'way), lowercase.
		// we got an 'round (Around = 'round), lowercased
		} else if (gc.i.isPreviousWord("'") && LC.match(/^(s|round|em|ve|ll|d|cha|re|til|way|all)$/i)) {
			mb.log.debug('Found contraction: $', wordbefore+"'"+LC);
			os = LC;

		// we got an Ev'..
		// Every = Ev'ry, lowercase
		// Everything = Ev'rything, lowercase (more cases?)
		} else if (gc.i.isPreviousWord("'") && wordbefore == "Ev") {
			mb.log.debug('Found contraction: $', wordbefore+"'"+LC);
			os = LC;

		// Make it O'Titled, Y'All
		} else if (LC.match(/^(o|y)$/i) && gc.i.isNextWord("'")) {
			os = UC;

		} else {
			os = this.titleStringByMode(LC, forceCaps);
			LC = os.toLowerCase(); // prepare all LC word
			UC = os.toUpperCase(); // prepare all UC word

			// Test if it's one of the lcWords but if gc.f.forceCaps is not set
			if (gc.mode.isLowerCaseWord(LC) && !forceCaps) {
				os = LC;

			// Test if it's one of the uppercase_words
			} else if (gc.mode.isUpperCaseWord(LC)) {
				os = UC;

			} else if (gc.f.isInsideBrackets()) {
				if (gc.u.isLowerCaseBracketWord(LC)) {

					// handle special case: (disc 1: Disc x)
					// e.g. do not lowercase disc!
					if (gc.f.colon && LC == "disc") {
					} else {
						os = LC;
					}
				}
			}
		}
		mb.log.debug('forceCaps: $, in: $, out: $', forceCaps, is, os);
		return mb.log.exit(os);
	};

	/**
	 * Capitalize the string, but check if some characters
	 * Inside the word need to be uppercased as well.
	 *
	 * @param is	the input string
	 * @returns		the capitalized string, if the flags allow
	 *				GC to capitalize the string.
	 **/
	this.titleStringByMode = function(is, forceCaps) {
		mb.log.enter(this.GID, "titleStringByMode");
		if (is == null || is == "") {
			return mb.log.exit("");
		}
		var os = is.toLowerCase();

		// see if the word before is a sentence stop character.
		// -- http://bugs.musicbrainz.org/ticket/40
		var opos = gc.o.getLength();
		var wordbefore = "";
		if (opos > 1) {
			wordbefore = gc.o.getWordAtIndex(opos-2);
		}

		// if in sentence caps mode, and last char was not
		// a punctuation or opening bracket -> lowercase.
		if ((!gc.f.slurpExtraTitleInformation) &&
			(gc.getMode().isSentenceCaps() && !forceCaps) &&
			(!gc.i.isFirstWord()) &&
			(!gc.u.isSentenceStopChar(wordbefore)) &&
			(!gc.f.openingBracket)) {

			mb.log.debug('SentenceCaps, before: $, after: $', is, os);

		} else {
			var chars = is.toLowerCase().split("");
			chars[0] = chars[0].toUpperCase(); // uppercase first character

			// only look at strings which start with Mc but length > 2
			if (is.length > 2 && is.substring(0,2) == "mc") {
				chars[2] = chars[2].toUpperCase(); // Make it McTitled

			// only look at strings which start with Mac but length > 3
			} else if (gc.u.isMacTitledWord(is)) {
				chars[3] = chars[3].toUpperCase(); // Make it MacTitled
			}
			os = chars.join("");
			mb.log.debug('Capitalized, before: $, after: $', is, os);
		}
		return mb.log.exit(os);
	};


	/**
	 * Convert a given number to roman notation.
	 */
	this.convertToRomanNumeral = function(is) {
		var i = parseInt(is);
		var s = [];
		if ((i > 3999) || (i < 1)) {
			s = ["N/A"];
		} else {
			while (i>999) { s.push("M"); i -= 1000; }
			if (i>899) { s.push("CM"); i -= 900; }
			if (i>499) { s.push("D"); i -= 500; }
			if (i>399) { s.push("CD"); i -= 400; }
			while (i>99) { s.push("C"); i -= 100; }
			if (i>89) { s.push("XC"); i -= 90; }
			if (i>49) { s.push("L"); i -= 50; }
			if (i>39) { s.push("XL"); i -= 40; }
			while (i>9) { s.push("X"); i -= 10; }
			if (i>8) { s.push("IX"); i -= 9; }
			if (i>4) { s.push("V"); i -= 5; }
			if (i>3) { s.push("IV"); i -= 4; }
			while (i>0) { s.push("I"); i -= 1; }
		}
		return mb.log.exit(s.join(""));
	}

	// exit constructor
	mb.log.exit();
}
