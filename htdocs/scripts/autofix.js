/* ************************************************************************* */
/*																		     */
/* Define wordlists		                                 					 */
/*														                     */
/* ************************************************************************* */

// Words which are always written lowercase.
//
// change log (who, when, what)
// -------------------------------------------------------
// tma			2005-01-29		first version
// g0llum		2005-04-17		added french lowercase characters
// g0llum		2005-06-14		added "tha" to be handled like "the"
var word_arr = [
	 "a", "and", "n", "an", "as", "at", "but",
	 "by", "for", "in", "nor", "of", "o", "on",
	 "or", "the", "to", "der", "und", "de", "du",
	 "et", "la", "le", "les", "un", "une", "y",
	 "con", "di", "da", "del", "à", "â", "ç", "è", 
	 "é", "ê", "ô", "ù", "û", "aux",
	 "tha"
];
var lowercase_words = toAssociativeArray(word_arr);

// Words which are written lowercase if in brackets
// change log (who, when, what)
// -------------------------------------------------------
// tma			2005-01-29		first version
// g0llum		2005-01-29		added dub, megamix, maxi
// .various		2005-05-09		karaoke
// g0llum		2005-07-10		added disco, unplugged
// g0llum		2005-07-10		changed acappella, has its own handling now.
//                              is handled as 1 word, but is expanded to 
//                              "a cappella" in post-processing
// g0llum		2005-07-21		added outtake(s), rehearsal, intro, outro
word_arr = [										  
	 "acoustic", "album", "alternate", "bonus", "clean",
	 "dirty", "disc", "extended", "instrumental", "live", 
	 "original", "radio", "single", "take", "demo",
	 "club", "dance", "edit", "skit", "mix", "remix", 
	 "version", "reprise", "megamix", "maxi", "feat",
	 "interlude", "dub", "dialogue", "cut", "karaoke", 
	 "acappella", "vs", "vocal", "alternative", "disco",
	 "unplugged", "video", "outtake", "outtakes", "rehearsal",
	 "intro", "outro", "acappella", "long", "short", "main",
	 "remake", "clubmix", "composition", "reinterpreted",
	 "session", "rework", "reworked", "remixed"
];
var lowercase_bracket_words = toAssociativeArray(word_arr);


// Words which the pre-processor looks for and puts them
// into brackets if they arent yet.
// change log (who, when, what)
// -------------------------------------------------------
// g0llum		2005-05-25		first version
var preprocessor_bracket_words = [
	 "cd", "disk", '12"', '7"'
];
preprocessor_bracket_words = toAssociativeArray(
	preprocessor_bracket_words.concat(word_arr)
);

// Words which are *not* converted if they are
// matched as a single pre-processor word at the 
// end of the sentence
// change log (who, when, what)
// -------------------------------------------------------
// g0llum		2005-05-25		first version
// g0llum		2005-07-10		added disco
// g0llum		2005-07-20		added dub
word_arr = [
	 "acoustic", "album", "alternate", "bonus", "clean",
	 "club", "dance", "dirty", "disc", "extended",
	 "instrumental", "live", "original", "radio",
	 "take", "disc", "mix", "version", "feat", "cut", 
	 "vocal", "alternative", "megamix", "disco", "video",
	 "dub", 
	 "long", "short", "main", "composition", "session",
	 "rework", "reworked", "remixed"
];
var preprocessor_bracket_singlewords = toAssociativeArray(word_arr );


// Words which are always written UPPERCASE. change log (who, when, what)
//
// -------------------------------------------------------
// g0llum		2005-01-31		first version
// various		2005-05-05		added "FM...PM"
// g0llum		2005-05-24		removed AM,PM because it yielded false positives e.g. "I AM stupid"
// g0llum		2005-07-10		added uk, bpm
// g0llum		2005-07-20		added ussr, usa, ok, nba, rip, ny
//											  classical words, hip-hop artists
word_arr = [
	"dj", "mc", "tv", "mtv", "ep", "lp", "i",
	"ii", "iii", "iiii", "iv", "v", "vi", "vii",
	"viii", "ix", "x", "bwv", "ymca", "nyc", "r&b",
	"bbc", "fm", "bc", "ad", "ac", "dc", "uk", "bpm",
	"ussr", "usa", "ok", "nba", "rip", "ny",
	"rv", "kv", "bwv", // classical works indication (kv=mozart, bwv=bach)
	"rza", "gza", "odb", "dmx", // hip-hop artists
	"2xlc", // techno artist: Talla 2XLC
];
var uppercase_words = toAssociativeArray(word_arr);

// Punctuation characters
// change log (who, when, what)
// -------------------------------------------------------
// g0llum		2005-05-24		first version
word_arr = [
	":", ".", ";", "?", "!"
];				
var sentencestop_chars = toAssociativeArray(word_arr);
word_arr[word_arr.length] = ",";
var punctuation_chars = toAssociativeArray(word_arr);


// Contractions http://englishplus.com/grammar/00000136.htm
// change log (who, when, what)
// -------------------------------------------------------
// g0llum		2005-04-19		first version
// g0llum		2005-05-25		added that'll, ain't
// g0llum		2005-06-14		added we'll
// g0llum		2005-07-20		added what'll
word_arr = [
	"aren't", "can't", "couldn't", "doesn't", "don't", "hadn't", "hasn't",
	"haven't", "he'd", "he'll", "here's", "he's", "i'd", "i'll", "i'm",
	"isn't", "it'd", "it'll", "it's", "i've", "let's", "mustn't", "she'd",
	"she'll", "she's", "shouldn't", "that'd", "that's", "there'd",
	"there'll", "there's", "they'd", "they'll", "they're", "they've",
	"wasn't", "we'd", "we're", "weren't", "we've", "what's", "who'd",
	"who's", "won't", "wouldn't", "you'd", "you'll", "you're", "you've",
	"ain't", "that'll", "we'll", "what'll", "what'cha",	
	"10's", "20's", "30's", "40's", "50's", "60's", "70's", "80's", "90's", "00's"
];
var contraction_words = toContractionWords(word_arr);

