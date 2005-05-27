// http://ioctl.org/jan/test/regexp.htm

// Words which are always written lowercase.
// change log (who, when, what)
// -------------------------------------------------------
// tma			2004-01-29		first version
// g0llum		2004-04-17		added french lowercase characters
var word_arr = [
	 "a", "and", "n", "an", "as", "at", "but",
	 "by", "for", "in", "nor", "of", "o", "on",
	 "or", "the", "to", "der", "und", "de", "du",
	 "et", "la", "le", "les", "un", "une", "y",
	 "con", "di", "da", "del", "à", "â", "ç", "è", 
	 "é", "ê", "ô", "ù", "û", "aux"
];
lowercase_words = toAssociativeArray(word_arr);

// Words which are written lowercase if in brackets
// change log (who, when, what)
// -------------------------------------------------------
// tma			2004-01-29		first version
// g0llum		2004-01-29		added dub, megamix, maxi
// .various		2005-05-09		karaoke, acapella
word_arr = [
	 "acoustic", "album", "alternate", "bonus", "clean",
	 "club", "dance", "dirty", "disc", "extended",
	 "instrumental", "live", "original", "radio",
	 "single", "take", "demo", "disc", "edit",
	 "skit", "mix", "remix", "take", "version",
	 "reprise", "dub", "megamix", "maxi", "feat",
	 "interlude", "dialogue", "cut", "karaoke",
	 "acapella", "vs", "vocal", "trance", "techno", 
	 "house", "alternative",
];
var lowercase_bracket_words = toAssociativeArray(word_arr);

// Words which the pre-processor looks for and puts them
// into brackets if they arent yet.
// change log (who, when, what)
// -------------------------------------------------------
// g0llum		2004-05-25		first version
var preprocessor_bracket_words = [
	 "cd", "disk", '12"', '7"'
]
preprocessor_bracket_words = toAssociativeArray(
	preprocessor_bracket_words.concat(word_arr)
);


// Words which are always written UPPERCASE.
// change log (who, when, what)
// -------------------------------------------------------
// g0llum		2004-01-31		first version
// .various		2004-05-05		added "FM...PM"
// g0llum		2004-05-24		removed AM,PM because it yielded false positives e.g. "I AM stupid"
word_arr = [
	"DJ", "MC", "TV", "MTV", "EP", "LP", "I",
	"II", "III", "IIII", "IV", "V", "VI", "VII",
	"VIII", "IX", "X", "BWV", "YMCA", "NYC", "R&B",
	"BBC", "FM", "BC", "AD", "AC", "DC"
];
uppercase_words = toAssociativeArray(word_arr);

// Punctuation characters
// change log (who, when, what)
// -------------------------------------------------------
// g0llum		2004-05-24		first version
word_arr = [
	":", ".", ",", ";", "?", "!"
];
punctuation_chars = toAssociativeArray(word_arr);

// Contractions http://englishplus.com/grammar/00000136.htm
// change log (who, when, what)
// -------------------------------------------------------
// g0llum		2004-04-19		first version
// g0llum		2004-05-25		added that'll, ain't
word_arr = [
	"aren't", "can't", "couldn't", "doesn't", "don't", "hadn't", "hasn't",
	"haven't", "he'd", "he'll", "here's", "he's", "i'd", "i'll", "i'm",
	"isn't", "it'd", "it'll", "it's", "i've", "let's", "mustn't", "she'd",
	"she'll", "she's", "shouldn't", "that'd", "that's", "there'd",
	"there'll", "there's", "they'd", "they'll", "they're", "they've",
	"wasn't", "we'd", "we're", "weren't", "we've", "what's", "who'd",
	"who's", "won't", "wouldn't", "you'd", "you'll", "you're", "you've",
	"ain't", "that'll", 
	"10's", "20's", "30's", "40's", "50's", "60's", "70's", "80's", "90's", "00's"
];
contraction_words = toContractionWords(word_arr);





// define matching characters for opening parantheses
var parenthesis = new Array();
parenthesis["("] = ")"; parenthesis["["] = "]";
parenthesis["{"] = "}"; parenthesis["<"] = ">";
parenthesis[")"] = "("; parenthesis["]"] = "[";
parenthesis["}"] = "{"; parenthesis[">"] = "<";

// These flags control the spacing/capitalization
var last_char_was_whitespace		= false;
var last_char_was_open_parenthesis	= false;
var last_char_was_hyphen			= false;
var last_word_was_colon				= false;
var last_char_was_acronym_split		= false;
var last_char_was_singlequote		= false;
var ellipsis						= false;

// holds the splitted words for processing.
var words							= new Array();
var words_index						= 0; // was "i" before
var words_subindex					= 0; // was "j" before
var words_candidate					= "";
var words_acronym					= new Array();
var words_number					= new Array();

// processed title goes here
var fixed_name						= new Array();

// used to keep track of levels of parenthesis
var open_bracket					= new Array();	 
var current_open_bracket			= "";
var current_close_bracket			= "";

// flag to force next to caps first letter
// seeded true because the first word should be capped
var force_capitalize_next_word			= true;

// flag to force a space before the next word
var space_next_word					= false;

// flag so we know not to lowercase acronyms if followed by major punctuation
var last_word_was_an_acronym		= false;

// flag is used for the number splitting routine (ie: 10,000,000)
var last_word_was_a_number			= false;

// flag is used for the detection of DiscWithNameStyle
var last_word_was_disc				= false;
var last_word_was_feat				= false;

// defines the current number split. note that this will not be cleared,
//which has the side-effect of forcing the first type of number split
// encountered to be the only one used for the entire string, assuming
// that people aren't going to be mixing grammar in titles.
var number_split					= null;

// Message stack
var debug_msgs = null;
var debug_starttime = null;


// ----------------------------------------------------------------------------
// resetMessages()
// -- Resets the debug messages
function resetMessages() {
	debug_msgs = new Array();
	debug_starttime = new Date().getTime();
}


// ----------------------------------------------------------------------------
// getMessages()
// -- Resets the list of debug messages
function getMessages() {
	return "<br> &nbsp; &nbsp; &nbsp;" + debug_msgs.join("<br> &nbsp; &nbsp; &nbsp;");
}


// ----------------------------------------------------------------------------
// addMessage()
// -- Adds a message to the list of debug messages
function addMessage(message) {
	debug_msgs[debug_msgs.length] = (new Date().getTime()-debug_starttime)+"[ms] :: "+message;
}
resetMessages();


// ----------------------------------------------------------------------------
// toAssociativeArray()
// -- Renders an array to an associative array
//    with lowercase keys.
function toAssociativeArray(thearray) {
	var temp = [];
	try {
		for (var m=0; m<thearray.length; m++) {
			var curr = thearray[m].toLowerCase()
			temp[curr] = curr;
		}
	} catch (e) {}
	return temp;
}


// ----------------------------------------------------------------------------
// toContractionWords()
// -- Renders the contraction words into an array which supports
//    lookup with the left part of the contraction like Isn't = array['Isn'] = 't';
function toContractionWords(thearray) {
	var temp = [];
	try {
		for (var i=0; i<thearray.length; i++) {
			var curr = thearray[i].toLowerCase();
			var parts = curr.split("'");
			var left_part = parts[0];
			var right_part = parts[1];
			if (left_part != null && right_part != null) {
				if (temp[left_part] == null) temp[left_part] = new Array();
				temp[left_part][temp[left_part].length] = right_part;
			}
		}
	} catch (e) {}
	return temp;
}


