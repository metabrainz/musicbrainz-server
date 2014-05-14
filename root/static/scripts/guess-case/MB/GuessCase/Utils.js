/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (c) 2005 Stefan Kestenholz (keschte)
   Copyright (C) 2010-2011 MetaBrainz Foundation

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

*/

MB.GuessCase = (MB.GuessCase) ? MB.GuessCase : {};

/**
 * Utility functions, definitions
 **/
MB.GuessCase.Utils = function () {
    var self = {};

    /**
     * Renders an array to an associative array with lowercase keys.
     **/
    self.toAssocArray = function (a) {
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
    self.inArray = function (a,k) {
	if (a == null || k == null) {
	    return false;
	}
	k = k.toLowerCase();
	var v = (a[k] || null);
	var f = (k != null &&
		 a != null &&
		 v != null &&
		 v == k &&
		 typeof(v) == 'string');

	return f;
    };

    /**
     * template function for wordlists
     * -------------------------------------------------------
     * keschte		2005-10-24		template for a wordlist
     **/
    self.isSomeWord = function (w) {
	if (!self.someWord) {
	    self.someWord = self.toAssocArray([]); // empty array
	}
	return self.inArray(self.someWord,w);
    };


    /**
     * Words which are *not* converted if they are matched as
     * a single pre-processor word at the end of the sentence.
     * -------------------------------------------------------
     * keschte		2005-05-25		first version
     * keschte		2005-07-10		added disco
     * keschte		2005-07-20		added dub
     **/
    self.getPrepBracketSingleWords = function () {
	return ["acoustic", "airplay", "album", "alternate", "alternative",
                "bonus", "clean", "club", "composition", "cut", "dance",
                "dirty", "disc", "disco", "dub", "extended", "feat",
                "instrumental", "live", "long", "main", "megamix", "mix",
                "original", "radio", "remixed", "rework", "reworked",
                "session", "short", "take", "trance", "version", "video",
                "vocal" ];
    };
    self.isPrepBracketSingleWord = function (w) {

	if (!self.preBracketSingleWords) {
	    self.preBracketSingleWords = self.toAssocArray(self.getPrepBracketSingleWords());
	}
	var f = self.inArray(self.preBracketSingleWords,w);

	return f;
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
     * warp             2011-01-31              MBS-1312, add with and without
     * warp             2011-01-31              MBS-1313, add early, piano, rap, studio, techno, and trance
     **/

    self.getLowerCaseBracketWords = function () {
	return [
            'a_cappella', 'acoustic', 'airplay', 'album', 'alternate',
            'alternative', 'bonus', 'clean', 'club', 'clubmix', 'composition',
            'cut', 'dance', 'demo', 'dialogue', 'dirty', 'disc', 'disco', 'dub',
            'early', 'edit', 'excerpt', 'extended', 'feat', 'instrumental',
            'interlude', 'intro', 'karaoke', 'live', 'long', 'main', 'maxi',
            'medley', 'megamix', 'mix', 'orchestral', 'original', 'outro',
            'outtake', 'outtakes', 'piano', 'radio', 'rap', 'reedit',
            'rehearsal', 'reinterpreted', 'remake', 'remix', 'remixed',
            'reprise', 'rework', 'reworked', 'session', 'short', 'single',
            'skit', 'studio', 'take', 'techno', 'trance', 'unplugged',
            'version', 'video', 'vocal', 'vs', 'with', 'without'
        ];
    };

    self.isLowerCaseBracketWord = function (w) {

	if (!self.lowerCaseBracketWords) {
	    self.lowerCaseBracketWords = self.toAssocArray(self.getLowerCaseBracketWords());
	}
	var f = self.inArray(self.lowerCaseBracketWords,w);

	return f;
    }; // lowercase_bracket_words

    /**
     * Words which the pre-processor looks for and puts them
     * into brackets if they arent yet.
     * -------------------------------------------------------
     * keschte		2005-05-25		first version
     **/
    self.isPrepBracketWord = function (w) {

	if (!self.prepBracketWords) {
	    self.prepBracketWords = self.toAssocArray(
		["cd","disk",'12"','7"', "a_cappella", "re_edit"]
		    .concat(self.getLowerCaseBracketWords()));
	}
	var f = self.inArray(self.prepBracketWords,w);

	return f;
    }; // preprocessor_bracket_words


    /**
     * Sequence stop characters
     * -------------------------------------------------------
     * keschte		2005-05-24		first version
     **/
    self.isSentenceStopChar = function (w) {

	if (!self.sentenceStopChars) {
	    self.sentenceStopChars = self.toAssocArray([
		":",".",";","?","!","/"
	    ]);
	}
	var f = self.inArray(self.sentenceStopChars,w);

	return f;
    }; // sentencestop_chars

    /**
     * Apostrophe
     * -------------------------------------------------------
     * warp		2011-08-13		first version
     **/
    self.isApostrophe = function (w) { return w == "'" || w == "’"; };

    /**
     * Punctuation characters
     * -------------------------------------------------------
     * keschte		2005-05-24		first version
     **/
    self.isPunctuationChar = function (w) {
	if (!self.punctuationChars) {
	    self.punctuationChars = self.toAssocArray([
		":",".",";","?","!",","
	    ]);
	}
	return self.inArray(self.punctuationChars,w);
    }; // punctuation_chars

    /**
     * Check if a word w has to be MacTitled http://www.daire.org/names/scotsurs2.html
     * -------------------------------------------------------
     **/
    self.getMacTitledWords = function () {
	var nm = ["achallies","achounich","adam","adie","aindra","aldonich","alduie","allan","allister","alonie","andeoir","andrew","angus","ara","aree","arthur","askill","aslan","aulay","auselan","ay","baxter","bean","beath","beolain","beth","bheath","bride","brieve","burie","caa","cabe","caig","caishe","call","callum","calman","calmont","camie","cammon","cammond","canish","cansh","cartney","cartair","carter","cash","caskill","casland","caul","cause","caw","cay","ceallaich","chlerich","chlery","choiter","chruiter","cloy","clure","cluskie","clymont","codrum","coll","colman","comas","combe","combich","combie","conacher","conachie","conchy","condy","connach","connechy","connell","conochie","cooish","cook","corkill","corkindale","corkle","cormack","cormick","corquodale","corry","cosram","coull","cowan","crae","crain","craken","craw","creath","crie","crimmon","crimmor","crindle","cririe","crouther","cruithein","cuag","cuaig","cubbin","cuish","culloch","cune","cunn","currach","cutchen","cutcheon","dade","daniell","david","dermid","diarmid","donachie","donald","donleavy","dougall","dowall","drain","duff","duffie","dulothe","eachan","eachern","eachin","eachran","earachar","elfrish","elheran","eoin","eol","erracher","ewen","fadzean","fall","farquhar","farlane","fater","feat","fergus","fie","gaw","geachie","geachin","geoch","ghee","gilbert","gilchrist","gill","gilledon","gillegowie","gillivantic","gillivour","gillivray","gillonie","gilp","gilroy","gilvernock","gilvra","gilvray","glashan","glasrich","gorrie","gorry","goun","gowan","grath","gregor","greusich","grewar","grime","grory","growther","gruder","gruer","gruther","guaran","guffie","gugan","guire","haffie","hardie","hardy","harold","hendrie","hendry","howell","hugh","hutchen","hutcheon","iain","ildowie","ilduy","ilreach","illeriach","ilriach","ilrevie","ilvain","ilvora","ilvrae","ilvride","ilwhom","ilwraith","ilzegowie","immey","inally","indeor","indoe","innes","inroy","instalker","intyre","iock","issac","ivor","james","kail","kames","kaskill","kay","keachan","keamish","kean","kechnie","kee","keggie","keith","kellachie","kellaigh","kellar","kelloch","kelvie","kendrick","kenzie","keochan","kerchar","kerlich","kerracher","kerras","kersey","kessock","kichan","kie","kieson","kiggan","killigan","killop","kim","kimmie","kindlay","kinley","kinnell","kinney","kinning","kinnon","kintosh","kinven","kirdy","kissock","knight","lachlan","lae","lagan","laghlan","laine of lochbuie","laren","lairish","lamond","lardie","laverty","laws","lea","lean","leay","lehose","leish","leister","lellan","lennan","leod","lergain","lerie","leverty","lewis","lintock","lise","liver","lucas","lugash","lulich","lure","lymont","manus","martin","master","math","maurice","menzies","michael","millan","minn","monies","morran","munn","murchie","murchy","murdo","murdoch","murray","murrich","mutrie","nab","nair","namell","naughton","nayer","nee","neilage","neill","neilly","neish","neur","ney","nicol","nider","niter","niven","nuir","nuyer","omie","omish","onie","oran","o","oull","ourlic","owen","owl","patrick","petrie","phadden","phail","phater","phee","phedran","phedron","pheidiran","pherson","phillip","phorich","phun","quarrie","queen","quey","quilkan","quistan","quisten","quoid","ra","rach","rae","raild","raith","rankin","rath","ritchie","rob","robb","robbie","robert","robie","rorie","rory","ruer","rurie","rury","shannachan","shimes","simon","sorley","sporran","swan","sween","swen","symon","taggart","tary","tause","tavish","tear","thomas","tier","tire","ulric","ure","vail","vanish","varish","veagh","vean","vicar","vinish","vurich","vurie","walrick","walter","wattie","whannell","whirr","whirter","william","intosh","intyre"];
	for (var i=nm.length-1; i>=0; i--) { nm[i] = "mac"+nm[i]; }
	return nm;
    };

    /**
     * Check if a word w has to be MacTitled http://www.daire.org/names/scotsurs2.html
     * -------------------------------------------------------
     * keschte		2005-05-31		first version
     **/
    self.isMacTitledWord = function (w) {

	if (!self.macTitledWords) {
	    self.macTitledWords = self.toAssocArray(self.getMacTitledWords());
	}
        return self.inArray(self.macTitledWords,w);
    }; // words_mactitled

    /**
     * Returns the corresponding bracket to a given
     * one, or null.
     * -------------------------------------------------------
     * keschte		2005-05-31		first version
     **/
    self.getCorrespondingBracket = function (w) {

	if (!self.bracketPairs) {
	    var t = [];
	    t["("] = ")"; t[")"] = "(";
	    t["["] = "]"; t["]"] = "[";
	    t["{"] = "}"; t["}"] = "{";
	    t["<"] = ">"; t[">"] = "<";
	    self.bracketPairs = t;
	}
	var cb = self.bracketPairs[w];
	if (MB.utility.isNullOrEmpty(cb)) {
	    return "";
	}
	return cb;
    }; // parenthesis

    /**
     * Trim leading, trailing and running-line whitespace from the given string
     **/
    self.trim  = function (is) {

	if (MB.utility.isNullOrEmpty(is)) {
	    is = "";
	} else if (typeof is != 'string') {
	    is = "";
	}
        return (is.replace(/^\s\s*/,"").replace(/\s\s*$/,"").replace(/([\(\[])\s+/,"$1").replace(/\s+([\)\]])/,"$1").replace(/\s\s*/g," "));
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
    self.titleString = function (is, forceCaps) {

	forceCaps = (forceCaps != null ? forceCaps : gc.f.forceCaps);

	if (MB.utility.isNullOrEmpty(is)) {
	    return "";
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

	var wordbefore = gc.i.getWordAtIndex(pos-2);
	var os;
	var LC = is.toLowerCase(); // prepare all LC word
	var UC = is.toUpperCase(); // prepare all UC word
	if (is == UC && is.length > 1 && gc.CFG_UC_UPPERCASED) {
	    os = UC;

	    // we got an 'x (apostrophe),keep the text lowercased
	} else if (LC.length == 1 && self.isApostrophe(gc.i.getPreviousWord())) {
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
	} else if (self.isApostrophe(gc.i.getPreviousWord()) && LC.match(/^(s|round|em|ve|ll|d|cha|re|til|way|all)$/i)) {
	    os = LC;

	    // we got an Ev'..
	    // Every = Ev'ry, lowercase
	    // Everything = Ev'rything, lowercase (more cases?)
	} else if (self.isApostrophe(gc.i.getPreviousWord()) && wordbefore == "Ev") {
	    os = LC;

	    // Make it O'Titled, Y'All
	} else if (LC.match(/^(o|y)$/i) && self.isApostrophe(gc.i.getNextWord())) {
	    os = UC;

	} else {
	    os = self.titleStringByMode(LC, forceCaps);
	    LC = os.toLowerCase(); // prepare all LC word
	    UC = os.toUpperCase(); // prepare all UC word

            var next_word = gc.i.getNextWord();
            var followed_by_punctuation =
                next_word && next_word.length == 1 && self.isPunctuationChar(next_word);

	    // unless forceCaps is enabled, lowercase the word if it is not followed
            // by punctuation.
	    if (!forceCaps && gc.mode.isLowerCaseWord(LC) && !followed_by_punctuation) {
		os = LC;
	    }

	    // Test if it's one of the uppercase_words
            else if (gc.mode.isUpperCaseWord(LC)) {
		os = UC;
	    }

            else if (gc.f.isInsideBrackets()) {
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
	return os;
    };

    /**
     * Capitalize the string, but check if some characters
     * Inside the word need to be uppercased as well.
     *
     * @param is	the input string
     * @returns		the capitalized string, if the flags allow
     *				GC to capitalize the string.
     **/
    self.titleStringByMode = function (is, forceCaps) {
	if (is == null || is == "") {
	    return "";
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
	    (gc.mode.isSentenceCaps() && !forceCaps) &&
	    (!gc.i.isFirstWord()) &&
	    (!gc.u.isSentenceStopChar(wordbefore)) &&
	    (!gc.f.openingBracket)) {

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
	}
	return os;
    };


    /**
     * Convert a given number to roman notation.
     */
    self.convertToRomanNumeral = function (is) {
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
	return s.join("");
    }

    return self;
}