// Words which are MacTitled http://www.daire.org/names/scotsurs2.html
// change log (who, when, what)
// -------------------------------------------------------
// g0llum		2005-05-31		first version
word_arr = [
	"macachallies", "macachounich", "macadam", "macadie", "macaindra", 
	"macaldonich", "macalduie", "macallan", "macallister", "macalonie", 
	"macandeoir", "macandrew", "macangus", "macara", "macaree", "macarthur", 
	"macaskill", "macaslan", "macaulay", "macauselan", "macay", "macbaxter", 
	"macbean", "macbeath", "macbeolain", "macbeth", "macbheath", "macbride", 
	"macbrieve", "macburie", "maccaa", "maccabe", "maccaig", "maccaishe", 
	"maccall", "maccallum", "maccalman", "maccalmont", "maccamie", 
	"maccammon", "maccammond", "maccanish", "maccansh", "maccartney", 
	"maccartair", "maccarter", "maccash", "maccaskill", "maccasland", "maccaul", 
	"maccause", "maccaw", "maccay", "macceallaich", "macchlerich", "macchlery", 
	"macchoiter", "macchruiter", "maccloy", "macclure", "maccluskie", "macclymont", 
	"maccodrum", "maccoll", "maccolman", "maccomas", "maccombe", "maccombich", 
	"maccombie", "macconacher", "macconachie", "macconchy", "maccondy", "macconnach", 
	"macconnechy", "macconnell", "macconochie", "maccooish", "maccook", "maccorkill", 
	"maccorkindale", "maccorkle", "maccormack", "maccormick", "maccorquodale", 
	"maccorry", "maccosram", "maccoull", "maccowan", "maccrae", "maccrain", "maccraken", 
	"maccraw", "maccreath", "maccrie", "maccrimmon", "maccrimmor", "maccrindle", 
	"maccririe", "maccrouther", "maccruithein", "maccuag", "maccuaig", "maccubbin", 
	"maccuish", "macculloch", "maccune", "maccunn", "maccurrach", "maccutchen", 
	"maccutcheon", "macdade", "macdaniell", "macdavid", "macdermid", "macdiarmid", 
	"macdonachie", "macdonald", "macdonleavy", "macdougall", "macdowall", "macdrain", 
	"macduff", "macduffie", "macdulothe", "maceachan", "maceachern", "maceachin", 
	"maceachran", "macearachar", "macelfrish", "macelheran", "maceoin", "maceol", 
	"macerracher", "macewen", "macfadzean", "macfall", "macfarquhar", "macfarlane", 
	"macfater", "macfeat", "macfergus", "macfie", "macgaw", "macgeachie", "macgeachin", 
	"macgeoch", "macghee", "macgilbert", "macgilchrist", "macgill", "macgilledon", 
	"macgillegowie", "macgillivantic", "macgillivour", "macgillivray", "macgillonie", 
	"macgilp", "macgilroy", "macgilvernock", "macgilvra", "macgilvray", "macglashan", 
	"macglasrich", "macgorrie", "macgorry", "macgoun", "macgowan", "macgrath", 
	"macgregor", "macgreusich", "macgrewar", "macgrime", "macgrory", "macgrowther", 
	"macgruder", "macgruer", "macgruther", "macguaran", "macguffie", "macgugan", 
	"macguire", "machaffie", "machardie", "machardy", "macharold", "machendrie", 
	"machendry", "machowell", "machugh", "machutchen", "machutcheon", "maciain", 
	"macildowie", "macilduy", "macilreach", "macilleriach", "macilriach", 
	"macilrevie", "macilvain", "macilvora", "macilvrae", "macilvride", "macilwhom", 
	"macilwraith", "macilzegowie", "macimmey", "macinally", "macindeor", "macindoe", 
	"macinnes", "macinroy", "macinstalker", "macintyre", "maciock", "macissac", "macivor", 
	"macjames", "mackail", "mackames", "mackaskill", "mackay", "mackeachan", "mackeamish", 
	"mackean", "mackechnie", "mackee", "mackeggie", "mackeith", "mackellachie", 
	"mackellaigh", "mackellar", "mackelloch", "mackelvie", "mackendrick", "mackenzie", 
	"mackeochan", "mackerchar", "mackerlich", "mackerracher", "mackerras", "mackersey", 
	"mackessock", "mackichan", "mackie", "mackieson", "mackiggan", "mackilligan", 
	"mackillop", "mackim", "mackimmie", "mackindlay", "mackinley", "mackinnell", 
	"mackinney", "mackinning", "mackinnon", "mackintosh", "mackinven", "mackirdy", 
	"mackissock", "macknight", "maclachlan", "maclae", "maclagan", "maclaghlan", 
	"maclaine of lochbuie", "maclaren", "maclairish", "maclamond", "maclardie", 
	"maclaverty", "maclaws", "maclea", "maclean", "macleay", "maclehose", "macleish", 
	"macleister", "maclellan", "maclennan", "macleod", "maclergain", "maclerie", 
	"macleverty", "maclewis", "maclintock", "maclise", "macliver", "maclucas", 
	"maclugash", "maclulich", "maclure", "maclymont", "macmanus", "macmartin", 
	"macmaster", "macmath", "macmaurice", "macmenzies", "macmichael", "macmillan", 
	"macminn", "macmonies", "macmorran", "macmunn", "macmurchie", "macmurchy", 
	"macmurdo", "macmurdoch", "macmurray", "macmurrich", "macmutrie", "macnab", 
	"macnair", "macnamell", "macnaughton", "macnayer", "macnee", "macneilage", 
	"macneill", "macneilly", "macneish", "macneur", "macney", "macnicol", "macnider", 
	"macniter", "macniven", "macnuir", "macnuyer", "macomie", "macomish", "maconie", 
	"macoran", "maco", "macoull", "macourlic", "macowen", "macowl", "macpatrick", 
	"macpetrie", "macphadden", "macphail", "macphater", "macphee", "macphedran", 
	"macphedron", "macpheidiran", "macpherson", "macphillip", "macphorich", "macphun", 
	"macquarrie", "macqueen", "macquey", "macquilkan", "macquistan", "macquisten", 
	"macquoid", "macra", "macrach", "macrae", "macraild", "macraith", "macrankin", 
	"macrath", "macritchie", "macrob", "macrobb", "macrobbie", "macrobert", "macrobie", 
	"macrorie", "macrory", "macruer", "macrurie", "macrury", "macshannachan", 
	"macshimes", "macsimon", "macsorley", "macsporran", "macswan", "macsween", 
	"macswen", "macsymon", "mactaggart", "mactary", "mactause", "mactavish", 
	"mactear", "macthomas", "mactier", "mactire", "maculric", "macure", "macvail", 
	"macvanish", "macvarish", "macveagh", "macvean", "macvicar", "macvinish", 
	"macvurich", "macvurie", "macwalrick", "macwalter", "macwattie", "macwhannell", 
	"macwhirr", "macwhirter", "macwilliam", "macintosh", "macintyre"
];
var words_mactitled = toAssociativeArray(word_arr );

// Common mis-spellings of words that need to be fixed before
// running the title specific function.
// change log (who, when, what)
// -------------------------------------------------------
// g0llum		2005-05-31		first version
// g0llum		2005-07-21		added instrumental, extended, a.k.a.
var preprocess_searchterms = new Array(
	new Array(/(\b|^)D\.?J\.?(\s|\)|$)/i, "DJ"),
	new Array(/(\b|^)Vol(\d*)(\b)/i, "Vol. $1"),
	new Array(/(\b|^)Pt(\d*)(\b)/i, "Pt. $1"),
	new Array(/(\b|^)M\.?C\.?(\s|\)|$)/i, "MC"),
	new Array(/(\b|^)a\s?c+ap+el+a(\b)/i, "a_cappella"), // make a cappella one word, this is expanded in post-processing
	new Array(/(\b|^)re-mix(\b)/i, "remix"),
	new Array(/(\b|^)re-mixes(\b)/i, "remixes"),
	new Array(/(\b|^)re-make(\b)/i, "remake"),	
	new Array(/(\b|^)re-makes(\b)/i, "remakes"),	
	new Array(/(\b|^)re-edit(\b)/i, "reedit"),			
	new Array(/(\b|^)RMX(\b)/i, "remix"),
	new Array(/(\b|^)alt[\.]? take(\b)/i, "alternate take"),
	new Array(/(\b|^)instr\.?(\b)/i, "instrumental"), 
	new Array(/(\b|^)altern\.?(\s|\)|$)/i, "alternate"), 	
	new Array(/(\b|^)orig\.?(\s|\)|$)/i, "original"), 		
	new Array(/(\b|^)Extendet(\b)/i, "extended"),
	new Array(/(\b|^)ext[d]?\.?(\s|\)|$)/i, "extended"),
	new Array(/(\b|^)aka(\b)/i, "a.k.a.")
);

// Stuff that needs to be "corrected" after
// running the title specific function
// -------------------------------------------------------
// g0llum		2005-05-31		first version
// g0llum		2005-07-21		added "(main)" -> "(main version)"
var postprocess_searchterms = new Array(
	new Array(/(\b|^)a_cappella(\b)/i, "A Cappella"), // expand acappella to A Cappella
	new Array(/(\b|^)R\s*&\s*B(\b)/i, "R&B"),
	new Array(/(\b|^)\[live\](\b)/i, "(live)"),
	new Array(/(\b|^)a.k.a.(\b)/i, "a.k.a.")
);


/* ************************************************************************* */
/*																		     */
/* Define global variables                                 					 */
/*														                     */
/* ************************************************************************* */

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
var last_word_was_part				= false;
var last_word_was_volume			= false;

// defines the current number split. note that this will not be cleared,
//which has the side-effect of forcing the first type of number split
// encountered to be the only one used for the entire string, assuming
// that people aren't going to be mixing grammar in titles.
var number_split					= null;

// valid autofix modes
var AF_MODE_AUTOFIX = 'autofix';
var AF_MODE_SENTENCECAPS = 'sentencecaps';
var mode_extratitleinformation = false;



/* ************************************************************************* */
/*																		     */
/* Entry methods                                           					 */
/*														                     */
/* ************************************************************************* */