// ----------------------------------------------------------------------------
// resetContextFlags()
// -- Reset the context flags
function resetContextFlags() {
	last_char_was_whitespace = false;
	last_char_was_open_parenthesis = false;
	last_char_was_hyphen = false;
	last_word_was_colon = false;
	last_char_was_acronym_split = false;
	last_char_was_singlequote = false;
	ellipsis = false;
}


// ----------------------------------------------------------------------------
// resetGlobals()
// -- Reset the Global variables
function resetGlobals() {
	fixed_name = new Array();
	open_bracket = new Array();
	force_capitalize_next_word = true;
	space_next_word = false;
	last_word_was_an_acronym = false;
	last_word_was_a_number = false;
	last_word_was_disc = false;
	last_word_was_feat = false;
	last_word_was_colon = false;
	number_split = null;
}


// ----------------------------------------------------------------------------
// capitalizeLastWord()
// -- Capitalize the word at the current cursor position.
//    Modifies the last element of the fixed_name array
function capitalizeLastWord() {
	if (fixed_name.length == 0) return;
	var lastpos = fixed_name.length-1;
	var before = fixed_name[lastpos];
	var after = fixed_name[lastpos];
	if (fixed_name[lastpos].match(/^\w\..*/) == null) { // check that last word was not an acronym
		var probe = trim(fixed_name[lastpos].toLowerCase()); // some words that were manipulated might have space padding
		if (isInsideBrackets() && lowercase_bracket_words[probe] != null) { // If inside brackets, do nothing.
		} else if (uppercase_words[probe] != null) { // If it is an UPPERCASE word, do nothing.
		} else {
			var titledString = titleCaseWithExceptions(probe);
			fixed_name[lastpos] = titledString;
			addMessage('capitalizeLastWord() :: before=<span class="mbword">'+before+'</span>, after=<span class="mbword">'+titledString +'</span>');
		}
	}
}

// ----------------------------------------------------------------------------
// titleCaseWithExceptions()
// -- Capitalize the string, but check if some characters
//    inside the word need to be uppercased as well.
function titleCaseWithExceptions(input_string) {
	if (input_string == null || input_string == "") return "";
	var chars = input_string.split("");
	chars[0] = chars[0].toUpperCase(); // uppercase first character
	if (input_string.length > 2 && input_string.substring(0,2) == "mc") { // only look at strings which start with Mc but length > 2
		chars[2] = chars[2].toUpperCase(); // Make it McTitled
	} else if (input_string.length > 3 && input_string.substring(0,3) == "mac") { // only look at strings which start with Mac but length > 3
		chars[3] = chars[3].toUpperCase(); // Make it MacTitled
	} else if (input_string.length > 2 && input_string.substring(0,2) == "o'") { // only look at strings which start with O' but length > 2
		chars[2] = chars[2].toUpperCase(); // Make it O'Titled
	} 
	return chars.join("");
}