// ----------------------------------------------------------------------------
// artistNameFix()
// -- Artist title specific fixes
//    Replaces common stand-alone strings
//    by its Musicbrainz equivalent:
//      * none
//      * no artist
//      * not applicable
//      * n/a -> [no artist]
// @param	 strIn	the un-processed input string
// @returns					the processed string
//
function artistNameFix(strIn) {
	resetMessages();
	resetGlobals();
	resetContextFlags();
	mode = AF_MODE_AUTOFIX; // default
	if (strIn.match(/^\s*$/i)) // match empty
		return "[unknown]";
	if (strIn.match(/^[\(\[]?\s*Unknown\s*[\)\]]?$/i)) // match "unknown" and variants
		return "[unknown]";
	if (strIn.match(/^[\(\[]?\s*none\s*[\)\]]?$/i)) // match "none" and variants
		return "[no artist]";
	if (strIn.match(/^[\(\[]?\s*no[\s-]+artist\s*[\)\]]?$/i)) // match "no artist" and variants
		return "[no artist]";
	if (strIn.match(/^[\(\[]?\s*not[\s-]+applicable\s*[\)\]]?$/i)) // match "not applicable" and variants
		return "[no artist]";
	if (strIn.match(/^[\(\[]?\s*n\s*[\\\/]\s*a\s*[\)\]]?$/i)) // match "n/a" and variants
		return "[no artist]";
	words = splitWordsAndPunctuation(strIn);
	for (words_index = 0; words_index < words.length; words_index++) { // not i, but words_index anymore
		words_candidate = words[words_index];
		if (handleWhiteSpace(mode)) {
		} else {
			// DEBUG
			// addMessage("artistNameFix() :: "+words_index+"/"+words.length+" "+words[words_index]);
			if (handleColons(mode)) {
			} else if (handleAmpersands(mode)) {
			} else if (handleLineTerminators(mode)) {
			} else if (handleHypens(mode)) {
			} else if (handlePlus(mode)) {
			} else if (handleCommas(mode)) {
			} else if (handlePeriods(mode)) {
			} else if (handleAsterix(mode)) {
			} else if (handleSlashes(mode)) {
			} else if (handleDoubleQuotes(mode)) {
			} else if (handleSingleQuotes(mode)) {
			} else if (handleOpeningParenthesis(mode)) {
			} else if (handleClosingParenthesis(mode)) {
			} else {
				// Deal with words and digits, There are 3 cases to handle.
				//  * Digit only strings
				//  * Acronyms
				//  * 'Normal' words
				if (handleDigitOnlyString(mode)) {
				} else if (handleAcronym(mode)) {
				} else handleArtistNameWord(mode);
				resetContextFlags();
				force_capitalize_next_word = false;
				space_next_word = true;
			}
		}
	}
	capitalizeLastWord(mode);
	fixed_name[fixed_name.length] = closeOpenParentheses();
	var rs1 = handlePostProcessing(mode);
	addMessage('artistNameFix() :: result=@@@'+rs1+'###');
	return rs1;
}

// ----------------------------------------------------------------------------
// artistNameGuessSortName()
// -- Guesses the sortname for artists
function artistNameGuessSortName(strIn, mode) {
	resetMessages();
	mode = checkAutoFixMode(mode);
	strIn = trim(strIn);
	if (strIn.match(/\[no artist\]/i)) return "[no artist]";
	if (strIn.match(/\[unknown\]/i)) return "[unknown]";
	var ssplit = " and ";
	ssplit = (strIn.indexOf(" + ") != -1 ? " + " : ssplit);
	ssplit = (strIn.indexOf(" & ") != -1 ? " & " : ssplit);
	parts = strIn.split(ssplit);
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
		addMessage('guessSortName() :: words: @@@'+words.join('### @@@')+'###');
		var reorder = false;
		if (words[0].match(/^DJ$/i)) {
			words[0] = null; append = (", DJ" + append); // handle DJ xyz -> xyz, DJ
		} else if (words[0].match(/^The$/i)) {
			words[0] = null; append = (", The" + append); // handle The xyz -> xyz, The
		} else if (words[0].match(/^Los$/i)) {
			words[0] = null; append = (", Los" + append); // handle Los xyz -> xyz, Los
		} else if (words[0].match(/^Dr\.$/i)) {
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
				if (rewords.length > 1) rewords[0] += ","; 
					// only append comma if there was more than 1 
					// non-empty word (and therefore switched)
				words = rewords;
			}
		}
		addMessage('guessSortName() :: re-ordered: @@@'+words.join('### @@@')+ append + '###');
		parts[i] = "";
		for (var bi=0; bi<words.length; bi++) {
			if (!isNullOrEmpty(words[bi])) parts[i] += words[bi]; // skip empty words
			if (bi < words.length-1) parts[i] += " "; // if not last word, add space
		} parts[i] += append;
		parts[i] = trim(parts[i]);
	}
	strIn = trim(parts.join(ssplit));
	addMessage('guessSortName() :: result=@@@'+strIn+'###');
	return strIn;
}

// ----------------------------------------------------------------------------
// albumNameFix()
// -- Album title specific fixes
// @param	 strIn	the un-processed input string
// @returns					the processed string
function albumNameFix(strIn, mode) {
	resetMessages();
	resetGlobals();
	resetContextFlags();
	mode = checkAutoFixMode(mode);
	strIn = preProcessTrimInformationToOmit(strIn);
	strIn = preProcessAbbreviations(strIn);
	strIn = processVinylExpressions(strIn);
	words = splitWordsAndPunctuation(strIn);
	words = preProcessExtraTitleInformation(words);
	for (words_index = 0; words_index < words.length; words_index++) { // not i, but words_index anymore
		words_candidate = words[words_index];
		// DEBUG
		// addMessage("albumNameFix() :: "+words_index+"/"+(words.length-1)+" @@@"+words[words_index]+"###");
		if (handleWhiteSpace(mode)) {
		} else {
			// DEBUG
			if (handleColons(mode)) {
			} else if (handleAmpersands(mode)) {
			} else if (handleLineTerminators(mode)) {
			} else if (handleHypens(mode)) {
			} else if (handlePlus(mode)) {
			} else if (handleCommas(mode)) {
			} else if (handlePeriods(mode)) {
			} else if (handleAsterix(mode)) {
			} else if (handleSlashes(mode)) {
			} else if (handleDoubleQuotes(mode)) {
			} else if (handleSingleQuotes(mode)) {
			} else if (handleOpeningParenthesis(mode)) {
			} else if (handleClosingParenthesis(mode)) {
			} else {
				// Deal with words and digits, There are 3 cases to handle.
				//  * Digit only strings
				//  * Acronyms
				//  * 'Normal' words
				if (handleDigitOnlyString(mode)) {
				} else if (handleAcronym(mode)) {
				} else handleAlbumNameWord(mode);
				resetContextFlags();
			}
		}
	}
	capitalizeLastWord(mode);
	fixed_name[fixed_name.length] = closeOpenParentheses();
	var rs2 = handlePostProcessing(mode);
	addMessage('albumNameFix() :: result=@@@'+rs2+'###');
	return rs2;
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
// @param strIn				the un-processed input string
// @returns							the processed string
function trackNameFix(strIn, mode) {
	resetMessages();
	resetGlobals();
	resetContextFlags();
	mode = checkAutoFixMode(mode);
	if (strIn.match(/^([\(\[]?\s*data(\s+track)?\s*[\)\]]?$)/i))
		return "[data track]";
	if (strIn.match(/^([\(\[]?\s*silen(t|ce)(\s+track)?\s*[\)\]]?)$/i))
		return "[silence]";
	if (strIn.match(/^([\(\[]?\s*untitled(\s+track)?\s*[\)\]]?)$/i))
		return "[untitled]";
	if (strIn.match(/^([\(\[]?\s*(unknown|bonus)(\s+track)?\s*[\)\]]?)$/i))
		return "[unknown]";
	if (strIn.match(/^\?+$/i))
		return "[unknown]";
	strIn = preProcessTrimInformationToOmit(strIn);
	strIn = preProcessAbbreviations(strIn);
	strIn = processVinylExpressions(strIn);
	words = splitWordsAndPunctuation(strIn);
	words = preProcessExtraTitleInformation(words);
	for (words_index = 0; words_index < words.length; words_index++) { // not i, but words_index anymore
		words_candidate = words[words_index];
		if (handleWhiteSpace(mode)) {
		} else {
			// DEBUG
			// addMessage("trackNameFix() :: "+words_index+"/"+(words.length-1)+" "+words[words_index]);
			if (handleColons(mode)) {
			} else if (handleAmpersands(mode)) {
			} else if (handleLineTerminators(mode)) {
			} else if (handleHypens(mode)) {
			} else if (handlePlus(mode)) {
			} else if (handleCommas(mode)) {
			} else if (handlePeriods(mode)) {
			} else if (handleAsterix(mode)) {
			} else if (handleSlashes(mode)) {
			} else if (handleDoubleQuotes(mode)) {
			} else if (handleSingleQuotes(mode)) {
			} else if (handleOpeningParenthesis(mode)) {
			} else if (handleClosingParenthesis(mode)) {
			} else {
				// Deal with words and digits, there are 3 cases to handle.
				//  * Digit only strings
				//  * Acronyms
				//  * 'Normal' words
				if (handleDigitOnlyString(mode)) {
				} else if (handleAcronym(mode)) {
				} else handleTrackNameWord(mode);
				resetContextFlags();
			}
		}
	}
	capitalizeLastWord(mode);
	fixed_name[fixed_name.length] = closeOpenParentheses();
	var rs3 = handlePostProcessing(mode);
	addMessage('trackNameFix() :: result=@@@'+rs3+'###');
	return rs3;
}


// ----------------------------------------------------------------------------
// checkAutoFixMode()
// -- checks if given mode parameter is a valid value.
function checkAutoFixMode(mode) {
	mode = (mode == null ? AF_MODE_AUTOFIX : mode);
	if ((mode != AF_MODE_AUTOFIX) && 
		(mode != AF_MODE_SENTENCECAPS)) mode = AF_MODE_AUTOFIX;
	addMessage('checkAutoFixMode() :: current mode is  **** '+mode+' **** ');
	return mode;
}






/* ************************************************************************* */
/*																		     */
/* Methods which manipulate the fixed_name array.        					 */
/*														                     */
/* ************************************************************************* */

// ----------------------------------------------------------------------------
// appendStringToFixedName()
// -- Adds the current candidate to the fixed_name array
function appendStringToFixedName(word) {
	if (word == " ") {
		appendSpaceToFixedName();
	} else if (word != "" && word != null) {
		addMessage('  appendStringToFixedName(@@@'+word+'###)');
		fixed_name[fixed_name.length] = word;
	}
}

// ----------------------------------------------------------------------------
// appendSpaceToFixedName()
// -- Adds a space to the fixed_name array
function appendSpaceToFixedName() {
	// appendStringToFixedName(" ");		 
	fixed_name[fixed_name.length] = " ";
}

// ----------------------------------------------------------------------------
// appendSpaceToFixedNameIfNeeded()
// -- Checks the global flag space_next_word
//    and adds a space to the fixed_name array
//    if needed. The flag is *NOT* reset.
function appendSpaceToFixedNameIfNeeded() {
	if (space_next_word) appendSpaceToFixedName();
}









/* ************************************************************************* */
/*																		     */
/* methods which handle the different candidate types below					 */
/*														                     */
/* ************************************************************************* */

// ----------------------------------------------------------------------------
// handleWhiteSpace(mode)
// -- Deal with whitespace.				(\t)
//    primarily we only look at whitespace for context purposes
function handleWhiteSpace(mode) {
	if (words_candidate == " ") {
		last_char_was_whitespace = true;
		space_next_word = true;
		if (last_char_was_open_parenthesis) space_next_word = false;
		return true;
	}
	return false;
}

// ----------------------------------------------------------------------------
// handleColons(mode)
// -- Deal with colons (:)
//    colons are used as a sub-title split, and also for disc/box name splits
function handleColons(mode) {
	if (words_candidate.match(/\:/) != null) {
		addMessage('handleColons() :: "'+words_candidate+'"');
		// TODO: removed this, else there might be whitespace in front of
		// the colon, which is never allowed. (confirm?)
		// if (last_char_was_whitespace) appendSpaceToFixedName(); // add a space, and remember to
		appendStringToFixedName(words_candidate);
		space_next_word = (words[words_index + 1] == " "); 
		resetContextFlags();
		force_capitalize_next_word = true;
		last_word_was_colon = true;
		return true;
	}
	return false;
}

// ----------------------------------------------------------------------------
// handleAsterix(mode)
// -- Deal with asterix (*)
function handleAsterix(mode) {
	if (words_candidate.match(/\*/) != null) {
		addMessage('handleAsterix() :: "'+words_candidate+'"');
		if (last_char_was_whitespace) appendSpaceToFixedName(); // add a space, and remember to
        space_next_word = last_char_was_whitespace; // add one before the next word
		appendStringToFixedName(words_candidate);
		if (!space_next_word && words[words_index + 1] == " ") words_index++; 
		resetContextFlags();
		force_capitalize_next_word = true;
		last_word_was_colon = true;
		return true;
	}
	return false;
}

// ----------------------------------------------------------------------------
// handleAmpersands(mode)
// -- Deal with ampersands (&)
function handleAmpersands(mode) {
	if (words_candidate.match(/\&/) != null) {
		addMessage('handleAmpersands() :: "'+words_candidate+'"');
		resetContextFlags();
		force_capitalize_next_word = true;
		appendSpaceToFixedName(); // add a space, and remember to
		space_next_word = true; // add one before the next word
		appendStringToFixedName(words_candidate);
		return true;
	}
	return false;
}

// ----------------------------------------------------------------------------
// handleLineTerminators(mode)
// -- Deal with line terminators (?!;)
//    (other than the period).
function handleLineTerminators(mode) {
	if (words_candidate.match(/[\?\!\;]/) != null) {
		addMessage('handleLineTerminators() :: "'+words_candidate+'"');
		resetContextFlags();
		capitalizeLastWord(mode); 
		force_capitalize_next_word = true;
		space_next_word = true;
		appendStringToFixedName(words_candidate);
		return true;
	}
	return false;
}

// ----------------------------------------------------------------------------
// handleHypens(mode)
// -- Deal with hyphens (-)
//    if a hyphen has a space near it, then it should be spaced out and treated
//    similar to a sentence pause, otherwise it's a part of a hyphenated word.
//    unfortunately it's not practical to implement real em-dashes, however we'll
//    treat a spaced hyphen as an em-dash for the purposes of caps.
function handleHypens(mode) {
	if (words_candidate.match(/-/) != null) {
		addMessage('handleHypens() :: "'+words_candidate+'"');
		if (last_char_was_whitespace) appendSpaceToFixedName(); // add a space, and remember to
		else capitalizeLastWord(mode);
		appendStringToFixedName(words_candidate);
		space_next_word = (words[words_index + 1] == " "); 
		resetContextFlags();
		if (mode == AF_MODE_SENTENCECAPS) {
			force_capitalize_next_word = false; // don't capitalize next word after hyphen in sentence mode.
		} else force_capitalize_next_word = true;
		last_char_was_hyphen = true;
		return true;
	}
	return false;
}

// ----------------------------------------------------------------------------
// handlePlus(mode)
// -- Deal with plus symbol	(+)
function handlePlus(mode) {
	if (words_candidate.match(/\+/) != null) {
		addMessage('handlePlus() :: "'+words_candidate+'"');
		if (last_char_was_whitespace) appendSpaceToFixedName(); // add a space, and remember to
		appendStringToFixedName(words_candidate);
		space_next_word = (words[words_index + 1] == " "); 
		resetContextFlags();
		force_capitalize_next_word = true;
		return true;
	}
	return false;
}

// ----------------------------------------------------------------------------
// handleSlashes(mode)
// -- Deal with slashes (/)
//    if a slash has a space near it, pad it out, otherwise leave as is.
//    @flags:
//      * Next word capitalized
//      * Do not add a space before next word.
function handleSlashes(mode) {
	if (words_candidate.match(/[\\\/]/) != null) {
		addMessage('handleSlashes() :: whitespace before='+last_char_was_whitespace);
		if (last_char_was_whitespace) appendSpaceToFixedName(); // add a space, and remember to
		appendStringToFixedName(words_candidate);
		space_next_word = (words[words_index + 1] == " "); 
		resetContextFlags();
		force_capitalize_next_word = true;
		return true;
	}
	return false;
}

// ----------------------------------------------------------------------------
// handleDoubleQuotes(mode)
// -- Deal with double quotes (")
function handleDoubleQuotes(mode) {
	if (words_candidate.match(/\"/) != null) {
		addMessage('handleDoubleQuotes() :: ');
		if (last_char_was_whitespace) appendSpaceToFixedName(); // add a space, and remember to
		appendStringToFixedName(words_candidate);
		space_next_word = (words[words_index + 1] == " "); 
		resetContextFlags();
		force_capitalize_next_word = true;
		return true;
	}
	return false;
}

// ----------------------------------------------------------------------------
// handleSingleQuotes(mode)
// -- Deal with single quotes (')
//    * need to keep context on whether we're inside quotes or not.
//    * Look for contractions (see contractions_words for a list of
// 	    Contractions that are handled, and format the right part (after)
//      the (') as lowercase.
//    @flags:
//      * Toggle open_doublequote
//      * Capitalize next word in any case
//      * Do not add space if opened quotes
function handleSingleQuotes(mode) {
	if (words_candidate.match(/'/) != null) {
		addMessage('handleSingleQuotes() :: ');
		var foundcontraction = false;
		if (!last_char_was_whitespace && // look if current word and the word before
			words_index > 0 && // form one of the contradiction_words
			words_index < words.length-1) {
			var left_part = words[words_index-1].toLowerCase();
			var right_part = words[words_index+1].toLowerCase();
			var haystack = contraction_words[left_part];
			if (haystack != null && right_part != " ") {
				for (var cwi=0; cwi<haystack.length; cwi++) {
					if (haystack[cwi] == right_part) {
						addMessage('handleSingleQuotes() :: Found contraction='+left_part+"'"+right_part);
						foundcontraction = true;
						appendStringToFixedName(words_candidate+""+right_part);
						words_index++;
					}
				}
			}
		}
		if (!foundcontraction) {
			if (last_char_was_whitespace) appendSpaceToFixedName();
			appendStringToFixedName(words_candidate);
			if (words[words_index + 1] == " ") {
				space_next_word = true;				  // if there is a space after the ' assume its a closing singlequote
				// force_capitalize_next_word = true; // do not force capitalization (else Rollin' on, the On gets capitalized.
			} else space_next_word = false;
		}
		resetContextFlags();
		last_char_was_singlequote = true;
		return true;
	}
	return false;
}

// ----------------------------------------------------------------------------
// handleOpeningParenthesis(mode)
// -- Deal with opening parenthesis	(([{<)
//    knowing whether we're inside parenthesis (and multiple levels thereof) is
//    important for determining what words should be capped or not.
//    @flags:
//      * Set current_open_bracket
//      * Capitalize next word in any case
//      * Do not add space before next word
function handleOpeningParenthesis(mode) {
	if (words_candidate.match(/[\(\[\{\<]/) != null) {
		addMessage('handleOpeningParenthesis() :: "'+words_candidate+'", stack: ('+open_bracket+')');
		current_open_bracket = words_candidate;
		current_close_bracket = parenthesis[current_open_bracket]; // Set what we look for as a closing paranthesis
		capitalizeLastWord(mode); // force caps on last word
        open_bracket[open_bracket.length] = current_open_bracket;
		// set mode to extratitleinformation if words are found.
		var nextwordislowercased = false;
		for (var di = words_index + 1; di < words.length; di++) {
			if ((inArray(lowercase_bracket_words, words[di])) ||
				(words[di].match(/^featuring$|^ft$|^feat$/i) != null)) {
				mode_extratitleinformation = true;
				if (di == (words_index + 1)) nextwordislowercased = true;
			}
			if (words[di] == current_close_bracket) break;
		}
		appendSpaceToFixedNameIfNeeded();
		resetContextFlags();
		space_next_word = false;
		last_char_was_open_parenthesis = true;
		force_capitalize_next_word = !nextwordislowercased;
		appendStringToFixedName(words_candidate);

		last_word_was_disc = false;	// clear the flags (for the colon-handling after volume, part
		last_word_was_part = false; // and disc, even if no digit followed (and thus no colon was
		last_word_was_volume = false; // added (flawed implementation, but it works i guess)
		return true;
	}
	return false;
}

// ----------------------------------------------------------------------------
// handleClosingParenthesis(mode)
// -- Deal with closing parenthesis	(([{<)
//    knowing whether we're inside parenthesis (and multiple levels thereof) is
//    important for determining what words should be capped or not.
//    @flags:
//      * Set current_open_bracket
//      * Capitalize next word in any case
//      * Add space before next word
function handleClosingParenthesis(mode) {
	if (words_candidate.match(/[\)\]\}\>]/) != null) {
		addMessage('handleClosingParenthesis() :: "'+words_candidate+'", stack: ('+open_bracket+')');
		if (words_index >= 2 && 
			words_candidate == "]" && 
			fixed_name[fixed_name.length-1].match(/^unknown|untitled|silence$/i) != null &&  
			fixed_name[fixed_name.length-2] == "[") {
			fixed_name[fixed_name.length-1] = fixed_name[fixed_name.length-1].toLowerCase();
		} else capitalizeLastWord(mode); // capitalize the last word
		if (isInsideBrackets()) {
			open_bracket.pop();
			mode_extratitleinformation = false;
		}
		resetContextFlags();
		force_capitalize_next_word = true;
		space_next_word = true;
		appendStringToFixedName(words_candidate);
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
// handleCommas(mode)
// -- Deal with commas.			(,)
//    commas can mean two things: a sentence pause, or a number split. We
//    need context to guess which one it's meant to be, thus the digit
//    triplet checking later on. Multiple commas are removed.
//    @flags:
//      * Do not capitalize next word
//      * Add space before next word
function handleCommas(mode) {
	if (words_candidate.match(/\,/) != null) {
		if (fixed_name[fixed_name.length -1 ] != ",") {
			addMessage('handleCommas() :: "'+words_candidate+'"');
			resetContextFlags();
			space_next_word = true;
			force_capitalize_next_word = false;
			appendStringToFixedName(words_candidate);
		}
		return true;
	}
	return false;
}

// ----------------------------------------------------------------------------
// handlePeriods(mode)
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
function handlePeriods(mode) {
	if (words_candidate.match(/\./) != null) {
		addMessage('handlePeriods() :: "'+words_candidate+'"');
		if (fixed_name[fixed_name.length - 1] == ".") {
			if (!ellipsis) {
				ellipsis = true;
				fixed_name[fixed_name.length] = ".";
				fixed_name[fixed_name.length] = ".";
			}
			force_capitalize_next_word = true; // capitalize next word in any case.
			space_next_word = true;
		} else {
			resetContextFlags();
			capitalizeLastWord(mode); // just a normal, boring old period
			force_capitalize_next_word = true; // force caps on last word
			space_next_word = true;
			fixed_name[fixed_name.length] = ".";
		}
		return true;
	}
	return false;
}

// ----------------------------------------------------------------------------
// handleAcronym(mode)
// -- check for an acronym
function handleAcronym(mode) {
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
		// The method works as follows:
		// "A.B.C. I Love You" 		=> "A.B.C. I Love You"
		// "A. B. C. I Love You" 	=> "A.B.C. I Love You"
		// "A.B.C I Love You" 		=> "A.B. C I Love You"
		// "P.S I Love You" => "P. S I Love You"
		while (words_index + words_subindex < words.length) {
			var cw = words[words_index+words_subindex];
			if (expect_word && cw.match(/^\w$/) != null) {
				words_acronym[words_acronym.length] = cw.toUpperCase(); // consume dot
				expect_word = false;
				consumed_dot = false;
			} else {
				if (cw == "." && !consumed_dot) {
					words_acronym[words_acronym.length] = "."; // consume dot
					consumed_dot = true;
					expect_word = true;
				} else {
					if (consumed_dot && cw == " ") {
						expect_word = true; // consume a single whitespace 
					} else {
						var lastpart = words_acronym[words_acronym.length-1];
						if (lastpart == ".") {
						} else if (lastpart == ".") {
						} else {
							words_acronym.pop(); // loose last of the acronym
							words_subindex--; // its for example "P.S. I" love you
						}
						break; // found something which is not part of the acronym
					}
				}
			}
			words_subindex++;
		}
	}
	if (words_acronym.length > 2) {
		var tempStr = words_acronym.join(""); // yes, we have an acronym, get string
		tempStr = tempStr.replace(/(\.)*$/, "."); // replace any number of trailing "." with ". "
		addMessage('handleAcronym(mode) :: '+tempStr);
		appendSpaceToFixedNameIfNeeded();
		appendStringToFixedName(tempStr);
		last_word_was_an_acronym = true;
		space_next_word = true;
		force_capitalize_next_word = false;
		words_index	= words_index + words_subindex - 1; // set pointer to after acronym
		return true;
	}
	return false;
}

// ----------------------------------------------------------------------------
// handleDigitOnlyString(mode)
// -- Check for a digit only string
function handleDigitOnlyString(mode) {
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
		words_index = words_index + words_subindex - 1 ;
		var number = words_number.join("");
		if (last_word_was_disc || last_word_was_part || last_word_was_volume) {			
			// delete leading '0', if last word was a seriesnumberstyle word.
			// e.g. disc 02 -> disc 2
			number = number.replace(/^0*/, ""); 
		}
		addMessage('handleDigitOnlyString() :: @@@"'+words_number.join('')+'"###, next word='+words[words_index+1]);

		// add : after disc with number, with more words following
		// only if there is a string which is assumed to be the
		// disc title.
		// e.g. Albumname cd 4 -> Albumname (disc 4)
		// but  Albumname cd 4 the name -> Albumname (disc 4: The Name)
		var addcolon = false;
		if (last_word_was_disc || last_word_was_part || last_word_was_volume) {
			if (words_index < words.length-2) {
				var nword = words[words_index + 1];
				var naword = words[words_index + 2];
				var nwordm = nword.match(/[\):\-&]/);
				var nawordm = naword.match(/[\(:\-&]/);
				// alert(nword+"="+nwordm+"    "+naword+"="+nawordm);
				// only add a colon, if the next word is not ")", ":", "-", "&"
				// and the word after the next is not "-", "&", "("
				if (nwordm == null && nawordm == null) addcolon = true;
				else if (last_word_was_part && 
						 naword != "(") fixed_name[fixed_name.length-1] += "s";
			}
			last_word_was_disc = false;	// clear the flags (for the colon-handling after volume, part
			last_word_was_part = false; // and disc, even if no digit followed (and thus no colon was
			last_word_was_volume = false; // added (flawed implementation, but it works i guess)
			space_next_word = true;
			force_capitalize_next_word = true;
		} 
		appendSpaceToFixedNameIfNeeded();
		appendStringToFixedName(number);
		force_capitalize_next_word = false;
		last_word_was_a_number = true;		
		if (addcolon) {
			appendStringToFixedName(":");     // if there is no colon already present, add a colon
			force_capitalize_next_word = true;
			last_word_was_colon = true;
		}
		return true;
	}
	return false;
}

// ----------------------------------------------------------------------------
// handleArtistNameWord(mode)
// -- Artist name specific processing of words
function handleArtistNameWord(mode) {
addMessage('handleArtistNameWord() :: Candidate=@@@'+words_candidate+'###');
	words_candidate = titleCase(words_candidate, mode);
	if (handleVersus(mode)) {
	} else if (words_candidate.match(/^(pres|presents)$/i)) {
		words_candidate = "presents";
		appendSpaceToFixedName();
		appendStringToFixedName(words_candidate);
		if (words[words_index+1] == ".") words_index++;
	} else {
		appendSpaceToFixedNameIfNeeded();
		appendStringToFixedName(words_candidate);
	}
	last_word_was_a_number = false;
	return true;
}

// ----------------------------------------------------------------------------
// handleAlbumNameWord(mode)
// -- Album name specific processing of words
function handleAlbumNameWord(mode) {
	words_candidate = titleCase(words_candidate, mode);
	if (handleDisc(mode)) {
	} else if (handleFeaturingArtist(mode)) {
	} else if (handleVersus(mode)) {
	} else if (handleVolume(mode)) {
	} else if (handlePart(mode)) {
	} else { // handle normal word.
		appendSpaceToFixedNameIfNeeded();
		appendStringToFixedName(words_candidate);
		force_capitalize_next_word = false;
		space_next_word = true;
	}
	last_word_was_a_number = false;
}

// ----------------------------------------------------------------------------
// handleTrackNameWord(mode)
// -- Track name specific processing of words
function handleTrackNameWord(mode) {
	var probe = words_candidate.toLowerCase();
	words_candidate = titleCase(words_candidate, mode);
	if (handleFeaturingArtist(mode)) {
	} else if (handleVersus(mode)) {
	} else if (handleVolume(mode)) {
	} else if (handlePart(mode)) {
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
		appendStringToFixedName(words_candidate);
	}	
	last_word_was_a_number = false;
}

// ----------------------------------------------------------------------------
// handleVersus(mode)
// -- Correct vs.
function handleVersus(mode) {
	if (words_candidate.match(/^vs$/i)) {
		addMessage('handleVersus() :: @@@'+words_candidate+'###');
		capitalizeLastWord(mode);
		if (!last_char_was_open_parenthesis) appendSpaceToFixedName();
		appendStringToFixedName(words_candidate.toLowerCase());
		appendStringToFixedName(".");
		if (words[words_index + 1] == ".") words_index += 1; // skip trailing (.)
		force_capitalize_next_word = true;
		space_next_word = true;
		return true;
	}
	return false;
}

// ----------------------------------------------------------------------------
// handleVolume(mode)
// -- Handle "Vol", "Vol.", "Volume" -> ", Volume"
function handleVolume(mode) {
	if (words_candidate.match(/^(vol|volume)$/i) &&
		words_index < words.length-1) {
		var wi = words_index+1;
		while (wi < words.length-1 && words[wi].match(/ |\./i)) wi++; // consume spaces and dots 
		if (words[wi].match(/(\d|[ivx]+)/i)) {
			// only do the conversion if ..., volume is followed
			// by a digit or a roman number				
			if (words_index >= 2 && 
				!inArray(punctuation_chars, fixed_name[fixed_name.length-1])) { // if no other punctuation char present
				while (fixed_name.length > 0 && // check if there was a hypen (+whitespace) before, and drop it. 
					   fixed_name[fixed_name.length-1].match(/ |-/i)) fixed_name.pop();
   				capitalizeLastWord(mode); // capitalize last word before comma.
				fixed_name[fixed_name.length] = ","; // add a comma
			} else {
				// capitalize last word before punctuation char.
			   	capitalizeWordAtIndex(mode, fixed_name, fixed_name.length-2); 
			}
			words_candidate = "Volume";
			appendSpaceToFixedNameIfNeeded();
			appendStringToFixedName(words_candidate);
			force_capitalize_next_word = false;
			space_next_word = true;
			last_word_was_volume = true;
			last_word_was_a_number = false;
			if (words[words_index+1] == ".") words_index++; // skip trailing dot, was already handled.
			return true;
		}
	}
	return false;
}

// ----------------------------------------------------------------------------
// handlePart(mode)
// -- Handle "Pt", "Pt.", "Part" -> ", Part"
function handlePart(mode) {
	if (words_candidate.match(/^(pt|part|pts)$/i) &&
		words_index < words.length-1) {
		var wi = words_index + 1;
		while (wi < words.length-1 && words[wi].match(/ |\.|#/i)) wi++; // consume spaces and dots 
		if (words[wi].match(/(\d|[ivx]+)/i)) {
			// only do the conversion if ..., part is followed
			// by a digit or a roman number
			if (words_index >= 2 && 
				!inArray(punctuation_chars, fixed_name[fixed_name.length-1])) { // if no other punctuation char present
				while (fixed_name.length > 0 && // check if there was a hypen (+whitespace) before, and drop it.
					   fixed_name[fixed_name.length-1].match(/ |-/i)) fixed_name.pop();
				fixed_name[fixed_name.length] = ","; // add a comma
			} else {
				// capitalize last word before punctuation char.
			   	capitalizeWordAtIndex(mode, fixed_name, fixed_name.length-2); 
			}
			words_candidate = "Part";
			appendSpaceToFixedNameIfNeeded();
			appendStringToFixedName(words_candidate);
			force_capitalize_next_word = true;
			space_next_word = true;
			last_word_was_part = true;
			last_word_was_a_number = false;
			words_index = wi-1; // set index to last before number.
			return true;
		} 
	}
	return false;
}

// ----------------------------------------------------------------------------
// handleDisc(mode)
// -- correct cd{n}, disc{n}, disk{n}, disque{n} terms
function handleDisc(mode) {
	var matcher = null;
	if (!last_word_was_colon && // do not convert xxx (disc 1: cd) to "...: disc"
		words_index > 0 && // do not convert "cd.." to "Disc..."
		words_index < words.length && // do not convert "cd.." to "Disc..."
		(matcher = words_candidate.match(/^(Cd|Disk|Discque|Disc)([^\s\d]*)(\s*)(\d*)/i)) != null) { // test for disc/disk and variants
		// If first word is not one of "Cd", "Disk", "Disque", "Disc" but i.e. Discography, give up.
		if (matcher[2] != "") return false;
		// check if a number is part of the disc title, i.e. Cd2, has to 
		// be expanded to Cd-space-2
		if (matcher[4] != "") {
			var numericpart = matcher[4];
			numericpart = numericpart.replace("^0", ""); // delete leading '0', e.g. disc 02 -> disc 2
			var p1 = words.slice(0, words_index+1); 
			var p2 = words.slice(words_index+1, words.length);
			p1[p1.length] = " "; 		 // add space before the number
			p1[p1.length] = numericpart; // add numeric part
			words = p1.concat(p2);
		}
		var wi = words_index+1;
		while (wi < words.length && words[wi].match(/ |\./i)) wi++; // consume spaces and dots 
		if (words[wi].match(/(\d|[ivx]+)/i) || words[words_index-2] == "bonus") {
			if (fixed_name[fixed_name.length-1] == "-" || 
				fixed_name[fixed_name.length-1] == ":") {
				fixed_name.pop(); // delete hypen, or colon if one occurs before 
								  // disc: e.g. Albumname - Disk1
								  // disc: Albumname, Volume 2: cd 1
			}
			appendSpaceToFixedNameIfNeeded();
			if (open_bracket.length == 0) { //if we're not inside brackets, open up a new pair.
				words_candidate = "(";
				words[words.length] = ")";
				handleOpeningParenthesis(mode);
			}
			appendStringToFixedName("disc");
			space_next_word = false;
			force_capitalize_next_word = false;
			last_word_was_a_number = false;
			last_word_was_disc = true;
			return true;
		}
	}
	return false;
}

// ----------------------------------------------------------------------------
// handleFeaturingArtist(mode)
// -- Detect featuring, f[.], ft[.], feat[.] and add 
// 	  parantheses as needed.
//
// change log:
// ---------------------------------------------------
// g0llum		2005-08-12		added ^f$[.] to cases
//								which are added converted to feat.
function handleFeaturingArtist(mode) {
	if (words_candidate.match(/^featuring$|^f$|^ft$|^feat$/i)) {
		var featparts = new Array();
		featparts[featparts.length] = "feat.";
		if (!last_char_was_open_parenthesis) {
			if (isInsideBrackets()) { // close open parantheses before the feat. part.				
				var closebrackets = new Array();
				while (isInsideBrackets()) { // close brackets that were opened before
					current_open_bracket = open_bracket[open_bracket.length-1];
					current_close_bracket = parenthesis[current_open_bracket];
					appendStringToFixedName(current_close_bracket);
					if (words[words.length-1] == current_close_bracket) words.pop();
					open_bracket.pop();
				}
			}		
			// handle case:
			// Blah ft. Erroll Flynn Some Remixname remix
			// -> pre-processor added parantheses such that the string is:
			// Blah ft. erroll flynn Some Remixname (remix)
			// -> now there are parantheses needed before remix
			// Blah (feat. Erroll Flynn Some Remixname) (remix)
			for (var nextparen = words_index; nextparen < words.length; nextparen++)
				if (words[nextparen] == "(") break;
			if (nextparen != words_index &&
				nextparen < words.length-1) { // we got a part, but not until the end of the string 
				var p1 = words.slice(0, nextparen);
				var p2 = words.slice(nextparen, words.length);
				p1[p1.length] = ")"; // close off feat. part before next paranthesis.
				p1[p1.length] = " ";
				words = p1.concat(p2);
  			} 
			words_candidate = "(";
			handleOpeningParenthesis();
		}
		var featStr = featparts.join("");
		appendStringToFixedName(featStr);
		force_capitalize_next_word = true;
		space_next_word = true;
		mode_extratitleinformation = true;
		last_word_was_feat = true;
		if (words[words_index + 1] == ".") words_index += 1; // skip trailing (.)
		addMessage('handleFeaturingArtist() :: @@@'+featStr+'###');
		return true;
	}
	return false;
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
// @param	 strIn		the un-processed input string
// @returns								 sets the GLOBAL array of words and puctuation characters
function splitWordsAndPunctuation(strIn) {
	strIn = strIn.replace(/^\s\s*/, ""); // delete leading space
	strIn = strIn.replace(/\s\s*$/, ""); // delete trailing space
	strIn = strIn.replace(/\s\s*/g, " "); // compress whitespace:
	var localwords = new Array();
	var chars = strIn.split("");
	var word = "";
	for (var i=0; i<chars.length; i++) {
		if (chars[i].match(/[^!\"%&'()\[\]\{\}\*\+,-\.\/:;<=>\?\s#]/)) {
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
		dumpwords += '@@@';
		dumpwords += localwords[ci];
		dumpwords += '### ';
	}
	addMessage('splitWordsAndPunctuation() :: words: '+dumpwords);
	return localwords;
}

// ----------------------------------------------------------------------------
// preProcessAbbreviations()
// --  take care of "RMX", "alt. take" "alt take"
function preProcessAbbreviations(strIn) {
	for (var i=0; i<preprocess_searchterms.length; i++) {
		var re = preprocess_searchterms[i][0];
		var match = strIn.match(re);
		if (match) {
			var replaceStr = match[1] + preprocess_searchterms[i][1] + match[2];
			strIn = strIn.replace(re, replaceStr);
			// addMessage(re+' '+match+' @@@'+replaceStr+'###');
		}
	}
	addMessage('preProcessAbbreviations() :: after processing @@@'+strIn+'###');
	return strIn;
}

// ----------------------------------------------------------------------------
// preProcessTrimInformationToOmit()
// --  take care of (bonus), (bonus track)
function preProcessTrimInformationToOmit(strIn) {
	strIn = strIn.replace(/[\(\[]?bonus(\s+track)?s?\s*[\)\]]?$/i, "");
	strIn = strIn.replace(/[\(\[]?retail(\s+version)?\s*[\)\]]?$/i, "");
	addMessage('preProcessTrimInformationToOmit() :: after processing @@@'+strIn+'###');
	return strIn;
}



// ----------------------------------------------------------------------------
// handlePostProcessing(mode)
// -- Collect words from fixed_name and apply minor
//   fixed that aren't handled in the specific function.
function handlePostProcessing(mode) {
	var rs4 = trim(fixed_name.join(""));
	for (var i=0; i<postprocess_searchterms.length; i++) {
		var re = postprocess_searchterms[i][0];
		var match = rs4.match(re);
		if (match) {
			var replaceStr = match[1] + postprocess_searchterms[i][1] + match[2];
			rs4 = rs4.replace(re, replaceStr);
		}
	}
	addMessage('handlePostProcessing() :: after processing @@@'+rs4+'###');
	rs4 = processVinylExpressions(rs4);
	addMessage('handlePostProcessing() :: after vinyl expressions @@@'+rs4+'###');
	return rs4;
}


// ----------------------------------------------------------------------------
// processVinylExpressions()
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
function processVinylExpressions(strIn) {
	var re = /(\s+|\()((\d+)[\s|-]?(inch\b|in\b|'+|"))([^s]|$)/i;
	var m = strIn.match(re);
	if (m) {
		var mindex = m.index;
		var mlenght  = m[1].length + m[2].length + m[5].length; // calculate the length of the expression
		var firstPart = strIn.substring(0, mindex);
		var lastPart = strIn.substring(mindex+mlenght, strIn.length); // add number
		var parts = new Array(); // compile the vinyl designation.
		parts[parts.length] = firstPart;
		parts[parts.length] = m[1]; // add matched first expression (either ' ' or '('
		parts[parts.length] = m[3]; // add matched number, but skip the in,inch,'' part
		parts[parts.length] = '"'; // add vinyl doubleqoute
		parts[parts.length] = (m[5] != " " && m[5] != ")" && m[5] != "," ? " " : ""); // add space after ", if none is present and next character is not ")" or ","
		parts[parts.length] = m[5]; // add first character of next word / space.
		parts[parts.length] = lastPart; // add rest of string
		strIn = parts.join("");
	}
	return strIn;
}

// ----------------------------------------------------------------------------
// preProcessExtraTitleInformation()
// --
// pre-process to find any lowercase_bracket word that needs to be put into parantheses.
// starts from the back and collects words that belong into
// the brackets: e.g.
// My Track Extended Dub remix => My Track (extended dub remix)
// My Track 12" remix => My Track (12" remix)
function preProcessExtraTitleInformation(tnwords) {
	var wi = tnwords.length-1;
	var handlePreProcess = false;
	var isDoubleQuote = false;
	while (((tnwords[wi] == " ") || // skip whitespace
		   (tnwords[wi] == '"' && (tnwords[wi-1] == "7" || tnwords[wi-1] == "12")) || // vinyl 7" or 12"
		   (tnwords[wi+1] == '"' && (tnwords[wi] == "7" || tnwords[wi] == "12")) || 
		   (inArray(preprocessor_bracket_words, tnwords[wi]))) && 
		    wi >= 0) {
		handlePreProcess = true;
		wi--;
	}
	// "Dance, Dance, Dance", wi is: Dance = (-2), " " = -3, next word "," does not match.
	// "Give and Take", wi is: take = (-2), " " = -3, next word "and" does not match.
	// -> wi (-3) is in preprocessor_bracket_singlewords array, handlePreProcess is
	// reset to false.
	if ((wi == tnwords.length-3) && 						   
	    (preprocessor_bracket_singlewords[tnwords[wi+2].toLowerCase()] != null)) {
		addMessage('preProcessExtraTitleInformation() :: pre-process, word found, but its a singlewords @@@'+tnwords.join("")+'###');
		handlePreProcess = false;
	} 
	if (handlePreProcess && wi > 0 && wi < tnwords.length-1) {
		wi++; // increment to last word that matched.
		var newwords = tnwords.slice(0, wi);
		if (newwords[wi-1] == "-") newwords.pop();
		newwords[newwords.length] = "(";
		newwords = newwords.concat(tnwords.slice(wi, tnwords.length));
		newwords[newwords.length] = ")";
		tnwords = newwords;
		addMessage('preProcessExtraTitleInformation() :: after pre-process @@@'+tnwords.join("")+'###');
	}
	return tnwords;
}


// ----------------------------------------------------------------------------
// capitalizeWordAtIndex(mode)
// -- Capitalize the word at the current cursor position.
//    Modifies the last element of the fixed_name array
function capitalizeWordAtIndex(mode, theArray, index) {
	if (theArray.length == 0) return;
	if (index < 1 || theArray.length-1 < index) return;
	if (mode == AF_MODE_SENTENCECAPS) return; // don't capitalize last word before puncuation/end of string in sentence mode.
	var before = fixed_name[index];
	var after = fixed_name[index];
	var lastword = fixed_name[index-1];
	if (fixed_name[index].match(/^\w\..*/) == null) { // check that last word a word.
		var probe = trim(fixed_name[index].toLowerCase()); // some words that were manipulated might have space padding
		if (isInsideBrackets() && inArray(lowercase_bracket_words, probe)) { 
			// If inside brackets, do nothing.
		} else if (inArray(uppercase_words, probe)) { 
			// If it is an UPPERCASE word, do nothing.
		} else if (probe == "s" && lastword == "'") {
			// do not capitalize "s" if it occurs after a
			// singlequote like "C.C. Bloom's"
		} else {
			after = titleCaseWithExceptions(probe, mode);
			fixed_name[index] = after;
			if (before != after) addMessage('capitalizeWordAtIndex(mode, index='+index+'/'+(theArray.length-1)+') :: before=@@@'+before+'###, after=@@@'+after+'###');
		}
	}
}


// ----------------------------------------------------------------------------
// capitalizeLastWord(mode)
// -- Capitalize the word at the current cursor position.
//    Modifies the last element of the fixed_name array
function capitalizeLastWord(mode) {
	capitalizeWordAtIndex(mode, fixed_name, fixed_name.length-1);
}

// ----------------------------------------------------------------------------
// titleCaseWithExceptions()
// -- Capitalize the string, but check if some characters
//    inside the word need to be uppercased as well.
function titleCaseWithExceptions(strIn, mode) {
	if (strIn == null || strIn == "") return "";
	var rs5 = strIn.toLowerCase();
	if ((!mode_extratitleinformation) &&
		(mode == AF_MODE_SENTENCECAPS) && 
		(words_index > 0) &&
		(!inArray(sentencestop_chars, fixed_name[fixed_name.length-1])) && 
		(!last_char_was_open_parenthesis)) {
		// if in sentence caps mode, and last char was not 
		// a punctuation or opening bracket -> lowercase
	    addMessage('titleCaseWithExceptions(mode) :: Sentence, before=@@@'+strIn+'###, after=@@@'+rs5+'###');
		return rs5;
	} else {
		var chars = strIn.toLowerCase().split("");
		chars[0] = chars[0].toUpperCase(); // uppercase first character
		if (strIn.length > 2 && strIn.substring(0,2) == "mc") { // only look at strings which start with Mc but length > 2
			chars[2] = chars[2].toUpperCase(); // Make it McTitled
		} else if (strIn.length > 3 && 
				   inArray(words_mactitled, strIn) && 
				   strIn.substring(0,3) == "mac") { // only look at strings which start with Mac but length > 3
			chars[3] = chars[3].toUpperCase(); // Make it MacTitled
		}  
		rs5 = chars.join("");
		addMessage('titleCaseWithExceptions(mode) :: Capitalized, before=@@@'+strIn+'###, after=@@@'+rs5+'###');
		return rs5;
	}
}

// ----------------------------------------------------------------------------
// titleCase()
// --  Upper case first letter of word unless it's one of the words in the
//     lowercase words array
// @param strIn	the un-processed input string
// @returns				the processed string
// change log (who, when, what)
// -------------------------------------------------------
// tma			2005-01-29		first version
// g0llum		2005-01-30		added cases for McTitled, MacTitled, O'Titled
// g0llum		2005-01-31		converted loops to associative arrays.
function titleCase(strIn, mode) {
	var rs6 = strIn.toLowerCase();
	if (rs6 == null) return "";
	if (rs6 == "") return rs6;
	if (rs6.length == 1 && words_index > 1 && words[words_index - 1] == "'") { 
		// we got an 'x (apostrophe), keep the text lowercased
	} else if (rs6.match(/^s|round|em$/i) && words[words_index - 1] == "'") { 
		// we got an 's (apostrophed ...'s), keep the text lowercased
		// we got an 'round (apostrophed Around), keep the text lowercased
		// we got an 'em (shortened Them), keep lowercase.
	} else if (rs6.match(/^o|y$/i) && words[words_index + 1] == "'") { 
		// Make it O'Titled, Y'All
		rs6 = strIn.toUpperCase(); 
	} else {
		rs6 = titleCaseWithExceptions(rs6, mode);
		var probe = rs6.toLowerCase(); // prepare probe to lookup entries of the wordlists.
		if (inArray(lowercase_words, probe) && !force_capitalize_next_word) { 
			// Test if it's one of the lowercase_words  
			// but if force_capitalize_next_word is not set
			rs6 = strIn.toLowerCase();
		} else if (inArray(uppercase_words, probe)) { 
			// Test if it's one of the uppercase_words
			rs6 = strIn.toUpperCase();
		} else if (isInsideBrackets()) { 
			// If inside brackets
			if (inArray(lowercase_bracket_words, probe)) { 
				// Test if it's one of the lowercase_bracket_words
				if (last_word_was_colon && probe == "disc") { 
					// handle special case: (disc 1: Disc x)
				} else rs6 = strIn.toLowerCase();
			}
		}
	}
	addMessage('titleCase(input=@@@'+strIn+'###, force_caps='+force_capitalize_next_word+') OUT: @@@'+rs6+'###');
	return rs6;
}










/* ************************************************************************* */
/*																		     */
/* utility methods: keep global stats, and transform arrays into associative */
/* arrays. 						                                             */
/*														                     */
/* ************************************************************************* */

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
	// addMessage('resetContextFlags() :: Done.');
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
	last_word_was_part = false;
	last_word_was_volume = false;
	last_word_was_feat = false;
	last_word_was_colon = false;
	number_split = null;
	// addMessage('resetGlobals() :: Done.');
}

// ----------------------------------------------------------------------------
// toAssociativeArray()
// -- Renders an array to an associative array with lowercase keys.
function toAssociativeArray(theArray) {
	var temp = [];
	try {
		for (var m=0; m<theArray.length; m++) {
			var curr = theArray[m].toLowerCase()
			temp[curr] = curr;
		}
	} catch (e) {}
	return temp;
}

// ----------------------------------------------------------------------------
// inArray()
// -- Checks if the variable theKey is in the given array theArray
// returns true, 	if theKey != null
// 					if theArray != null
// 					if theArray has an entry for theKey
// 					if theArray entry for theKey is theKey 
// 					(accounts for array methods push, pop etc.)
function inArray(theArray, theKey) {
	theKey = (theKey != null ? theKey.toLowerCase() : null);
	return (theKey != null && theArray != null &&  
			theArray[theKey] != null && theArray[theKey] == theKey); 
}

// ----------------------------------------------------------------------------
// toContractionWords()
// -- Renders the contraction words into an array which supports
//    lookup with the left part of the contraction like Isn't = array['Isn'] = 't';
function toContractionWords(theArray) {
	var temp = [];
	try {
		for (var i=0; i<theArray.length; i++) {
			var curr = theArray[i].toLowerCase();
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
// trim()
function trim(strIn) {
	return strIn
		.replace(/^\s\s*/, "")
		.replace(/\s\s*$/, "")
		.replace(/([\(\[])\s+/, "$1")
		.replace(/\s+([\)\]])/, "$1")
		.replace(/\s\s*/g, " ");
}

// ----------------------------------------------------------------------------
// isNullOrEmpty()
// -- Test a string if it is null or ""
function isNullOrEmpty(strIn) {
	return (strIn == null || strIn == "");
}






















/* ************************************************************************* */
/*																		     */
/* debug methods: process messages into the debug_msgs array				 */
/*														                     */
/* ************************************************************************* */


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
resetMessages();

// ----------------------------------------------------------------------------
// getMessages()
// -- Resets the list of debug messages
function getMessages() {
	return "<br> &nbsp; &nbsp; &nbsp;" + 
		   debug_msgs.join("<br> &nbsp; &nbsp; &nbsp;");
}


// ----------------------------------------------------------------------------
// addMessage()
// -- Adds a message to the list of debug messages
function addMessage(message) {
	var tmp = message.split("@@@");
	message = tmp.join('<span class="mbword">');
	tmp = message.split("###");
	message = tmp.join('</span>');
	message = message.replace(" ", "&nbsp;");
	debug_msgs[debug_msgs.length] = 
		(new Date().getTime()-debug_starttime)+"[ms] :: "+message;
}