// ----------------------------------------------------------------------------
// splitWordsAndPunctuation()
// -- This function will return an array of all the words,
// 	  punctuation and spaces of the input string
//    Before splitting the string into the different
//    candidates, the following actions are taken:
//      * remove leading and trailing whitespace
//      * compress whitespace, e.g replace all instances of
//        multiple space with a single space
// @param	 input_string		the un-processed input string
// @returns								 sets the GLOBAL array of words and puctuation characters
function splitWordsAndPunctuation(input_string) {
	input_string = input_string.replace(/^\s\s*/, ""); // delete leading space
	input_string = input_string.replace(/\s\s*$/, ""); // delete trailing space
	input_string = input_string.replace(/\s\s*/g, " "); // compress whitespace:
	var localwords = new Array();
	var chars = input_string.split("");
	var word = "";
	for (var i=0; i<chars.length; i++) {
		if (chars[i].match(/[^!\"%&'()\[\]\{\}\*\+,-\.\/:;<=>\?\s]/)) {
			// see http://www.codingforums.com/archive/index.php/t-49001
			// for reference (escaping the sequence)
			word += chars[i]; // greedy match anything except our stop characters
		} else {
			if (word != "") localwords[localwords.length] = word;
			localwords[localwords.length] = chars[i];
			word = "";
		}
	}
	localwords[localwords.length] = word;
	var dumpwords = '';
	for (var ci=0; ci<localwords.length; ci++) {
		dumpwords += '<span class="mbword">';
		dumpwords += localwords[ci].replace(" ", "&nbsp");
		dumpwords += '</span> ';
	}
	addMessage('splitWordsAndPunctuation() :: words: '+dumpwords);
	return localwords;
}

// ----------------------------------------------------------------------------
// replaceAbbreviations()
// --  take care of "RMX", "alt. take" "alt take"
function replaceAbbreviations(input_string) {
	var searchlist = new Array(
		new Array(/(\s|\()re-mix((\s|\))|$)/i, "remix"),
		new Array(/(\s|\()RMX((\s|\))|$)/i, "remix"),
		new Array(/(\s|\()alt[\.]? take((\s|\))|$)/i, "alternate take")
	);
	for (var i=0; i<searchlist.length; i++) {
		var re = searchlist[i][0];
		var match = input_string.match(re);
		if (match) {
			var replaceStr = match[1] + searchlist[i][1] + match[2];
			input_string = input_string.replace(re, replaceStr);
			// addMessage(re+' '+match+' <span class="mbword">'+replaceStr.replace(' ', '&nbsp;')+'</span>');
		}
	}
	addMessage('replaceAbbreviations() :: after processing <span class="mbword">'+input_string.replace(" ", "&nbsp")+'</span>');
	return input_string;
}

// ----------------------------------------------------------------------------
// handleVinylExpressions()
// --
// * look only at substrings which start with ' '  OR '('
// * convert 7', 7'', 7", 7in, 7inch TO '7"_' (with a following SPACE)
// * convert 12', 12'', 12", 12in, 12inch TO '12"_' (with a following SPACE)
// * do NOT handle strings like 80's	
// Examples:
//  Original string: "Fine Day (Mike Koglin 12' mix)"
//  	Last matched portion: " 12' "
//  	Matched portion 1 = " "
//  	Matched portion 2 = "12'"
//  	Matched portion 3 = "12"
//  	Matched portion 4 = "'"
//  	Matched portion 5 = " "
//  Original string: "Where Love Lives (Come on In) (12"Classic mix)"
//  	Last matched portion: "(12"C"
//  	Matched portion 1 = "("
//  	Matched portion 2 = "12""
//  	Matched portion 3 = "12"
//  	Matched portion 4 = """
//  	Matched portion 5 = "C"
//  Original string: "greatest 80's hits"
//		Match failed.
function handleVinylExpressions(return_string) {
	var re = /(\s+|\()((\d+)(inch\b|in\b|'+|"))([^s])/i;
	var m = return_string.match(re);
	if (m) {
		var mindex = m.index;
		var mlenght  = m[1].length + m[2].length + m[5].length; // calculate the length of the expression
		var firstPart = return_string.substring(0, mindex);
		var lastPart = return_string.substring(mindex+mlenght, return_string.length); // add number
		var parts = new Array(); // compile the vinyl designation.
		parts[parts.length] = firstPart;
		parts[parts.length] = m[1]; // add matched first expression (either ' ' or '('
		parts[parts.length] = m[3]; // add matched number, but skip the in,inch,'' part
		parts[parts.length] = '"'; // add vinyl doubleqoute
		parts[parts.length] = (m[5] != " " ? " " : ""); // add space after ", if none is present
		parts[parts.length] = m[5]; // add number
		parts[parts.length] = lastPart;
		return_string = parts.join("");
	}
	return return_string;
}

// ----------------------------------------------------------------------------
// preProcessTrackNameWords()
// --
// pre-process to find any lowercase_bracket word that needs to be put into parantheses.
// starts from the back and collects words that belong into
// the brackets: e.g.
// My Track Extended Dub remix => My Track (extended dub remix)
// My Track 12" remix => My Track (12" remix)
function preprocessTrackNameWords(tnwords) {
	var wi = tnwords.length-1;
	var handlePreProcess = false;
	var isDoubleQuote = false;
	while (((tnwords[wi] == " ") || // skip whitespace
		   (tnwords[wi] == '"' && (tnwords[wi-1] == "7" || tnwords[wi-1] == "12")) || // vinyl 7" or 12"
		   (tnwords[wi+1] == '"' && (tnwords[wi] == "7" || tnwords[wi] == "12")) || 
		   (preprocessor_bracket_words[tnwords[wi].toLowerCase()] != null)) && 
		    wi >= 0) {
		handlePreProcess = true;
		wi--;
	}
	if (handlePreProcess && wi !=  tnwords.length-1) {
		wi++; // increment to last word that matched.
		var newwords = tnwords.slice(0, wi);
		newwords[newwords.length] = "(";
		newwords = newwords.concat(tnwords.slice(wi, tnwords.length));
		newwords[newwords.length] = ")";
		tnwords = newwords;
		addMessage('preprocessTrackNameWords() :: after pre-process <span class="mbword">'+tnwords.join("").replace(" ", "&nbsp")+'</span>');
	}
	return tnwords;
}

// ----------------------------------------------------------------------------
// titleCase()
// --  Upper case first letter of word unless it's one of lowercase_words[]
// @param input_string	the un-processed input string
// @returns				the processed string
//
// change log (who, when, what)
// -------------------------------------------------------
// tma			2004-01-29		first version
// g0llum		2004-01-30		added cases for McTitled, MacTitled, O'Titled
// g0llum		2004-01-31		converted loops to associative arrays.
//
// TODO:
// -----
// * is this proper for all words?
function titleCase(input_string) {
	var return_string = input_string.toLowerCase();
	if (return_string == null) return "";
	if (return_string == "") return return_string;
	if (return_string.length == 1 && words_index > 1 && words[words_index - 1] == "'") { 
		// we got an 'x (apostrophe), keep the text lowercased
	} else if (return_string == "round" && words[words_index - 1] == "'") { 
		// we got an 'round (apostrophed Around), keep the text lowercased
	} else if (return_string == "o" && words[words_index + 1] == "'") { 
		// Make it O'Titled
		return_string = input_string.toUpperCase(); 
	} else {
		return_string = titleCaseWithExceptions(return_string);
		var probe = return_string.toLowerCase(); // prepare probe to lookup entries of the wordlists.
		if (lowercase_words[probe] != null && !force_capitalize_next_word) { // Test if it's one of the lowercase_words  but if force_capitalize_next_word is not set,
			return_string = input_string.toLowerCase();
		} else if (uppercase_words[probe] != null) { // Test if it's one of the uppercase_words
			return_string = input_string.toUpperCase();
		} else if (isInsideBrackets()) { // If inside brackets
			if (lowercase_bracket_words[probe] != null) { // Test if it's one of the lowercase_bracket_words
				if (last_word_was_colon && probe == "disc") { // handle special case: (disc 1: Disc x)
				} else return_string = input_string.toLowerCase();
			}
		}
	}
	addMessage('titleCase(input=<span class="mbword">'+input_string.replace(' ', '&nbsp;')+'</span>, force_caps='+force_capitalize_next_word+') OUT: <span class="mbword">'+return_string.replace(' ', '&nbsp;')+'</span>');
	return return_string;
}



/* ************************************************************************* */
/*																		     */
/* Methods which manipulate the fixed_name array.        					 */
/*														                     */
/* ************************************************************************* */


// ----------------------------------------------------------------------------
// appendWordToFixedName()
// -- Adds the current candidate to the fixed_name array
function appendWordToFixedName(word) {
	if (word != "" && word != null) {
		addMessage('&nbsp;&nbsp;appendWordToFixedName(word=<span class="mbword">"'+word.replace(" ", "&nbsp;")+'"</span>)');
		fixed_name[fixed_name.length] = word;
	}
}


// ----------------------------------------------------------------------------
// appendSpaceToFixedName()
// -- Adds a space to the fixed_name array
function appendSpaceToFixedName() {
	appendWordToFixedName(" ");
}


// ----------------------------------------------------------------------------
// appendSpaceToFixedNameIfNeeded()
// -- Checks the global flag space_next_word
//    and adds a space to the fixed_name array
//    if needed. The flag is *NOT* reset.
function appendSpaceToFixedNameIfNeeded() {
	if (space_next_word) appendWordToFixedName(" ");
}









/* ************************************************************************* */
/*																		     */
/* methods which handle the different candidate types below					 */
/*														                     */
/* ************************************************************************* */


// ----------------------------------------------------------------------------
// handleWhiteSpace()
// -- Deal with whitespace.				(\t)
//    primarily we only look at whitespace for context purposes
function handleWhiteSpace() {
	if (words_candidate.match(/\s/) != null && !last_word_was_disc) {
		last_char_was_whitespace = true;
		space_next_word = true;
		if (last_char_was_open_parenthesis) space_next_word = false;
		return true;
	}
	return false;
}


// ----------------------------------------------------------------------------
// handleColons()
// -- Deal with colons (:)
//    colons are used as a sub-title split, and also for disc/box name splits
function handleColons() {
	if (words_candidate.match(/\:/) != null) {
		addMessage('handleColons() :: "'+words_candidate+'"');
		resetContextFlags();
		force_capitalize_next_word = true;
		last_word_was_colon = true;
		space_next_word = true;
		appendWordToFixedName(words_candidate);
		return true;
	}
	return false;
}


// ----------------------------------------------------------------------------
// handleLineTerminators()
// -- Deal with ampersands (&)
function handleAmpersands() {
	if (words_candidate.match(/\&/) != null) {
		addMessage('handleAmpersands() :: "'+words_candidate+'"');
		resetContextFlags();
		force_capitalize_next_word = true;
		appendSpaceToFixedName(); // add a space, and remember to
		space_next_word = true; // add one before the next word
		appendWordToFixedName(words_candidate);
		return true;
	}
	return false;
}


// ----------------------------------------------------------------------------
// handleLineTerminators()
// -- Deal with line terminators (?!;)
//    (other than the period).
function handleLineTerminators() {
	if (words_candidate.match(/[\?\!\;]/) != null) {
		addMessage('handleLineTerminators() :: "'+words_candidate+'"');
		resetContextFlags();
		force_capitalize_next_word = true;
		space_next_word = true;
		appendWordToFixedName(words_candidate);
		return true;
	}
	return false;
}


// ----------------------------------------------------------------------------
// handleHypens()
// -- Deal with hyphens (-)
//    if a hyphen has a space near it, then it should be spaced out and treated
//    similar to a sentence pause, otherwise it's a part of a hyphenated word.
//    unfortunately it's not practical to implement real em-dashes, however we'll
//    treat a spaced hyphen as an em-dash for the purposes of caps.
function handleHypens() {
	if (words_candidate.match(/-/) != null) {
		addMessage('handleHypens() :: "'+words_candidate+'"');
		if (last_char_was_whitespace) {
			appendSpaceToFixedName(); // add a space, and remember to
			space_next_word = true; // add one before the next word
		} else {
			space_next_word = false;
		}
		appendWordToFixedName(words_candidate);
		if (!space_next_word && words[words_index + 1] == " ") {
			words_index++; // fix case where 95- 96, e.g. skip trailing whitespace if there was none before the hyphen
		}
		resetContextFlags();
		force_capitalize_next_word = true;
		last_char_was_hyphen = true;
		return true;
	}
	return false;
}


// ----------------------------------------------------------------------------
// handlePlus()
// -- Deal with plus symbol	(+)
function handlePlus() {
	if (words_candidate.match(/\+/) != null) {
		addMessage('handlePlus() :: "'+words_candidate+'"');
		if (last_char_was_whitespace) {
			appendSpaceToFixedName(); // add a space, and remember to
			space_next_word = true; // add one before the next word
		} else {
			space_next_word = false;
		}
		appendWordToFixedName(words_candidate);
		resetContextFlags();
		force_capitalize_next_word = true;
		return true;
	}
	return false;
}


// ----------------------------------------------------------------------------
// handleSlashes()
// -- Deal with slashes (/)
//    if a slash has a space near it, pad it out, otherwise leave as is.
//    @flags:
//      * Next word capitalized
//      * Do not add a space before next word.
function handleSlashes() {
	if (words_candidate.match(/[\\\/]/) != null) {
		addMessage("handleSlashes() :: whitespace before="+last_char_was_whitespace);
		if (last_char_was_whitespace) {
			appendSpaceToFixedName(); // keep whitespace before "/"
		}
		appendWordToFixedName(words_candidate);
		force_capitalize_next_word = true;
		space_next_word = false;
		resetContextFlags();
		return true;
	}
	return false;
}


// ----------------------------------------------------------------------------
// handleDoubleQuotes()
// -- Deal with double quotes (")
function handleDoubleQuotes() {
	if (words_candidate.match(/\"/) != null) {
		addMessage("handleDoubleQuotes() :: ");
		if (last_char_was_whitespace) {
			appendSpaceToFixedName(); // keep whitespace before "/"
		}
		appendWordToFixedName(words_candidate);
		force_capitalize_next_word = true;
		resetContextFlags();
		space_next_word = (words[words_index + 1 == " "]); // keep whitespace intact
		return true;
	}
	return false;
}


// ----------------------------------------------------------------------------
// handleSingleQuotes()
// -- Deal with single quotes (')
//    * need to keep context on whether we're inside quotes or not.
//    * Look for contractions (see contractions_words for a list of
// 	    Contractions that are handled, and format the right part (after)
//      the (') as lowercase.
//    @flags:
//      * Toggle open_doublequote
//      * Capitalize next word in any case
//      * Do not add space if opened quotes
function handleSingleQuotes() {
	if (words_candidate.match(/'/) != null) {
		addMessage("handleSingleQuotes() :: ");
		var foundcontraction = false;
		if (!last_char_was_whitespace && words_index > 0 && words_index < words.length-1) {
			var left_part = words[words_index-1].toLowerCase();
			var right_part = words[words_index+1].toLowerCase();
			var haystack = contraction_words[left_part];
			if (haystack != null && right_part != " ") {
				for (var cwi=0; cwi<haystack.length; cwi++) {
					if (haystack[cwi] == right_part) {
						addMessage("handleSingleQuotes() :: Found contraction="+left_part+"'"+right_part);
						foundcontraction = true;
						appendWordToFixedName(words_candidate+""+right_part);
						words_index++;
					}
				}
			}
		}
		if (!foundcontraction) {
			if (last_char_was_whitespace) appendSpaceToFixedName();
			appendWordToFixedName(words_candidate);
			force_capitalize_next_word = true;
			space_next_word = false;
		}
		resetContextFlags();
		last_char_was_singlequote = true;
		return true;
	}
	return false;
}


// ----------------------------------------------------------------------------
// handleOpeningParenthesis()
// -- Deal with opening parenthesis	(([{<)
//    knowing whether we're inside parenthesis (and multiple levels thereof) is
//    important for determining what words should be capped or not.
//    @flags:
//      * Set current_open_bracket
//      * Capitalize next word in any case
//      * Do not add space before next word
function handleOpeningParenthesis() {
	if (words_candidate.match(/[\(\[\{\<]/) != null) {
		addMessage('handleOpeningParenthesis() :: "'+words_candidate+'", stack: ('+open_bracket+')');
		current_open_bracket = words_candidate;
		current_close_bracket = parenthesis[current_open_bracket]; // Set what we look for as a closing paranthesis
		bracketloop:
		for (var di = words_index + 1; di < words.length; di++) {
			if (words[di] == current_close_bracket) {
				open_bracket[open_bracket.length] = current_open_bracket;
				break bracketloop;
			}
		}
		capitalizeLastWord(); // force caps on last word
		appendSpaceToFixedNameIfNeeded();
		resetContextFlags();
		space_next_word = false;
		last_char_was_open_parenthesis = true;
		force_capitalize_next_word = true;
		appendWordToFixedName(words_candidate);
		return true;
	}
	return false;
}


// ----------------------------------------------------------------------------
// handleClosingParenthesis()
// -- Deal with closing parenthesis	(([{<)
//    knowing whether we're inside parenthesis (and multiple levels thereof) is
//    important for determining what words should be capped or not.
//    @flags:
//      * Set current_open_bracket
//      * Capitalize next word in any case
//      * Add space before next word
function handleClosingParenthesis() {
	if (words_candidate.match(/[\)\]\}\>]/) != null) {
		addMessage('handleClosingParenthesis() :: "'+words_candidate+'", stack: ('+open_bracket+')');
		capitalizeLastWord(); // capitalize the last word
		if (isInsideBrackets()) {
			current_close_bracket = words_candidate;
			current_open_bracket = parenthesis[current_close_bracket];
			if (current_open_bracket == open_bracket[open_bracket.length - 1]) {
				open_bracket.pop();
			}
		}
		resetContextFlags();
		force_capitalize_next_word = true;
		space_next_word = true;
		appendWordToFixedName(words_candidate);
		return true;
	}
	return false;
}

// ----------------------------------------------------------------------------
// isInsideBrackets()
//
function isInsideBrackets() {
	return (open_bracket.length > 0);
}

// ----------------------------------------------------------------------------
// closeOpenParentheses()
// -- Work through the stack of opened parantheses
//    and close them
function closeOpenParentheses() {
	addMessage('closeOpenParentheses() :: [' + open_bracket + ']');
	var parts = new Array();
	while (isInsideBrackets()) { // close brackets that were opened before
		current_open_bracket = open_bracket[open_bracket.length-1];
		current_close_bracket = parenthesis[current_open_bracket];
		parts[parts.length] = current_close_bracket;
		open_bracket.pop();
	}
	return parts.join("");
}


// ----------------------------------------------------------------------------
// handlePeriods()
// -- Deal with commas.			(,)
//    commas can mean two things: a sentence pause, or a number split. We
//    need context to guess which one it's meant to be, thus the digit
//    triplet checking later on. Multiple commas are removed.
//    @flags:
//      * Do not capitalize next word
//      * Add space before next word
function handleCommas() {
	if (words_candidate.match(/\,/) != null) {
		if (fixed_name[fixed_name.length -1 ] != ",") {
			addMessage('handleCommas() :: "'+words_candidate+'"');
			resetContextFlags();
			space_next_word = true;
			force_capitalize_next_word = false;
			appendWordToFixedName(words_candidate);
		}
		return true;
	}
	return false;
}


// ----------------------------------------------------------------------------
// handlePeriods()
// -- Deal with periods.		 (.)
//    Periods can also mean four things:
//      * a sentence break (full stop);
//      * a number split in some countries
//      * part of an ellipsis (...)
//      * an acronym split.
//    We flag digits and digit triplets in the words routine.
//    @flags:
//      * Do not capitalize next word
//      * Add space before next word
function handlePeriods() {
	if (words_candidate.match(/\./) != null) {
		addMessage('handlePeriods() :: "'+words_candidate+'"');
		if (fixed_name[fixed_name.length -1 ] == ".") {
			if (!ellipsis) {
				ellipsis = true;
				fixed_name[fixed_name.length] = ".";
				fixed_name[fixed_name.length] = ".";
			}
			force_capitalize_next_word = !ellipsis; // if ellipsis true => caps false, else true.
			space_next_word = true;
		} else {
			resetContextFlags();
			capitalizeLastWord(); // just a normal, boring old period
			force_capitalize_next_word = true; // force caps on last word
			space_next_word = true;
			fixed_name[fixed_name.length] = ".";
		}
		return true;
	}
	return false;
}


// ----------------------------------------------------------------------------
// handleAcronym()
// -- check for an acronym
function handleAcronym() {
	words_subindex = 1;
	words_acronym = new Array();
	if (words_candidate.match(/^\w$/) != null) {
		words_acronym[0] = words_candidate.toUpperCase();
		var expect_word = false;
		var consumed_dot = false;   
		// acronym handling was made less strict to 
		// fix broken acronyms which look like this: "A. B. C."
		// the variable consumed_dot, is used such that such
		// cases do not yield false positives:
		// A D.J. -> which should be handled as 2 separate
		// words "a", and the acronym "D.J."
		while (words_index + words_subindex < words.length) {
			var cw = words[words_index+words_subindex];
			if (expect_word && cw.match(/^\w$/) != null) {
				words_acronym[words_acronym.length] = cw.toUpperCase(); // consume dot
				expect_word = false;
			} else {
				if (cw == ".") {
					words_acronym[words_acronym.length] = "."; // consume dot
					consumed_dot = true;
					expect_word = true;
				} else if (consumed_dot && cw == " ") expect_word = true; // consume a single whitespace 
				else break; // found something which is not part of the acronym
			}
			words_subindex++;
		}
	}
	if (words_acronym.length > 2) {
		var tempStr = words_acronym.join(""); // yes, we have an acronym, get string
		tempStr = tempStr.replace(/(\.)*$/, ". "); // replace any number of trailing "." with ". "
		addMessage("handleAcronym() :: "+tempStr);
		appendSpaceToFixedNameIfNeeded();
		appendWordToFixedName(tempStr);
		last_word_was_an_acronym = true;
		force_capitalize_next_word = false;
		words_index	= words_index+words_subindex - 1; // set pointer to after acronym
		return true;
	}
	return false;
}


// ----------------------------------------------------------------------------
// lookForAndProcessDigitOnlyString()
// -- Check for a digit only string
function lookForAndProcessDigitOnlyString() {
	words_number = new Array();
	words_subindex = 1;
	if (words_candidate.match(/^\d+$/)) {
		words_number[words_number.length] = words_candidate;
		var expect_a_number_split = true;
		numberloop:
		while (words_index+words_subindex < words.length) {
			if (expect_a_number_split) {
				if (words[words_index+words_subindex].match(/[,.]/) != null) {
					words_number[words_number.length] = words[words_index+words_subindex]; // found a potential number split
					expect_a_number_split = false;
				} else break numberloop;
			} else {
				// look for a group of 3 digits
				if (words[words_index+words_subindex].match(/^\d\d\d$/) != null) {
					if (number_split == null) {
						number_split = words_number[words_number.length - 1]; // confirmed number split
					}
					words_number[words_number.length] = words[words_index+words_subindex];
					expect_a_number_split = true;
				} else {
					if (words[words_index+words_subindex].match(/^\d\d$/) != null) {
						if (number_split != words_number[words_number.length - 1] && words_number.length > 2) {
							// check for the opposite number splitter (, or .)
							// because numbers are generally either
							// 1,000,936.00 or 1.300.402,00 depending on
							// the country
							words_number[words_number.length] = words[words_index+words_subindex];
							words_subindex++;
						} else {
							words_number.pop(); // stand-alone number pair
							words_subindex--;
						}
					} else {
						if (words[words_index+words_subindex].match(/^\d\d\d\d+$/) != null) {
							// big number at the end, probably a decimal point,
							// end of number in any case
							words_number[words_number.length] = words[words_index+words_subindex];
							words_subindex++;
						} else {
							words_number.pop(); // last number split was not
							words_subindex--;	 // actually a number split
						}
					}
					break numberloop;
				}
			}
			words_subindex++;
		}
		last_word_was_a_number = true;
		force_capitalize_next_word = false;
		words_index = words_index + words_subindex - 1 ;
		// add : after disc with number, with more words following
		// only if there is a string which is assumed to be the
		// disc title.
		// e.g. Albumname cd 4 -> Albumname (disc 4)
		// but  Albumname cd 4 the name -> Albumname (disc 4: The Name)
		if (last_word_was_disc) {
			if (words_index < words.length-1 && // if there are more words after the current
				words[words_index + 1] != ")" && // if next character is *not* closing parenthesis
				words[words_index + 1] != ":") {
				words_number[words_number.length] = ":"; // if there is no colon already present, add a colon
				force_capitalize_next_word = true;
				last_word_was_colon = true;
			}
			space_next_word = false;
			force_capitalize_next_word = true;
			last_word_was_disc = false;
		}
		addMessage('lookForAndProcessDigitOnlyString() :: <span class="mbword">"'+words_number.join('')+'"</span>, next word='+words[words_index+1]);
		appendSpaceToFixedNameIfNeeded();
		appendWordToFixedName(words_number.join(""));
		return true;
	}
	return false;
}


// ----------------------------------------------------------------------------
// handleArtistNameWord()
// -- Artist name specific processing of words
function handleArtistNameWord() {
	addMessage('handleArtistNameWord() :: Candidate=<span class="mbword">'+words_candidate+'</span>');
	words_candidate = titleCase(words_candidate);
	if (handleVersus()) {
	} else if (words_candidate.match(/^(pres|presents)$/i)) {
		words_candidate = "presents";
		appendSpaceToFixedName();
		appendWordToFixedName(words_candidate);
		if (words[words_index+1] == ".") words_index++;
	} else {
		appendSpaceToFixedNameIfNeeded();
		appendWordToFixedName(words_candidate);
	}
	last_word_was_a_number = false;
	return true;
}


// ----------------------------------------------------------------------------
// handleAlbumNameWord()
// -- Album name specific processing of words
function handleAlbumNameWord() {
	words_candidate = titleCase(words_candidate);
	var matcher = null;
	if (!last_word_was_colon && words_index > 0 && 
		(matcher = words_candidate.match(/^(Cd|Disk|Disc)(\s*)(\d*)/i)) != null) { // test for disc/disk and variants
		if (fixed_name[fixed_name.length-1] == "-") {
			fixed_name.pop(); // delete hypen if one occurs before disc. eg. Albumname - Disk1
		}
		appendSpaceToFixedNameIfNeeded();
		if (open_bracket.length == 0) { //if we're not inside brackets, open up a new pair.
			words_candidate = "(";
			words[words.length] = ")";
			handleOpeningParenthesis();
		}
		appendWordToFixedName("disc");
		last_word_was_disc = true;
		last_word_was_a_number = false;
		force_capitalize_next_word = false;
		space_next_word = false;
		if (matcher[3] != "") { // check if a number is part of the disc title.
			appendSpaceToFixedName(); // add space before the number
			appendWordToFixedName(matcher[3]); // add numeric part
			last_word_was_disc = false;
			last_word_was_a_number = true;
		}
	} else if (handleFeaturingArtist()) {
	} else if (handleVersus()) {
	} else if (handleVolume()) {
	} else if (handlePart()) {
	} else { // handle normal word.
		appendSpaceToFixedNameIfNeeded();
		appendWordToFixedName(words_candidate);
		last_word_was_a_number = false;
		force_capitalize_next_word = false;
		space_next_word = true;
	}
}


// ----------------------------------------------------------------------------
// handleTrackNameWord()
// -- Track name specific processing of words
function handleTrackNameWord() {
	var probe = words_candidate.toLowerCase();
	// TODO: needs some more work:
	// e.g. if uncommented, it changes:
	// The Dance Of Eternity (Act II - Scene Seven - I.)	to:
	// The (dance of ...)
	// if (words_index > 0 && // if a track name starts with "live", don't add a ()
	// 	open_bracket.length == 0 &&
	// 	lowercase_bracket_words[probe] != null) {
	// 	words_candidate = " (" + probe;
	// 	open_bracket[open_bracket.length] = "(";
	// } else {
	
	words_candidate = titleCase(words_candidate);
	if (handleFeaturingArtist()) {
	} else if (handleVersus()) {
	} else if (handleVolume()) {
	} else if (handlePart()) {
	} else {
		if (words_candidate == "7in") { // check vinyl abreviations
			appendSpaceToFixedNameIfNeeded();
			words_candidate = "7\"";
			space_next_word = false;
			force_capitalize_next_word = false;
		} else if (words_candidate == "12in") { // check vinyl abreviations
			appendSpaceToFixedNameIfNeeded();
			words_candidate = "12\"";
			space_next_word = false;
			force_capitalize_next_word = false;
		} else { // handle other cases (e.g. normal words)
			appendSpaceToFixedNameIfNeeded();
			space_next_word = true;
			force_capitalize_next_word = false;
		}
		appendWordToFixedName(words_candidate);
	}	
	last_word_was_a_number = false;
}

// ----------------------------------------------------------------------------
// handleVersus()
// -- Correct vs.
function handleVersus() {
	if (words_candidate.match(/^vs$/i)) {
		addMessage('handleVersus() :: <span class="mbword">'+words_candidate+'</span>');
		capitalizeLastWord();
		if (!last_char_was_open_parenthesis) appendSpaceToFixedName();
		appendWordToFixedName(words_candidate.toLowerCase());
		appendWordToFixedName(".");
		if (words[words_index + 1] == ".") words_index += 1; // skip trailing (.)
		force_capitalize_next_word = true;
		space_next_word = true;
		return true;
	}
	return false;
}

// ----------------------------------------------------------------------------
// handleVolume()
// -- Handle "Vol", "Vol.", "Volume" -> ", Volume"
function handleVolume() {
	if (words_candidate.match(/^(vol|volume)$/i)) {
		if (words_index >= 2 && 
			punctuation_chars[fixed_name[fixed_name.length-1]] == null) { // if no other punctuation char present
			fixed_name[fixed_name.length] = ","; // add a comma
		}
		words_candidate = "Volume";
		if (words[words_index+1] == ".") words_index++;
		appendSpaceToFixedNameIfNeeded();
		appendWordToFixedName(words_candidate);
		last_word_was_a_number = false;
		force_capitalize_next_word = false;
		space_next_word = true;
		return true;
	}
	return false;
}

// ----------------------------------------------------------------------------
// handlePart()
// -- Handle "Pt", "Pt.", "Part" -> ", Part"
function handlePart() {
	if (!isInsideBrackets() && words_candidate.match(/^pt|part$/i)) {
		if (words_index >= 2 && fixed_name[fixed_name.length-1] != ",") {
			fixed_name[fixed_name.length] = ",";
		}
		words_candidate = "Part";
		if (words[words_index+1] == ".") words_index++;
		appendSpaceToFixedNameIfNeeded();
		appendWordToFixedName(words_candidate);
		last_word_was_a_number = false;
		force_capitalize_next_word = false;
		space_next_word = true;
		return true;
	}
	return false;
}

// ----------------------------------------------------------------------------
// handleFeaturingArtist()
// -- Correct featuring, ft, feat words and add parantheses as needed.
function handleFeaturingArtist() {
	if (words_candidate.match(/^featuring$|^ft$|^feat$/i)) {
		var featparts = new Array();
		var featDebug = "";
		featparts[featparts.length] = "feat.";
		if (!last_char_was_open_parenthesis) {
			// handle case:
			// Blah ft. Erroll Flynn Some Remixname remix
			// -> pre-processor added parantheses such that the string is:
			// Blah ft. erroll flynn Some Remixname (remix)
			// -> now there are parantheses needed before remix
			// Blah (feat. Erroll Flynn Some Remixname) (remix)
			for (var nextparen = words_index; nextparen < words.length; nextparen++)
				if (words[nextparen] == "(") break;
			if (nextparen != words_index) { // we got a part, but not until the end of the string
				var p1 = words.slice(0, nextparen);
				var p2 = words.slice(nextparen, words.length);
				p1[p1.length] = ")"; // close off feat. part before next paranthesis.
				p1[p1.length] = " ";
				words = p1.concat(p2);
				featDebug = words.slice(words_index, nextparen+1);
			} else words[words.length] = ")";
			words_candidate = "(";
			handleOpeningParenthesis(); // force addition of "("
		}
		var featStr = featparts.join("");
		appendWordToFixedName(featStr);
		force_capitalize_next_word = true;
		space_next_word = true;
		last_word_was_feat = true;
		if (words[words_index + 1] == ".") words_index += 1; // skip trailing (.)
		featDebug = "result: "+featStr+" debug: "+featDebug;
		addMessage('handleFeaturingArtist() :: <span class="mbword">'+featDebug.replace(" ", "&nbsp")+'</span>');
		return true;
	}
	return false;
}









// ----------------------------------------------------------------------------
// trackNameFix()
// -- Track title specific fixes
//    Replaces common stand-alone strings
//    by its Musicbrainz equivalent:
//      * data [track]				-> [data track]
//  	* silence|silent [track]	-> [silence]
//  	* untitled [track]			-> [untitled]
//  	* unknown|bonus [track]		-> [unknown]
// @param input_string				the un-processed input string
// @returns							the processed string
function trackNameFix(input_string) {
	if (input_string.match(/^([\(\[]?\s*data(\s+track)?\s*[\)\]]?$)/i))
		return "[data track]";
	if (input_string.match(/^([\(\[]?\s*silen(t|ce)(\s+track)?\s*[\)\]]?)$/i))
		return "[silence]";
	if (input_string.match(/^([\(\[]?\s*untitled(\s+track)?\s*[\)\]]?)$/i))
		return "[untitled]";
	if (input_string.match(/^([\(\[]?\s*unknown|bonus(\s+track)?\s*[\)\]]?)$/i))
		return "[unknown]";
	if (input_string.match(/^\?+$/i))
		return "[unknown]";
	resetMessages();
	resetGlobals();
	resetContextFlags();
	
	input_string = replaceAbbreviations(input_string);
	input_string = handleVinylExpressions(input_string);
	words = splitWordsAndPunctuation(input_string);
	words = preprocessTrackNameWords(words);

	// loop through all the words
	for (words_index = 0; words_index < words.length; words_index++) { // not i, but words_index anymore
		words_candidate = words[words_index];
		if (handleWhiteSpace()) {
		} else {
			addMessage("trackNameFix() :: "+words_index+"/"+words.length+" "+words[words_index]);
			if (handleColons()) {
			} else if (handleAmpersands()) {
			} else if (handleLineTerminators()) {
			} else if (handleHypens()) {
			} else if (handlePlus()) {
			} else if (handleSlashes()) {
			} else if (handleDoubleQuotes()) {
			} else if (handleSingleQuotes()) {
			} else if (handleOpeningParenthesis()) {
			} else if (handleClosingParenthesis()) {
			} else if (handleCommas()) {
			} else if (handlePeriods()) {
			} else {
				// Deal with words and digits, there are 3 cases to handle.
				//  * Digit only strings
				//  * Acronyms
				//  * 'Normal' words
				if (lookForAndProcessDigitOnlyString()) {
				} else if (handleAcronym()) {
				} else handleTrackNameWord();
				resetContextFlags();
			}
		}
	}
	capitalizeLastWord();
	fixed_name[fixed_name.length] = closeOpenParentheses();
	var return_string = getAndCheckFixedName();
	addMessage('trackNameFix() :: result=<span class="mbword">'+return_string.replace(" ", "&nbsp")+'</span>');
	return return_string;
}


// ----------------------------------------------------------------------------
// artistNameFix()
// -- Artist title specific fixes
//    Replaces common stand-alone strings
//    by its Musicbrainz equivalent:
//      * none
//      * no artist
//      * not applicable
//      * n/a -> [no artist]
// @param	 input_string	the un-processed input string
// @returns					the processed string
//
function artistNameFix(input_string) {
	if (input_string.match(/^\s*$/i)) // match empty
		return "[unknown]";
	if (input_string.match(/^[\(\[]?\s*Unknown\s*[\)\]]?$/i)) // match "unknown" and variants
		return "[unknown]";
	if (input_string.match(/^[\(\[]?\s*none\s*[\)\]]?$/i)) // match "none" and variants
		return "[no artist]";
	if (input_string.match(/^[\(\[]?\s*no[\s-]+artist\s*[\)\]]?$/i)) // match "no artist" and variants
		return "[no artist]";
	if (input_string.match(/^[\(\[]?\s*not[\s-]+applicable\s*[\)\]]?$/i)) // match "not applicable" and variants
		return "[no artist]";
	if (input_string.match(/^[\(\[]?\s*n\s*[\\\/]\s*a\s*[\)\]]?$/i)) // match "n/a" and variants
		return "[no artist]";
	resetMessages();
	resetGlobals();
	resetContextFlags();
	words = splitWordsAndPunctuation(input_string);

	// loop through all the words
	for (words_index = 0; words_index < words.length; words_index++) { // not i, but words_index anymore
		words_candidate = words[words_index];
		if (handleWhiteSpace()) {
		} else {
			addMessage("artistNameFix() :: "+words_index+"/"+words.length+" "+words[words_index]);
			if (handleColons()) {
			} else if (handleAmpersands()) {
			} else if (handleLineTerminators()) {
			} else if (handleHypens()) {
			} else if (handlePlus()) {
			} else if (handleSlashes()) {
			} else if (handleDoubleQuotes()) {
			} else if (handleSingleQuotes()) {
			} else if (handleOpeningParenthesis()) {
			} else if (handleClosingParenthesis()) {
			} else if (handleCommas()) {
			} else if (handlePeriods()) {
			} else {
				// Deal with words and digits, There are 3 cases to handle.
				//  * Digit only strings
				//  * Acronyms
				//  * 'Normal' words
				if (lookForAndProcessDigitOnlyString()) {
				} else if (handleAcronym()) {
				} else handleArtistNameWord();
				resetContextFlags();
				force_capitalize_next_word = false;
				space_next_word = true;
			}
		}
	}
	capitalizeLastWord();
	fixed_name[fixed_name.length] = closeOpenParentheses();
	var return_string = getAndCheckFixedName();
	addMessage('artistNameFix() :: result=<span class="mbword">'+return_string.replace(" ", "&nbsp")+'</span>');
	return return_string;
}


// ----------------------------------------------------------------------------
// albumNameFix()
// -- Album title specific fixes
// @param	 input_string	the un-processed input string
// @returns					the processed string
function albumNameFix(input_string) {
	resetMessages();
	resetGlobals();
	resetContextFlags();
	words = splitWordsAndPunctuation(input_string);

	// pre-process to find any lowercase_bracket word that needs to be put into parantheses.
	// starts from the back and collects words that belong into
	// the brackets: e.g.
	// My Track Extended Dub remix => My Track (extended dub remix)
	words_index = words.length-1;
	var handlePreProcess = false;
	while (words[words_index] == " " || // skip whitespace
		  (preprocessor_bracket_words[words[words_index].toLowerCase()] != null && words_index >= 0)) {
		handlePreProcess = true;
		words_index--;
	}
	if (handlePreProcess && words_index !=  words.length-1) {
		words_index++; // increment to last word that matched.
		var newwords = words.slice(0, words_index);
		newwords[newwords.length] = "(";
		newwords = newwords.concat(words.slice(words_index, words.length));
		newwords[newwords.length] = ")";
		words = newwords;
		addMessage('albumNameFix() :: after pre-process <span class="mbword">'+words.join("").replace(" ", "&nbsp")+'</span>');
	}

	// loop through all the words
	for (words_index = 0; words_index < words.length; words_index++) { // not i, but words_index anymore
		words_candidate = words[words_index];
		if (handleWhiteSpace()) {
		} else {
			addMessage("albumNameFix() :: "+words_index+"/"+words.length+" "+words[words_index]);
			if (handleColons()) {
			} else if (handleAmpersands()) {
			} else if (handleLineTerminators()) {
			} else if (handleHypens()) {
			} else if (handlePlus()) {
			} else if (handleSlashes()) {
			} else if (handleDoubleQuotes()) {
			} else if (handleSingleQuotes()) {
			} else if (handleOpeningParenthesis()) {
			} else if (handleClosingParenthesis()) {
			} else if (handleCommas()) {
			} else if (handlePeriods()) {
			} else {
				// Deal with words and digits, There are 3 cases to handle.
				//  * Digit only strings
				//  * Acronyms
				//  * 'Normal' words
				if (lookForAndProcessDigitOnlyString()) {
				} else if (handleAcronym()) {
				} else handleAlbumNameWord();
				resetContextFlags();
			}
		}
	}
	capitalizeLastWord();
	fixed_name[fixed_name.length] = closeOpenParentheses();
	var return_string = getAndCheckFixedName();
	addMessage('albumNameFix() :: result=<span class="mbword">'+return_string.replace(" ", "&nbsp")+'</span>');
	return return_string;
}


// ----------------------------------------------------------------------------
// getAndCheckFixedName()
// -- Collect words from fixed_name and apply minor
//   fixed that aren't handled in the specific function.
function getAndCheckFixedName() {
	var return_string = trim(fixed_name.join(""));
	var searchlist = new Array(
		new Array(" R & B ", " R&B "),
		new Array("[live]", "(live)")
	);
	for (var i=0; i<searchlist.length; i++) {
		if (return_string.indexOf(searchlist[i][0]) != -1) {
			return_string = return_string.replace(searchlist[i][0], searchlist[i][1]);
		}
	}

	// vinyl expression
	// * look only at substrings which start with ' '  OR '('
	// * convert 7', 7'', 7", 7in, 7inch TO '7"_' (with a following SPACE)
	// * convert 12', 12'', 12", 12in, 12inch TO '12"_' (with a following SPACE)
	// * do NOT handle strings like 80's	
	//
	// Examples:
	//  Original string: "Fine Day (Mike Koglin 12' mix)"
	//  	Last matched portion: " 12' "
	//  	Matched portion 1 = " "
	//  	Matched portion 2 = "12'"
	//  	Matched portion 3 = "12"
	//  	Matched portion 4 = "'"
	//  	Matched portion 5 = " "
	//  Original string: "Where Love Lives (Come on In) (12"Classic mix)"
	//  	Last matched portion: "(12"C"
	//  	Matched portion 1 = "("
	//  	Matched portion 2 = "12""
	//  	Matched portion 3 = "12"
	//  	Matched portion 4 = """
	//  	Matched portion 5 = "C"
	//  Original string: "greatest 80's hits"
	//		Match failed.
	var re = /(\s+|\()((\d+)(inch\b|in\b|'+|"))([^s])/i;
	var matcher = return_string.match(re);
	if (matcher) {
		var mindex = matcher.index;
		var mlenght  = matcher[1].length + matcher[2].length + matcher[5].length; // calculate the length of the expression
		var firstPart = return_string.substring(0, mindex);
		var lastPart = return_string.substring(mindex+mlenght, return_string.length); // add number

		// compile the proper vinyl designation.
		var parts = new Array();
		parts[parts.length] = firstPart;
		parts[parts.length] = matcher[1]; // first part (either ' ' or '('
		parts[parts.length] = matcher[3]; // add number
		parts[parts.length] = '"'; // add vinyl doubleqoute
		parts[parts.length] = (matcher[5] != " " ? " " : ""); // add space after ", if none is present
		parts[parts.length] = matcher[5]; // add number
		parts[parts.length] = lastPart;
		return_string = parts.join("");
	}
	return return_string;
}


// ----------------------------------------------------------------------------
// trim()
function trim(input_string) {
	return input_string
		.replace(/^\s\s*/, "")
		.replace(/\s\s*$/, "")
		.replace(/([\(\[])\s+/, "$1")
		.replace(/\s+([\)\]])/, "$1")
		.replace(/\s\s*/g, " ");
}


// ----------------------------------------------------------------------------
// isNullOrEmpty()
// -- Test a string if it is null or ""
function isNullOrEmpty(input_string) {
	return (input_string == null || input_string == "");
}


// ----------------------------------------------------------------------------
// artistNameGuessSortName()
// -- Guesses the sortname for artists
function artistNameGuessSortName(input_string) {
	input_string = trim(input_string);
	if (input_string.match(/\[no artist\]/i)) return "[no artist]";
	if (input_string.match(/\[unknown\]/i)) return "[unknown]";
	var ssplit = " and ";
	ssplit = (input_string.indexOf(" + ") != -1 ? " + " : ssplit);
	ssplit = (input_string.indexOf(" & ") != -1 ? " & " : ssplit);
	parts = input_string.split(ssplit);
	for (var i=0; i<parts.length; i++) {
		var candidate = trim(parts[i]);
		var append = "";
		var srRegExP = /, Sr[\.]?$/i; // strip Jr./Sr. from the string
		var jrRegExP = /, Jr[\.]?$/i; // and remember to append that at the end.
		if (candidate.match(srRegExP)) {
			append = ", Sr."; candidate = candidate.replace(srRegExP, "");
		} else if (candidate.match(jrRegExP)) {
			append = ", Jr."; candidate = candidate.replace(jrRegExP, "");
		}
		words = candidate.split(" ");
		addMessage('guessSortName() :: words: <span class="mbword">'+words.join('</span> <span class="mbword">')+'</span>');
		var reorder = false;
		if (words[0].match(/DJ/i)) {
			words[0] = null; append = (", DJ" + append); // handle DJ xyz -> xyz, DJ
		} else if (words[0].match(/The/i)) {
			words[0] = null; append = (", The" + append); // handle The xyz -> xyz, The
		} else if (words[0].match(/Los/i)) {
			words[0] = null; append = (", Los" + append); // handle Los xyz -> xyz, Los
		} else if (words[0].match(/Dr\./i)) {
			words[0] = null; append = (", Dr." + append); // handle Dr. xyz -> xyz, Dr.
			reorder = true; // re-order the trackname still
		} else reorder = true; // re-order is default
		if (reorder) {
			var rewords = [];
			if (words.length > 1) {
				for (var ai=0; ai<words.length-1; ai++) { // >> firstnames, middlenames one pos right
					if (ai == words.length-2 && words[ai] == "St.") {
						words[ai+1] = words[ai] + " " + words[ai+1]; 	// handle St. because it belongs
																	// to the lastname
					} else if (!isNullOrEmpty(words[ai])) rewords[ai+1] = words[ai];
				}
				rewords[0] = words[words.length-1]; // lastname, firstname
				if (rewords.length > 1) rewords[0] += ","; // only append comma if there was
														// more than 1 non-empty word (and
														// thus switched)
				words = rewords;
			}
		}
		addMessage('guessSortName() :: re-ordered: <span class="mbword">'+words.join('</span> <span class="mbword">')+ append + '</span>');
		parts[i] = "";
		for (var bi=0; bi<words.length; bi++) {
			if (!isNullOrEmpty(words[bi])) parts[i] += words[bi]; // skip empty words
			if (bi < words.length-1) parts[i] += " "; // if not last word, add space
		} parts[i] += append;
		parts[i] = trim(parts[i]);
	}
	input_string = trim(parts.join(ssplit));
	addMessage('guessSortName() :: result=<span class="mbword">'+input_string.replace(" ", "&nbsp")+'</span>');
	return input_string;
}




