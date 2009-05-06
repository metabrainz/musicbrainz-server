var TurkishI,
    NON_BMP_CHAR_CODES = {
    BOTTOM : 55296,
    TOP    : 56319
}
String.prototype.toMusicBrainzUpperCase = function() { 
    if (this.length === 0) {
        return "";
    }
    var returnString = "",
        x,
        i = 0;
    do
    {
        x = this[i];
        if (x.charCodeAt(0) >= NON_BMP_CHAR_CODES.BOTTOM && x.charCodeAt(0) <= NON_BMP_CHAR_CODES.TOP) {  // Deseret characters are in plane 1, thus 2 chars wide.  Also avoids CJK issues and other planes 1 - 16 issues.
            x = String.fromCharCode(this.charAt(i).charCodeAt(0)) + String.fromCharCode(this.charAt(++i).charCodeAt(0));
        }
        switch(x) {
            /* Handle Turkish I problem. */
            case "i": returnString += TurkishI ? "İ" : "I"; break;
            case "ı": returnString += "I"; break;
            case "İ": returnString += "İ"; break;  // Make sure it stays dotted. - composed version
            case "İ": returnString += "İ"; break;  // Make sure it stays dotted. - precomposed version
            /* Composed characters where want titlecase, not uppercase. */
            case "ǆ": returnString += "ǅ"; break;
            case "ǳ": returnString += "ǲ"; break;
            case "ǌ": returnString += "ǋ"; break;
            case "ǉ": returnString += "ǈ"; break;
            case "ǉ": returnString += "ǈ"; break;
            case "ǉ": returnString += "ǈ"; break;
            /* Non-reversible titlecasing for composed characters where want titlecase, not uppercase.  Non-reversibility is per Unicode spec. */
            case "ﬀ": returnString += "Ff"; break;
            case "ﬁ": returnString += "Fi"; break;
            case "ﬂ": returnString += "Ffi"; break;
            case "ﬃ": returnString += "Ffi"; break;
            case "ﬄ": returnString += "Ffl"; break;
            case "ﬅ": returnString += "St"; break;
            case "ﬆ": returnString += "St"; break;
            case "և": returnString += "Եւ"; break;
            case "ﬓ": returnString += "Մն"; break;
            case "ﬔ": returnString += "Մե"; break;
            case "ﬕ": returnString += "Մի"; break;
            case "ﬖ": returnString += "Վն"; break;
            case "ﬗ": returnString += "Մխ"; break;
            case "ŉ": returnString += "ʼN"; break;
            case "ΐ": returnString += "Ϊ́"; break;
            case "ΰ": returnString += "Ϋ́"; break;
            case "ǰ": returnString += "J̌"; break;
            case "ẖ": returnString += "H̱"; break;
            case "ẗ": returnString += "T̈"; break;
            case "ẘ": returnString += "W̊"; break;
            case "ẙ": returnString += "Y̊"; break;
            case "ẚ": returnString += "A"; break;
            case "ὐ": returnString += "Υ̓"; break;
            case "ὒ": returnString += "Υ̓̀"; break;
            case "ὔ": returnString += "Υ̓́"; break;
            case "ὖ": returnString += "Υ̓͂"; break;
            case "ᾶ": returnString += "Α͂"; break;
            case "ῆ": returnString += "Η͂"; break;
            case "ῒ": returnString += "Ϊ̀"; break;
            case "ΐ": returnString += "Ϊ́"; break;
            case "ῖ": returnString += "Ι͂"; break;
            case "ῗ": returnString += "Ϊ͂"; break;
            case "ῢ": returnString += "Ϋ̀"; break;
            case "ΰ": returnString += "Ϋ́"; break;
            case "ῤ": returnString += "Ρ̓"; break;
            case "ῦ": returnString += "Υ͂"; break;
            case "ῧ": returnString += "Ϋ͂"; break;
            case "ῶ": returnString += "Ω͂"; break;
            case "ȸ": returnString += "Db"; break;
            case "ʣ": returnString += "Dz"; break;
            case "ʥ": returnString += "Dʑ "; break;
            case "ʤ": returnString += "Dʒ"; break;
            case "ʩ": returnString += "Fŋ"; break;
            case "ʪ": returnString += "Ls"; break;
            case "ʫ": returnString += "Lz"; break;
            case "ɮ": returnString += "ʒ "; break;
            case "ȹ": returnString += "Qp"; break;
            case "ʨ": returnString += "Tɕ"; break;
            case "ʦ": returnString += "Ts"; break;
            case "ʧ": returnString += "Tʃ"; break;
            /* Characters broken in various browser implementations of toLocaleUpperCase.  */
            case "ȳ": returnString += "Ȳ"; break;  // U+0233 - test 21, broken in IE8
            case "ɇ": returnString += "Ɇ"; break;  // U+0247 - test 24, broken in IE8
            case "ⰺ": returnString += "Ⰺ"; break;  // U+2C3A - test 8, broken in IE8
            case "ⲳ": returnString += "Ⲳ"; break;  // U+2CB3 - test 158, broken in IE8
            case "ⲵ": returnString += "Ⲵ"; break;  // U+2CB5 - test 159, broken in IE8
            case "ⲷ": returnString += "Ⲷ"; break;  // U+2CB7 - test 160, broken in IE8
            /* Deseret Unicode block, no characters implemented in toLocaleUpperCase in any major browser.  */
            case "𐐨": returnString += "𐐀"; break;  // Deseret small letter long i (U+10428)
            case "𐐩": returnString += "𐐁"; break;  // Deseret small letter long e (U+10429)
            case "𐐪": returnString += "𐐂"; break;  // Deseret small letter long a (U+1042a)
            case "𐐫": returnString += "𐐃"; break;  // Deseret small letter long ah (U+1042b)
            case "𐐬": returnString += "𐐄"; break;  // Deseret small letter long o (U+1042c)
            case "𐐭": returnString += "𐐅"; break;  // Deseret small letter long oo (U+1042d)
            case "𐐮": returnString += "𐐆"; break;  // Deseret small letter short i (U+1042e)
            case "𐐯": returnString += "𐐇"; break;  // Deseret small letter short e (U+1042f)
            case "𐐰": returnString += "𐐈"; break;  // Deseret small letter short a (U+10430)
            case "𐐱": returnString += "𐐉"; break;  // Deseret small letter short ah (U+10431)
            case "𐐲": returnString += "𐐊"; break;  // Deseret small letter short o (U+10432)
            case "𐐳": returnString += "𐐋"; break;  // Deseret small letter short oo (U+10433)
            case "𐐴": returnString += "𐐌"; break;  // Deseret small letter ay (U+10434)
            case "𐐵": returnString += "𐐍"; break;  // Deseret small letter ow (U+10435)
            case "𐐶": returnString += "𐐎"; break;  // Deseret small letter wu (U+10436)
            case "𐐷": returnString += "𐐏"; break;  // Deseret small letter yee (U+10437)
            case "𐐸": returnString += "𐐐"; break;  // Deseret small letter h (U+10438)
            case "𐐹": returnString += "𐐑"; break;  // Deseret small letter pee (U+10439)
            case "𐐺": returnString += "𐐒"; break;  // Deseret small letter bee (U+1043a)
            case "𐐻": returnString += "𐐓"; break;  // Deseret small letter tee (U+1043b)
            case "𐐼": returnString += "𐐔"; break;  // Deseret small letter dee (U+1043c)
            case "𐐽": returnString += "𐐕"; break;  // Deseret small letter chee (U+1043d)
            case "𐐾": returnString += "𐐖"; break;  // Deseret small letter jee (U+1043e)
            case "𐐿": returnString += "𐐗"; break;  // Deseret small letter kay (U+1043f)
            case "𐑀": returnString += "𐐘"; break;  // Deseret small letter gay (U+10440)
            case "𐑁": returnString += "𐐙"; break;  // Deseret small letter ef (U+10441)
            case "𐑂": returnString += "𐐚"; break;  // Deseret small letter vee (U+10442)
            case "𐑃": returnString += "𐐛"; break;  // Deseret small letter eth (U+10443)
            case "𐑄": returnString += "𐐜"; break;  // Deseret small letter thee (U+10444)
            case "𐑅": returnString += "𐐝"; break;  // Deseret small letter es (U+10445)
            case "𐑆": returnString += "𐐞"; break;  // Deseret small letter zee (U+10446)
            case "𐑇": returnString += "𐐟"; break;  // Deseret small letter esh (U+10447)
            case "𐑈": returnString += "𐐠"; break;  // Deseret small letter zhee (U+10448)
            case "𐑉": returnString += "𐐡"; break;  // Deseret small letter er (U+10449)
            case "𐑊": returnString += "𐐢"; break;  // Deseret small letter el (U+1044a)
            case "𐑋": returnString += "𐐣"; break;  // Deseret small letter em (U+1044b)
            case "𐑌": returnString += "𐐤"; break;  // Deseret small letter en (U+1044c)
            case "𐑍": returnString += "𐐥"; break;  // Deseret small letter eng (U+1044d)
            case "𐑎": returnString += "𐐦"; break;  // Deseret small letter oi (U+1044e)
            case "𐑏": returnString += "𐐧"; break;  // Deseret small letter ew (U+1044f)
            default:
                returnString += x.toLocaleUpperCase();
        }
        i++;
    }
    while (i < this.length);
    return returnString;
};

String.prototype.toMusicBrainzLowerCase = function() { 
    if (this.length === 0) {
        return "";
    }
    var returnString = "",
        x,
        i = 0;
    do
    {
        x = this[i];
        if (x.charCodeAt(0) >= NON_BMP_CHAR_CODES.BOTTOM && x.charCodeAt(0) <= NON_BMP_CHAR_CODES.TOP) {  // Deseret characters are in plane 1, thus 2 chars wide.  Also avoids CJK issues and other planes 1 - 16 issues.
            x = String.fromCharCode(this.charAt(i).charCodeAt(0)) + String.fromCharCode(this.charAt(++i).charCodeAt(0));
        }
        switch(x) {
            /* Handle Turkish I problem. */
            case "ı": returnString += "ı"; break;  // Make sure it stays dotless.
            case "İ": returnString += "i"; break;  // Precomposed version
            case "İ": returnString += "i"; break;  // Composed version
            case "I": returnString += TurkishI ? "ı" : "i"; break;
            /* Characters broken in various browser implementations of toLocaleLowerCase.  */
            case "Ǝ": returnString += "ǝ"; break;  // U+018E - test 1, broken in IE8
            case "Ⲅ": returnString += "ⲅ"; break;  // U+2C84 - test 36, broken in IE8
            case "Ⲛ": returnString += "ⲛ"; break;  // U+2C9A - test 47, broken in IE8
            case "Ⳓ": returnString += "ⳓ"; break;  // U+2CD2 - test 75, broken in IE8
            case "Ⳕ": returnString += "ⳕ"; break;  // U+2CD4 - test 76, broken in IE8
            case "Ⴇ": returnString += "ⴇ"; break;  // U+10A7 - test 127, broken in IE8
            case "Ⴈ": returnString += "ⴈ"; break;  // U+10A8 - test 128, broken in IE8
            /* Deseret Unicode block, no characters implemented in toLocaleLowerCase in any major browser.  */
            case "𐐀": returnString += "𐐨"; break;  // Deseret capital letter long i (U+10400)
            case "𐐁": returnString += "𐐩"; break;  // Deseret capital letter long e (U+10401)
            case "𐐂": returnString += "𐐪"; break;  // Deseret capital letter long a (U+10402)
            case "𐐃": returnString += "𐐫"; break;  // Deseret capital letter long ah (U+10403)
            case "𐐄": returnString += "𐐬"; break;  // Deseret capital letter long o (U+10404)
            case "𐐅": returnString += "𐐭"; break;  // Deseret capital letter long oo (U+10405)
            case "𐐆": returnString += "𐐮"; break;  // Deseret capital letter short i (U+10406)
            case "𐐇": returnString += "𐐯"; break;  // Deseret capital letter short e (U+10407)
            case "𐐈": returnString += "𐐰"; break;  // Deseret capital letter short a (U+10408)
            case "𐐉": returnString += "𐐱"; break;  // Deseret capital letter short ah (U+10409)
            case "𐐊": returnString += "𐐲"; break;  // Deseret capital letter short o (U+1040a)
            case "𐐋": returnString += "𐐳"; break;  // Deseret capital letter short oo (U+1040b)
            case "𐐌": returnString += "𐐴"; break;  // Deseret capital letter ay (U+1040c)
            case "𐐍": returnString += "𐐵"; break;  // Deseret capital letter ow (U+1040d)
            case "𐐎": returnString += "𐐶"; break;  // Deseret capital letter wu (U+1040e)
            case "𐐏": returnString += "𐐷"; break;  // Deseret capital letter yee (U+1040f)
            case "𐐐": returnString += "𐐸"; break;  // Deseret capital letter h (U+10410)
            case "𐐑": returnString += "𐐹"; break;  // Deseret capital letter pee (U+10411)
            case "𐐒": returnString += "𐐺"; break;  // Deseret capital letter bee (U+10412)
            case "𐐓": returnString += "𐐻"; break;  // Deseret capital letter tee (U+10413)
            case "𐐔": returnString += "𐐼"; break;  // Deseret capital letter dee (U+10414)
            case "𐐕": returnString += "𐐽"; break;  // Deseret capital letter chee (U+10415)
            case "𐐖": returnString += "𐐾"; break;  // Deseret capital letter jee (U+10416)
            case "𐐗": returnString += "𐐿"; break;  // Deseret capital letter kay (U+10417)
            case "𐐘": returnString += "𐑀"; break;  // Deseret capital letter gay (U+10418)
            case "𐐙": returnString += "𐑁"; break;  // Deseret capital letter ef (U+10419)
            case "𐐚": returnString += "𐑂"; break;  // Deseret capital letter vee (U+1041a)
            case "𐐛": returnString += "𐑃"; break;  // Deseret capital letter eth (U+1041b)
            case "𐐜": returnString += "𐑄"; break;  // Deseret capital letter thee (U+1041c)
            case "𐐝": returnString += "𐑅"; break;  // Deseret capital letter es (U+1041d)
            case "𐐞": returnString += "𐑆"; break;  // Deseret capital letter zee (U+1041e)
            case "𐐟": returnString += "𐑇"; break;  // Deseret capital letter esh (U+1041f)
            case "𐐠": returnString += "𐑈"; break;  // Deseret capital letter zhee (U+10420)
            case "𐐡": returnString += "𐑉"; break;  // Deseret capital letter er (U+10421)
            case "𐐢": returnString += "𐑊"; break;  // Deseret capital letter el (U+10422)
            case "𐐣": returnString += "𐑋"; break;  // Deseret capital letter em (U+10423)
            case "𐐤": returnString += "𐑌"; break;  // Deseret capital letter en (U+10424)
            case "𐐥": returnString += "𐑍"; break;  // Deseret capital letter eng (U+10425)
            case "𐐦": returnString += "𐑎"; break;  // Deseret capital letter oi (U+10426)
            case "𐐧": returnString += "𐑏"; break;  // Deseret capital letter ew (U+10427)
            default:
                returnString += x.toLocaleLowerCase();
        }
        i++;
    }
    while (i < this.length);
    return returnString;
};
/********************************************************************************************
 * Function: Capitalizes only the first letter of a string.                                 *
 *                                                                                          *
 * Passed a string, returns it with the first letter capitalized.  Supports wide chars.     *
 ********************************************************************************************/
function titleCaseString(inputstring) {
    if (typeof(inputstring) == "undefined") {
        return "";
    }
    var x = inputstring.slice(0,1);
    if (x.charCodeAt(0) >= NON_BMP_CHAR_CODES.BOTTOM && x.charCodeAt(0) <= NON_BMP_CHAR_CODES.TOP) {  // Unicode hex scalar values for D800-DBFF, the Unicode surrogate code points.
        if (inputstring.length > 2) {
            inputstring = inputstring.slice(0, 2).toMusicBrainzUpperCase() + inputstring.slice(2).toMusicBrainzLowerCase();
        } else {
            inputstring = inputstring.toMusicBrainzUpperCase();
        }
    } else {
        if (inputstring.length > 1) {
            inputstring = x.toMusicBrainzUpperCase() + inputstring.slice(1).toMusicBrainzLowerCase();
        } else {
            inputstring = inputstring.toMusicBrainzUpperCase();
        }
    }
    return inputstring;
}
/********************************************************************************************
 * Function: validateRoman                                                                  *
 *                                                                                          *
 * Passed a string, returns true if it is a legal Roman numeral.                            *
 ********************************************************************************************/
function validateRoman(input) {
    if (typeof(input) === "undefined" || input === "") {
        return false;
    } else {
        var romanPattern = /^M{0,4}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})$/;
        return romanPattern.test(input);
    }
}
/********************************************************************************************
 * Function: convertRomanToArabic                                                           *
 *                                                                                          *
 * Passed a legal Roman numeral, returns the equivalent as int.                             *
 ********************************************************************************************/
function convertRomanToArabic(input) {
    if (typeof(input) === "undefined" || input === "") {
        return 0;
    } else {
        var iterations = input.length,
            stringPosition = 0,
            arabicNumber = 0,
            letters = [],
            getValue = function(thisLetter, nextLetter) {
                if (thisLetter === " ") {
                    return 0;
                }
                switch (thisLetter+nextLetter) {
                    case "IV":
                        ++stringPosition;
                        return 4;
                    case "IX":
                        ++stringPosition;
                        return 9;
                    case "XL":
                        ++stringPosition;
                        return 40;
                    case "XC":
                        ++stringPosition;
                        return 90;
                    case "CD":
                        ++stringPosition;
                        return 400;
                    case "CM":
                        ++stringPosition;
                        return 900;
                    default:
                        return letters[thisLetter];
                }
            };
            input = input+"   ";
            letters.I = 1;
            letters.V = 5;
            letters.X = 10;
            letters.L = 50;
            letters.C = 100;
            letters.D = 500;
            letters.M = 1000;
        do {
            arabicNumber += getValue(input[stringPosition], input[++stringPosition]);
        } while (--iterations);
        return arabicNumber;
    }
}
/*********************************************************************************************************
 * Useful references:                                                                                    *
 * Unicode Standard Annex #21: Case Mappings                                                             *
 * http://unicode.org/reports/tr21/tr21-5.html                                                           *
 *********************************************************************************************************
 * Function: loadRuleSet ( one of 6 GC groups: artist, title, label, duration, text, textartist )        *
 * Loads language-specific rules for the user's current GC mode setting.                                 *
 *                                                                                                       *
 * Add new language rulesets here.  Make sure to add them                                                *
 * both to the artist name and non-artist name switches.                                                 *
 *                                                                                                       *
 * Language Flags:   (All must be set for any language, even if unused!)                                 *
 *                                                                                                       *
 * ----------------------------------------------------------------------------------------------------- *
 * alwaysUppercasedWords.......Words that should always be all UPPERCASE  (examples: USA, DC, BBC)       *
 * ----------------------------------------------------------------------------------------------------- *
 * ambiguousUppercasedWords....Words that may sometimes be all UPPERCASE, but not 100% of the            *
 *                             time.  (examples: )  These will stay normal cased, but                    *
 *                             with heads-up warnings.                                                   *
 * ----------------------------------------------------------------------------------------------------- *
 * ambiguousLowercasedWords....Words that may sometimes be all lowercase, but not 100% of the            *
 *                             time.  (example: Presents)  These will stay normal cased, but             *
 *                             with heads-up warnings.                                                   *
 * ----------------------------------------------------------------------------------------------------- *
 * capitalizeFragments.........Capitalize first word inside parentheses and brackets.                    *
 * ----------------------------------------------------------------------------------------------------- *
 * capitalizeSentences.........Capitalize the first word of text, and each first word following          *
 *                             the end of a sentence.                                                    *
 * ----------------------------------------------------------------------------------------------------- *
 * changeCapitalization........Titlecase (English mode) if true, sentence mode if false.                 *
 * ----------------------------------------------------------------------------------------------------- *
 * commaUppercasedWords........Words that are 99.9% always all UPPERCASE if before and after             *
 *                             a comma.  (Allows better capitalization of ambiguous Uppercased           *
 *                             words.) (examples: ME, ON, OR).  These will always be be uppercased.      *
 *                             (Useful mainly for locations that should always be all UPPERCASE.)        *
 * ----------------------------------------------------------------------------------------------------- *
 * dashFigure..................The correct dash to be used within numbers (not numeric ranges), such     *
 *                             as phone numbers.                                                         *
 * ----------------------------------------------------------------------------------------------------- *
 * dashQuotation...............The correct dash to be used prior to a quotation. (example ― "Foo!")      *
 * ----------------------------------------------------------------------------------------------------- *
 * dashRange...................The correct dash to be used to indicate a numeric range, like 1 – 10.     *
 * ----------------------------------------------------------------------------------------------------- *
 * extraTitleInfoWords.........Language-specific ExtraTitleInformation words.  (ex: remix, vocal, clean) *
 *                             Do not use multi-word phrases - only single words here!                   *
 *                             This must have at least one value, please use "alternate)" to close out   *
 *                             this value.                                                               *
 * ----------------------------------------------------------------------------------------------------- *
 * fixApostropheWords..........Make the second letter character in O'Clock-style words capitalized.      *
 * ----------------------------------------------------------------------------------------------------- *
 * fragmentPunctuation.........Punctuation used to indicate the beginning of a parenthetical             *
 *                             or bracketed section of text.                                             *
 * ----------------------------------------------------------------------------------------------------- *
 * junkHyphens.................Hyphens and dashes which may or may not be used in the language, but will *
 *                             never be used correctly in Guess Case-processed text.                     *
 * ----------------------------------------------------------------------------------------------------- *
 * junkHyphensReplacement......The character to be used to replace all of the junkHyphens.               *
 * ----------------------------------------------------------------------------------------------------- *
 * junkTildes..................Tildes which may or may not be used in the language, but will never be    *
 *                             used correctly in Guess Case-processed text.                              *
 * ----------------------------------------------------------------------------------------------------- *
 * junkTildesReplacement.......The character to be used to replace all of the junkTildes.                *
 * ----------------------------------------------------------------------------------------------------- *
 * lowerCaseApostropheWords....True if words like 'round should stay as 'round.                          *
 * ----------------------------------------------------------------------------------------------------- *
 * lowerCaseWords..............Short words that should always be lowercased.                             *
 * ----------------------------------------------------------------------------------------------------- *
 * lowerCaseWordsEndWords......Short words from the above list which should be uppercased if at the      *
 *                             end of a sentence fragment, or before a period.  Examples: on, in:        *
 *                             'Come On (acoustic)' instead of 'Come on (acoustic)'                      *
 *                             'Jumpin' In' instead of 'Jumpin' in'                                      *
 * ----------------------------------------------------------------------------------------------------- *
 * mirroredGuillemets..........True if the language uses guillemets, and each « should have a matching   *
 *                             » (whichever direction they should be pointing on each side).  False if   *
 *                             the language does not use guillemets, or if it only uses two » or two «.  *
 * ----------------------------------------------------------------------------------------------------- *
 * numberAbbreviation..........What word is used to indicate Number?  ex: No.                            *
 * ----------------------------------------------------------------------------------------------------- *
 * numberWords.................Used as a last ditch effort to avoid false positives when differentiating *
 *                             between "Part" as a word, and "Part:" as in PartNumberStyle.  If          *
 *                             "Foo Bar, Part One" is a valid construction, with the number word right   *
 *                             after the wordForPart, then fill in this with the typed out names         *
 *                             for numbers in this language.  If there are variations possible, such as  *
 *                             "twenty one" and "twenty-one", please include both.  However, if this is  *
 *                             not a valid construction in this language, leave this as "".              *
 *                             IMPORTANT: Numbers must be in the array here in numerical order!          *
 * ----------------------------------------------------------------------------------------------------- *
 * punctuationCharacters.......Characters used as valid punctuation in the language.                     *
 * ----------------------------------------------------------------------------------------------------- *
 * roleWords...................Words like "conductor" which indicate a performance role, and should      *
 *                             always be lowercased, but only if they are both inside parenthesis and    *
 *                             followed by a colon.  example: (conductor: Foo Bar)                       *
 * ----------------------------------------------------------------------------------------------------- *
 * sentenceEndingPunctuation...Punctuation used to indicate the end of a sentence.                       *
 * ----------------------------------------------------------------------------------------------------- *
 * spaceAfterPunctuation.......A space should always appear after these punctuation marks.               *
 *                             Use "" if no space should appear after any punctuation marks.             *
 * ----------------------------------------------------------------------------------------------------- *
 * spaceBeforePunctuation......A space should always appear before these punctuation marks.              *
 *                             Use "" if no space should appear before any punctuation marks.            *
 * ----------------------------------------------------------------------------------------------------- *
 * spaceChar...................If spaces are required before certain punctuation (whichever of :;!?»«    *
 *                             are used in the language), what space character should be used?           *
 * ----------------------------------------------------------------------------------------------------- *
 * usesRomanNumerals...........Are Roman numerals legal to be used in this language?                     *
 * ----------------------------------------------------------------------------------------------------- *
 * For the following, use "" as the value if there is no applicable word in the language:                *
 * wordForBox..................What word might be used for box, as in box set, in this language?         *
 * wordForPt...................What word might be used for "Foo, Pt 1" in this language?                 *
 * wordForPart.................What word might be used for "Foo, Part 1" in this language?               *
 * wordForParts................What word might be used for "Foo, Parts 1-2" in this language?            *
 * wordForVolumeA..............What word might be used for "Foo, Volume 1" in this language?             *
 * wordForVolumeB..............What word might be used for "Foo, Vol. 1" in this language?               *
 * wordForDisc.................What word might be used for "Foo (disc 1)" in this language?              *
 * ----------------------------------------------------------------------------------------------------- *
 * romanWordsLower.............Words in this language which also happen to be Roman numerals.  Any words *
 *                             listed here will ignore Roman numeral rules and become lowercased.        *
 * ----------------------------------------------------------------------------------------------------- *
 * romanWordsNormal............Words in this language which also happen to be Roman numerals.  Any words *
 *                             listed here will ignore Roman numeral rules and become normal cased.      *
 *********************************************************************************************************/
// All punctuation characters, use to create new modes
var AllPunctuation = "-!\"#$%&'()\\*\\+,\\./\\․/‣:;<=;΄ʹ͵΅>?@[\\\\\\]^_`{|}‽⁋;΄΅·~⁊‧։֊…¤‐\\(@‒⳹⳺⳻⳼–¡¿—⁄、ʹ͵‥᛫〽𐤟〜 ‹›―჻‖˜◊∴→⇒" +
                       "⊃⊢´⊨⁂☞∵§~_¦|¶º°%‰‱#⁘⁙⁚⁛⁜⁝⁞ ⸐⸑⸒⸓⸔⸖⸕^†״׃‡•\\*\\₡ƒ׀₤₧¥¢＝゠⸗׳$£٭，₩₪»«仝ヽヾゝゞ〃〲〱〳〵〴〵「」『』〔〕｛｝" +
                       "〈〉《》【】〖〗〘〙〚〛゛゜。、・ↀↁↂ¨©ª¬®±²³µ¶·¸¹ºʼˈ˘˙˚˛˜˝ˣ₰℈℔℞℟℣℥⏑⏒⏓⏔⸀⸌⸍⸜⸝" +
                       "〆〜…‥•◦※＊〽♪♫♬♩〒〶〠〄⁅⁆Ⓧ﷼Ⓨ㉿\\]",
    AllCapsPositions = [], // Used to store the position of ALLCAPS words
    allFoldableChars = "a-zA-Z" +              //  Latin: ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz
                       "\u00B5" +              //  Latin: µ
                       "\u00C0-\u00D6" +       //  Latin: ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ
                       "\u00D8-\u00DF" +
                       "\u00E1-\u00F6" +
                       "\u0100-\u013F" +
                       "\u0140-\u017E" +
                       "\u0180-\u024F" +       //  Latin: ƀƁƂƃƄƅƆƇƈƉƊƋƌƍƎƏƐƑƒƓƔƕƖƗƘƙƚƛƜƝƞƟƠơƢƣƤƥƦƧƨƩƪƫƬƭƮƯưƱƲƳƴƵƶƷƸƹƺƻƼƽƾƿǀǁǂǃǄǅǆǇǈ
                                               //         ǉǊǋǌǍǎǏǐǑǒǓǔǕǖǗǘǙǚǛǜǝǞǟǠǡǢǣǤǥǦǧǨǩǪǫǬǭǮǯǰǱǲǳǴǵǶǷǸǹǺǻǼǽǾǿȀȁȂȃȄȅȆȇȈȉȊȋȌȍȎȏȐȑȒȓȔȕȖȗȘ
                                               //         șȚțȜȝȞȟȠȡȢȣȤȥȦȧȨȩȪȫȬȭȮȯȰȱȲȳȴȵȶȷȸȹȺȻȼȽȾȿɀɁɂɃɄɅɆɇɈɉɊɋɌɍɎɏ
                       "\u0250-\u02AF" +       //  Latin IPA Extensions: ɐɑɒɓɔɕɖɗɘəɚɛɜɝɞɟɠɡɢɣɤɥɦɧɨɩɪɫɬɭɮɯɰɱɲɳɴɵɶɷɸɹɺɻɼɽɾɿʀʁʂʃʄʅʆʇʈʉʊʋ
                                               //                        ʌʍʎʏʐʑʒʓʔʕʖʗʘʙʚʛʜʝʞʟʠʡʢʣʤʥʦʧʨʩʪʫʬʭʮʯ
                       "\u0300-\u036F" +       //  Greek combining characters
                       "\u0370-\u0373" +       //  Greek: ͰͱͲͳ
                       "\u0376-\u037D" +       //  Greek: Ͷͷͺͻͼͽ
                       "\u0386-" +             //  Greek: Ά·ΈΉΊΌΎΏΐΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩΪΫάέήίΰαβγδεζηθικλμνξοπρςστυφχψωϊϋόύώϏϐϑϒϓϔϕϖϗϘϙ
                                               //         ϚϛϜϝϞϟϠϡ   (\u0386-\u03E1)
                  //   "\u03E2-\u03EF" +       //  Coptic: ϢϣϤϥϦϧϨϩϪϫϬϭϮϯ
                  //   "\u03F0-\u03FF" +       //  Greek: ϰϱϲϳϴϵ϶ϷϸϹϺϻϼϽϾϿ
                  //   "\u0400-\u04FF" +       //  Cyrillic: ЀЁЂЃЄЅІЇЈЉЊЋЌЍЎЏАБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмнопрстуфхцчшщъыьэ
                  //  Commented out as it is   //            юяѐёђѓєѕіїјљњћќѝўџѠѡѢѣѤѥѦѧѨѩѪѫѬѭѮѯѰѱѲѳѴѵѶѷѸѹѺѻѼѽѾѿҀҁ҂҃҄҅҆҇҈҉ҊҋҌҍҎҏҐґҒғҔҕҖҗҘҙҚқ
                  //  all one continuous       //            ҜҝҞҟҠҡҢңҤҥҦҧҨҩҪҫҬҭҮүҰұҲҳҴҵҶҷҸҹҺһҼҽҾҿӀӁӂӃӄӅӆӇӈӉӊӋӌӍӎӏӐӑӒӓӔӕӖӗӘәӚӛӜӝӞӟӠӡӢӣӤӥӦӧӨө
                  //  range.                   //            ӪӫӬӭӮӯӰӱӲӳӴӵӶӷӸӹӺӻӼӽӾӿ
                              "\u0523" +       //  Cyrillic: ԀԁԂԃԄԅԆԇԈԉԊԋԌԍԎԏԐԑԒԓԔԕԖԗԘԙԚԛԜԝԞԟԠԡԢԣ   (\u0500-\u0523)
                       "\u0531-\u0587" +       //  Armenian: ԱԲԳԴԵԶԷԸԹԺԻԼԽԾԿՀՁՂՃՄՅՆՇՈՉՊՋՌՍՎՏՐՑՒՓՔՕՖՙ՚՛՜՝՞՟աբգդեզէըթժիլխծկհձղճմյնշոչպջռսվտրցւփքօֆև
                       "\u10A0-\u10FA\u10FC" + //  Georgian: ႠႡႢႣႤႥႦႧႨႩႪႫႬႭႮႯႰႱႲႳႴႵႶႷႸႹႺႻႼႽႾႿჀჁჂჃჄჅაბგდევზთიკლმნოპჟრსტუფქღყშჩცძწჭხჯჰჱჲჳჴჵჶჷჸჹჺჼ
                       "\u1D00-\u1D7F" +       //  Latin: ᴀᴁᴂᴃᴄᴅᴆᴇᴈᴉᴊᴋᴌᴍᴎᴏᴐᴑᴒᴓᴔᴕᴖᴗᴘᴙᴚᴛᴜᴝᴞᴟᴠᴡᴢᴣᴤᴥᴦᴧᴨᴩᴪᴫᴬᴭᴮᴯᴰᴱᴲᴳᴴᴵᴶᴷᴸᴹᴺᴻᴼᴽᴾᴿᵀᵁᵂᵃᵄᵅᵆᵇᵈᵉᵊᵋᵌᵍᵎ
                                               //         ᵏᵐᵑᵒᵓᵔᵕᵖᵗᵘᵙᵚᵛᵜᵝᵞᵟᵠᵡᵢᵣᵤᵥᵦᵧᵨᵩᵪᵫᵬᵭᵮᵯᵰᵱᵲᵳᵴᵵᵶᵷᵸᵹᵺᵻᵼᵽᵾᵿ
                       "\u1D80-\u1DBF" +       //  Latin: ᶀᶁᶂᶃᶄᶅᶆᶇᶈᶉᶊᶋᶌᶍᶎᶏᶐᶑᶒᶓᶔᶕᶖᶗᶘᶙᶚᶛᶜᶝᶞᶟᶠᶡᶢᶣᶤᶥᶦᶧᶨᶩᶪᶫᶬᶭᶮᶯᶰᶱᶲᶳᶴᶵᶶᶷᶸᶹᶺᶻᶼᶽᶾᶿ
                       "\u1E00-\u1EFF" +       //  Latin: ḀḁḂḃḄḅḆḇḈḉḊḋḌḍḎḏḐḑḒḓḔḕḖḗḘḙḚḛḜḝḞḟḠḡḢḣḤḥḦḧḨḩḪḫḬḭḮḯḰḱḲḳḴḵḶḷḸḹḺḻḼḽḾḿṀṁṂṃṄṅṆṇṈṉṊṋṌṍṎṏṐ
                                               //         ṑṒṓṔṕṖṗṘṙṚṛṜṝṞṟṠṡṢṣṤṥṦṧṨṩṪṫṬṭṮṯṰṱṲṳṴṵṶṷṸṹṺṻṼṽṾṿẀẁẂẃẄẅẆẇẈẉẊẋẌẍẎẏẐẑẒẓẔẕẖẗẘẙẚẛẜẝẞẟẠạẢả
                                               //         ẤấẦầẨẩẪẫẬậẮắẰằẲẳẴẵẶặẸẹẺẻẼẽẾếỀềỂểỄễỆệỈỉỊịỌọỎỏỐốỒồỔổỖỗỘộỚớỜờỞởỠỡỢợỤụỦủỨứỪừỬửỮữỰựỲỳ
                                               //         ỴỵỶỷỸỹỺỻỼỽỾỿ
                       "\u1F00-\u1FFF" +       //  Greek: ἀἁἂἃἄἅἆἇἈἉἊἋἌἍἎἏἐἑἒἓἔἕἘἙἚἛἜἝἠἡἢἣἤἥἦἧἨἩἪἫἬἭἮἯἰἱἲἳἴἵἶἷἸἹἺἻἼἽἾἿὀὁὂὃὄὅὈὉὊὋὌὍὐὑὒὓὔὕὖὗ
                                               //         ὙὛὝὟὠὡὢὣὤὥὦὧὨὩὪὫὬὭὮὯὰάὲέὴήὶίὸόὺύὼώᾀᾁᾂᾃᾄᾅᾆᾇᾈᾉᾊᾋᾌᾍᾎᾏᾐᾑᾒᾓᾔᾕᾖᾗᾘᾙᾚᾛᾜᾝᾞᾟᾠᾡᾢᾣᾤᾥᾦᾧᾨᾩᾪᾫᾬᾭ
                                               //         ᾮᾯᾰᾱᾲᾳᾴᾶᾷᾸᾹᾺΆᾼ᾽ι᾿῀῁ῂῃῄῆῇῈΈῊΉῌ῍῎῏ῐῑῒΐῖῗῘῙῚΊ῝῞῟ῠῡῢΰῤῥῦῧῨῩῪΎῬ῭΅`ῲῳῴῶῷῸΌῺΏῼ´῾
                       "\u2132" +              //  Latin: Ⅎ
                       "\u214E" +              //  Latin: ⅎ
                       "\u2183-\u2184" +       //  Latin: Ↄↄ
                       "\u2471-\u247D" +       //  Latin: ⱱⱲⱳⱴⱵⱶⱷⱸⱹⱺⱻⱼⱽ
                       "\u2C00-\u2C5E" +       //  Glagolitic: ⰀⰁⰂⰃⰄⰅⰆⰇⰈⰉⰊⰋⰌⰍⰎⰏⰐⰑⰒⰓⰔⰕⰖⰗⰘⰙⰚⰛⰜⰝⰞⰟ
                                               //              ⰠⰡⰢⰣⰤⰥⰦⰧⰨⰩⰪⰫⰬⰭⰮⰰⰱⰲⰳⰴⰵⰶⰷⰸⰹⰺⰻⰼⰽⰾⰿⱀ
                                               //              ⱁⱂⱃⱄⱅⱆⱇⱈⱉⱊⱋⱌⱍⱎⱏⱐⱑⱒⱓⱔⱕⱖⱗⱘⱙⱚⱛⱜⱝⱞ
                       "\u2C60-" +             //  Latin: ⱠⱡⱢⱣⱤⱥⱦⱧⱨⱩⱪⱫⱬⱭⱮⱯ  (\u2C60-\u2C6F)
                   //  "\u2C70-\u2C7F" +       //  Latin: ⱰⱱⱲⱳⱴⱵⱶⱷⱸⱹⱺⱻⱼⱽⱾⱿ
                   //  "\u2C80-\u2CFF" +       //  Coptic: ⲀⲁⲂⲃⲄⲅⲆⲇⲈⲉⲊⲋⲌⲍⲎⲏⲐⲑⲒⲓⲔⲕⲖⲗⲘⲙⲚⲛⲜⲝⲞⲟⲠⲡⲢⲣⲤⲥⲦⲧⲨⲩⲪⲫⲬⲭⲮⲯⲰⲱⲲⲳⲴⲵⲶⲷⲸⲹⲺⲻⲼⲽⲾⲿⳀⳁⳂⳃⳄⳅⳆⳇⳈⳉ
                   // Another range...         //          ⳊⳋⳌⳍⳎⳏⳐⳑⳒⳓⳔⳕⳖⳗⳘⳙⳚⳛⳜⳝⳞⳟⳠⳡⳢⳣⳤ⳥⳦⳧⳨⳩⳪
                   //  "\u2D00-\u2D2F" +       //  Georgian: ⴀⴁⴂⴃⴄⴅⴆⴇⴈⴉⴊⴋⴌⴍⴎⴏⴐⴑⴒⴓⴔⴕⴖⴗⴘⴙⴚⴛⴜⴝⴞⴟⴠⴡⴢⴣⴤⴥ
                              "\u2DFF" +       //  Cyrillic: ⷠⷡⷢⷣⷤⷥⷦⷧⷨⷩⷪⷫⷬⷭⷮⷯⷰⷱⷲⷳⷴⷵⷶⷷⷸⷹⷺⷻⷼⷽⷾⷿ  (\u2DE0-\u2DFF)
                       "\uA640-\uA697" +       //  Cyrillic: ꙀꙁꙂꙃꙄꙅꙆꙇꙈꙉꙊꙋꙌꙍꙎꙏꙐꙑꙒꙓꙔꙕꙖꙗꙘꙙꙚꙛꙜꙝꙞꙟꙢꙣꙤꙥꙦꙧꙨꙩꙪꙫꙬꙭꙮ꙯꙰꙱꙲꙳꙼꙽꙾ꙿꚀꚁꚂꚃꚄꚅꚆꚇ
                                               //         ꚈꚉꚊꚋꚌꚍꚎꚏꚐꚑꚒꚓꚔꚕꚖꚗ
                       "\uA720-\uA78C" +       //  Latin: ꜠꜡ꜢꜣꜤꜥꜦꜧꜨꜩꜪꜫꜬꜭꜮꜯꜰꜱꜲꜳꜴꜵꜶꜷꜸꜹꜺꜻꜼꜽꜾꜿꝀꝁꝂꝃꝄꝅꝆꝇꝈꝉꝊꝋꝌꝍꝎꝏꝐꝑꝒꝓꝔꝕꝖꝗꝘꝙꝚꝛꝜꝝꝞꝟ
                                               //         ꝠꝡꝢꝣꝤꝥꝦꝧꝨꝩꝪꝫꝬꝭꝮꝯꝰꝱꝲꝳꝴꝵꝶꝷꝸꝹꝺꝻꝼꝽꝾꝿꞀꞁꞂꞃꞄꞅꞆꞇꞈ꞉꞊Ꞌꞌ
                       "\uA7FB-\uA7FF" +       //  Latin: ꟻꟼꟽꟾꟿ
                       "\uF20E" +              //  Latin: 
                       "\uFB00-\uFB06" +       //  Latin ligatures: ﬀﬁﬂﬃﬄﬅ
                       "\uFB13-\uFB17" +       //  Armenian ligatures: ﬆﬓﬔﬕﬖﬗ
                       "\uD801\uDC00-\uDC4F" + //  Deseret: 𐐀𐐁𐐂𐐃𐐄𐐅𐐆𐐇𐐈𐐉𐐊𐐋𐐌𐐍𐐎𐐏𐐐𐐑𐐒𐐓𐐔𐐕𐐖𐐗𐐘𐐙𐐚𐐛𐐜𐐝𐐞𐐟𐐠𐐡𐐢𐐣𐐤𐐥𐐦𐐧𐐨𐐩𐐪𐐫𐐬𐐭𐐮𐐯𐐰𐐱𐐲𐐳𐐴𐐵𐐶𐐷𐐸𐐹𐐺𐐻𐐼𐐽𐐾𐐿𐑀𐑁𐑂𐑃𐑄𐑅𐑆𐑇𐑈𐑉𐑊𐑋𐑌𐑍𐑎𐑏
                       "C\u0308" +        //  Latin: N̈
                       "n\u0308" +        //  Latin: n̈
                       "H\u0331" +             //  Latin: H̱
                       "P\u0303" +        //  Latin: P̃
                       "S\u0329" +        //  Latin: S̩
                       "T\u0308" +        //  Latin: T̈
                       "W\u030A" +        //  Latin: W̊
                       "p\u0303" +        //  Latin: p̃
                       "s\u0329" +        //  Latin: s̩
                       "\u0144\u030A" +        //  Latin: ń̊
                       "\u030A\u030A" +        //  Latin: Y̊
                       "У\u030A" +        //  Cyrillic: У̊
                       "у\u030A" +        //  Cyrillic: у̊
                       "\u0399\u0308\u0301" +  //  Greek: Ϊ́
                       "\u03A5\u0308\u0301" +  //  Greek: Ϋ́
                       "J\u030C" +        //  Latin: J̌
                       "H\u0331" +             //  Latin: H̱
                       "T\u0308" +        //  Latin: T̈
                       "W\u030A" +        //  Latin: W̊
                       "Y\u030A" +        //  Latin: Y̊
                       "A\u02BE" +        //  Latin: Aʾ
                       "\u03A5\u0313" +        //  Greek: Υ̓
                       "\u03A5\u0313\u0300" +  //  Greek: Υ̓̀
                       "\u03A5\u0313\u0301" +  //  Greek: Υ̓́
                       "\u03A5\u0313\u0342" +  //  Greek: Υ̓͂
                       "\u0391\u0342" +        //  Greek: Α͂
                       "\u0397\u0342" +        //  Greek: Η͂
                       "\u0399\u0308\u0300" +  //  Greek: Ϊ̀
                       "\u0399\u0308\u0301" +  //  Greek: Ϊ́
                       "\u0399\u0342" +        //  Greek: Ι͂
                       "\u0399\u0308\u0342" +  //  Greek: Ϊ͂
                       "\u03A5\u0308\u0300" +  //  Greek: Ϋ̀
                       "\u03A5\u0308\u0301" +  //  Greek: Ϋ́
                       "\u03A1\u0313" +        //  Greek: Ρ̓
                       "\u03A5\u0342" +        //  Greek: Υ͂
                       "\u03A5\u0308\u0342" +  //  Greek: Ϋ͂
                       "\u03A9\u0342" +        //  Greek: Ω͂
                       "\u1FBA\u0345" +        //  Greek:  Ὰͅ
                       "\u0386\u0345" +        //  Greek:  Άͅ
                       "\u1FCA\u0345" +        //  Greek:  Ὴͅ
                       "\u0389\u0345" +        //  Greek:  Ήͅ
                       "\u1FFA\u0345" +        //  Greek:  Ὼͅ
                       "\u038F\u0345" +        //  Greek:  Ώͅ
                       "\u0391\u0342\u0345" +  //  Greek:  ᾼ͂
                       "\u0397\u0342\u0345" +  //  Greek:  ῌ͂
                       "\u03A9\u0342\u0345" +   //  Greek:  ῼ͂
                       "ʼNΪ́Ϋ́J̌H̱T̈W̊Y̊AΥ̓Υ̓̀Υ̓́Υ̓͂Α͂Η͂Ϊ̀Ϊ́Ι͂Ϋ̀Ϋ́Ρ̓Υ͂Ϋ͂Ω͂", // Latin composed characters which result from title case folding
/* This next block is the same as the above, but with all lower-case letters removed. (The Unicode equivalent of A-Z.)  */
    allUpperCaseChars = "[\u0100\u0102\u0104\u0106\u0108\u010A\u010C\u010E\u0110\u0112\u0114\u0116\u0118\u011A\u011C\u011E" +
                         "\u0120\u0122\u0124\u0126\u0128\u012A\u012C\u012E\u0130\u0132\u0134\u0136\u0139\u013B\u013D\u013F" +
                         "\u0141\u0143\u0145\u0147\u014A\u014C\u014E\u0150\u0152\u0154\u0156\u0158\u015A\u015C\u015E\u0160" +
                         "\u0162\u0164\u0166\u0168\u016A\u016C\u016E\u0170\u0172\u0174\u0176\u0178\u0179\u017B\u017D\u0181" +
                         "\u0182\u0184\u0186\u0187\u0189\u018A\u018B\u0193\u0194\u019C\u019D\u019F\u01A0\u01A2\u01A4\u01A6" +
                         "\u01A7\u01A9\u01AC\u01AE\u01AF\u01B5\u01B7\u01B8\u01BC\u01C4\u01C7\u01CA\u01CD\u01CF\u01D1\u01D3" +
                         "\u01D5\u01D7\u01D9\u01DB\u01DE\u01E0\u01E2\u01E4\u01E6\u01E8\u01EA\u01EC\u01EE\u01F1\u01F4\u01F6" +
                         "\u01F7\u01F8\u01FA\u01FC\u01FE\u0200\u0202\u0204\u0206\u0208\u020A\u020C\u020E\u0210\u0212\u0214" +
                         "\u0216\u0218\u021A\u021C\u021E\u0220\u0222\u0224\u0226\u0228\u022A\u022C\u022E\u0230\u0232\u023A" +
                         "\u023B\u023D\u023E\u0241\u0248\u024A\u024C\u024E\u0370\u0372\u0376\u0386\u038C\u038E\u038F\u03CF" +
                         "\u03D8\u03DA\u03DC\u03DE\u03E0\u03E2\u03E4\u03E6\u03E8\u03EA\u03EC\u03EE\u03F4\u03F7\u03F9\u03FA" +
                         "\u0460\u0462\u0464\u0466\u0468\u046A\u046C\u046E\u0470\u0472\u0474\u0476\u0478\u047A\u047C\u047E" +
                         "\u0480\u048A\u048C\u048E\u0490\u0492\u0494\u0496\u0498\u049A\u049C\u049E\u04A0\u04A2\u04A4\u04A6" +
                         "\u04A8\u04AA\u04AC\u04AE\u04B0\u04B2\u04B4\u04B6\u04B8\u04BA\u04BC\u04BE\u04C0\u04C1\u04C3\u04C5" +
                         "\u04C7\u04C9\u04CB\u04CD\u04D0\u04D2\u04D4\u04D6\u04D8\u04DA\u04DC\u04DE\u04E0\u04E2\u04E4\u04E6" +
                         "\u04E8\u04EA\u04EC\u04EE\u04F0\u04F2\u04F4\u04F6\u04F8\u04FA\u04FC\u04FE\u0500\u0502\u0504\u0506" +
                         "\u0508\u050A\u050C\u050E\u0510\u0512\u0514\u0516\u0518\u051A\u051C\u051E\u0520\u0522\u1E00\u1E02" +
                         "\u1E04\u1E06\u1E08\u1E0A\u1E0C\u1E0E\u1E10\u1E12\u1E14\u1E16\u1E18\u1E1A\u1E1C\u1E1E\u1E20\u1E22" +
                         "\u1E24\u1E26\u1E28\u1E2A\u1E2C\u1E2E\u1E30\u1E32\u1E34\u1E36\u1E38\u1E3A\u1E3C\u1E3E\u1E40\u1E42" +
                         "\u1E44\u1E46\u1E48\u1E4A\u1E4C\u1E4E\u1E50\u1E52\u1E54\u1E56\u1E58\u1E5A\u1E5C\u1E5E\u1E60\u1E62" +
                         "\u1E64\u1E66\u1E68\u1E6A\u1E6C\u1E6E\u1E70\u1E72\u1E74\u1E76\u1E78\u1E7A\u1E7C\u1E7E\u1E80\u1E82" +
                         "\u1E84\u1E86\u1E88\u1E8A\u1E8C\u1E8E\u1E90\u1E92\u1E94\u1E9E\u1EA0\u1EA2\u1EA4\u1EA6\u1EA8\u1EAA" +
                         "\u1EAC\u1EAE\u1EB0\u1EB2\u1EB4\u1EB6\u1EB8\u1EBA\u1EBC\u1EBE\u1EC0\u1EC2\u1EC4\u1EC6\u1EC8\u1ECA" +
                         "\u1ECC\u1ECE\u1ED0\u1ED2\u1ED4\u1ED6\u1ED8\u1EDA\u1EDC\u1EDE\u1EE0\u1EE2\u1EE4\u1EE6\u1EE8\u1EEA" +
                         "\u1EEC\u1EEE\u1EF0\u1EF2\u1EF4\u1EF6\u1EF8\u1EFA\u1EFC\u1EFE\u1F59\u1F5B\u1F5D\u1F5F\u2102\u2107" +
                         "\u2115\u2119\u2124\u2126\u2128\u213E\u213F\u2145\u2183\u2C60\u2C67\u2C69\u2C6B\u2C72\u2C75\u2C80" +
                         "\u2C82\u2C84\u2C86\u2C88\u2C8A\u2C8C\u2C8E\u2C90\u2C92\u2C94\u2C96\u2C98\u2C9A\u2C9C\u2C9E\u2CA0" +
                         "\u2CA2\u2CA4\u2CA6\u2CA8\u2CAA\u2CAC\u2CAE\u2CB0\u2CB2\u2CB4\u2CB6\u2CB8\u2CBA\u2CBC\u2CBE\u2CC0" +
                         "\u2CC2\u2CC4\u2CC6\u2CC8\u2CCA\u2CCC\u2CCE\u2CD0\u2CD2\u2CD4\u2CD6\u2CD8\u2CDA\u2CDC\u2CDE\u2CE0" +
                         "\u2CE2\uA640\uA642\uA644\uA646\uA648\uA64A\uA64C\uA64E\uA650\uA652\uA654\uA656\uA658\uA65A\uA65C" +
                         "\uA65E\uA662\uA664\uA666\uA668\uA66A\uA66C\uA680\uA682\uA684\uA686\uA688\uA68A\uA68C\uA68E\uA690" +
                         "\uA692\uA694\uA696\uA722\uA724\uA726\uA728\uA72A\uA72C\uA72E\uA732\uA734\uA736\uA738\uA73A\uA73C" +
                         "\uA73E\uA740\uA742\uA744\uA746\uA748\uA74A\uA74C\uA74E\uA750\uA752\uA754\uA756\uA758\uA75A\uA75C" +
                         "\uA75E\uA760\uA762\uA764\uA766\uA768\uA76A\uA76C\uA76E\uA779\uA77B\uA77D\uA77E\uA780\uA782\uA784" +
                         "\uA786\uA78BN\u0308H\u0331P\u0303S\u0329T\u0308W\u030A\u030A\u030A" +
                         "У\u030A\u0399\u0308\u0301\u03A5\u0308\u0301J\u030CH\u0331T\u0308W\u030A" +
                         "Y\u030AA\u02BE\u03A5\u0313\u03A5\u0313\u0300\u03A5\u0313\u0301\u03A5\u0313\u0342\u0391" +
                         "\u0342\u0397\u0342\u0399\u0308\u0300\u0399\u0308\u0301\u0399\u0342\u0399\u0308\u0342\u03A5\u0308" +
                         "\u0300\u03A5\u0308\u0301\u03A1\u0313\u03A5\u0342\u03A5\u0308\u0342\u03A9\u0342\u1FBA\u0345\u0386" +
                         "\u0345\u1FCA\u0345\u0389\u0345\u1FFA\u0345\u038F\u0345\u0391\u0342\u0345\u0397\u0342\u0345\u03A9" +
                         "ʼNΪ́Ϋ́J̌H̱T̈W̊Y̊AΥ̓Υ̓̀Υ̓́Υ̓͂Α͂Η͂Ϊ̀Ϊ́Ι͂Ϋ̀Ϋ́Ρ̓Υ͂Ϋ͂Ω͂" +
                         "\u0342\u0345" +
                         "\u00C0-\u00D6" +
                         "\u00D8-\u00DE" +
                         "\u018E-\u0191" +
                         "\u0196-\u0198" +
                         "\u01B1-\u01B3" +
                         "\u0243-\u0246" +
                         "\u0388-\u038A" +
                         "\u0391-\u03A1" +
                         "\u03A3-\u03AB" +
                         "\u03D2-\u03D4" +
                         "\u03FD-\u042F" +
                         "\u0531-\u0556" +             // This really strange layout is required.
                         "\u10A0-\u10C5" +             // If you merge all of these strings with
                         "\u1F08-\u1F0F" +             // ranges back into a single string,
                         "\u1F18-\u1F1D" +             // funky things happen in Firefox and other
                         "\u1F28-\u1F2F" +             // browsers when you use this variable in a
                         "\u1F38-\u1F3F" +             // regexp - it will insert spaces at random
                         "\u1F48-\u1F4D" +             // into the ranges, breaking them.
                         "\u1F68-\u1F6F" +
                         "\u1FB8-\u1FBB" +
                         "\u1FC8-\u1FCB" +
                         "\u1FD8-\u1FDB" +
                         "\u1FE8-\u1FEC" +
                         "\u1FF8-\u1FFB" +
                         "\u210B-\u210D" +
                         "\u2110-\u2112" +
                         "\u211A-\u211D" +
                         "\u212A-\u212D" +
                         "\u2130-\u2133" +
                         "\u2C00-\u2C2E" +
                         "\u2C62-\u2C64" +
                         "\u2C6D-\u2C6F" +
                         "\uD801\uDC00-\uDC27" +
                         "A-Z]";
/*********************************************************************************************************
* Note: While not *every single* character in the above included ranges contains a letter which has     *
*       a matching lower/upper cased pair (phonetic symbols, ligatures, etc), those characters must     *
*       still be included.  If they are left out, any character following them will be treated as if    *
*       it is the start of a new word, thus causing mid-word capitalization.                            *
*                                                                                                       *
* Excluded ranges with Latin letter-like characters:                                                    *
* U+2100 - U+214F Symbols, not actual letters                                                           *
* U+2460 - U+24FF Symbols, not actual letters (In the Unicode case-folding list, but any time anyone    *
*                 might actually use it on MB, they likely want to keep the case.)                      *
*                 Same for U+2126, U+212A - U+212B, U+2160 - U+216F.                                    *
* U+FF21 - U+FF3A Fullwidth already pre-processed to halfwidth                                          *
* U+FF41 - U+FF5A Fullwidth already pre-processed to halfwidth                                          *
* U+1D400 - U+1D7FF Math symbols, not intended to be alphabetical                                       *
*********************************************************************************************************/
function loadRuleSet(type, mode) {
    var commonRoleWords = "(accordion|acoustic\\sbass\\sguitar|acoustic\\sguitar|acoustic\\supright\\sbass|aeolian\\sharp|afuche|alphorn|" +
                           "alto\\sclarinet|alto\\ssaxophone|alto\\sviolin|appalachian\\sdulcimer|bagpipe|balalaika|bandoneón|banghu|" +
                           "banhu|banjo|bansuri|baritone\\shorn|baritone\\ssaxophone|bass|bass\\sclarinet|bass\\sguitar|bass\\strombone|" +
                           "bassoon|bát|bells|berimbau|biwa|bongos|bouzouki|bowed\\spsaltery|bugle|bull-roarer|cabasa|calliope|carillon|" +
                           "castanets|celesta|cello|chamberlin|chập\\schoa|chapman\\sstick|chiêng|cittern|cizhonghu|clarinet|" +
                           "classical\\sguitar|claves|clavichord|clavinet|concertina|conch|conductor|congas|contrabass|contrabass\\sclarinet|" +
                           "contrabassoon|cornet|cornett|cowbell|crotales|crwth|cymbals|cymbalum|đại\\scô|đàn\\sbầu|đàn\\snguyệt|đàn\\snhị|" +
                           "đàn\\stam\\sthập\\slục|đàn\\stranh|đàn\\stứ\\sdây|đàn\\stỳ\\sbà|denis\\sd'or|didgeridoo|diyingehu|djembe|dobro|" +
                           "double\\sbass|double\\sreed|doyra|drum\\smachine|drums|drumset|dubreq\\sstylophone|electric\\sbass\\sguitar|" +
                           "electric\\scello|electric\\sguitar|electric\\spiano|electric\\ssitar|electric\\supright\\sbass|electric\\sviolin|" +
                           "english\\shorn|èrhú|euphonium|fiddle|fipple\\sflutes|flugelhorn|flute|free\\sreed|french\\shorn|gadulka|gaohu|" +
                           "gayageum|gehu|geomungo|glass\\sarmonica|glass\\sharmonica|glockenspiel|goblet\\sdrum|gong|gongs|grand\\spiano|" +
                           "greek\\sbaglama|gudok|güiro|guitar|hammered\\sdulcimer|hammond\\sorgan|handbells|hardart|hardingfele|harmonica|" +
                           "harmonium|harp|harpsichord|heckelphone|horn|huqin|hurdy\\sgurdy|jew's\\sharp|jing\\shú|k'long\\spút|kazoo|kemenche|" +
                           "keyboard|khalam|kinnor|kithara|kokyu|komungo|kora|koto|langeleik|lasso\\sd'amore|lute|lyre|mandola|mandolin|" +
                           "maracas|marimba|mbira|mellophone|mellotron|melodica|mendoza|mexican\\svihuela|minimoog|mõ|moog|moon\\slute|" +
                           "morin\\skhuur|musical\\sbow|musical\\ssaw|narrator|nose\\sflute|nyckelharpa|oboe|ocarina|omnichord|ondes\\smartenot|" +
                           "ophicleide|organ|other\\spercussion|oud|pan\\spipes|percussion\\sinstruments|piano|piccolo|pipe\\sorgan|psaltery|" +
                           "ratchet|reader|rebab|rebec|recorder|reed\\sorgan|reeds|rhodes\\spiano|sackbut|sampler|sanh|sanshin|santur|sanxián|" +
                           "sáo\\strúc|sarod|saxophone|serpent|shakuhachi|shamisen|sheng|sho|shofar|singing\\sbowl|singular\\sreed|sitar|" +
                           "slide\\sguitar|slide\\swhistle|snare\\sdrum|song\\sloan|soprano\\ssaxophone|soprano\\sviolin|sousaphone|" +
                           "spanish\\sacoustic\\sguitar|spanish\\svihuela|speaker|spoons|steel\\sguitar|steelpan|suikinkutsu|synclavier|" +
                           "synthesizer|tambourine|teleharmonium|temple\\sblocks|tenor\\shorn|tenor\\ssaxophone|theremin|tibetan\\swater\\sdrum|" +
                           "tiểu\\scô|timbales|timpani|tin\\swhistle|toy\\spiano|treble\\sviolin|tres|triangle|trombone|trumpet|tuba|" +
                           "tubular\\sbells|turkish\\sbaglama|turntables|uilleann\\spipes|ukulele|upright\\spiano|valve\\strombone|" +
                           "vertical\\sflute|vibraphone|vibraslap|vielle|viola|viola\\sd'amore|viola\\sda\\sgamba|viola\\sorganista|" +
                           "violin|violotta|vocoder|wagner\\stuba|warr\\sguitar|washboard|washtub\\sbass|waterphone|whip|whistle|" +
                           "willow\\sflute|wood\\sblock|woodwind|xalam|xylophone|yángqín|yehu|zhonghu|zhongruan|zither";
    /* =====================================================================*/
    /* Name dashes to avoid having to deal with unicode code point ids.     */
    /* =====================================================================*/
    var dash = [];
    dash.Armenian_hyphen        = "\u058A"; // ֊
    dash.em_dash                = "\u2014"; // —
    dash.en_dash                = "\u2013"; // –
    dash.figure_dash            = "\u2012"; // ‒
    dash.Hebrew_maqaf           = "\u05BE"; // ־
    dash.hyphen                 = "\u2010"; // ‐
    dash.hyphen_bullet          = "\u2043"; // ⁃
    dash.hyphen_minus           = "-";      // -
    dash.macron                 = "\u00AF"; // ¯
    dash.minus_sign             = "\u2212"; // −
    dash.Mongolian_todo_hyphen  = "\u1806"; // ᠆
    dash.quotation_dash         = "\u2015"; // ―
    dash.soft_hyphen            = "\u00AD"; //
    dash.swung_dash             = "\u2053"; // ⁓
    dash.tilde                  = "~";      // ~
    dash.tilde_operator         = "\u223C"; // ∼
    dash.underscore             = "_";      // _
    dash.wave_dash              = "\u301C"; // 〜
    /* =====================================================================*/
    /* Rules below are for artist name text.                                */
    /* =====================================================================*/
    if (type == "artist" || type == "textartist") {
        var gcrules = {};
        switch (mode) {
        case "Czech":
            gcrules = {
                alwaysUppercasedWords: "",
                ambiguousLowercasedWords: "",
                ambiguousUppercasedWords: "",
                capitalizeFragments: true,
                capitalizeSentences: true,
                changeCapitalization: true,
                commaUppercasedWords: "",
                dashFigure: dash.hyphen_minus,
                dashQuotation: dash.hyphen_minus,
                dashRange: dash.en_dash,
                extraTitleInfoWords: "alternate)",
                fixApostropheWords: true,
                fragmentPunctuation: "([[{(])",
                junkHyphens: [dash.hyphen_minus, dash.hyphen, dash.Armenian_hyphen, dash.Hebrew_maqaf, dash.Mongolian_todo_hyphen, dash.soft_hyphen, dash.minus_sign, dash.hyphen_bullet, dash.macron, dash.quotation_dash, dash.figure_dash, dash.en_dash, dash.em_dash],
                junkHyphensReplacement: dash.hyphen_minus,
                junkTildes: [dash.tilde, dash.tilde_operator, dash.swung_dash],
                junkTildesReplacement: dash.tilde,
                lowerCaseApostropheWords: false,
                lowerCaseWords: ["and","v","v.","vs","vs."],
                lowerCaseWordsEndWords: "",
                mirroredGuillemets: true,
                numberAbbreviation: "No.",
                numberWords: [],
                /* Do not include ' " or ‐ in the punctuation lists! (… can be in the spaceBeforePunctuation list, but it must be \s?…\s? to work right. */
                punctuationCharacters: "([-!#$%&()*+,./:;<=>?@[\\\\\\]^_`{|}~‒–…—―˜»«№◊∴→⇒⊃⊢⊨⁂☞∵§~_¦|¶º°%‰‱^†‡•\\*\\₡ƒ₤₧¥¢$£₩₪]+)",
                roleWords: "",
                spaceAfterPunctuation: "([!#$%&)*+,./:;=>?\\\\\\]|}~»]+)",
                spaceBeforePunctuation: "([~‒–—―=˜/\\[(«])",
                spaceChar: "",
                sentenceEndingPunctuation: [".", "!", "?", "\\s?…\\s?", "/", ":"],
                usesRomanNumerals: true,
                wordForBox: "",
                wordForPt: "",
                wordForPart: "",
                wordForParts: "",
                wordForVolumeA: "",
                wordForVolumeB: "",
                wordForDisc: "",
                romanWordsLower: [],
                romanWordsNormal: ["MIX"]
            };
            break;
        case "English":
            gcrules = {
                alwaysUppercasedWords: "(2XLC|AC|DC|DMX|GZA|ODB|RZA|KLF|DMC|XTC|PVD|ABBA|MC|DJ)",
                ambiguousLowercasedWords: "(present|presents|presenting)",
                ambiguousUppercasedWords: "",
                capitalizeFragments: true,
                capitalizeSentences: true,
                changeCapitalization: true,
                commaUppercasedWords: "",
                dashFigure: dash.figure_dash,
                dashQuotation: dash.quotation_dash,
                dashRange: dash.en_dash,
                extraTitleInfoWords: "alternate)",
                fixApostropheWords: true,
                fragmentPunctuation: "([[{(])",
                junkHyphens: [dash.hyphen_minus, dash.hyphen, dash.Armenian_hyphen, dash.Hebrew_maqaf, dash.Mongolian_todo_hyphen, dash.soft_hyphen, dash.minus_sign, dash.hyphen_bullet, dash.macron, dash.em_dash],
                junkHyphensReplacement: dash.hyphen,
                junkTildes: [dash.tilde, dash.wave_dash, dash.tilde_operator, dash.swung_dash],
                junkTildesReplacement: dash.tilde,
                lowerCaseApostropheWords: false,
                lowerCaseWords: ["a","and","at","by","de","des","etc.","etc","of","or","the","to","v","v.","vs","vs."],
                lowerCaseWordsEndWords: "",
                mirroredGuillemets: false,
                numberAbbreviation: "No.",
                numberWords: [],
                /* Do not include ' " or ‐ in the punctuation lists! (… can be in the spaceBeforePunctuation list, but it must be \s?…\s? to work right. */
                punctuationCharacters: "([-!#$%&()*+,./:;<=>?@[\\\\\\]^_`{|}‽·~@‒–…—―˜◊∴→⇒⊃⊢⊨⁂☞∵§~_¦|¶º°%‰‱^†‡•\\*\\₡ƒ₤₧¥¢$£₩₪]+)",
                roleWords: "",
                spaceAfterPunctuation: "([!$%&)+,./:;=>?\\\\\\]|}~]+)",
                spaceBeforePunctuation: "([~‒–—―=˜#/$&\\[(])",
                spaceChar: "",
                sentenceEndingPunctuation: [".", "!", "?", "\\s?…\\s?", "/", ":"],
                usesRomanNumerals: true,
                wordForBox: "",
                wordForPt: "",
                wordForPart: "",
                wordForParts: "",
                wordForVolumeA: "",
                wordForVolumeB: "",
                wordForDisc: "",
                romanWordsLower: [],
                romanWordsNormal: ["MIX"]
            };
            break;
        case "French":
            /* murdos, dmppanda */
            gcrules = {
                alwaysUppercasedWords: "",
                ambiguousLowercasedWords: "",
                ambiguousUppercasedWords: "",
                capitalizeFragments: true,
                capitalizeSentences: true,
                changeCapitalization: true,
                commaUppercasedWords: "",
                dashFigure: dash.hyphen_minus,
                dashQuotation: dash.hyphen_minus,
                dashRange: dash.en_dash,
                extraTitleInfoWords: "alternate)",
                fixApostropheWords: true,
                fragmentPunctuation: "([[{(])",
                junkHyphens: [dash.hyphen_minus, dash.hyphen, dash.Armenian_hyphen, dash.Hebrew_maqaf, dash.Mongolian_todo_hyphen, dash.soft_hyphen, dash.minus_sign, dash.hyphen_bullet, dash.macron],
                junkHyphensReplacement: dash.hyphen_minus,
                junkTildes: [dash.tilde, dash.wave_dash, dash.tilde_operator, dash.swung_dash],
                junkTildesReplacement: dash.tilde,
                lowerCaseApostropheWords: false,
                lowerCaseWords: ["à","de","des","du","et","l","la","le"],
                lowerCaseWordsEndWords: "",
                mirroredGuillemets: true,
                numberAbbreviation: "Nᵒ",
                numberWords: [],
                /* Do not include ' " or ‐ in the punctuation lists! (… can be in the spaceBeforePunctuation list, but it must be \s?…\s? to work right. */
                punctuationCharacters: "([-!#$%&()*+,./:;<=>?@[\\\\\\]^_`{|}~№‒–…—―˜»«¢£€]+)",
                roleWords: "",
                spaceAfterPunctuation: "([!#$%&)*+,./:;=>?\\\\\\]|}~»]+)",
                spaceBeforePunctuation: "([~‒–=—―;:!?˜/[(»«])",
                spaceChar: "\u00A0",
                sentenceEndingPunctuation: [".", "!", "?", "\\s?…\\s?", "/", ":"],
                usesRomanNumerals: true,
                wordForBox: "",
                wordForPt: "",
                wordForPart: "",
                wordForParts: "",
                wordForVolumeA: "",
                wordForVolumeB: "",
                wordForDisc: "",
                romanWordsLower: [],
                romanWordsNormal: ["MIX"]
            };
            break;
        case "Latvian":
            gcrules = {
                alwaysUppercasedWords: "",
                ambiguousLowercasedWords: "",
                ambiguousUppercasedWords: "",
                capitalizeFragments: true,
                capitalizeSentences: true,
                changeCapitalization: true,
                commaUppercasedWords: "",
                dashFigure: dash.hyphen_minus,
                dashQuotation: dash.hyphen_minus,
                dashRange: dash.en_dash,
                extraTitleInfoWords: "alternate)",
                fixApostropheWords: true,
                fragmentPunctuation: "([[{(])",
                junkHyphens: [dash.hyphen_minus, dash.hyphen, dash.Armenian_hyphen, dash.Hebrew_maqaf, dash.Mongolian_todo_hyphen, dash.soft_hyphen, dash.minus_sign, dash.hyphen_bullet, dash.macron, dash.quotation_dash, dash.figure_dash, dash.en_dash, dash.em_dash],
                junkHyphensReplacement: dash.hyphen_minus,
                junkTildes: [dash.tilde, dash.tilde_operator, dash.swung_dash],
                junkTildesReplacement: dash.tilde,
                lowerCaseApostropheWords: false,
                lowerCaseWords: ["and","v","v.","vs","vs."],
                lowerCaseWordsEndWords: "",
                mirroredGuillemets: true,
                numberAbbreviation: "No.",
                numberWords: [],
                /* Do not include ' " or ‐ in the punctuation lists! (… can be in the spaceBeforePunctuation list, but it must be \s?…\s? to work right. */
                punctuationCharacters: "([-!#$%&()*+,./:;<=>?@[\\\\\\]^_`{|}~‒…–—―˜»«№◊∴→⇒⊃⊢⊨⁂☞∵§~_¦|¶º°%‰‱^†‡•\\*\\₡ƒ₤₧¥¢$£₩₪]+)",
                roleWords: "",
                spaceAfterPunctuation: "([!#$%&)*+,./:;=>?\\\\\\]|}~»]+)",
                spaceBeforePunctuation: "([~‒–—―=˜/\\[(«])",
                spaceChar: "",
                sentenceEndingPunctuation: [".", "!", "?", "\\s?…\\s?", "/", ":"],
                usesRomanNumerals: true,
                wordForBox: "",
                wordForPt: "",
                wordForPart: "",
                wordForParts: "",
                wordForVolumeA: "",
                wordForVolumeB: "",
                wordForDisc: "",
                romanWordsLower: [],
                romanWordsNormal: ["MIX"]
            };
            break;
        case "Lithuanian":
            gcrules = {
                alwaysUppercasedWords: "",
                ambiguousLowercasedWords: "",
                ambiguousUppercasedWords: "",
                capitalizeFragments: true,
                capitalizeSentences: true,
                changeCapitalization: true,
                commaUppercasedWords: "",
                dashFigure: dash.hyphen_minus,
                dashQuotation: dash.hyphen_minus,
                dashRange: dash.en_dash,
                extraTitleInfoWords: "alternate)",
                fixApostropheWords: true,
                fragmentPunctuation: "([[{(])",
                junkHyphens: [dash.hyphen_minus, dash.hyphen, dash.Armenian_hyphen, dash.Hebrew_maqaf, dash.Mongolian_todo_hyphen, dash.soft_hyphen, dash.minus_sign, dash.hyphen_bullet, dash.macron, dash.quotation_dash, dash.figure_dash, dash.en_dash, dash.em_dash],
                junkHyphensReplacement: dash.hyphen_minus,
                junkTildes: [dash.tilde, dash.tilde_operator, dash.swung_dash],
                junkTildesReplacement: dash.tilde,
                lowerCaseApostropheWords: false,
                lowerCaseWords: ["and","v","v.","vs","vs."],
                lowerCaseWordsEndWords: "",
                mirroredGuillemets: true,
                numberAbbreviation: "No.",
                numberWords: [],
                /* Do not include ' " or ‐ in the punctuation lists! (… can be in the spaceBeforePunctuation list, but it must be \s?…\s? to work right. */
                punctuationCharacters: "([-!#$%&()*+,./:;<=>?@[\\\\\\]^_`{|}~‒…–—―˜»«№◊∴→⇒⊃⊢⊨⁂☞∵§~_¦|¶º°%‰‱^†‡•\\*\\₡ƒ₤₧¥¢$£₩₪]+)",
                roleWords: "",
                spaceAfterPunctuation: "([!#$%&)*+,./:;=>?\\\\\\]|}~»]+)",
                spaceBeforePunctuation: "([~‒–—―=˜/\\[(«])",
                spaceChar: "",
                sentenceEndingPunctuation: [".", "!", "?", "\\s?…\\s?", "/", ":"],
                usesRomanNumerals: true,
                wordForBox: "",
                wordForPt: "",
                wordForPart: "",
                wordForParts: "",
                wordForVolumeA: "",
                wordForVolumeB: "",
                wordForDisc: "",
                romanWordsLower: [],
                romanWordsNormal: ["MIX"]
            };
            break;
        case "Norwegian":
            /* mo */
            gcrules = {
                alwaysUppercasedWords: "",
                ambiguousLowercasedWords: "",
                ambiguousUppercasedWords: "",
                capitalizeFragments: true,
                capitalizeSentences: true,
                changeCapitalization: true,
                commaUppercasedWords: "",
                dashFigure: dash.hyphen_minus,
                dashQuotation: dash.hyphen_minus,
                dashRange: dash.en_dash,
                extraTitleInfoWords: "alternate)",
                fixApostropheWords: true,
                fragmentPunctuation: "([[{(])",
                junkHyphens: [dash.hyphen_minus, dash.hyphen, dash.Armenian_hyphen, dash.Hebrew_maqaf, dash.Mongolian_todo_hyphen, dash.soft_hyphen, dash.minus_sign, dash.hyphen_bullet, dash.macron],
                junkHyphensReplacement: dash.hyphen_minus,
                junkTildes: [dash.tilde, dash.wave_dash, dash.tilde_operator, dash.swung_dash],
                junkTildesReplacement: dash.tilde,
                lowerCaseApostropheWords: false,
                lowerCaseWords: ["og"],
                lowerCaseWordsEndWords: "",
                mirroredGuillemets: true,
                numberAbbreviation: "No.",
                numberWords: [],
                /* Do not include ' " or ‐ in the punctuation lists! (… can be in the spaceBeforePunctuation list, but it must be \s?…\s? to work right. */
                punctuationCharacters: "([-!#$%&()*+,./:;<=>?@[\\\\\\]^_`{|}~‒–…—―˜¢£€]+)",
                roleWords: "",
                spaceAfterPunctuation: "([!#$%&)*+,./:;=>?\\\\\\]|}~]+)",
                spaceBeforePunctuation: "([~‒–=—―˜/[(])",
                spaceChar: "",
                sentenceEndingPunctuation: [".", "!", "?", "\\s?…\\s?", "/", ":"],
                usesRomanNumerals: true,
                wordForBox: "",
                wordForPt: "",
                wordForPart: "",
                wordForParts: "",
                wordForVolumeA: "",
                wordForVolumeB: "",
                wordForDisc: "",
                romanWordsLower: [],
                romanWordsNormal: ["MIX","I","VI"]
            };
            break;
        case "Polish":
            gcrules = {
                alwaysUppercasedWords: "",
                ambiguousLowercasedWords: "",
                ambiguousUppercasedWords: "",
                capitalizeFragments: true,
                capitalizeSentences: true,
                changeCapitalization: true,
                commaUppercasedWords: "",
                dashFigure: dash.hyphen_minus,
                dashQuotation: dash.hyphen_minus,
                dashRange: dash.en_dash,
                extraTitleInfoWords: "alternate)",
                fixApostropheWords: true,
                fragmentPunctuation: "([[{(])",
                junkHyphens: [dash.hyphen_minus, dash.hyphen, dash.Armenian_hyphen, dash.Hebrew_maqaf, dash.Mongolian_todo_hyphen, dash.soft_hyphen, dash.minus_sign, dash.hyphen_bullet, dash.macron, dash.quotation_dash, dash.figure_dash, dash.en_dash, dash.em_dash],
                junkHyphensReplacement: dash.hyphen_minus,
                junkTildes: [dash.tilde, dash.tilde_operator, dash.swung_dash],
                junkTildesReplacement: dash.tilde,
                lowerCaseApostropheWords: false,
                lowerCaseWords: ["and","v","v.","vs","vs."],
                lowerCaseWordsEndWords: "",
                mirroredGuillemets: true,
                numberAbbreviation: "No.",
                numberWords: [],
                /* Do not include ' " or ‐ in the punctuation lists! (… can be in the spaceBeforePunctuation list, but it must be \s?…\s? to work right. */
                punctuationCharacters: "([-!#$%&()*+,./:;<=>?@[\\\\\\]^_`{|}~‒–—…―˜»«№◊∴→⇒⊃⊢⊨⁂☞∵§~_¦|¶º°%‰‱^†‡•\\*\\₡ƒ₤₧¥¢$£₩₪]+)",
                roleWords: "",
                spaceAfterPunctuation: "([!#$%&)*+,./:;=>?\\\\\\]|}~»]+)",
                spaceBeforePunctuation: "([~‒–—―=˜/\\[(«])",
                spaceChar: "",
                sentenceEndingPunctuation: [".", "!", "?", "\\s?…\\s?", "/", ":"],
                usesRomanNumerals: true,
                wordForBox: "",
                wordForPt: "",
                wordForPart: "",
                wordForParts: "",
                wordForVolumeA: "",
                wordForVolumeB: "",
                wordForDisc: "",
                romanWordsLower: [],
                romanWordsNormal: ["MIX"]
            };
            break;
        case "Russian":
            /* pronik */
            gcrules = {
                alwaysUppercasedWords: "",
                ambiguousLowercasedWords: "",
                ambiguousUppercasedWords: "",
                capitalizeFragments: true,
                capitalizeSentences: true,
                changeCapitalization: true,
                commaUppercasedWords: "",
                dashFigure: dash.hyphen_minus,
                dashQuotation: dash.hyphen_minus,
                dashRange: dash.en_dash,
                extraTitleInfoWords: "alternate)",
                fixApostropheWords: true,
                fragmentPunctuation: "([[{(])",
                junkHyphens: [dash.hyphen_minus, dash.hyphen, dash.Armenian_hyphen, dash.Hebrew_maqaf, dash.Mongolian_todo_hyphen, dash.soft_hyphen, dash.minus_sign, dash.hyphen_bullet, dash.macron, dash.em_dash],
                junkHyphensReplacement: dash.hyphen_minus,
                junkTildes: [dash.tilde, dash.wave_dash, dash.tilde_operator, dash.swung_dash],
                junkTildesReplacement: dash.tilde,
                lowerCaseApostropheWords: false,
                lowerCaseWords: "",
                lowerCaseWordsEndWords: "",
                mirroredGuillemets: true,
                numberAbbreviation: "№.",
                numberWords: [],
                /* Do not include ' " or ‐ in the punctuation lists! (… can be in the spaceBeforePunctuation list, but it must be \s?…\s? to work right. */
                punctuationCharacters: "([-!#$%&()*+,./:;<=>?@[\\\\\\]^_`{|}~‒–…—―˜»«№]+)",
                roleWords: "",
                spaceAfterPunctuation: "([!#$%&)*+,./:;=>?\\\\\\]|}~»]+)",
                spaceBeforePunctuation: "([~‒–=—―˜/[(«])",
                spaceChar: "",
                sentenceEndingPunctuation: [".", "!", "?", "\\s?…\\s?", "/", ":"],
                usesRomanNumerals: true,
                wordForBox: "",
                wordForPt: "",
                wordForPart: "",
                wordForParts: "",
                wordForVolumeA: "",
                wordForVolumeB: "",
                wordForDisc: "",
                romanWordsLower: [],
                romanWordsNormal: ["MIX"]
                /* Uses Guillemots normally for quotation punctuation */
            };
            break;
        case "Sentence":
            gcrules = {
                alwaysUppercasedWords: "(RCA)",
                ambiguousLowercasedWords: "",
                ambiguousUppercasedWords: "",
                capitalizeFragments: true,
                capitalizeSentences: true,
                changeCapitalization: true,
                commaUppercasedWords: "",
                dashFigure: dash.hyphen_minus,
                dashQuotation: dash.hyphen_minus,
                dashRange: dash.en_dash,
                extraTitleInfoWords: "alternate)",
                fixApostropheWords: true,
                fragmentPunctuation: "([[{(])",
                junkHyphens: [dash.hyphen_minus, dash.hyphen, dash.Armenian_hyphen, dash.Hebrew_maqaf, dash.Mongolian_todo_hyphen, dash.soft_hyphen, dash.minus_sign, dash.hyphen_bullet, dash.macron, dash.quotation_dash, dash.figure_dash, dash.en_dash, dash.em_dash],
                junkHyphensReplacement: dash.hyphen_minus,
                junkTildes: [dash.tilde, dash.tilde_operator, dash.swung_dash],
                junkTildesReplacement: dash.tilde,
                lowerCaseApostropheWords: false,
                lowerCaseWords: ["and","at","by","de","des","etc.","etc","la","le","of","on","or","the","to","v","v.","vs","vs."],
                lowerCaseWordsEndWords: "",
                mirroredGuillemets: true,
                numberAbbreviation: "No.",
                numberWords: [],
                /* Do not include ' " or ‐ in the punctuation lists! (… can be in the spaceBeforePunctuation list, but it must be \s?…\s? to work right. */
                punctuationCharacters: "([-!#$%&()*+,./:;<=>?@[\\\\\\]^_`{|}~‒…–—¡¿―˜»«№◊∴→⇒⊃⊢⊨⁂☞∵§~_¦|¶º°%‰‱^†‡•\\*\\₡ƒ₤₧¥¢$£₩₪]+)",
                roleWords: "",
                spaceAfterPunctuation: "([!#$%&)*+,./:;=>?\\\\\\]|}~»]+)",
                spaceBeforePunctuation: "([~‒–—―=˜/\\[(«])",
                spaceChar: "",
                sentenceEndingPunctuation: [".", "!", "?", "\\s?…\\s?", "/", ":"],
                usesRomanNumerals: true,
                wordForBox: "",
                wordForPt: "",
                wordForPart: "",
                wordForParts: "",
                wordForVolumeA: "",
                wordForVolumeB: "",
                wordForDisc: "",
                romanWordsLower: ["MIX","I","VI"],
                romanWordsNormal: []
            };
            break;
        case "Slovak":
            gcrules = {
                alwaysUppercasedWords: "",
                ambiguousLowercasedWords: "",
                ambiguousUppercasedWords: "",
                capitalizeFragments: true,
                capitalizeSentences: true,
                changeCapitalization: true,
                commaUppercasedWords: "",
                dashFigure: dash.hyphen_minus,
                dashQuotation: dash.hyphen_minus,
                dashRange: dash.en_dash,
                extraTitleInfoWords: "alternate)",
                fixApostropheWords: true,
                fragmentPunctuation: "([[{(])",
                junkHyphens: [dash.hyphen_minus, dash.hyphen, dash.Armenian_hyphen, dash.Hebrew_maqaf, dash.Mongolian_todo_hyphen, dash.soft_hyphen, dash.minus_sign, dash.hyphen_bullet, dash.macron, dash.quotation_dash, dash.figure_dash, dash.en_dash, dash.em_dash],
                junkHyphensReplacement: dash.hyphen_minus,
                junkTildes: [dash.tilde, dash.tilde_operator, dash.swung_dash],
                junkTildesReplacement: dash.tilde,
                lowerCaseApostropheWords: false,
                lowerCaseWords: ["and","v","v.","vs","vs."],
                lowerCaseWordsEndWords: "",
                mirroredGuillemets: true,
                numberAbbreviation: "No.",
                numberWords: [],
                /* Do not include ' " or ‐ in the punctuation lists! (… can be in the spaceBeforePunctuation list, but it must be \s?…\s? to work right. */
                punctuationCharacters: "([-!#$%&()*+,./:;<=>?@[\\\\\\]^_`{|}~‒–…—―˜»«№◊∴→⇒⊃⊢⊨⁂☞∵§~_¦|¶º°%‰‱^†‡•\\*\\₡ƒ₤₧¥¢$£₩₪]+)",
                roleWords: "",
                spaceAfterPunctuation: "([!#$%&)*+,./:;=>?\\\\\\]|}~»]+)",
                spaceBeforePunctuation: "([~‒–—―=˜/\\[(«])",
                spaceChar: "",
                sentenceEndingPunctuation: [".", "!", "?", "\\s?…\\s?", "/", ":"],
                usesRomanNumerals: true,
                wordForBox: "",
                wordForPt: "",
                wordForPart: "",
                wordForParts: "",
                wordForVolumeA: "",
                wordForVolumeB: "",
                wordForDisc: "",
                romanWordsLower: [],
                romanWordsNormal: ["MIX"]
            };
            break;
        case "Vietnamese":
            gcrules = {
                alwaysUppercasedWords: "",
                ambiguousLowercasedWords: "",
                ambiguousUppercasedWords: "",
                capitalizeFragments: true,
                capitalizeSentences: true,
                changeCapitalization: true,
                commaUppercasedWords: "",
                dashFigure: dash.hyphen_minus,
                dashQuotation: dash.hyphen_minus,
                dashRange: dash.en_dash,
                extraTitleInfoWords: "alternate)",
                fixApostropheWords: true,
                fragmentPunctuation: "([[{(])",
                junkHyphens: [dash.hyphen_minus, dash.hyphen, dash.Armenian_hyphen, dash.Hebrew_maqaf, dash.Mongolian_todo_hyphen, dash.soft_hyphen, dash.minus_sign, dash.hyphen_bullet, dash.macron],
                junkHyphensReplacement: dash.hyphen_minus,
                junkTildes: [dash.tilde, dash.wave_dash, dash.tilde_operator, dash.swung_dash],
                junkTildesReplacement: dash.tilde,
                lowerCaseApostropheWords: false,
                lowerCaseWords: ["à","de","des","du","et","l","la","le"],
                lowerCaseWordsEndWords: "",
                mirroredGuillemets: true,
                numberAbbreviation: "Nᵒ",
                numberWords: [],
                /* Do not include ' " or ‐ in the punctuation lists! (… can be in the spaceBeforePunctuation list, but it must be \s?…\s? to work right. */
                punctuationCharacters: "([-!#$%&()*+,./:;<=>?@[\\\\\\]^_`{|}~№‒…–—―˜¢£€]+)",
                roleWords: "",
                spaceAfterPunctuation: "([!#$%&)*+,./:;=>?\\\\\\]|}~]+)",
                spaceBeforePunctuation: "([~‒–=—―;:!?˜/[(])",
                spaceChar: "\u202F",
                sentenceEndingPunctuation: [".", "!", "?", "\\s?…\\s?", "/", ":"],
                usesRomanNumerals: true,
                wordForBox: "",
                wordForPt: "",
                wordForPart: "",
                wordForParts: "",
                wordForVolumeA: "",
                wordForVolumeB: "",
                wordForDisc: "",
                romanWordsLower: [],
                romanWordsNormal: ["MIX"]
            };
            break;
        default:
        }
        /* =====================================================================*/
        /* Rules below are for non-artist name text.                            */
        /* =====================================================================*/
    } else {
        switch (mode) {
        case "Czech":
            gcrules = {
                alwaysUppercasedWords: "(BWV|RV|HWV|KV)",
                ambiguousLowercasedWords: "",
                ambiguousUppercasedWords: "",
                capitalizeFragments: true,
                capitalizeSentences: true,
                changeCapitalization: false,
                commaUppercasedWords: "",
                dashFigure: dash.hyphen_minus,
                dashQuotation: dash.hyphen_minus,
                dashRange: dash.en_dash,
                extraTitleInfoWords: "alternate)",
                fixApostropheWords: true,
                fragmentPunctuation: "([[{(])",
                junkHyphens: [dash.hyphen_minus, dash.hyphen, dash.Armenian_hyphen, dash.Hebrew_maqaf, dash.Mongolian_todo_hyphen, dash.soft_hyphen, dash.minus_sign, dash.hyphen_bullet, dash.macron, dash.quotation_dash, dash.figure_dash, dash.en_dash, dash.em_dash],
                junkHyphensReplacement: dash.hyphen_minus,
                junkTildes: [dash.tilde, dash.tilde_operator, dash.swung_dash],
                junkTildesReplacement: dash.tilde,
                lowerCaseApostropheWords: false,
                lowerCaseWords: ["and"],
                lowerCaseWordsEndWords: "",
                mirroredGuillemets: false,
                numberAbbreviation: "No.",
                numberWords: [],
                /* Do not include ' " or ‐ in the punctuation lists! (… can be in the spaceBeforePunctuation list, but it must be \s?…\s? to work right. */
                punctuationCharacters: "([-!#$%&()*+,./:;<=>?@[\\\\\\]^_`{|}~‒–…—―˜№◊∴→⇒⊃⊢⊨⁂☞∵§~_¦|¶º°%‰‱#^†‡•\\*\\₡ƒ₤₧¥¢$£₩₪]+)",
                roleWords: commonRoleWords + ")",
                spaceAfterPunctuation: "([!#$%&)*+,./:;=>?\\\\\\]|}~]+)",
                spaceBeforePunctuation: "([~‒–=—―˜/\\[(])",
                spaceChar: "",
                sentenceEndingPunctuation: [".", "!", "?", "\\s?…\\s?", "/", ":"],
                usesRomanNumerals: true,
                wordForBox: "",
                wordForPt: "",
                wordForPart: "",
                wordForParts: "",
                wordForVolumeA: "",
                wordForVolumeB: "",
                wordForDisc: "",
                romanWordsLower: [],
                romanWordsNormal: ["MIX"]
            };
            break;
        case "English":
            gcrules = {
                alwaysUppercasedWords: "(AK|AZ|AR|CA|CT|DE|DC|FL|GA|GU|HI|ID|IA|KS|KY|LA|" +        /* US States and Provinces        */
                                        "MH|MD|MI|MN|MS|MT|NE|NV|NH|NJ|NM|NY|NC|ND|MP|PW|PR|" +     /* US States and Provinces        */
                                        "RI|SC|SD|TN|TX|UT|VT|VI|WA|WV|WI|WY|" +                    /* US States and Provinces        */
                                        "NYC|HMV|OSU|XMU|WFMU|WHFS|HFS|NYU|JHU|MIT|" +              /* Places                         */
                                        "AB|BC|MB|NB|NL|NT|NS|NU|PE|QC|SK|YT|" +                    /* Canadian States and Provinces  */
                                        "2XLC|AC|DC|DMX|GZA|ODB|RZA|KLF|DMC|XTC|PVD|ABBA|" +        /* Artists                        */
                                        "BPM|DJ|EP|LP|MC|R&B|BWV|RV|HWV|KV|AC|LWV|TWV|WAB|" +       /* Music Terms                    */
                                        "ZMV|AWV|BVN|DLR|FVB|FWV|GWV|KWV|LWV|MWV|RWV|TFV|" +        /* Music Terms                    */
                                        "WKO|WWV|ZWV|NMA|SWV|RPM|BPM" +                             /* Music Terms                    */
                                        "AT&T|BBC|MLB|MTV|NBA|NBC|NFL|NHL|YMCA|XFM|RCA|BMG|" +      /* Companies and Organizations    */
                                        "NASA|AHL|AT&T|" +                                          /* Companies and Organizations    */
                                        "MD|JD|MC|DJ|" +                                            /* Titles                         */
                                        "FFI|FFII|FFIII|FFIV|FFV|FFVI|FFVII|FFVIII|FFIX|FFX|" +     /* Games frequently abbreviated   */
                                        "FFXI|FFXII|FFXIII|" +                                      /* Games frequently abbreviated   */
                                        "FM|TV|TM|VIP|CD|CPO|CEO|JFK|ESP|QED|BBQ|BGM|UFO|DNA|" +    /* Other Words                    */
                                        "NRG|4WD|HIV|LSD|DVD|PSP|MPH|AEGIS|API|UNIX|" +             /* Other Words                    */
                                        "DNA|AIDS|ANSI|ASCII)",                                     /* Other Words                    */
                ambiguousLowercasedWords: "(presenting|presents|a\\.k\\.a\\.)",
                ambiguousUppercasedWords: "(ad)",
                capitalizeFragments: true,
                capitalizeSentences: true,
                changeCapitalization: true,
                commaUppercasedWords: "(al|co|il|in|ma|me|mo|oh|ok|on|or|pa|va)",
                dashFigure: dash.figure_dash,
                dashQuotation: dash.quotation_dash,
                dashRange: dash.en_dash,
                extraTitleInfoWords: "alternate)",
                fixApostropheWords: true,
                fragmentPunctuation: "([[{(])",
                junkHyphens: [dash.hyphen_minus, dash.hyphen, dash.Armenian_hyphen, dash.Hebrew_maqaf, dash.Mongolian_todo_hyphen, 
                              dash.soft_hyphen, dash.minus_sign, dash.hyphen_bullet, dash.macron, dash.em_dash],
                junkHyphensReplacement: dash.hyphen,
                junkTildes: [dash.tilde, dash.wave_dash, dash.tilde_operator, dash.swung_dash],
                junkTildesReplacement: dash.tilde,
                lowerCaseApostropheWords: true,
                lowerCaseWords: ["a","an","and","as","at","but","by","cum","de","des","etc.","etc","for","if","in","la","le","mid","nor","off","of",
                                 "on","or","per","qua","re","so","the","to","up","via","v","v.","vs","vs.","yet","a.k.a."],
                lowerCaseWordsEndWords: "(by|cum|in|off|on|so|up|yet|for|to)",
                mirroredGuillemets: false,
                numberAbbreviation: "No.",
                numberWords: ["one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen", 
                              "sixteen","seventeen","eighteen","nineteen","twenty","twenty-one","twenty-two","twenty-three","twenty-four","twenty-five",
                              "twenty-six","twenty-seven","twenty-eight","twenty-nine","thirty","thirty-one","thirty-two","thirty-three","thirty-four",
                              "thirty-five","thirty-six","thirty-seven","thirty-eight","thirty-nine","fourty","fourty-one","fourty-two","fourty-three",
                              "fourty-four","fourty-five","fourty-six","fourty-seven","fourty-eight","fourty-nine","fifty","fifty-one","fifty-two",
                              "fifty-three","fifty-four","fifty-five","fifty-six","fifty-seven","fifty-eight","fifty-nine","sixty","sixty-one",
                              "sixty-two","sixty-three","sixty-four","sixty-five","sixty-six","sixty-seven","sixty-eight","sixty-nine","seventy",
                              "seventy-one","seventy-two","seventy-three","seventy-four","seventy-five","seventy-six","seventy-seven","seventy-eight",
                              "seventy-nine","eighty","eighty-one","eighty-two","eighty-three","eighty-four","eighty-five","eighty-six","eighty-seven",
                              "eighty-eight","eighty-nine","ninety","ninety-one","ninety-two","ninety-three","ninety-four","ninety-five","ninety-six",
                              "ninety-seven","ninety-eight","ninety-nine","one hundred"],
                /* Do not include ' " or ‐ in the punctuation lists! … can be in the spaceBeforePunctuation list, but it must be \\s?…\\s? to work right. */
                punctuationCharacters: "([-!#$%&()*+,./:;<=>?@[\\\\\\]‽·^_`{|}~‒@–—…―˜◊∴→⇒⊃⊢⊨⁂☞∵§~_¦|¶º°%‰‱#^†‡•\\*\\₡ƒ₤₧¥¢$£₩₪]+)",
                roleWords: commonRoleWords + ")",
                spaceAfterPunctuation: "([!$%&)+,./:;=>?\\\\\\]|}~]+)",
                spaceBeforePunctuation: "([~‒–—―=˜#/$&\\[(])",
                spaceChar: "",
                sentenceEndingPunctuation: [".", "!", "?", "\\s?…\\s?", "/", ":", ";"],
                usesRomanNumerals: true,
                wordForBox: "box",
                wordForPt: "pt",
                wordForPart: "part",
                wordForParts: "parts",
                wordForVolumeA: "volume",
                wordForVolumeB: "vol",
                wordForDisc: "disc",
                romanWordsLower: [],
                romanWordsNormal: ["MIX"]
            };
            break;
        case "French":
            gcrules = {
                alwaysUppercasedWords: "(BWV|RV|HWV|KV)",
                ambiguousLowercasedWords: "",
                ambiguousUppercasedWords: "",
                capitalizeFragments: true,
                capitalizeSentences: true,
                changeCapitalization: false,
                dashFigure: dash.hyphen_minus,
                dashQuotation: dash.hyphen_minus,
                dashRange: dash.en_dash,
                commaUppercasedWords: "",
                extraTitleInfoWords: "alternate)",
                fixApostropheWords: true,
                fragmentPunctuation: "([[{(])",
                junkHyphens: [dash.hyphen_minus, dash.hyphen, dash.Armenian_hyphen, dash.Hebrew_maqaf, dash.Mongolian_todo_hyphen, dash.soft_hyphen, dash.minus_sign, dash.hyphen_bullet, dash.macron],
                junkHyphensReplacement: dash.hyphen_minus,
                junkTildes: [dash.tilde, dash.wave_dash, dash.tilde_operator, dash.swung_dash],
                junkTildesReplacement: dash.tilde,
                lowerCaseApostropheWords: false,
                lowerCaseWords: ["à","de","des","du","et","l","la","le"],
                lowerCaseWordsEndWords: "",
                mirroredGuillemets: true,
                numberAbbreviation: "Nᵒ",
                numberWords: [],
                /* Do not include ' " or ‐ in the punctuation lists! (… can be in the spaceBeforePunctuation list, but it must be \s?…\s? to work right. */
                punctuationCharacters: "([-!#$%&()*+,./:;<=>?@[\\\\\\]^_`{|}~№‒–…—―˜»«¢£€]+)",
                roleWords: commonRoleWords + ")",
                spaceAfterPunctuation: "([!#$%&)*+,./:«;=>?\\\\\\]|}~»]+)",
                spaceBeforePunctuation: "([~‒–=—―;:!?˜/[(»«])",
                spaceChar: "\u00A0",
                sentenceEndingPunctuation: [".", "!", "?", "\\s?…\\s?", "/", ":"],
                usesRomanNumerals: true,
                wordForBox: "",
                wordForPt: "",
                wordForPart: "partie",
                wordForParts: "parties",
                wordForVolumeA: "",
                wordForVolumeB: "",
                wordForDisc: "discque",
                romanWordsLower: [],
                romanWordsNormal: ["MIX"]
            };
            break;
        case "Latvian":
            gcrules = {
                alwaysUppercasedWords: "(BWV|RV|HWV|KV)",
                ambiguousLowercasedWords: "",
                ambiguousUppercasedWords: "",
                capitalizeFragments: true,
                capitalizeSentences: true,
                changeCapitalization: false,
                commaUppercasedWords: "",
                dashFigure: dash.hyphen_minus,
                dashQuotation: dash.hyphen_minus,
                dashRange: dash.en_dash,
                extraTitleInfoWords: "alternate)",
                fixApostropheWords: true,
                fragmentPunctuation: "([[{(])",
                junkHyphens: [dash.hyphen_minus, dash.hyphen, dash.Armenian_hyphen, dash.Hebrew_maqaf, dash.Mongolian_todo_hyphen, dash.soft_hyphen, dash.minus_sign, dash.hyphen_bullet, dash.macron, dash.quotation_dash, dash.figure_dash, dash.en_dash, dash.em_dash],
                junkHyphensReplacement: dash.hyphen_minus,
                junkTildes: [dash.tilde, dash.tilde_operator, dash.swung_dash],
                junkTildesReplacement: dash.tilde,
                lowerCaseApostropheWords: false,
                lowerCaseWords: ["and"],
                lowerCaseWordsEndWords: "",
                mirroredGuillemets: false,
                numberAbbreviation: "No.",
                numberWords: [],
                /* Do not include ' " or ‐ in the punctuation lists! (… can be in the spaceBeforePunctuation list, but it must be \s?…\s? to work right. */
                punctuationCharacters: "([-!#$%&()*+,./:;<=>?@[\\\\\\]^_`{|}~‒–—…―˜№◊∴→⇒⊃⊢⊨⁂☞∵§~_¦|¶º°%‰‱#^†‡•\\*\\₡ƒ₤₧¥¢$£₩₪]+)",
                roleWords: commonRoleWords + ")",
                spaceAfterPunctuation: "([!#$%&)*+,./:;=>?\\\\\\]|}~]+)",
                spaceBeforePunctuation: "([~‒–=—―˜/\\[(])",
                spaceChar: "",
                sentenceEndingPunctuation: [".", "!", "?", "\\s?…\\s?", "/", ":"],
                usesRomanNumerals: true,
                wordForBox: "",
                wordForPt: "",
                wordForPart: "",
                wordForParts: "",
                wordForVolumeA: "",
                wordForVolumeB: "",
                wordForDisc: "",
                romanWordsLower: [],
                romanWordsNormal: ["MIX"]
            };
            break;
        case "Lithuanian":
            gcrules = {
                alwaysUppercasedWords: "(BWV|RV|HWV|KV)",
                ambiguousLowercasedWords: "",
                ambiguousUppercasedWords: "",
                capitalizeFragments: true,
                capitalizeSentences: true,
                changeCapitalization: false,
                commaUppercasedWords: "",
                dashFigure: dash.hyphen_minus,
                dashQuotation: dash.hyphen_minus,
                dashRange: dash.en_dash,
                extraTitleInfoWords: "alternate)",
                fixApostropheWords: true,
                fragmentPunctuation: "([[{(])",
                junkHyphens: [dash.hyphen_minus, dash.hyphen, dash.Armenian_hyphen, dash.Hebrew_maqaf, dash.Mongolian_todo_hyphen, dash.soft_hyphen, dash.minus_sign, dash.hyphen_bullet, dash.macron, dash.quotation_dash, dash.figure_dash, dash.en_dash, dash.em_dash],
                junkHyphensReplacement: dash.hyphen_minus,
                junkTildes: [dash.tilde, dash.tilde_operator, dash.swung_dash],
                junkTildesReplacement: dash.tilde,
                lowerCaseApostropheWords: false,
                lowerCaseWords: ["and"],
                lowerCaseWordsEndWords: "",
                mirroredGuillemets: false,
                numberAbbreviation: "No.",
                numberWords: [],
                /* Do not include ' " or ‐ in the punctuation lists! (… can be in the spaceBeforePunctuation list, but it must be \s?…\s? to work right. */
                punctuationCharacters: "([-!#$%&()*+,./:;<=>?@[\\\\\\]^_`{|}~‒…–—―˜№◊∴→⇒⊃⊢⊨⁂☞∵§~_¦|¶º°%‰‱#^†‡•\\*\\₡ƒ₤₧¥¢$£₩₪]+)",
                roleWords: commonRoleWords + ")",
                spaceAfterPunctuation: "([!#$%&)*+,./:;=>?\\\\\\]|}~]+)",
                spaceBeforePunctuation: "([~‒–=—―˜/\\[(])",
                spaceChar: "",
                sentenceEndingPunctuation: [".", "!", "?", "\\s?…\\s?", "/", ":"],
                usesRomanNumerals: true,
                wordForBox: "",
                wordForPt: "",
                wordForPart: "",
                wordForParts: "",
                wordForVolumeA: "",
                wordForVolumeB: "",
                wordForDisc: "",
                romanWordsLower: [],
                romanWordsNormal: ["MIX"]
            };
            break;
        case "Norwegian":
            gcrules = {
                alwaysUppercasedWords: "(BWV|RV|HWV|KV)",
                ambiguousLowercasedWords: "",
                ambiguousUppercasedWords: "",
                capitalizeFragments: true,
                capitalizeSentences: true,
                changeCapitalization: false,
                commaUppercasedWords: "",
                dashFigure: dash.hyphen_minus,
                dashQuotation: dash.hyphen_minus,
                dashRange: dash.en_dash,
                extraTitleInfoWords: "alternate)",
                fixApostropheWords: true,
                fragmentPunctuation: "([[{(])",
                junkHyphens: [dash.hyphen_minus, dash.hyphen, dash.Armenian_hyphen, dash.Hebrew_maqaf, dash.Mongolian_todo_hyphen, dash.soft_hyphen, dash.minus_sign, dash.hyphen_bullet, dash.macron],
                junkHyphensReplacement: dash.hyphen_minus,
                junkTildes: [dash.tilde, dash.wave_dash, dash.tilde_operator, dash.swung_dash],
                junkTildesReplacement: dash.tilde,
                lowerCaseApostropheWords: false,
                lowerCaseWords: ["and","og"],
                lowerCaseWordsEndWords: "",
                mirroredGuillemets: true,
                numberAbbreviation: "No.",
                numberWords: [],
                /* Do not include ' " or ‐ in the punctuation lists! (… can be in the spaceBeforePunctuation list, but it must be \s?…\s? to work right. */
                punctuationCharacters: "([-!#$%&()*+,./:;<=>?@[\\\\\\]^_`{|}~‒…–—―˜¢£€]+)",
                roleWords: commonRoleWords + ")",
                spaceAfterPunctuation: "([!#$%&)*+,./:;=>?\\\\\\]|}~]+)",
                spaceBeforePunctuation: "([~‒–—=―˜/[(])",
                spaceChar: "",
                sentenceEndingPunctuation: [".", "!", "?", "\\s?…\\s?", "/", ":"],
                usesRomanNumerals: true,
                wordForBox: "",
                wordForPt: "",
                wordForPart: "del",
                wordForParts: "delene",
                wordForVolumeA: "volum",
                wordForVolumeB: "vol.",
                wordForDisc: "disk",
                romanWordsLower: [],
                romanWordsNormal: ["MIX","I","VI"]
            };
            break;
        case "Polish":
            gcrules = {
                alwaysUppercasedWords: "(BWV|RV|HWV|KV)",
                ambiguousLowercasedWords: "",
                ambiguousUppercasedWords: "",
                capitalizeFragments: true,
                capitalizeSentences: true,
                changeCapitalization: false,
                commaUppercasedWords: "",
                dashFigure: dash.hyphen_minus,
                dashQuotation: dash.hyphen_minus,
                dashRange: dash.en_dash,
                extraTitleInfoWords: "alternate)",
                fixApostropheWords: true,
                fragmentPunctuation: "([[{(])",
                junkHyphens: [dash.hyphen_minus, dash.hyphen, dash.Armenian_hyphen, dash.Hebrew_maqaf, dash.Mongolian_todo_hyphen, dash.soft_hyphen, dash.minus_sign, dash.hyphen_bullet, dash.macron, dash.quotation_dash, dash.figure_dash, dash.en_dash, dash.em_dash],
                junkHyphensReplacement: dash.hyphen_minus,
                junkTildes: [dash.tilde, dash.tilde_operator, dash.swung_dash],
                junkTildesReplacement: dash.tilde,
                lowerCaseApostropheWords: false,
                lowerCaseWords: ["and"],
                lowerCaseWordsEndWords: "",
                mirroredGuillemets: false,
                numberAbbreviation: "No.",
                numberWords: [],
                /* Do not include ' " or ‐ in the punctuation lists! (… can be in the spaceBeforePunctuation list, but it must be \s?…\s? to work right. */
                punctuationCharacters: "([-!#$%&()*+,./:;<=>?@[\\\\\\]^_`{|}~‒…–—―˜№◊∴→⇒⊃⊢⊨⁂☞∵§~_¦|¶º°%‰‱#^†‡•\\*\\₡ƒ₤₧¥¢$£₩₪]+)",
                roleWords: commonRoleWords + ")",
                spaceAfterPunctuation: "([!#$%&)*+,./:;=>?\\\\\\]|}~]+)",
                spaceBeforePunctuation: "([~‒–=—―˜/\\[(])",
                spaceChar: "",
                sentenceEndingPunctuation: [".", "!", "?", "\\s?…\\s?", "/", ":"],
                usesRomanNumerals: true,
                wordForBox: "",
                wordForPt: "",
                wordForPart: "",
                wordForParts: "",
                wordForVolumeA: "",
                wordForVolumeB: "",
                wordForDisc: "",
                romanWordsLower: [],
                romanWordsNormal: ["MIX"]
            };
            break;
        case "Russian":
            gcrules = {
                alwaysUppercasedWords: "(BWV|RV|HWV|KV)",
                ambiguousLowercasedWords: "",
                ambiguousUppercasedWords: "",
                capitalizeFragments: true,
                capitalizeSentences: true,
                changeCapitalization: false,
                commaUppercasedWords: "",
                dashFigure: dash.hyphen_minus,
                dashQuotation: dash.hyphen_minus,
                dashRange: dash.en_dash,
                extraTitleInfoWords: "alternate)",
                fixApostropheWords: true,
                fragmentPunctuation: "([[{(])",
                junkHyphens: [dash.hyphen_minus, dash.hyphen, dash.Armenian_hyphen, dash.Hebrew_maqaf, dash.Mongolian_todo_hyphen, dash.soft_hyphen, dash.minus_sign, dash.hyphen_bullet, dash.macron, dash.em_dash],
                junkHyphensReplacement: dash.hyphen_minus,
                junkTildes: [dash.tilde, dash.wave_dash, dash.tilde_operator, dash.swung_dash],
                junkTildesReplacement: dash.tilde,
                lowerCaseApostropheWords: false,
                lowerCaseWords: "",
                lowerCaseWordsEndWords: "",
                mirroredGuillemets: true,
                numberAbbreviation: "№",
                numberWords: [],
                /* Do not include ' " or ‐ in the punctuation lists! (… can be in the spaceBeforePunctuation list, but it must be \s?…\s? to work right. */
                punctuationCharacters: "([-!#$%&()*+,./:;<=>?@[\\\\\\]^_`{|}~‒…–—―˜»«№]+)",
                roleWords: commonRoleWords + ")",
                spaceAfterPunctuation: "([!#$%&)*+,./:;=>?\\\\\\]|}~»]+)",
                spaceBeforePunctuation: "([~‒–=—―˜/[(«])",
                spaceChar: "",
                sentenceEndingPunctuation: [".", "!", "?", "\\s?…\\s?", "/", ":"],
                usesRomanNumerals: true,
                wordForBox: "",
                wordForPt: "ч.",
                wordForPart: "Часть",
                wordForParts: "части",
                wordForVolumeA: "Том",
                wordForVolumeB: "",
                wordForDisc: "диск",
                romanWordsLower: [],
                romanWordsNormal: ["MIX"]
                /* Uses Guillemots normally for quotation punctuation */
            };
            break;
        case "Sentence":
            gcrules = {
                alwaysUppercasedWords: "(AK|AZ|AR|CA|CT|DE|DC|FL|GA|GU|HI|ID|IA|KS|KY|LA|" +        /* US States and Provinces        */
                                        "MH|MD|MI|MN|MS|MT|NE|NV|NH|NJ|NM|NY|NC|ND|MP|PW|PR|" +     /* US States and Provinces        */
                                        "RI|SC|SD|TN|TX|UT|VT|VI|WA|WV|WI|WY|" +                    /* US States and Provinces        */
                                        "NYC|HMV|OSU|XMU|WFMU|WHFS|HFS|NYU|JHU|" +                  /* Places                         */
                                        "AB|BC|MB|NB|NL|NT|NS|NU|PE|QC|SK|YT|" +                    /* Canadian States and Provinces  */
                                        "2XLC|AC|DC|DMX|GZA|ODB|RZA|KLF|DMC|XTC|PVD|ABBA|" +        /* Artists                        */
                                        "BPM|DJ|EP|LP|MC|R&B|BWV|RV|HWV|KV|AC|LWV|TWV|WAB|" +       /* Music Terms                    */
                                        "ZMV|AWV|BVN|DLR|FVB|FWV|GWV|KWV|LWV|MWV|RWV|TFV|" +        /* Music Terms                    */
                                        "WKO|WWV|ZWV|NMA|SWV|RPM|BPM" +                             /* Music Terms                    */
                                        "AT&T|BBC|MLB|MTV|NBA|NBC|NFL|NHL|YMCA|XFM|RCA|BMG|" +      /* Companies and Organizations    */
                                        "NASA|AHL|AT&T|" +                                          /* Companies and Organizations    */
                                        "MD|JD|MC|DJ|" +                                            /* Titles                         */
                                        "FFI|FFII|FFIII|FFIV|FFV|FFVI|FFVII|FFVIII|FFIX|FFX|" +     /* Games frequently abbreviated   */
                                        "FFXI|FFXII|FFXIII|" +                                      /* Games frequently abbreviated   */
                                        "FM|TV|TM|VIP|CD|CPO|CEO|JFK|ESP|QED|BBQ|BGM|UFO|DNA|" +    /* Other Words                    */
                                        "NRG|4WD|HIV|LSD|DVD|PSP|MPH|AEGIS|API|UNIX|" +             /* Other Words                    */
                                        "DNA|AIDS|ANSI|ASCII)",                                     /* Other Words                    */
                ambiguousLowercasedWords: "",
                ambiguousUppercasedWords: "(RCA)",
                capitalizeFragments: true,
                capitalizeSentences: true,
                changeCapitalization: false,
                commaUppercasedWords: "",
                dashFigure: dash.hyphen_minus,
                dashQuotation: dash.hyphen_minus,
                dashRange: dash.en_dash,
                extraTitleInfoWords: "alternate)",
                fixApostropheWords: true,
                fragmentPunctuation: "([[{(])",
                junkHyphens: [dash.hyphen_minus, dash.hyphen, dash.Armenian_hyphen, dash.Hebrew_maqaf, dash.Mongolian_todo_hyphen, dash.soft_hyphen, dash.minus_sign, dash.hyphen_bullet, dash.macron, dash.quotation_dash, dash.figure_dash, dash.en_dash, dash.em_dash],
                junkHyphensReplacement: dash.hyphen_minus,
                junkTildes: [dash.tilde, dash.tilde_operator, dash.swung_dash],
                junkTildesReplacement: dash.tilde,
                lowerCaseApostropheWords: false,
                lowerCaseWords: ["and","de","des","et","la","le","the"],
                lowerCaseWordsEndWords: "",
                mirroredGuillemets: false,
                numberAbbreviation: "No.",
                numberWords: [],
                /* Do not include ' " or ‐ in the punctuation lists! (… can be in the spaceBeforePunctuation list, but it must be \s?…\s? to work right. */
                punctuationCharacters: "([-!#$%&()*+,./:;<=>?@[\\\\\\]^_`{|}~‒¡¿–—―…˜»«№◊∴→⇒⊃⊢⊨⁂☞∵§~_¦|¶º°%‰‱#^†‡•\\*\\₡ƒ₤₧¥¢$£₩₪]+)",
                roleWords: commonRoleWords + ")",
                spaceAfterPunctuation: "([!#$%&)*+,./:;=>?\\\\\\]|}~»]+)",
                spaceBeforePunctuation: "([~‒–=—―˜/\\[(«])",
                spaceChar: "",
                sentenceEndingPunctuation: [".", "!", "?", "\\s?…\\s?", "/", ":"],
                usesRomanNumerals: true,
                wordForBox: "",
                wordForPt: "",
                wordForPart: "",
                wordForParts: "",
                wordForVolumeA: "",
                wordForVolumeB: "",
                wordForDisc: "",
                romanWordsLower: ["MIX","I","VI"],
                romanWordsNormal: []
            };
            break;
        case "Slovak":
            gcrules = {
                alwaysUppercasedWords: "(BWV|RV|HWV|KV)",
                ambiguousLowercasedWords: "",
                ambiguousUppercasedWords: "",
                capitalizeFragments: true,
                capitalizeSentences: true,
                changeCapitalization: false,
                commaUppercasedWords: "",
                dashFigure: dash.hyphen_minus,
                dashQuotation: dash.hyphen_minus,
                dashRange: dash.en_dash,
                extraTitleInfoWords: "alternate)",
                fixApostropheWords: true,
                fragmentPunctuation: "([[{(])",
                junkHyphens: [dash.hyphen_minus, dash.hyphen, dash.Armenian_hyphen, dash.Hebrew_maqaf, dash.Mongolian_todo_hyphen, dash.soft_hyphen, dash.minus_sign, dash.hyphen_bullet, dash.macron, dash.quotation_dash, dash.figure_dash, dash.en_dash, dash.em_dash],
                junkHyphensReplacement: dash.hyphen_minus,
                junkTildes: [dash.tilde, dash.tilde_operator, dash.swung_dash],
                junkTildesReplacement: dash.tilde,
                lowerCaseApostropheWords: false,
                lowerCaseWords: "",
                lowerCaseWordsEndWords: "",
                mirroredGuillemets: false,
                numberAbbreviation: "No.",
                numberWords: [],
                /* Do not include ' " or ‐ in the punctuation lists! (… can be in the spaceBeforePunctuation list, but it must be \s?…\s? to work right. */
                punctuationCharacters: "([-!#$%&()*+,./:;<=>?@[\\\\\\]^_`{|}~…‒–—―˜№◊∴→⇒⊃⊢⊨⁂☞∵§~_¦|¶º°%‰‱#^†‡•\\*\\₡ƒ₤₧¥¢$£₩₪]+)",
                roleWords: commonRoleWords + ")",
                spaceAfterPunctuation: "([!#$%&)*+,./:;=>?\\\\\\]|}~]+)",
                spaceBeforePunctuation: "([~‒–=—―˜/\\[(])",
                spaceChar: "",
                sentenceEndingPunctuation: [".", "!", "?", "\\s?…\\s?", "/", ":"],
                usesRomanNumerals: true,
                wordForBox: "",
                wordForPt: "",
                wordForPart: "",
                wordForParts: "",
                wordForVolumeA: "",
                wordForVolumeB: "",
                wordForDisc: "",
                romanWordsLower: [],
                romanWordsNormal: ["MIX"]
            };
            break;
        case "Vietnamese":
            gcrules = {
                alwaysUppercasedWords: "(BWV|RV|HWV|KV)",
                ambiguousLowercasedWords: "",
                ambiguousUppercasedWords: "",
                capitalizeFragments: true,
                capitalizeSentences: true,
                changeCapitalization: false,
                dashFigure: dash.hyphen_minus,
                dashQuotation: dash.hyphen_minus,
                dashRange: dash.en_dash,
                commaUppercasedWords: "",
                extraTitleInfoWords: "alternate)",
                fixApostropheWords: true,
                fragmentPunctuation: "([[{(])",
                junkHyphens: [dash.hyphen_minus, dash.hyphen, dash.Armenian_hyphen, dash.Hebrew_maqaf, dash.Mongolian_todo_hyphen, dash.soft_hyphen, dash.minus_sign, dash.hyphen_bullet, dash.macron],
                junkHyphensReplacement: dash.hyphen_minus,
                junkTildes: [dash.tilde, dash.wave_dash, dash.tilde_operator, dash.swung_dash],
                junkTildesReplacement: dash.tilde,
                lowerCaseApostropheWords: false,
                lowerCaseWords: ["à","de","des","du","et","l","la","le"],
                lowerCaseWordsEndWords: "",
                mirroredGuillemets: true,
                numberAbbreviation: "Nᵒ",
                numberWords: ["một","hai","ba","bốn","năm","sáu","bảy","tám","chín","mười","mười một","mười hai","mười ba","mười bốn","mười lăm", 
                              "mười sáu","mười bảy","mười tám","mười chín","hai mươi","hai mươi mốt","hai mươi hai","hai mươi ba","hai mươi bốn", 
                              "hai mươi lăm","hai mươi sáu","hai mươi bảy","hai mươi tám","hai mươi chín","ba mươi","ba mươi mốt","ba mươi hai", 
                              "ba mươi ba","ba mươi bốn","ba mươi năm","ba mươi sáu","ba mươi bảy","ba mươi tám","ba mươi chín","bốn mươi","bốn mươi mốt", 
                              "bốn mươi hai","bốn mươi ba","bốn mươi bốn","bốn mươi lăm","bốn mươi sáu","bốn mươi bảy","bốn mươi tám","bốn mươi chín", 
                              "năm mươi","năm mươi mốt","năm mươi hai","năm mươi ba","năm mươi bốn","năm mươi lăm","năm mươi sáu","năm mươi bảy", 
                              "năm mươi tám","năm mươi chín","sáu mươi","sáu mươi mốt","sáu mươi hai","sáu mươi ba","sáu mươi bốn","sáu mươi lăm",
                              "sáu mươi sáu","sáu mươi bảy","sáu mươi tám","sáu mươi chín","bảy mươi","bảy mươi mốt","bảy mươi hai","bảy mươi ba", 
                              "bảy mươi bốn","bảy mươi lăm","bảy mươi sáu","bảy mươi bảy","bảy mươi tám","bảy mươi chín","tám mươi","tám mươi hai",
                              "tám mươi hai","tám mươi ba","tám mươi bốn","tám mươi lăm","tám mươi sáu","tám mươi bảy","tám mươi tám","tám mươi chín", 
                              "chín mươi","chín mươi hai","chín mươi hai","chín mươi ba","chín mươi bốn","chín mươi lăm","chín mươi sáu","chín mươi bảy", 
                              "chín mươi tám","chín mươi chín"],
                /* Do not include ' " or ‐ in the punctuation lists! (… can be in the spaceBeforePunctuation list, but it must be \s?…\s? to work right. */
                punctuationCharacters: "([-!#$%&()*+,./:;<=>?@[\\\\\\]^_`{|}~№‒–…—―˜¢£€]+)",
                roleWords: commonRoleWords + ")",
                spaceAfterPunctuation: "([!#$%&)*+,./:;=>?\\\\\\]|}~]+)",
                spaceBeforePunctuation: "([~‒–=—―;:!?˜/[(])",
                spaceChar: "\u202F",
                sentenceEndingPunctuation: [".", "!", "?", "\\s?…\\s?", "/", ":"],
                usesRomanNumerals: true,
                wordForBox: "",
                wordForPt: "",
                wordForPart: "partie",
                wordForParts: "parties",
                wordForVolumeA: "",
                wordForVolumeB: "",
                wordForDisc: "discque",
                romanWordsLower: [],
                romanWordsNormal: ["MIX"]
            };
            break;
        default:
        }
    }
    return gcrules;
}
/*************************************************************************************
 * Function: validateRuleSet ( language ruleset object )                             *
 *                                                                                   *
 * Make sure that the current mode is properly configured within Guess Case,         *
 * give the user enough info to file a decent bug ticket if not.                     *
 *************************************************************************************/
function validateRuleSet(ruleSet, mode) {
    function somethingWrong(whatIsWrong, mode) {
        if (reportErrors === true) {
            alertUser("error", text.GCProblem + mode + ", " + whatIsWrong);
            return false;
        }
    }
    switch ("undefined") {
        case typeof(ruleSet.alwaysUppercasedWords):
            somethingWrong("alwaysUppercasedWords");
            break;
        case typeof(ruleSet.ambiguousLowercasedWords):
            somethingWrong("ambiguousLowercasedWords");
            break;
        case typeof(ruleSet.ambiguousUppercasedWords):
            somethingWrong("ambiguousUppercasedWords");
            break;
        case typeof(ruleSet.capitalizeFragments):
            somethingWrong("capitalizeFragments");
            break;
        case typeof(ruleSet.capitalizeSentences):
            somethingWrong("capitalizeSentences");
            break;
        case typeof(ruleSet.changeCapitalization):
            somethingWrong("changeCapitalization");
            break;
        case typeof(ruleSet.commaUppercasedWords):
            somethingWrong("commaUppercasedWords");
            break;
        case typeof(ruleSet.dashFigure):
            somethingWrong("dashFigure");
            break;
        case typeof(ruleSet.dashQuotation):
            somethingWrong("dashQuotation");
            break;
        case typeof(ruleSet.dashRange):
            somethingWrong("dashRange");
            break;
        case typeof(ruleSet.extraTitleInfoWords):
            somethingWrong("extraTitleInfoWords");
            break;
        case typeof(ruleSet.fixApostropheWords):
            somethingWrong("fixApostropheWords");
            break;
        case typeof(ruleSet.fragmentPunctuation):
            somethingWrong("fragmentPunctuation");
            break;
        case typeof(ruleSet.junkHyphens):
            somethingWrong("junkHyphens");
            break;
        case typeof(ruleSet.junkHyphensReplacement):
            somethingWrong("junkHyphensReplacement");
            break;
        case typeof(ruleSet.junkTildes):
            somethingWrong("junkTildes");
            break;
        case typeof(ruleSet.junkTildesReplacement):
            somethingWrong("junkTildesReplacement");
            break;
        case typeof(ruleSet.lowerCaseApostropheWords):
            somethingWrong("lowerCaseApostropheWords");
            break;
        case typeof(ruleSet.lowerCaseWords):
            somethingWrong("lowerCaseWords");
            break;
        case typeof(ruleSet.lowerCaseWordsEndWords):
            somethingWrong("lowerCaseWordsEndWords");
            break;
        case typeof(ruleSet.mirroredGuillemets):
            somethingWrong("mirroredGuillemets");
            break;
        case typeof(ruleSet.numberAbbreviation):
            somethingWrong("numberAbbreviation");
            break;
        case typeof(ruleSet.punctuationCharacters):
            somethingWrong("punctuationCharacters");
            break;
        case typeof(ruleSet.roleWords):
            somethingWrong("roleWords");
            break;
        case typeof(ruleSet.spaceAfterPunctuation):
            somethingWrong("spaceAfterPunctuation");
            break;
        case typeof(ruleSet.spaceBeforePunctuation):
            somethingWrong("spaceBeforePunctuation");
            break;
        case typeof(ruleSet.spaceChar):
            somethingWrong("spaceChar");
            break;
        case typeof(ruleSet.sentenceEndingPunctuation):
            somethingWrong("sentenceEndingPunctuation");
            break;
        case typeof(ruleSet.usesRomanNumerals):
            somethingWrong("usesRomanNumerals");
            break;
        case typeof(ruleSet.wordForBox):
            somethingWrong("wordForBox");
            break;
        case typeof(ruleSet.wordForDisc):
            somethingWrong("wordForDisc");
            break;
        case typeof(ruleSet.wordForVolumeA):
            somethingWrong("wordForVolumeA");
            break;
        case typeof(ruleSet.wordForVolumeB):
            somethingWrong("wordForVolumeB");
            break;
        case typeof(ruleSet.wordForParts):
            somethingWrong("wordForParts");
            break;
        case typeof(ruleSet.wordForPart):
            somethingWrong("wordForPart");
            break;
        case typeof(ruleSet.wordForPt):
            somethingWrong("wordForPt");
            break;
        case typeof(ruleSet.romanWordsLower):
            somethingWrong("romanWordsLower");
            break;
        case typeof(ruleSet.romanWordsNormal):
            somethingWrong("romanWordsNormal");
            break;
        default:
            return true;
    }
}
/*************************************************************************************
 * Function: findBasicErrors ( language ruleset object, GC group type,               *
 *                             track number / event number, string to be processed ) *
 *                                                                                   *
 * Stage 1 of Guess Case, checks for basic problems in the input text, fixes what it *
 * can, warns about what it can't.                                                   *
 *************************************************************************************/
function findBasicErrors(ruleSet, type, number, stringBeingFixed, mode, keepUpperCased) {
    /* ---------------------------------------------------------------------*/
    /* Convert HTML entities into text.                                     */
    /* ---------------------------------------------------------------------*/
    stringBeingFixed = $(document.createElement("textarea")).html(stringBeingFixed.replace("<","&lt;")
                                                                                  .replace(">","&gt;")
                                                                                  .replace("&","&#38;"))
                                                                                  .text()
                                                                                  .replace("&lt;","<")
                                                                                  .replace("&gt;",">")
                                                                                  .replace("&#38;","&");
    /* ---------------------------------------------------------------------*/
    /* Replace "?" titles early.  (We change them later anyhow, but 
    /* if we leave it til then, they'll bomb out some of the replacements
    /* between here and there.
    /* ---------------------------------------------------------------------*/
    stringBeingFixed = stringBeingFixed.replace(/^\?+$/,"unknown");
    /* ---------------------------------------------------------------------*/
    /* Standardize some punctuation.                                        */
    /* ---------------------------------------------------------------------*/
    stringBeingFixed = stringBeingFixed.replace(/([^\.])\.\.\s/g, "$1. ")  // doubled periods
                                       .replace(/\s\.\.([^\.])/g, " .$1")  // doubled periods
                                       .replace(/\.{4,}/g, "...")  // 4+ periods
                                       .replace(/<</g, "«") // guilemets
                                       .replace(/>>/g, "»") // guilemets
                                       .replace(/\[\.\s?\]/g,"") // bracketed period
                                       .replace(/\,{1,}/g,",") // Remove extra commas when more than one are adjacent to each other
                                       .replace(/\-{1,}/g,"-") // Remove extra hyphens when more than one are adjacent to each other
                                       .replace(/\s?[\+#\\\*]\*?$/,"") // Remove trailing *, **, \, +, and # (Normally used for bonus or other note info)
                                       .replace(/\.\s?(aac|ape|fla|flac|mp3|ogg|shn|wav)$/,""); // Remove file types that might make it into the string
    if (ruleSet.punctuationCharacters.match("…") !== "null") {  // Replace ... with elipses (if used by the language).
        stringBeingFixed = stringBeingFixed.replace(/(\.){3}/g, "…");
    }
    for (var hyphenTypes in ruleSet.junkHyphens) {  // hyphens and dashes
        if (ruleSet.junkHyphens.hasOwnProperty(hyphenTypes)) {
            stringBeingFixed = stringBeingFixed.replace(new RegExp(ruleSet.junkHyphens[hyphenTypes], "g"),ruleSet.junkHyphensReplacement);
        }
    }
    for (var tildaTypes in ruleSet.junkTildes) {  // tildes
        if (ruleSet.junkTildes.hasOwnProperty(tildaTypes)) {
            stringBeingFixed = stringBeingFixed.replace(new RegExp(ruleSet.junkTildes[tildaTypes], "g"),ruleSet.junkTildesReplacement);
        }
    }
    var changePunctuation = function(p1) {
        switch (p1) {
            case "’":      // apostrophes and primes
            case "ʼ":
            case "ʻ":
            case "ˮ":
            case "՚":
            case "′":
            case "´":
            case "‘":
            case "’":
            case "‛":
            case "`":
            case "″":
            case "‴":
            case "⁗":
            case "ʹ":
            case "ʺ":
                return "'";
            case "\u2329":  // See http://www.unicode.org/charts/PDF/U2300.pdf notes
            case "\u27E8":
                return "‹";
            case "\u232A":  // See http://www.unicode.org/charts/PDF/U2300.pdf notes
            case "\u27E9":
                return "›";
            case "\u02D0":
            case "\u2236":
            case "\uFF1A":
            case "\u05C3":
            case "：":
                return ":";
            case "․":
                return ".";
            case "⁄":
                return "/";
            case "\u01C3":  // exclaimation points
            case "！":
                return "!";
            case "\uFF1F":  // question marks
            case "\u2E2E":
            case "？":
                return "?";
            case "；":      // Fullwidth semi-colon
                return ";";
            case "\u00B4":  // acute accent
            case "\u2018":  // single quotation marks
            case "\u2019":
            case "\u201A":
            case "\u201B":
                return "'";
            case "\u201C":  // double quotation marks
            case "\u201D":
            case "\u201E":
            case "\u201F":
                return '"';
            case " ":       // Space (matched by \s)
            case "_":       // Underscore
            case "\u00A0":  // No-break space (matched by \s except in IE7 and earlier, which failed to include this space in \s.)
            case "\u0009":  // Tab (matched by \s except in IE7 and earlier, which failed to include this space in \s.)
            case "\u2000":  // En quad (matched by \s except in IE7 and earlier, which failed to include this space in \s.)
            case "\u2001":  // Em quad (matched by \s except in IE7 and earlier, which failed to include this space in \s.)
            case "\u2002":  // En space (matched by \s except in IE7 and earlier, which failed to include this space in \s.)
            case "\u2003":  // Em space (matched by \s except in IE7 and earlier, which failed to include this space in \s.)
            case "\u2004":  // Three-per-em space (matched by \s except in IE7 and earlier, which failed to include this space in \s.)
            case "\u2005":  // Four-per-em space (matched by \s except in IE7 and earlier, which failed to include this space in \s.)
            case "\u2006":  // Six-per-em space (matched by \s except in IE7 and earlier, which failed to include this space in \s.)
            case "\u2007":  // Figure space (matched by \s except in IE7 and earlier, which failed to include this space in \s.)
            case "\u2008":  // Punctuation space (matched by \s except in IE7 and earlier, which failed to include this space in \s.)
            case "\u2009":  // Thin space (matched by \s except in IE7 and earlier, which failed to include this space in \s.)
            case "\u180E":  // Mongolian vowel separator (matched by \s except in IE7 and earlier, which failed to include this space in \s.)
            case "\u200A":  // Hair space (matched by \s except in IE7 and earlier, which failed to include this space in \s.)
            case "\u2028":  // Line separator (matched by \s except in IE7 and earlier, which failed to include this space in \s.)
            case "\u2029":  // Paragraph separator (matched by \s except in IE7 and earlier, which failed to include this space in \s.)
            case "\u202F":  // Narrow no-break space (matched by \s except in IE7 and earlier, which failed to include this space in \s.)
            case "\u205F":  // Medium mathematical space (matched by \s except in IE7 and earlier, which failed to include this space in \s.)
            case "\u3000":  // Ideographic space (matched by \s except in IE7 and earlier, which failed to include this space in \s.)
            case "\u1680":  // Ogham space mark (matched by \s except in IE7 and earlier, which failed to include this space in \s.)
            case "\u2420":  // Symbol for space
            case "\u303F":  // Ideographic Half-Full Space
                return " ";
            case "﴾":
            case "（":      // Fullwidth (
                return " (";
            case "﴿":
            case "）":      // Fullwidth )
                return ")";
            case "［":      // Fullwidth [
                return " [";
            case "］":      // Fullwidth ]
                return "]";
            case "[.]":   // Bracketed period
            case "[ .]":
            case "[. ]":
            case "[ . ]":
            case "\u000A":  // Line feed (matched by \s except in IE7 and earlier, which failed to include this space in \s.)
            case "\u000B":  // Vertical tab (matched by \s except in IE7 and earlier, which failed to include this space in \s.)
            case "\u000C":  // Form feed (matched by \s except in IE7 and earlier, which failed to include this space in \s.)
            case "\u000D":  // Carriage return (matched by \s except in IE7 and earlier, which failed to include this space in \s.)
            case "\u200C": // Zero-width non-joiner
            case "\u200D": // Zero-width joiner
            case "\u2060": // Word joiner ("a zero width non-breaking space(only) intended for disambiguation of functions for byte order mark ")
            case "\uFEFF": // Zero-width no-break space
                return "";
            case "Ⅰ"    : return "I";
            case "Ⅱ"    : return "II";
            case "Ⅲ"    : return "III";
            case "Ⅳ"    : return "IV";
            case "Ⅴ"    : return "V";
            case "Ⅵ"    : return "VI";
            case "Ⅶ"    : return "VII";
            case "Ⅷ"    : return "VIII";
            case "Ⅸ"    : return "IX";
            case "Ⅹ"    : return "X";
            case "Ⅺ"    : return "XI";
            case "Ⅻ"    : return "XII";
            case "Ⅼ"    : return "L";
            case "Ⅽ"    : return "C";
            case "Ⅾ"    : return "D";
            case "Ⅿ"    : return "M";
            case "ⅰ"    : return "i";
            case "ⅱ"    : return "ii";
            case "ⅲ"    : return "iii";
            case "ⅳ"    : return "iv";
            case "ⅴ"    : return "v";
            case "ⅵ"    : return "vi";
            case "ⅶ"    : return "vii";
            case "ⅷ"    : return "viii";
            case "ⅸ"    : return "ix";
            case "ⅹ"    : return "x";
            case "ⅺ"    : return "xi";
            case "ⅻ"    : return "xii";
            case "ⅼ"    : return "l";
            case "ⅽ"    : return "c";
            case "ⅾ"    : return "d";
            case "ⅿ"    : return "m";
            case "℉"    : return "°F";
            case "℃"    : return "°C";
            case "µ"    : return "μ";
            default:
                return p1;
        }
    },
        strLen = stringBeingFixed.length,
        newString = [];
    do {  // While not punctuation, this also is used as a useful place to decompose certain presentational Unicode forms, such as precomposed Roman numerals.
        newString.push(stringBeingFixed[strLen-1].replace(/[’ʼʻˮ՚′´﴾﴿‘’‛`″‴⁗ʹʺ℉µ℃ⅠⅡⅢⅣⅤⅥⅦⅧⅨⅪⅫⅬⅭⅮⅯⅰⅱⅲⅳⅴⅵⅶⅷⅸⅹⅺⅻⅼⅽⅿⅾ\u003E\u00A0\u0009\u2000-\u2009\u180E\u200A\u2028\u2029\u202F\u205F\u3000\u1680\u000A-\u000D\u232A\u27E8\u003C․\u02D0\u2236\uFF1A\u05C3：\⁄\u01C3！\uFF1F\u2E2E？；\u00B4\u2018-\u201F\u200C\U200D\u2060\u303F\u005F\］\［\（\）\s\uFEFF\27E9\2329]/g, changePunctuation));
    } while (--strLen);
    stringBeingFixed = newString.reverse()
                                .join("")
                                .replace(/\-{1,}/g,"-") // Remove extra hyphens when more than one are adjacent to each other
                                .replace(/\'{2,}/g,'"') // Swap doubled+ ' apostrophe for a single " apostrophe (509 in the English database!)
                                .replace(/\s?[\+#\\\*]\*?$/,"") // Remove trailing *, **, \, +, and # (Normally used for bonus or other note info)
                                .replace(/\.\s?(aac|ape|fla|flac|mp3|ogg|shn|wav)$/,"") // Remove file types that might make it into the string
                                .replace(new RegExp("([" + allFoldableChars + "]\/|\/[" + allFoldableChars + "])", "g"),  // Protect non-separator /'s from our screwing up the spacing
                                    function (str, p1) {
                                        return p1.replace("/","\uDBC0\uDC01");  // U+100001 is guaranteed to never be a valid character in *anything*
                                    }
                                );
    /* ---------------------------------------------------------------------*/
    /* Standardize spellings of some words.                                 */
    /* ---------------------------------------------------------------------*/
    if (new RegExp("w\\/\\s|\\s\\/w").test(stringBeingFixed)) {
        storeError(text.inclFeat, type, number);
    }
    stringBeingFixed = stringBeingFixed.replace(/(?:w\/\s|\s\/w)/gi, " feat. ") // Foo w/Tom Bar → Foo feat. Tom Bar
                                       .replace(/(?:re?(?:\-|\‐)?mi?x)(e?(?:s|d))?/gi, " remix$1 ")
                                       .replace(/(?:re-?make)(s)?/gi, " remake$1 ")
                                       .replace(/(?:re[\‐\-]?edit)(s|ed)?/gi, " re-edit$1 ")
                                       .replace(/\bext(en)?d?(et|ed)?\.?(?:\b|$)/gi, " extended ")
                                       .replace(/(?:\b)trad\.?/gi, " traditional ")
                                       .replace(/(\b|^|\()a\s?(?:\.?|\/)?(?:\\|\s)?\s?k\s?(?:\.?|\/)(?:\\|\s)?\s?a\s?(?:\.|\s|$)/gi, "$1a.k.a. ") // aka but not aka'aar
                                       .replace(/(?:\s|^)ver\(?:?\.?(?:s)\)?\.?(?:\s|$)/gi, " versions ")
                                       .replace(/(?:\b|^)ver\.?(?:\s|\)|$)/gi, " version ")
                                       .replace(/(?:\b|^)f(?:ea|eat|t|\.)(?:uring)?[\:\.]?(?:\s|\))(?:\s?[\-\-])?/gi, " feat. ")
                                       .replace(/(\s|^|\()(7|10|12)(?:\s?|\s\")\'\'/g,' $2" ') // 12'' and 12 " → 12"
                                       .replace(/(\s|^|(\())(7|10|12)(\s|\-|\‐)?in(ch)?(\s|$)/gi,' $1$3" ') // 12in → 12"
                                       .replace(/(?:\b|^)u\.?\s?s\.?\s?a\.?(?:\s|$)/gi," U.S.A. ")
                                       .replace(/(?:\b|^)u\.?k\.?(?:\s|$)/gi," U.K. ")
                                       .replace(/(?:\b|^)u\.?\s?s\.?\s?s\.?\s?r\.?(?:\s|$)/gi," U.S.S.R. ")
                                       .replace(/(?:\b|^)p\.?\s?s\.?(?:\s|$)/gi," P.S. ")
                                       .replace(/(?:\b|^)alt(?:ern)?[\.']?(?:\s|$)/gi," alternate ")
                                       .replace(/(?:\b|^|\"|\()instr?\.?(?:\s|$|\)|\")/gi," instrumental ")
                                       .replace(/(?:\b|^)ori?g\.?(inal)?(?:\s|$)/gi," original ")
                                       .replace(/(?:\b|^)pres\.?(?:\s|$)/gi," presents ")
                                       .replace(/(?:\b|^)v(?:ersu)?r?s\.?(?:\s|$)/gi," vs. ")
                                       .replace(/(?:\b|^)\bentr[èée\s\'\-|\‐]{0,2}act[èée]?/gi,"Entr'acte") // Entr'acte
                                       .replace(/\s(?:\‐|\-)\>\s/g," / ");  // Normally > and -> when surrounded by spaces indicates MultipleTracks.
    /* ---------------------------------------------------------------------*/
    /* Fix extraneous spaces before punctuation marks.                      */
    /* ---------------------------------------------------------------------*/
    stringBeingFixed = stringBeingFixed.replace(new RegExp('\\s' + ruleSet.punctuationCharacters, "g"),
    function(str, p1) {
        return jQuery.trim(p1);
    });
    /* ---------------------------------------------------------------------*/
    /* Fix missing spaces before punctuation marks.                         */
    /* ---------------------------------------------------------------------*/
    stringBeingFixed = stringBeingFixed.replace(/–(\d+)/g,"\uDBC0\uDCFD$1") // Preserve spacing around number ranges
                                       .replace(/(\d+)–/g,"$1\uDBC0\uDCFD") // Preserve spacing around number ranges
                                       .replace(/\-(\d+)/g,"\uDBC0\uDCFE$1") // Preserve spacing around number ranges
                                       .replace(/(\d+)\-/g,"$1\uDBC0\uDCFE") // Preserve spacing around number ranges
                                       .replace(/\s…/g,"\uDBC0\uDCFF…") // Preserve spacing around ellipses
                                       .replace(/…\s/g,"…\uDBC0\uDCFF") // Preserve spacing around number ranges
                                       .replace(new RegExp(ruleSet.spaceBeforePunctuation, "g"), " $1")
                                       .replace(/\uDBC0\uDCFD/g,"–") // Preserve spacing around number ranges
                                       .replace(/\uDBC0\uDCFE/g,"-") // Preserve spacing around number ranges
                                       .replace(/\uDBC0\uDCFF/g," "); // Preserve spacing around elipses
    /* ---------------------------------------------------------------------*/
    /* Fix missing spaces after punctuation marks.                          */
    /* ---------------------------------------------------------------------*/
    stringBeingFixed = stringBeingFixed.replace(new RegExp(ruleSet.spaceAfterPunctuation + "([\\w\\.]+\\s)?", "g"),
        function (str, p1, p2) {
            if (typeof(p2) !== "undefined") {  // Don't add spaces in 'good' acronyms - they'd be fixed later on, but we'd have no way to catch "U.S.A. Y.M.C.A."
                return p1 + p2;
            } else {
                return p1 + " ";
            }
        }
    );
    /* ---------------------------------------------------------------------*/
    /* Remove redundant whitespace.                                         */
    /* ---------------------------------------------------------------------*/
    stringBeingFixed = jQuery.trim(stringBeingFixed.replace(/\s+/g, " "));
    /* ---------------------------------------------------------------------*/
    /* Find and store positions for any all CAPS words.                     */
    /* This is not ruleset dependant, so it must break the separation       */
    /* between stages 1 and 2.                                              */
    /* ---------------------------------------------------------------------*/
    if (keepUpperCased) {
        AllCapsPositions = stringBeingFixed.split(" ");
        for (var n in AllCapsPositions) {
            if (AllCapsPositions[n].toMusicBrainzUpperCase() == AllCapsPositions[n]) {
                AllCapsPositions[n] = true;
            } else {
                AllCapsPositions[n] = false;
            }
        }
    }
    /* ---------------------------------------------------------------------*/
    /* Make the input string all lowercase.                                 */
    /* ---------------------------------------------------------------------*/
    stringBeingFixed = stringBeingFixed.toMusicBrainzLowerCase();
    /* ---------------------------------------------------------------------*/
    /* Fix the spacing of number ranges.                                    */
    /* ---------------------------------------------------------------------*/
    stringBeingFixed = stringBeingFixed.replace(/\b(\d+)[\-|\‐|\–]{1,3}(\d+)\b/g,"$1"+ruleSet.dashRange+"$2");
    /* ---------------------------------------------------------------------*/
    /* Fix the spacing and dash type of phone numbers.                      */
    /* ---------------------------------------------------------------------*/
    stringBeingFixed = stringBeingFixed.replace(/(\(?)(\d{3})(\))?\s?(?:.\s)?(\d{3})(?:\s?.\s?)(\d{4})\b/g, // North American phone numbers
        function(str,p1,p2,p3,p4,p5) {
            return p1+p2+p3+" "+p4+ruleSet.dashFigure+p5;
        }
    );
    /* ---------------------------------------------------------------------*/
    /* Fix the spacing and dash type around quotation marks.                */
    /* ---------------------------------------------------------------------*/
    stringBeingFixed = stringBeingFixed.replace(/([\-\‐\―])?(\s?\"\s?)/g,
        function(str,p1,p2) {
            if (null !== p1 && typeof(p1) !== "undefined" && p1 !== " " && p1 !== "") {
                return " "+ruleSet.dashQuotation+' "';
            } else {
                return p2;
            }
        }
    );
    stringBeingFixed = stringBeingFixed.replace(/\s\s/g," ");
    /* ---------------------------------------------------------------------*/
    /* Fix the spacing and punctuation of times.                            */
    /* ---------------------------------------------------------------------*/
    stringBeingFixed = stringBeingFixed.replace(/\s(\d{1,2})[:\.]\s(\d{1,2})\s?(a|p)\.?m\.?/gi,
        function(str,p1,p2,p3) {
            return " "+p1+":"+p2+" "+p3.toMusicBrainzLowerCase()+".m.";
        }
    );
    /* ---------------------------------------------------------------------*/
    /* Fix commonly misspelled words.                                       */
    /* ---------------------------------------------------------------------*/
    var misspelledWords = "(acaroling|absense|acapela|acapella|accapela|acapella|acappella|acappela|accappella|occapella|a\\scapella|" +
                           "accoustic|accordian|adagioallegro|adago|adiago|agagio|adantino|afroamerican|agression|agressive|airbourne|" +
                           "aligator|alladin|allergro|allgro|alegro|allogro|allego|allegetto|alegretto|aleegretto|allegreto|allamerican|" +
                           "allien|allive|alnaafiysh|aminor|andate|adante|andate|andatne|annointed|artifical|asai|attaca|bachorchester|" +
                           "ballbreaker|bangabang|bbbbaby|beautifull|beatiful|bebopalula|begining|belive|beleive|besame|browneyed|bflat|" +
                           "bibbidibobbidiboo|bizzare|bouree|bourree|brazillian|brillant|buisness|burried|buhleaguer|bmv|bmw|bwm|wbv|bvw|" +
                           "cafe|carnaval|carribean|chickaboom|chrismas|clavierubung|clavierübung|comming|concious|cont\\'d|concierto|" +
                           "contabile|contabile|copywrite|crucifiction|cflat|csharp|desparate|\\'?divertimento\\'\\'?|eflat|eightyone|" +
                           "eightytwo|eightythree|eightyfour|eightyfive|eightysix|eightyseven|eightyeight|eightynine|esharp|embracable|" +
                           "enviromental|enlightment|espanolas|etoiles|etude|etudes|etudestableaux|étudestableaux|etudetableau|etudetableaux|" +
                           "étudetableaux|everthing|exerpt|existance|facist|fantaisieimpromptu|fantasiestucke|fiftyfifty|fiftysecond|fiftyone|" +
                           "fiftytwo|fiftythree|fiftyfour|fiftyfive|fiftysix|fiftyseven|fiftyeight|fiftynine|finacial|fmoll|fourty|fortyone|" +
                           "fortytwo|fortythree|fortyfour|fortyfive|fortysix|fortyseven|fortyeight|fortynine|fourtyone|fourtytwo|fourtythree|" +
                           "fourtyfour|fourtyfive|fourtysix|fourtyseven|fourtyeight|fourtynine|fflat|fictiondouble|francais|francaise|frandance|" +
                           "fsharp|ganster|ghandi|graziozo|guiness|gymnopedie|gymnopedies|happend|happines|hvw|im|inbetween|independance|" +
                           "independant|indestructable|instrmental|instumental|intrumental|intango|intencity|intermezo|juxtapozed|kinderscenen|" +
                           "l\\'apresmidi|l\\'aprèsmidi|l\\'arlesienne|largetto|lefthanded|lovin|manysplendored|meastoso|maetoso|minuett|menuet|" +
                           "minutetto|minuetto|mariage|marmelade|martininthefields|metamorphoses|miserables|mezzosoprano|missisippi|missle|movt|" +
                           "mov|mvt|n\\'estce|ntrance|ninetyone|ninetytwo|ninetythree|ninetyfour|ninetyfive|ninetysix|ninetyseven|ninetyeight|" +
                           "ninetynine|nothern|oppus|orchestrasymphony|orchetsra|orginal|outbloodyrageous|overturefantasy|perfomance|philarmonic|" +
                           "pocco|pokemon|pollaca|polonaisefantaisie|prarie|pronounciation|qball|quassi|r\\'n\\'b|r\\'n\\'r|" +
                           "radiosymphonieorchester|rambunkshush|rebopboombam|rednosed|rehersal|remeber|rememberance|rendezvu|rendevous|" +
                           "resurection|ressurection|rimskykorsakov|rockafella|rondoburleske|roneau|satelite|saxaphone|schoneberg|selffulfilling|" +
                           "seperate|seperation|sestenuto|seventyone|seventytwo|seventythree|seventyfour|seventyfive|seventysix|seventyseven|" +
                           "seventyeight|seventynine|sherzo|sixtyone|sixtytwo|sixtythree|sixtyfour|sixtyfive|sixtysix|sixtyseven|sixtyeight|" +
                           "sixtynine|soley|someting|somwhere|sonate|sould|strat|stratfordonguy|strenght|suprise|symphoy|tennesee|tennesse|" +
                           "tenessee|theif|ther|thirtyone|thirtytwo|thirtythree|thirtyfour|thirtyfive|thirtysix|thirtyseven|thirtyeight|" +
                           "thirtynine|throught|tiltawhirl|tocatta|tommorow|tommorrow|tounge|trampolene|trancendental|transcendance|tremelo|" +
                           "turangalîlasymphonie|twelth|twentyone|twentytwo|twentythree|twentyfour|twentyfive|twentysix|twentyseven|twentyeight|" +
                           "twentynine|unforgetable|unkown|vallecillogray|variatio|vengence|vicace|viscious|villian|voulezvous|welltempered|wholy|" +
                           "withdrawl|wonderfull|wunderhornlieder|yerself|youself|zauberflote|p'yongyang|pyongyang)",
        fixAndReportMisspelling = function(badWord, goodWord, goodSpelling) {
            if (typeof(goodSpelling) === "undefined") {
                goodSpelling = goodWord;
            }
        storeError(text.CommonlyMisspelled+" "+badWord+" → "+goodSpelling, type, number);
        return goodWord;
    };
    stringBeingFixed = stringBeingFixed.replace(new RegExp("\\b" + misspelledWords + "\\b","gi"),
        function (str, p1) {
            switch (p1) {
                /* Nothing here that needs to become 2+ words should - it will break "keep all caps" option.         */
                /* Add them here without the space, we'll fix that after the keep all caps handled.  Putting it      */
                /* here, though, the editor gets a heads up warning about the correction.                            */
                case "acaroling"         : return fixAndReportMisspelling(p1,"a-caroling"); 
                case "absense"           : return fixAndReportMisspelling(p1,"absence");           // 11
                case "acapela"           :
                case "acapella"          :                                                         // 19
                case "accapela"          :
                case "acapella"          :
                case "acappella"         :
                case "acappela"          :
                case "accappella"        :
                case "occapella"         :                                                         // 12
                case "a capella"         : return fixAndReportMisspelling(p1,"acappella","a cappella");
                case "accoustic"         : return fixAndReportMisspelling(p1,"acoustic");          // 18
                case "accordian"         : return fixAndReportMisspelling(p1,"accordion");         // 28
                case "adagioallegro"     : return fixAndReportMisspelling(p1,"adagioallegro","adagio allegro"); // 19
                case "adago"             :                                                      
                case "adiago"            :
                case "agagio"            : return fixAndReportMisspelling(p1,"adagio");
                case "adantino"          : return fixAndReportMisspelling(p1,"andantino");
                case "afroamerican"      : return fixAndReportMisspelling(p1,"afro-american");     // 35
                case "agression"         : return fixAndReportMisspelling(p1,"aggression");        // 21
                case "agressive"         : return fixAndReportMisspelling(p1,"aggressive");        // 25
                case "airbourne"         : return fixAndReportMisspelling(p1,"airborne");          // 16
                case "aligator"          : return fixAndReportMisspelling(p1,"alligator");         // 35
                case "alladin"           : return fixAndReportMisspelling(p1,"aladdin  ");         // 12
                case "allergro"          :
                case "allgro"            :
                case "alegro"            :                                                         // 15
                case "allogro"           :
                case "allego"            : return fixAndReportMisspelling(p1,"allegro");           // 25
                case "allegetto"         :
                case "alegretto"         :                                                         // 11
                case "aleegretto"        :
                case "allegreto"         : return fixAndReportMisspelling(p1,"allegretto");        // 12
                case "allamerican"       : return fixAndReportMisspelling(p1,"all-american");      // 23
                case "allien"            : return fixAndReportMisspelling(p1,"alien");             // 30
                case "allive"            : return fixAndReportMisspelling(p1,"alive");
                case "alnaafiysh"        : return fixAndReportMisspelling(p1,"al-naafiysh");       // 24 (song title by Hashim)
                case "aminor"            : return fixAndReportMisspelling(p1,"A-minor");           // 25
                case "andate"            :
                case "adante"            :                                                         // 48
                case "andate"            :                                                         // 12
                case "andatne"           : return fixAndReportMisspelling(p1,"andante");
                case "annointed"         : return fixAndReportMisspelling(p1,"anointed");          // 11
                case "artifical"         : return fixAndReportMisspelling(p1,"artificial");        // 20
                case "asai"              : return fixAndReportMisspelling(p1,"assai");
                case "attaca"            : return fixAndReportMisspelling(p1,"attacca");           // 15
                case "bachorchester"     : return fixAndReportMisspelling(p1,"bach-orchester"); 
                case "ballbreaker"       : return fixAndReportMisspelling(p1,"ball-breaker"); 
                case "bangabang"         : return fixAndReportMisspelling(p1,"bang-a-bang"); 
                case "bbbbaby"           : return fixAndReportMisspelling(p1,"b-b-b-baby"); 
                case "beautifull"        :
                case "beatiful"          : return fixAndReportMisspelling(p1,"beautiful");         // 12
                case "bebopalula"        : return fixAndReportMisspelling(p1,"be-bop-a-lula"); 
                case "begining"          : return fixAndReportMisspelling(p1,"beginning");         // 23
                case "belive"            : 
                case "beleive"           : return fixAndReportMisspelling(p1,"believe");           // 12
                case "besame"            : return fixAndReportMisspelling(p1,"bésame");
                case "browneyed"         : return fixAndReportMisspelling(p1,"brown-eyed");
                case "bflat"             : return fixAndReportMisspelling(p1,"B-flat");            // 3699 in database!
                case "bibbidibobbidiboo" : return fixAndReportMisspelling(p1,"bibbidi-bobbidi-boo"); 
                case "bizzare"           : return fixAndReportMisspelling(p1,"bizarre");           // 30
                case "bouree"            :                                                         // 74
                case "bourree"           : return fixAndReportMisspelling(p1,"bourrée");           // 87
                case "brazillian"        : return fixAndReportMisspelling(p1,"brazilian"); 
                case "brillant"          : return fixAndReportMisspelling(p1,"brilliant");         // 11
                case "buisness"          : return fixAndReportMisspelling(p1,"business");          // 11
                case "burried"           : return fixAndReportMisspelling(p1,"buried");            // 12
                case "buhleaguer"        : return fixAndReportMisspelling(p1,"bu$hleaguer"); 
                case "bmv"               :
                case "bmw"               :                                                         // Every instance in the db related to Bach, not the car.
                case "bwm"               :
                case "wbv"               :
                case "bvw"               : return fixAndReportMisspelling(p1,"BWV");        
                case "cafe"              : return fixAndReportMisspelling(p1,"café");
                case "carnaval"          : return fixAndReportMisspelling(p1,"carnival");          // 328
                case "carribean"         : return fixAndReportMisspelling(p1,"caribbean");         // 35
                case "chickaboom"        : return fixAndReportMisspelling(p1,"chick-a-boom"); 
                case "chrismas"          : return fixAndReportMisspelling(p1,"christmas");         // 40
                case "clavierubung"      : 
                case "clavierübung"      : return fixAndReportMisspelling(p1,"clavier-übung"); 
                case "comming"           : return fixAndReportMisspelling(p1,"coming");            // 56
                case "concious"          : return fixAndReportMisspelling(p1,"conscious");         // 20
                case "cont'd"            : return fixAndReportMisspelling(p1,"continued");         // AbbreviationStyle, 49 in db
                case "concierto"         : return fixAndReportMisspelling(p1,"concerto");          // 190 in db
                case "contabile"         :
                case "contabile"         : return fixAndReportMisspelling(p1,"cantabile");
                case "copywrite"         : return fixAndReportMisspelling(p1,"copyright");         // 23
                case "crucifiction"      : return fixAndReportMisspelling(p1,"crucifixion");       // 29
                case "cflat"             : return fixAndReportMisspelling(p1,"C-flat");
                case "csharp"            : return fixAndReportMisspelling(p1,"C-sharp");
                case "desparate"         : return fixAndReportMisspelling(p1,"desperate");         // 14
                case "'divertimento''"   :
                case "'divertimento'"    : return fixAndReportMisspelling(p1,"divertimento");      // 11
                case "eflat"             : return fixAndReportMisspelling(p1,"E-flat");            // 3943 in database!
                case "eightyone"         : return fixAndReportMisspelling(p1,"eighty-one"); 
                case "eightytwo"         : return fixAndReportMisspelling(p1,"eighty-two"); 
                case "eightythree"       : return fixAndReportMisspelling(p1,"eighty-three"); 
                case "eightyfour"        : return fixAndReportMisspelling(p1,"eighty-four"); 
                case "eightyfive"        : return fixAndReportMisspelling(p1,"eighty-five"); 
                case "eightysix"         : return fixAndReportMisspelling(p1,"eighty-six"); 
                case "eightyseven"       : return fixAndReportMisspelling(p1,"eighty-seven"); 
                case "eightyeight"       : return fixAndReportMisspelling(p1,"eighty-eight"); 
                case "eightynine"        : return fixAndReportMisspelling(p1,"eighty-nine"); 
                case "esharp"            : return fixAndReportMisspelling(p1,"E-sharp");
                case "embracable"        : return fixAndReportMisspelling(p1,"embraceable"); 
                case "enviromental"      : return fixAndReportMisspelling(p1,"environmental");     // 15
                case "enlightment"       : return fixAndReportMisspelling(p1,"enlightenment"); 
                case "espanolas"         : return fixAndReportMisspelling(p1,"españolas"); 
                case "etoiles"           : return fixAndReportMisspelling(p1,"étoiles");
                case "etude"             : return fixAndReportMisspelling(p1,"étude");             // 725 in database
                case "etudes"            : return fixAndReportMisspelling(p1,"études");            // 293
                case "etudestableaux"    : 
                case "étudestableaux"    : return fixAndReportMisspelling(p1,"études-tableaux"); 
                case "etudetableau"      : 
                case "etudetableaux"     : 
                case "étudetableaux"     : return fixAndReportMisspelling(p1,"étude-tableaux"); 
                case "everthing"         : return fixAndReportMisspelling(p1,"everything");        // 38
                case "exerpt"            : return fixAndReportMisspelling(p1,"excerpt");           // 20
                case "existance"         : return fixAndReportMisspelling(p1,"existence");         // 19
                case "facist"            : return fixAndReportMisspelling(p1,"fascist");           // 16
                case "fantaisieimpromptu": return fixAndReportMisspelling(p1,"fantaisie-impromptu"); 
                case "fantasiestucke"    : return fixAndReportMisspelling(p1,"fantasiestücke"); 
                case "fiftyfifty"        : return fixAndReportMisspelling(p1,"fifty-fifty"); 
                case "fiftysecond"       : return fixAndReportMisspelling(p1,"fifty-second"); 
                case "fiftyone"          : return fixAndReportMisspelling(p1,"fifty-one"); 
                case "fiftytwo"          : return fixAndReportMisspelling(p1,"fifty-two"); 
                case "fiftythree"        : return fixAndReportMisspelling(p1,"fifty-three"); 
                case "fiftyfour"         : return fixAndReportMisspelling(p1,"fifty-four"); 
                case "fiftyfive"         : return fixAndReportMisspelling(p1,"fifty-five"); 
                case "fiftysix"          : return fixAndReportMisspelling(p1,"fifty-six"); 
                case "fiftyseven"        : return fixAndReportMisspelling(p1,"fifty-seven"); 
                case "fiftyeight"        : return fixAndReportMisspelling(p1,"fifty-eight"); 
                case "fiftynine"         : return fixAndReportMisspelling(p1,"fifty-nine"); 
                case "finacial"          : return fixAndReportMisspelling(p1,"financial");         // 17
                case "fmoll"             : return fixAndReportMisspelling(p1,"f-Moll");            // 16
                case "fourty"            : return fixAndReportMisspelling(p1,"forty");             // 14
                case "fortyone"          : return fixAndReportMisspelling(p1,"forty-one"); 
                case "fortytwo"          : return fixAndReportMisspelling(p1,"forty-two"); 
                case "fortythree"        : return fixAndReportMisspelling(p1,"forty-three"); 
                case "fortyfour"         : return fixAndReportMisspelling(p1,"forty-four"); 
                case "fortyfive"         : return fixAndReportMisspelling(p1,"forty-five"); 
                case "fortysix"          : return fixAndReportMisspelling(p1,"forty-six"); 
                case "fortyseven"        : return fixAndReportMisspelling(p1,"forty-seven"); 
                case "fortyeight"        : return fixAndReportMisspelling(p1,"forty-eight"); 
                case "fortynine"         : return fixAndReportMisspelling(p1,"forty-nine"); 
                case "fourtyone"         : return fixAndReportMisspelling(p1,"forty-one"); 
                case "fourtytwo"         : return fixAndReportMisspelling(p1,"forty-two"); 
                case "fourtythree"       : return fixAndReportMisspelling(p1,"forty-three"); 
                case "fourtyfour"        : return fixAndReportMisspelling(p1,"forty-four"); 
                case "fourtyfive"        : return fixAndReportMisspelling(p1,"forty-five"); 
                case "fourtysix"         : return fixAndReportMisspelling(p1,"forty-six"); 
                case "fourtyseven"       : return fixAndReportMisspelling(p1,"forty-seven"); 
                case "fourtyeight"       : return fixAndReportMisspelling(p1,"forty-eight"); 
                case "fourtynine"        : return fixAndReportMisspelling(p1,"forty-nine"); 
                case "fflat"             : return fixAndReportMisspelling(p1,"F-flat");
                case "fictiondouble"     : return fixAndReportMisspelling(p1,"fictiondouble","fiction double");
                case "francais"          : return fixAndReportMisspelling(p1,"français");
                case "francaise"         : return fixAndReportMisspelling(p1,"française"); 
                case "frandance"         : return fixAndReportMisspelling(p1,"fran-dance"); 
                case "fsharp"            : return fixAndReportMisspelling(p1,"F-sharp");           // 627 in database
                case "ganster"           : return fixAndReportMisspelling(p1,"gangster");          // 11
                case "ghandi"            : return fixAndReportMisspelling(p1,"Gandhi");            // 17
                case "graziozo"          : return fixAndReportMisspelling(p1,"grazioso");
                case "guiness"           : return fixAndReportMisspelling(p1,"Guinness");          // 13
                case "gymnopedie"        : return fixAndReportMisspelling(p1,"gymnopédie"); 
                case "gymnopedies"       : return fixAndReportMisspelling(p1,"gymnopédies"); 
                case "happend"           : return fixAndReportMisspelling(p1,"happened");          // 16
                case "happines"          : return fixAndReportMisspelling(p1,"happiness");
                case "hvw"               : return fixAndReportMisspelling(p1,"HWV");
                case "im"                : return fixAndReportMisspelling(p1,"I'm");
                case "inbetween"         : return fixAndReportMisspelling(p1,"inbetween","in between"); // 136
                case "independance"      : return fixAndReportMisspelling(p1,"independence");      // 37
                case "independant"       : return fixAndReportMisspelling(p1,"independent");       // 16
                case "indestructable"    : return fixAndReportMisspelling(p1,"indestructible"); 
                case "instrmental"       : 
                case "instumental"       : 
                case "intrumental"       : return fixAndReportMisspelling(p1,"instrumental");      // 38
                case "intango"           : return fixAndReportMisspelling(p1,"in-tango"); 
                case "intencity"         : return fixAndReportMisspelling(p1,"intensity"); 
                case "intermezo"         : return fixAndReportMisspelling(p1,"intermezzo"); 
                case "juxtapozed"        : return fixAndReportMisspelling(p1,"juxtaposed"); 
                case "kinderscenen"      : return fixAndReportMisspelling(p1,"kinderszenen"); 
                case "l'apresmidi"       : 
                case "l'aprèsmidi"       : return fixAndReportMisspelling(p1,"l'après-midi"); 
                case "l'arlesienne"      : return fixAndReportMisspelling(p1,"l'arlésienne"); 
                case "largetto"          : return fixAndReportMisspelling(p1,"larghetto");
                case "lefthanded"        : return fixAndReportMisspelling(p1,"left-handed"); 
                case "lovin"             : return fixAndReportMisspelling(p1,"lovin'");            // 322
                case "manysplendored"    : return fixAndReportMisspelling(p1,"many-splendored"); 
                case "meastoso"          :
                case "maetoso"           : return fixAndReportMisspelling(p1,"maestoso");
                case "minuett"           :                                                         // 11
                case "menuet"            : return fixAndReportMisspelling(p1,"minuet");
                case "minutetto"         :                                                         // 14
                case "minuetto"          : return fixAndReportMisspelling(p1,"menuetto");
                case "mariage"           : return fixAndReportMisspelling(p1,"marriage");          // 25
                case "marmelade"         : return fixAndReportMisspelling(p1,"marmalade");         // 29
                case "martininthefields" : return fixAndReportMisspelling(p1,"Martin-in-the-Fields'"); // 39
                case "metamorphoses"     : return fixAndReportMisspelling(p1,"métamorphoses"); 
                case "miserables"        : return fixAndReportMisspelling(p1,"misérables"); 
                case "mezzosoprano"      : return fixAndReportMisspelling(p1,"mezzo-soprano'");
                case "missisippi"        : return fixAndReportMisspelling(p1,"Mississippi");       // 11
                case "missle"            : return fixAndReportMisspelling(p1,"missile");           // 14
                case "movt"              :                                                         // 25
                case "mov"               :
                case "mvt"               : return fixAndReportMisspelling(p1,"movement");
                case "n'estce"           : return fixAndReportMisspelling(p1,"n'est ce"); 
                case "ntrance"           : return fixAndReportMisspelling(p1,"n-trance"); 
                case "ninetyone"         : return fixAndReportMisspelling(p1,"ninety-one"); 
                case "ninetytwo"         : return fixAndReportMisspelling(p1,"ninety-two"); 
                case "ninetythree"       : return fixAndReportMisspelling(p1,"ninety-three"); 
                case "ninetyfour"        : return fixAndReportMisspelling(p1,"ninety-four"); 
                case "ninetyfive"        : return fixAndReportMisspelling(p1,"ninety-five"); 
                case "ninetysix"         : return fixAndReportMisspelling(p1,"ninety-six"); 
                case "ninetyseven"       : return fixAndReportMisspelling(p1,"ninety-seven"); 
                case "ninetyeight"       : return fixAndReportMisspelling(p1,"ninety-eight"); 
                case "ninetynine"        : return fixAndReportMisspelling(p1,"ninety-nine"); 
                case "nothern"           : return fixAndReportMisspelling(p1,"northern");          // 18
                case "oppus"             : return fixAndReportMisspelling(p1,"opus");
                case "orchestrasymphony" : return fixAndReportMisspelling(p1,"symphonyorchestra"); // 12
                case "orchetsra"         : return fixAndReportMisspelling(p1,"orchestra");
                case "orginal"           : return fixAndReportMisspelling(p1,"original");          // 71
                case "outbloodyrageous"  : return fixAndReportMisspelling(p1,"out-bloody-rageous"); 
                case "overturefantasy"   : return fixAndReportMisspelling(p1,"overturefantasy"); 
                case "perfomance"        : return fixAndReportMisspelling(p1,"performance");
                case "philarmonic"       : return fixAndReportMisspelling(p1,"philharmonic");
                case "pocco"             : return fixAndReportMisspelling(p1,"poco");
                case "pokemon"           : return fixAndReportMisspelling(p1,"pokémon");           // 27
                case "pollaca"           : return fixAndReportMisspelling(p1,"polacca");
                case "polonaisefantaisie": return fixAndReportMisspelling(p1,"polonaise-fantaisie"); 
                case "prarie"            : return fixAndReportMisspelling(p1,"prairie");           // 25
                case "pronounciation"    : return fixAndReportMisspelling(p1,"pronunciation");     // 15
                case "pyongyang"         :
                case "p'yongyang"        : return fixAndReportMisspelling(p1,"p'yŏngyang"); 
                case "qball"             : return fixAndReportMisspelling(p1,"q-ball"); 
                case "quassi"            : return fixAndReportMisspelling(p1,"quasi");
                case "r'n'b"             : return fixAndReportMisspelling(p1,"R&B");
                case "r'n'r"             : return fixAndReportMisspelling(p1,"Rock 'n' Roll"); 
                case "radiosymphonieorchester": return fixAndReportMisspelling(p1,"radio-symphonie-orchester"); 
                case "rambunkshush"      : return fixAndReportMisspelling(p1,"ram-bunk-shush");
                case "rebopboombam"      : return fixAndReportMisspelling(p1,"re-bop-boom-bam"); 
                case "rednosed"          : return fixAndReportMisspelling(p1,"red-nosed");         // Rudolf is in the top 20 mis-spelled English release words, with 376 in the db
                case "rehersal"          : return fixAndReportMisspelling(p1,"rehearsal");         // 32
                case "remeber"           : return fixAndReportMisspelling(p1,"remember");          // 29
                case "rememberance"      : return fixAndReportMisspelling(p1,"remembrance");       // 49
                case "rendezvu"          : return fixAndReportMisspelling(p1,"rendez-vu"); 
                case "rendevous"         : return fixAndReportMisspelling(p1,"rendezvous");        // 24
                case "resurection"       : 
                case "ressurection"      : return fixAndReportMisspelling(p1,"resurrection");      // 38
                case "rimskykorsakov"    : return fixAndReportMisspelling(p1,"rimsky-korsakov"); 
                case "rockafella"        : return fixAndReportMisspelling(p1,"rockafeller"); 
                case "rondoburleske"     : return fixAndReportMisspelling(p1,"rondo-burleske"); 
                case "roneau"            : return fixAndReportMisspelling(p1,"rondeau");
                case "satelite"          : return fixAndReportMisspelling(p1,"satellite");         // 28
                case "saxaphone"         : return fixAndReportMisspelling(p1,"saxophone");         // 15
                case "schoneberg"        : return fixAndReportMisspelling(p1,"schöneberg"); 
                case "selffulfilling"    : return fixAndReportMisspelling(p1,"self-fulfilling"); 
                case "seperate"          : return fixAndReportMisspelling(p1,"separate");          // 18
                case "seperation"        : return fixAndReportMisspelling(p1,"separation");        // 53
                case "sestenuto"         : return fixAndReportMisspelling(p1,"sostenuto");
                case "seventyone"        : return fixAndReportMisspelling(p1,"seventy-one"); 
                case "seventytwo"        : return fixAndReportMisspelling(p1,"seventy-two"); 
                case "seventythree"      : return fixAndReportMisspelling(p1,"seventy-three"); 
                case "seventyfour"       : return fixAndReportMisspelling(p1,"seventy-four"); 
                case "seventyfive"       : return fixAndReportMisspelling(p1,"seventy-five"); 
                case "seventysix"        : return fixAndReportMisspelling(p1,"seventy-six"); 
                case "seventyseven"      : return fixAndReportMisspelling(p1,"seventy-seven"); 
                case "seventyeight"      : return fixAndReportMisspelling(p1,"seventy-eight"); 
                case "seventynine"       : return fixAndReportMisspelling(p1,"seventy-nine"); 
                case "sherzo"            : return fixAndReportMisspelling(p1,"scherzo");
                case "sixtyone"          : return fixAndReportMisspelling(p1,"sixty-one"); 
                case "sixtytwo"          : return fixAndReportMisspelling(p1,"sixty-two"); 
                case "sixtythree"        : return fixAndReportMisspelling(p1,"sixty-three"); 
                case "sixtyfour"         : return fixAndReportMisspelling(p1,"sixty-four"); 
                case "sixtyfive"         : return fixAndReportMisspelling(p1,"sixty-five"); 
                case "sixtysix"          : return fixAndReportMisspelling(p1,"sixty-six"); 
                case "sixtyseven"        : return fixAndReportMisspelling(p1,"sixty-seven"); 
                case "sixtyeight"        : return fixAndReportMisspelling(p1,"sixty-eight"); 
                case "sixtynine"         : return fixAndReportMisspelling(p1,"sixty-nine"); 
                case "soley"             : return fixAndReportMisspelling(p1,"solely");            // 40
                case "someting"          : return fixAndReportMisspelling(p1,"something"); 
                case "somwhere"          : return fixAndReportMisspelling(p1,"somewhere");         // 11
                case "sonate"            : return fixAndReportMisspelling(p1,"sonata");            // 555 in the database
                case "sould"             : return fixAndReportMisspelling(p1,"should");            // 20
                case "strat"             : return fixAndReportMisspelling(p1,"start");             // 15
                case "stratfordonguy"    : return fixAndReportMisspelling(p1,"stratford-on-guy"); 
                case "strenght"          : return fixAndReportMisspelling(p1,"strength");          // 18
                case "suprise"           : return fixAndReportMisspelling(p1,"surprise");          // 36
                case "symphoy"           : return fixAndReportMisspelling(p1,"symphony");
                case "tennesee"          : 
                case "tennesse"          : 
                case "tenessee"          : return fixAndReportMisspelling(p1,"Tennessee");         // 18
                case "theif"             : return fixAndReportMisspelling(p1,"thief");             // 14
                case "ther"              : return fixAndReportMisspelling(p1,"there");             // 14
                case "thirtyone"         : return fixAndReportMisspelling(p1,"thirty-one"); 
                case "thirtytwo"         : return fixAndReportMisspelling(p1,"thirty-two"); 
                case "thirtythree"       : return fixAndReportMisspelling(p1,"thirty-three"); 
                case "thirtyfour"        : return fixAndReportMisspelling(p1,"thirty-four"); 
                case "thirtyfive"        : return fixAndReportMisspelling(p1,"thirty-five"); 
                case "thirtysix"         : return fixAndReportMisspelling(p1,"thirty-six"); 
                case "thirtyseven"       : return fixAndReportMisspelling(p1,"thirty-seven"); 
                case "thirtyeight"       : return fixAndReportMisspelling(p1,"thirty-eight"); 
                case "thirtynine"        : return fixAndReportMisspelling(p1,"thirty-nine"); 
                case "throught"          : return fixAndReportMisspelling(p1,"through");           // 31
                case "tiltawhirl"        : return fixAndReportMisspelling(p1,"tilt-a-whirl"); 
                case "tocatta"           : return fixAndReportMisspelling(p1,"toccata");
                case "tommorow"          :
                case "tommorrow"         : return fixAndReportMisspelling(p1,"tomorrow");          // 38
                case "tounge"            : return fixAndReportMisspelling(p1,"tongue");            // 28
                case "trampolene"        : return fixAndReportMisspelling(p1,"trampoline");        // 11
                case "trancendental"     : return fixAndReportMisspelling(p1,"transcendental");    // 13
                case "transcendance"     : return fixAndReportMisspelling(p1,"transcendence");     // 13
                case "tremelo"           : return fixAndReportMisspelling(p1,"tremolo");           // 27
                case "turangalîlasymphonie": return fixAndReportMisspelling(p1,"turangalîla-symphonie"); 
                case "twelth"            : return fixAndReportMisspelling(p1,"twelfth");           // 14
                case "twentyone"         : return fixAndReportMisspelling(p1,"twenty-one"); 
                case "twentytwo"         : return fixAndReportMisspelling(p1,"twenty-two"); 
                case "twentythree"       : return fixAndReportMisspelling(p1,"twenty-three"); 
                case "twentyfour"        : return fixAndReportMisspelling(p1,"twenty-four"); 
                case "twentyfive"        : return fixAndReportMisspelling(p1,"twenty-five"); 
                case "twentysix"         : return fixAndReportMisspelling(p1,"twenty-six"); 
                case "twentyseven"       : return fixAndReportMisspelling(p1,"twenty-seven"); 
                case "twentyeight"       : return fixAndReportMisspelling(p1,"twenty-eight"); 
                case "twentynine"        : return fixAndReportMisspelling(p1,"twenty-nine"); 
                case "unforgetable"      : return fixAndReportMisspelling(p1,"unforgettable");     // 13
                case "unkown"            : return fixAndReportMisspelling(p1,"unknown");           // 16
                case "vallecillogray"    : return fixAndReportMisspelling(p1,"vallecillo-gray"); 
                case "variatio"          : return fixAndReportMisspelling(p1,"variation");
                case "vengence"          : return fixAndReportMisspelling(p1,"vengeance");         // 28
                case "vicace"            : return fixAndReportMisspelling(p1,"vivace");
                case "viscious"          : return fixAndReportMisspelling(p1,"vicious"); 
                case "villian"           : return fixAndReportMisspelling(p1,"villain");           // 14
                case "voulezvous"        : return fixAndReportMisspelling(p1,"voulez-vous"); 
                case "welltempered"      : return fixAndReportMisspelling(p1,"well-tempered");     // 561 in database
                case "wholy"             : return fixAndReportMisspelling(p1,"wholly");            // 13
                case "withdrawl"         : return fixAndReportMisspelling(p1,"withdrawal");        // 11
                case "wonderfull"        : return fixAndReportMisspelling(p1,"wonderful");         // 67
                case "wunderhornlieder"  : return fixAndReportMisspelling(p1,"wunderhorn-lieder"); 
                case "yerself"           :
                case "youself"           : return fixAndReportMisspelling(p1,"yourself");          // 15
                case "zauberflote"       : return fixAndReportMisspelling(p1,"zauberflöte");
                default                  : return p1;
            }
        }
    );
    return stringBeingFixed;
}
/****************************************************************************************
 * Function: fixCapitalization ( language ruleset object, GC group type,                *
 *                               track number / event number, string to be processed )  *
 *                                                                                      *
 * Stage 2 of Guess Case, handles the capitalization changes                            *
 *                                                                                      *
 * First while loop is modified from Title Caps                                         *
 * Ported to JavaScript By John Resig - http://ejohn.org/ - 21 May 2008 (revised ver.)  *
 * Original by John Gruber - http://daringfireball.net/projects/titlecase/TitleCase.pl  *
 * License: http://www.opensource.org/licenses/mit-license.php                          *
 * Modified and extended by BrianFreud                                                  *
 ****************************************************************************************/
(function() {
    this.fixCapitalization = function(ruleSet, type, number, stringBeingFixed, mode, keepUpperCased) {
        var lower = function(word) {
                return word.toMusicBrainzLowerCase();
        },
            upper = function(word) {
                return titleCaseString(word);
        },
            allUpper = function(word) {
                return word.toMusicBrainzUpperCase();
        },
            upperPunct = function(all, punct, word) {
                return punct + upper(word);
        },
            testWord = function(all, punct, word) {
                characterListRegExp = new RegExp("[" + allFoldableChars + "]\\.[" + allFoldableChars + "]");
                return (characterListRegExp).test(word) ? punct+word: punct+upper(word);
        };
        /* Capitalize individual words. */
        if (ruleSet.changeCapitalization) {
            var punct = ruleSet.punctuationCharacters,
                smallwords = "("+ruleSet.lowerCaseWords.join("|")+")", // Convert data array to a regexp-friendlier format
                bigwords = ruleSet.alwaysUppercasedWords,
                parts = [],
                split = /[:.;?!]|(?: |^)["Ò]/g, index = 0,
                charMapRegExp = new RegExp("(\\b|\\-|\\‐||\\s)([" + allFoldableChars + "][" + allFoldableChars + ".']*)\\b", "g");
            while (true) {
                var m = split.exec(stringBeingFixed);
                parts.push(stringBeingFixed.substring(index, m ? m.index: stringBeingFixed.length)
                     .replace(charMapRegExp,testWord)
                     .replace(new RegExp("\\b" + smallwords + "\\b", "ig"), lower)
                     .replace(new RegExp("^" + punct + smallwords + "\\b", "ig"), upperPunct)
                     .replace(new RegExp("\\b" + bigwords + "\\b", "ig"), allUpper)
                     .replace(new RegExp("\\b" + smallwords + punct + "$", "ig"), upper)
                     .replace(new RegExp("\\'[" + allFoldableChars + "]\\s"), lower)
                     );
                index = split.lastIndex;
                if (m) {
                    parts.push(m[0]);
                } else {
                    break;
                }
            }
            stringBeingFixed = parts.join("");
            /* ---------------------------------------------------------------------*/
            /* Find and store ambiguous always UPPERCASE words.                     */
            /* ---------------------------------------------------------------------*/
            if (reportErrors) {
                var ambigWord = stringBeingFixed.match(new RegExp("\\b" + ruleSet.ambiguousUppercasedWords + "\\b", "ig"));
                if (ambigWord !== null) {
                    for (var i = 0; i < ambigWord.length; i++) {
                        if (ambigWord[i].length > 0) {
                            storeError('Caution: This word should possibly be all UPPERCASE: ' + ambigWord[i], type, number);
                        }
                    }
                }
            }
        }
        /* ---------------------------------------------------------------------*/
        /* Find and all-capitalize Roman numerals.                              */
        /* Don't convert Roman to special unicode symbols, see                  */
        /*   http://www.unicode.org/versions/Unicode5.1.0/ (Search on "roman")  */
        /* ---------------------------------------------------------------------*/
        var upperAll = function(str) {
            return str.toMusicBrainzUpperCase();
        };
        if (ruleSet.usesRomanNumerals) {
            var romanparts = [];
            romanparts = stringBeingFixed.split(" ");
            for (var n in romanparts) {
                if (romanparts.hasOwnProperty(n)) {
                    romanparts[n] = jQuery.trim(romanparts[n]).replace(/^M{0,4}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})$/i,upperAll);
                }
            }
            stringBeingFixed = romanparts.join(" ");
        }
        /* ---------------------------------------------------------------------*/
        /* Find and un-all-capitalize Roman numerals that happen to be words.   */
        /* ---------------------------------------------------------------------*/
        var romanParts = [];
        romanParts = stringBeingFixed.split(" ");
        for (var s in romanParts) {
            if (romanParts.hasOwnProperty(s)) {
                for (var q in ruleSet.romanWordsLower) {
                    if (ruleSet.romanWordsLower.hasOwnProperty(q)) {
                        if (ruleSet.romanWordsLower[q] === romanParts[s]) {
                            romanParts[s] = romanParts[s].toMusicBrainzLowerCase();
                        }
                    }
                }
                for (var qq in ruleSet.romanWordsNormal) {
                    if (ruleSet.romanWordsNormal.hasOwnProperty(qq)) {
                        if (ruleSet.romanWordsNormal[qq] === romanParts[s]) {
                            romanParts[s] = titleCaseString(romanParts[s]);
                        }
                    }
                }
            }
        }
        stringBeingFixed = romanParts.join(" ");
        /* ---------------------------------------------------------------------*/
        /* Find and re-all-capitalize initial ALLCAPS words.                    */
        /* AllCapsPositions was caught and stored in stage 1.                   */
        /* ---------------------------------------------------------------------*/
        if (keepUpperCased) {
            var allcapsparts = stringBeingFixed.split(" ");
            for (var p in allcapsparts) {
                if (AllCapsPositions[p]) {
                    allcapsparts[p] = allcapsparts[p].toMusicBrainzUpperCase();
                }
            }
            stringBeingFixed = allcapsparts.join(" ");
        }
        /* ---------------------------------------------------------------------*/
        /* alwayslowercased is the superior rule to the ALLCAPS option for      */
        /* single letter alwayslowercased words.                                */
        /* ---------------------------------------------------------------------*/
        var lowercasedparts = [];
        lowercasedparts = stringBeingFixed.split(" ");
        for (var st in lowercasedparts) {
            if (lowercasedparts.hasOwnProperty(st)) {
                for (var v in ruleSet.lowerCaseWords) {
                    if (ruleSet.lowerCaseWords.hasOwnProperty(v)) {
                        if (ruleSet.lowerCaseWords[v].length === 1) {
                            if (ruleSet.lowerCaseWords[v] === lowercasedparts[st].toMusicBrainzLowerCase()) {
                                lowercasedparts[st] = lowercasedparts[st].toMusicBrainzLowerCase();
                            }
                        }
                    }
                }
            }
        }
        stringBeingFixed = lowercasedparts.join(" ");
        /* ---------------------------------------------------------------------*/
        /* Clear extraneous whitespace that pops up if a punctuation character  */
        /* which is spaceAfterPunctuation is the last character inside a ().    */
        /* ---------------------------------------------------------------------*/
        stringBeingFixed = stringBeingFixed.replace(/\((.+)\)/g,
            function(str, p1) {
                return "("+jQuery.trim(p1)+")";
            }
        );
        /* ---------------------------------------------------------------------*/
        /* Capitalize first word inside parenthesis, brackets, and / separated  */
        /* substrings.                                                          */
        /* ---------------------------------------------------------------------*/
        if (ruleSet.capitalizeFragments) {
            stringBeingFixed = stringBeingFixed.replace(new RegExp(ruleSet.fragmentPunctuation + "\\s?.", "g"),
            function(a) {
                return a.toMusicBrainzUpperCase();
            });
            /* ---------------------------------------------------------------------*/
            /* This next has to be separate from the above, in order to catch all   */
            /* instances in 'foo / (foo (foo) foo / foo'.  Otherwise, '/ (' gets    */
            /* snagged, and the first '(f' gets missed.                             */
            /* ---------------------------------------------------------------------*/
            stringBeingFixed = stringBeingFixed.replace(new RegExp("\\/\\s.", "g"),
            function(a) {
                return a.toMusicBrainzUpperCase();
            });
        }
        /* ---------------------------------------------------------------------*/
        /* Make lowercase any non-starting alwayslowercase words which still    */
        /* are uppercased (starting and ending words inside () mainly).         */
        /* ---------------------------------------------------------------------*/
        stringBeingFixed = stringBeingFixed.replace(new RegExp("\\b" + smallwords + "\\b", "ig"), lower)
                                           .replace(/\(a\s/g,"(A "); // except for "A", as it is pretty much never a continuation of a thought
        /* ---------------------------------------------------------------------*/
        /* Make all UPPERCASE any commaUppercasedWords, if applicable.          */
        /* ---------------------------------------------------------------------*/
        stringBeingFixed = stringBeingFixed.replace(new RegExp(",\\s?" + ruleSet.commaUppercasedWords + "\\s?,", "ig"), allUpper);
        /* ---------------------------------------------------------------------*/
        /* Capitalize sentences.                                                */
        /* ---------------------------------------------------------------------*/
        stringBeingFixed = stringBeingFixed.replace(/(\w\.(\w\.)+)/g,  // Protect acronyms from spacing, to avoid U.S.A.Y.M.C.A. later on
            function (str, p1) {
                return p1.replace(/\./g,"\uDBC0\uDC00");  // U+100000 is guaranteed to never be a valid character in *anything*
            }
        );
        if (ruleSet.capitalizeSentences) {
            var sentenceparts = [],
                splitFix = function(stringBeingFixed, mark) {
                    sentenceparts = stringBeingFixed.split(mark);
                    for (var n in sentenceparts) {
                        if (sentenceparts.hasOwnProperty(n)) {
                            sentenceparts[n] = titleCaseString(jQuery.trim(sentenceparts[n]));
                        }
                    }
                    /* ---------------------------------------------------------------------*/
                    /* Check if this punctuation mark is one that should be followed by a   */
                    /* space and/or preceeded by a space.                                   */
                    /* ---------------------------------------------------------------------*/
                    if (new RegExp(ruleSet.spaceAfterPunctuation).test(mark)) {
                        if (new RegExp(ruleSet.spaceBeforePunctuation).test(mark)) {
                            return sentenceparts.join(" " + mark + " ");
                        } else {
                            return sentenceparts.join(mark + " ");
                        }
                    } else {
                        if (new RegExp(ruleSet.spaceBeforePunctuation).test(mark)) {
                            return sentenceparts.join(" " + mark);
                        } else {
                            return sentenceparts.join(mark);
                        }
                    }
                };
            for (i in ruleSet.sentenceEndingPunctuation) {
                if (ruleSet.sentenceEndingPunctuation.hasOwnProperty(i)) {
		            if (new RegExp(stringBeingFixed).test(ruleSet.sentenceEndingPunctuation[i])) {
                        stringBeingFixed = splitFix(stringBeingFixed, ruleSet.sentenceEndingPunctuation[i]);
                    }
                }
            }
        }
        stringBeingFixed = stringBeingFixed.replace(/\uDBC0\uDC00/g,".");
        stringBeingFixed = stringBeingFixed.replace(/\s(\)|\])/g,"$1");  // Remove space before ). Happens when you have spaceAfterPunctuation ending a ().
        /* ---------------------------------------------------------------------*/
        /* Turn spaced out acronyms into space-less acronyms, also capitalize   */
        /* the first letter of an acronym, if that acronym had whitespace       */
        /* before it.                                                           */
        /* ---------------------------------------------------------------------*/
        stringBeingFixed = stringBeingFixed.replace(/((^|\s|\()(?:\"|\')?(\w\.\s?)+)/g,
            function(str, p1) {
                if (new RegExp(/(^|\s)((?:\w\.)(?:\s\w\.)+)/).test(p1)) {
                    return " "+p1.replace(/\s/g, "").toMusicBrainzUpperCase()+" ";
                } else {
                    return p1.toMusicBrainzUpperCase();
                }
            }
        );
        /* ---------------------------------------------------------------------*/
        /* Find and store possibly missed acronyms.                             */
        /* ---------------------------------------------------------------------*/
        if (reportErrors) {
            var missedAcronyms = stringBeingFixed.match(new RegExp("([" + allUpperCaseChars + "]\\.)+\\s[" + allUpperCaseChars + "]($|\\s)"));
            if (missedAcronyms !== null) {
                storeError('Caution: Possible acronym with missing final period: "' + missedAcronyms[0] + '"', type, number);
            }
        }
        /* ---------------------------------------------------------------------*/
        /* Fix words like Y'all, I'll, C'mon, ( 1 char ' 2+ chars).             */
        /* ---------------------------------------------------------------------*/
        if (ruleSet.fixApostropheWords) {
            stringBeingFixed = stringBeingFixed.replace(new RegExp("(\\b\\w'[" + allFoldableChars + "]{2,})" ,"g"),
            function(str, p1) {
                return titleCaseString(p1);
            });
            /* ---------------------------------------------------------------------*/
            /* Exception to the above: O'Clock, O'Leary, O'Henry, and Vulcan names. */
            /* ---------------------------------------------------------------------*/
            stringBeingFixed = stringBeingFixed.replace(/\b([to]\'\w)(\w+)\b/gi,
                function(str, p1, p2) {
                    return p1.toMusicBrainzUpperCase() + p2.toMusicBrainzLowerCase();
                }
            );
            /* ---------------------------------------------------------------------*/
            /* And d'Arcy, d'Foo, etc.                                              */
            /* ---------------------------------------------------------------------*/
            stringBeingFixed = stringBeingFixed.replace(/\bd\'(\w)(\w+)\b/gi,
                function(str, p1, p2) {
                    return "d'" + p1.toMusicBrainzUpperCase() + p2.toMusicBrainzLowerCase();
                }
            );
        }
        /* ---------------------------------------------------------------------*/
        /* Fix words like 'round.                                               */
        /* ---------------------------------------------------------------------*/
        if (ruleSet.lowerCaseApostropheWords) {
            stringBeingFixed = stringBeingFixed.replace(/((?:^|\s)'\w)/g,
            function(str, p1) {
                return p1.toMusicBrainzLowerCase();
            });
        }
        /* ---------------------------------------------------------------------*/
        /* Special capitalizations.                                             */
        /* ---------------------------------------------------------------------*/
        stringBeingFixed = stringBeingFixed.replace("Djs", "DJs");
        /* ---------------------------------------------------------------------*/
        /* Don't space around / or . in dates.                                  */
        /* ---------------------------------------------------------------------*/
        stringBeingFixed = stringBeingFixed.replace(/(\d{1,2})\s\/\s(\d{1,2})/g,"$1/$2")
                                           .replace(/(\d{1,2})\s\/\s(\d{2,4})/g,"$1/$2")
                                           .replace(/(\d{2,4})\.\s(\d{1,2})(?:\.\s(\d{1,2}))?/g,
            function (str, p1, p2, p3) {
                var separator = "";
                if (p1.length === 4) {
                    separator = ruleSet.dashFigure;
                } else {
                    separator = ".";
                }
                if (typeof(p3) === "undefined" || p3 === "") {
                    return p1+separator+p2;
                } else {
                    return p1+separator+p2+separator+p3;
                }
            }
        );
        /* ---------------------------------------------------------------------*/
        /* Capitalize first word of the track title, no matter what it is.      */
        /* ---------------------------------------------------------------------*/
        if (new RegExp("\\s").test(stringBeingFixed)) {
            var sections = stringBeingFixed.split(" ");
            stringBeingFixed = titleCaseString(sections.shift()) + " " + sections.join(" ");
        } else {
            stringBeingFixed = titleCaseString(stringBeingFixed);
        }
        /* ---------------------------------------------------------------------*/
        /* Fix lowercase sigma to correct word-ending lowercased sigma.         */
        /* ---------------------------------------------------------------------*/
        stringBeingFixed = stringBeingFixed.replace(/(.+)σ(\s|$)/g,"$1ς$2");
        /* ---------------------------------------------------------------------*/
        /* Handle Mc/Mac names.                                                 */
        /* ---------------------------------------------------------------------*/
        stringBeingFixed = stringBeingFixed.replace(/(\s|^)(ma?c)([A-Za-z]+)(\s|$)/gi,
            function(str,p1,p2,p3) {
                if (p3.slice(0,1) != "x" && p3.slice(0,1) != "z") {  // Neither letter has any MacNames
                    if (p3.match(new RegExp("\\b" + namesDict.macNames[p3.slice(0,1)] + "\\b", "ig")) !== null) {
                        p3 = titleCaseString(p3);
                    }
                }
                return p1 + p2 + p3 + " ";
            }
        );
        /* ---------------------------------------------------------------------*/
        /* Handle * used as character replacement (normally expletives).        */
        /* ---------------------------------------------------------------------*/
        stringBeingFixed = stringBeingFixed.replace(/\*(\w)/g,
            function (str, p1) {
                return "*"+p1.toMusicBrainzLowerCase();
            }
        );
        /* ---------------------------------------------------------------------*/
        /* Handle German es-zed (which JavaScript ignores in a toUpper!)        */
        /* ---------------------------------------------------------------------*/
        stringBeingFixed = stringBeingFixed.replace(/([\s$])ß(.*(?:\s|$))/g,
            function(str, p1, p2) {
                return p1+"SS"+p2.toMusicBrainzLowerCase();
            }
        );
        /* ---------------------------------------------------------------------*/
        /* Fix odd acronym ownership cases like O.D.'d.                         */
        /* ---------------------------------------------------------------------*/
        stringBeingFixed = stringBeingFixed.replace(/\.\s\'d\s/g,".'d ");
        /* ---------------------------------------------------------------------*/
        /* Floating point numbers are not sentences.                            */
        /* ---------------------------------------------------------------------*/
        stringBeingFixed = stringBeingFixed.replace(/(\d+)\.\s(\d+)/g,"$1.$2");
        /* ---------------------------------------------------------------------*/
        /* #1 not # 1.                                                          */
        /* ---------------------------------------------------------------------*/
        stringBeingFixed = stringBeingFixed.replace(/#\s(\d+)/g,"#$1");
        /* ---------------------------------------------------------------------*/
        /* Capitalize first-word-of-quote alwayslowercased words.               */
        /* ---------------------------------------------------------------------*/
        stringBeingFixed = stringBeingFixed.replace(new RegExp('\\"(' + ruleSet.lowerCaseWords.join("|") + ")", "g"),
            function(str, p1) {
                return '"' + titleCaseString(p1);
            }
        );
        /* ---------------------------------------------------------------------*
         * Fix DJ, MC, composers
         * ---------------------------------------------------------------------*/
        stringBeingFixed = stringBeingFixed.replace(/(?:\b|^)d\.?\s?j\.?(?:\s|$)/gi," DJ ")
                                           .replace(/(?:\b|^)m\.?\s?c\.?(?:\s|$)/gi," MC ")
                                           .replace(/\sop\s?(\d{1,2})(?:\s|$)/gi," Op. $1 ")        // 'Op. 123'
                                           .replace(/\sbwv\s?(\d{1,3})(?:\s|$)s/gi," BWV$1 ")       // 'Classical catalog: BWV (Bach)'
                                           .replace(/\srv\s?(\d{1,3})(?:\s|$)/gi," RV$1 ")          // 'Classical catalog: RV (Vivaldi)'
                                           .replace(/\shob\s?(\d{1,3})(?:\s|$)/gi," Hob$1 ")        // 'Classical catalog: Hob (Haydn)'
                                           .replace(/\shwv\s?(\d{1,3})(?:\s|$)/gi," HWV$1 ")        // 'Classical catalog: HWV (Handel)'
                                           .replace(/\shwwo\s?(\d{1,3})(?:\s|$)/gi," WwO$1 ")       // 'Classical catalog: WwO'
                                           .replace(/\shkv\s?(\d{1,3})(?:\s|$)/gi," KV$1 ")         // 'Classical catalog: KV (Mozart)'
                                           .replace(/\shph\.?d\s/gi," Ph.D ");                      // Capitalize Ph.D correctly
        return stringBeingFixed;
    };
})();
/*************************************************************************************
 * Function: applyGuidelines ( language ruleset object, GC group type,               *
 *                             track number / event number, string to be processed ) *
 *                                                                                   *
 * Stage 3 of Guess Case, applies style guidelines to the text.                      *
 *************************************************************************************/
function applyGuidelines(ruleSet, type, number, stringBeingFixed, mode) {
    /* ---------------------------------------------------------------------*/
    /* Bang + pound is almost always character explitive replacement,       */
    /* ignore normal spacing rules.                                         */
    /* ---------------------------------------------------------------------*/
    stringBeingFixed = stringBeingFixed.replace(/!\s?#\s?/g,"!#");
    /* ---------------------------------------------------------------------*/
    /* Fix explicit interrobangs, if the language uses them.                */
    /* ---------------------------------------------------------------------*/
    if (ruleSet.punctuationCharacters.match("‽") !== "null") {
        stringBeingFixed = stringBeingFixed.replace(/!\s\?\s?/g, "!?")
                                           .replace(/\?\s!\s?/g, "?!");
    }
    /* ---------------------------------------------------------------------*/
    /* Use non-breaking spaces, if there's a space in that position.        */
    /* ---------------------------------------------------------------------*/
    stringBeingFixed = stringBeingFixed.replace(/\s([»\:;?!])/g,
        function (str, p1) {
            return ruleSet.spaceChar + p1;
        }
    );
    stringBeingFixed = stringBeingFixed.replace(/«\s/g,
        function (str, p1) {
            return p1 + ruleSet.spaceChar;
        }
    );
    /* ---------------------------------------------------------------------*/
    /* Style-mandated artists and titles.                                   */
    /* ---------------------------------------------------------------------*/
            var testString = stringBeingFixed.toMusicBrainzLowerCase().replace(/[\[\(\{](.+)[\]\)\}]/,"$1");
            switch (testString) {
                /* DataTrackStyle */
                case "äèñê ñ äàííûìè":
                case "beveiliging":
                case "bonus cd rom content":
                case "bonus data track":
                case "bonus data-track":
                case "bonus-data track":
                case "cccd":
                case "cd media":
                case "cd plus":
                case "cd track":
                case "cd-extra":
                case "cd-maximum catalogue":
                case "cd-rom":
                case "cd+":
                case "copy control":
                case "copy protection":
                case "copycontrol":
                case "dados":
                case "data track":
                case "data":
                case "dataspår":
                case "dataspor":
                case "daten-cd":
                case "daten":
                case "datentrack":
                case "datos":
                case "do not rip":
                case "dodatki multimedialne":
                case "données":
                case "enhanced":
                case "gegevens":
                case "kopibeskyttelse":
                case "kopieerbeveiliging":
                case "kopieringsskydd":
                case "Kopierschutz":
                case "lgcd":
                case "multimedia":
                case "open disc":
                case "opendisc":
                case "prezentacja multimedialna":
                case "quicktime":
                case "video clip":
                case "video track":
                case "video":
                case "videoclip":
                case "videos":
                case "videotrack":
                case "στοιχεία":
                case "данные":
                case "диск с данными":
                case "データ":
                    stringBeingFixed = "[data track]";
                    storeError(text.DataTrack, type, number);
                    break;
                default:
            }
    /* ---------------------------------------------------------------------*/
    /* Fix comma-spaced numbers, like 1,000,000 and 1,000                   */
    /* ---------------------------------------------------------------------*/
    stringBeingFixed = stringBeingFixed.replace(/((?:\d{1,3},\s)+\d{3})/g,
        function(str, p1) {
            return p1.replace(/\s/, "");
        }
    );
    /* ---------------------------------------------------------------------*/
    /* Fix times, like 6: 00 and 12: 00.                                    */
    /* ---------------------------------------------------------------------*/
    stringBeingFixed = stringBeingFixed.replace(/(\d{1,2}:\s\d{2})/g,
        function(str, p1) {
            return p1.replace(/\s/, "");
        }
    );
    /* ---------------------------------------------------------------------*/
    /* Type-specific changes per guidelines.                                */
    /* ---------------------------------------------------------------------*/
    switch (type) {
        case "title":
        case "text":
            /* ---------------------------------------------------------------------*/
            /* Standardize foreign words prior to applying style rules.             */
            /* ---------------------------------------------------------------------*/
            if (ruleSet.wordForPt.length > 0) {
                stringBeingFixed = stringBeingFixed.replace(new RegExp("\\b" + ruleSet.wordForPt + "\\b"), "part"); // Multi-language support for "pt." before standardizing
            }
            if (ruleSet.wordForPart.length > 0) {
                stringBeingFixed = stringBeingFixed.replace(new RegExp("\\b" + ruleSet.wordForPart + "\\b"), "part"); // Multi-language support for "part" before standardizing
            }
            if (ruleSet.wordForParts.length > 0) {
                stringBeingFixed = stringBeingFixed.replace(new RegExp("\\b" + ruleSet.wordForParts + "\\b"), "parts"); // Multi-language support for "parts" before standardizing
            }
            if (ruleSet.wordForVolumeA.length > 0) {
                stringBeingFixed = stringBeingFixed.replace(new RegExp("\\b" + ruleSet.wordForVolumeA + "\\b"), "volume"); // Multi-language support for "volume" before standardizing
            }
            if (ruleSet.wordForVolumeB.length > 0) {
                stringBeingFixed = stringBeingFixed.replace(new RegExp("\\b" + ruleSet.wordForVolumeB + "\\b"), "volume"); // Multi-language support for "vol." before standardizing
            }
            if (ruleSet.wordForDisc.length > 0) {
                stringBeingFixed = stringBeingFixed.replace(new RegExp("\\b" + ruleSet.wordForDisc + "\\b"), "disc"); // Multi-language support for "disc" before standardizing
            }
            if (ruleSet.wordForBox.length > 0) {
                stringBeingFixed = stringBeingFixed.replace(new RegExp("\\b" + ruleSet.wordForBox + "\\b"), "box"); // Multi-language support for "box" before standardizing
            }
            /* ---------------------------------------------------------------------*/
            /* VolumeNumberStyle.                                                   */
            /* ---------------------------------------------------------------------*/
            stringBeingFixed = stringBeingFixed.replace(new RegExp(",?(^|\\s)[\\(\\[]?vol(?:\\.|(?:ume\\.?))\\s?([" + allFoldableChars + "\\d]+):?(.*)?", "gi"),
                function(all, p1,p2,p3) {
                    var startOfString;
                    if (p1 == " ") {
                        startOfString = ", ";
                    } else {
                        startOfString = "";
                    }
                    if (p3 === "" || p3 == "]") {
                        return startOfString+"Volume "+p2;
                    } else if (p3 == ")") {
                        return startOfString+"Volume "+p2+p3;
                    } else {
                        return startOfString+"Volume "+jQuery.trim((p2).replace(/[\]\)]/g,"").replace(/#/g,"")+": "+p3);
                    }
                }
            );
            stringBeingFixed = stringBeingFixed.replace(/\:$/,"");
            /* ---------------------------------------------------------------------*/
            /* PartNumberStyle.                                                     */
            /* ---------------------------------------------------------------------*/
            stringBeingFixed = stringBeingFixed.replace(/\s\(?p(?:ar)?ts?\.?\s(\d+)\sof\s\d+\)?/gi, " part $1 ");  //  Change "Foo Part 1 of 4" into "Foo Part 1"
            var partsInTitleRegExp = new RegExp("([" + AllPunctuation + "\\s])?\\s?\\,?[\\-?\\s\\[\\(]p(?:ar)?ts?s?\\.?\\b\\s?#?(?:\\.\\s)?([" + allFoldableChars + "\\d]+),?(?:\\s?((?:to)|(?:through)|(?:and)|&|\\-|\\‐|\\–|\\)\\s&\\s\\(p(?:ar)?ts?s?|\\+)\\s?)?#?(?:|\\s-|\\s|\\,|&|and|\\‐|\\-|\\–)+#?([" + allFoldableChars + "\\d]+)?[,:]?\\b,?\\s?(?:and|&)?\\s?([" + allFoldableChars + "\\d]+)?,?\\)?\\s?(.+)?", "gi");
            stringBeingFixed = stringBeingFixed.replace(/\s?\,?[\s\[\(]p(?:ar)?ts?s?\.?(\d+)/g," part $1")  // Catch pt1 but not pterodactyl.
                                               .replace(partsInTitleRegExp,
                function(str, beforepunct, p1, p2, p3, p4, p5) {
                         var notASentence = false,
                             numberTextStrings = "(" + ruleSet.numberWords.join("|") + ")";
                         if (typeof(beforepunct) === "undefined") {
                             beforepunct = "";
                         }
                         if (typeof(p4) !== "undefined") {
                             if  (p4 === "" && typeof(p5) !== "undefined") {
                                 p4 = p5;    // Handle cases like "This Is a Song, Parts 1 & 2, 3 the Subtitle" and "This Is a Song, Part 1, 2, & 3 the
                                 p5 = "";    // Subtitle", where data *still* gets trapped in the wrong field.
                             }
                         }
                         /*******************************************************************/
                         /* Return true if p1 and p2 have sequential final letters.         */
                         /* Make them both uppercase to advoid a false negative on a and B. */
                         /*******************************************************************/
                         function checkAlphabeticalOrder(numberOfLetters) {
                             if (parseInt(p1.toMusicBrainzUpperCase().charCodeAt(numberOfLetters-1), 10) + 1 == parseInt(p3.toMusicBrainzUpperCase().charCodeAt(numberOfLetters-1), 10) && p1.toMusicBrainzUpperCase().charCodeAt(numberOfLetters-1) == p3.toMusicBrainzUpperCase().charCodeAt(numberOfLetters-1)) {
                                 return true;
                             } else {
                                 return false;
                             }
                         }
                         /***************************************************************************/
                         /* Fingerprint, with increasing risk of error and slowness at each step,   */
                         /* to identify if this is a PartNumberStyle case, or the word 'Part'.      */
                         /***************************************************************************/
                         if (typeof(p2) !== "undefined") {
                             if (p2 !== "") { // p2 is always empty when it is a sentence, so if p2 is not empty, this is not a sentence.
                                 notASentence = true;
                             }
                         }
                         if (!notASentence) {
                             if (typeof(p3) !== "undefined") {
                                 if (p3 === "") {
                                     notASentence = true; // p2 is never empty when it is a sentence, so if p3 is empty, this is not a sentence.
                                 }
                             } else {
                                 notASentence = true; // p2 is never empty when it is a sentence, so if p3 == undefined, this is not a sentence.
                             }
                             if (!notASentence) {
                                 if (typeof(p3) !== "undefined") {
                                     if (new RegExp(/^[\d]$/).test(p2)) {  // Look for a number in p3.
                                         notASentence = true; // Makes the assumption that one would never use numbers right in front of "Part" unless referencing a PartNumber.  (Part 1 Foo Bar)
                                     }
                                     if (!notASentence) {
                                         if (typeof(p4) !== "undefined") {  // Look for a number in p4.
                                             if (new RegExp(/^[\d]$/).test(p3)) {
                                                 notASentence = true; // Makes the assumption that one would almost never use numbers one word in front of "Part" unless referencing a PartNumber.  (Part Foo 1 Bar)
                                             }
                                         }
                                     }
                                     if (!notASentence) {
                                         if (typeof(p2) !== "undefined" && typeof(p3) !== "undefined") {
                                             if (validateRoman(p2.toMusicBrainzUpperCase()) && validateRoman(p3.toMusicBrainzUpperCase())) { // Test if both are Roman numerals.
                                                 notASentence = true; // Makes the assumption that one would rarely use two Roman numerals in front of "Part" unless referencing a PartNumber.  (Part III VI Bar)
                                             }
                                             if (!notASentence) {
                                                 if (p1.length === 1 && p3.length === 1) {
                                                     notASentence = true; // Makes the assumption that if there is a 1 letter string each in p1 and p3, this is not a sentence.  (Part A B Bar)
                                                 }
                                                 if (!notASentence) {
                                                     if (p1.length === 2 && p3.length === 2) {
                                                         if (checkAlphabeticalOrder(1)) {
                                                             notASentence = true; // Makes the assumption that if there is a 2 letter string each in p1 and p3, and they are sequential, this is not a sentence.  (Part AA AB Bar)
                                                         }
                                                     }
                                                     if (!notASentence) {
                                                         if (p1.length === 3 && p3.length === 3) {
                                                             if (checkAlphabeticalOrder(1)) {
                                                                 notASentence = true; // If there is a 3 letter string each in p1 and p3, and they are sequential, this is not a sentence.  (Part AAA AAB Bar)
                                                             }
                                                         }
                                                         if (!notASentence) {
                                                             if (p1.length === 4 && p3.length === 4) {
                                                                 if (checkAlphabeticalOrder(1)) {
                                                                     notASentence = true; // If there is a 4 letter string each in p1 and p3, and they are sequential, this is not a sentence.  (Part AAAA AAAB Bar)
                                                                 }
                                                             }
                                                             if (!notASentence) {
                                                                 if (typeof(p4) != "undefined") {
                                                                     if (validateRoman(p2.toMusicBrainzUpperCase()) && validateRoman(p4.toMusicBrainzUpperCase().replace(/^&\s(.+)\)/,"$1"))) {
                                                                         notASentence = true; // Makes the assumption that one would rarely use two Roman numerals within the three words following "Part".  (Part III Foo VI)
                                                                     }                        // p4 would only still be present at this point as sentence text, text in a subtitle, or in a '& VI)' form, hence the regexp.
                                                                 }
                                                                 /* Finally, by this point, we have only two groups left: sentences and subtitles.  Time to go back to str. */
                                                                 if (!notASentence) {
                                                                     if (str.match("Part:")) {  // Note the colon.
                                                                         notASentence = true;   // Assume it's a part number.    (Part: 2 Foo Bar)
                                                                     }
                                                                     if (!notASentence) {
                                                                         if (str.match("Pt")) {
                                                                             notASentence = true;  // Abbreviated "Pt" almost certainly indicates PartNumberStyle.  (Pt. Foo Bar)
                                                                         }
                                                                         if (!notASentence) {
                                                                             if (str.slice(0,7).match(new RegExp("[\\.\\:]"))) {
                                                                                 notASentence = true;  // Period or colon within reasonable range of the word "Part".  Take that to indicate PartNumberStyle.  (Part: 4 Foo Bar)
                                                                             }
                                                                             if (!notASentence) {
                                                                                 if (str.slice(0,9).match(new RegExp("\\d+"))) {
                                                                                     notASentence = true;  // A number within reasonable range of the word "Part".  Take that to indicate PartNumberStyle.  (Part   4 Foo Bar)
                                                                                 }
                                                                                 if (!notASentence) {
                                                                                     if (!(new RegExp("(^[" + ruleSet.romanWordsNormal.join("|") + "|" + ruleSet.romanWordsLower.join("|") + "]$)", "i").test(p1)) || p1 == "I" || p1 == "VI") {  // Make sure it's not a Roman numeral that also happens to be a valid word in the language.
                                                                                         if (validateRoman(p1.toMusicBrainzUpperCase())) {
                                                                                             if (validateRoman(p3.match(new RegExp("[A-Za-z]+")).join().toUpperCase()) || validateRoman(p4.match(new RegExp("[A-Za-z]+")).join().toUpperCase())) {  // Check for a I II sequence, avoid a false positive
                                                                                                 notASentence = true;  // The first word after "Part" is a Roman numeral, assume PartNumberStyle.  (Part II Foo Bar)
                                                                                             }
                                                                                         }
                                                                                         if (!notASentence) {
                                                                                             if (new RegExp(numberTextStrings, "i").test(p1)) {
                                                                                                 notASentence = true;  // We matched to a written out number.  (Part One Foo Bar)
                                                                                             }
                                                                                             if (!notASentence) {
                                                                                                 if ((p1.length == p2.length || p2.length == p3.length) && (new RegExp("\\d").test(p1)) || new RegExp("\\d").test(p3)) {
                                                                                                     notASentence = true;  // Look for mixed letter/number part numbers, like A1, A1a, etc.
                                                                                                 }
                                                                                             }

                                                                                         } // At this point, give up, and assume it's a sentence.
                                                                                     }
                                                                                 }
                                                                             }
                                                                         }
                                                                     }
                                                                 }
                                                             }
                                                         }
                                                     }
                                                 }
                                             }
                                         }
                                     }
                                 }
                             }
                         }
                         if (!notASentence) {
                             return str;  // It *is* a sentence.  Return it unchanged.
                         }
                         if (typeof(p2) === "undefined") {
                             p2 = "";
                         }
                         if (typeof(p3) === "undefined") {
                             p3 = "";
                         }
                         if (typeof(p4) === "undefined") {
                             p4 = "";
                         }
                         if (typeof(p5) === "undefined") {
                             p5 = "";
                         }
                        /***********************************************************
                         * Now we know we have a real PartNumberStyle case.
                         * The data is currently split amidst p1-p4, as we are so
                         * permissive in the PartNumberStyle guidelines (and
                         * how lousy a lot of the pre-Guess Case data can be).
                         ***********************************************************
                         *    |    p1  |       p2     |   p3    |     p4
                         *    |-------------------------------------------------------
                         *    |    1   |              |         |
                         *    |    1   |              |         |
                         *    |    1   |              |         |    / Bar
                         *    |    1   |              |         |   : Bar
                         *    |    1   |              |         |   : Parttitle
                         *    |    1   |              |         |   )
                         *    |    1   |              |         |   ) ‐ (Part 3)
                         *    |    1   |              |         |   ) / Bar
                         *    |    1   |              |   2     |
                         *    |    1   |              |   2     |    & 3)
                         *    |    1   |              |   2     |   )
                         *    |    1   |              |   the   |    Subtitle
                         *    |    1   |   ‐          |   2     |
                         *    |    1   |   ‐          |   2     |   )
                         *    |    1   |   ‐          |   3     |
                         *    |    1   |   ‐          |   3     |    & 5)
                         *    |    1   |   ‐          |   3     |   , & 5)
                         *    |    1   |   ‐          |   3     |   )
                         *    |    1   |   –          |   2     |
                         *    |    1   |   ) & (Part  |   2     |   )
                         *    |    1   |   ) & (Part  |   3     |   )
                         *    |    1   |   &          |   2     |
                         *    |    1   |   &          |   2     |   )
                         *    |    1   |   &          |   3     |
                         *    |    1   |   &          |   Pt    |   . 2
                         *    |    1   |   and        |   2     |   )
                         *    |    1B  |              |         |
                         *    |    3   |              |         |
                         *    |    3   |              |         |   )
                         *    |   One  |              |         |
                         *    |   One  |              |         |
                         *    |   One  |              |         |    / Bar
                         *    |   One  |              |         |   : Bar
                         *    |   One  |              |         |   : Parttitle
                         *    |   One  |              |         |   )
                         *    |   One  |              |         |   ) ‐ (Part Three)
                         *    |   One  |              |         |   ) / Bar
                         *    |   One  |              |  Two    |
                         *    |   One  |              |  Two    |    & Three)
                         *    |   One  |              |  Two    |   )
                         *    |   One  |              |   the   |    Subtitle
                         *    |   One  |   ‐          |  Two    |
                         *    |   One  |   ‐          |  Two    |   )
                         *    |   One  |   ‐          | Three   |
                         *    |   One  |   ‐          | Three   |    & Five)
                         *    |   One  |   ‐          | Three   |   , & Five)
                         *    |   One  |   ‐          | Three   |   )
                         *    |   One  |   –          |  Two    |
                         *    |   One  |   ) & (Part  |  Two    |   )
                         *    |   One  |   ) & (Part  | Three   |   )
                         *    |   One  |   &          |  Two    |
                         *    |   One  |   &          |  Two    |   )
                         *    |   One  |   &          | Three   |
                         *    |   One  |   &          |   Pt    |   . Two
                         *    |   One  |   and        |  Two    |   )
                         *    |    a   |              |         |
                         *    |    a   |              |         |   ) ‐ (Part C)
                         *    |    a   |              |   B     |
                         *    |    a   |              |   B     |    & C)
                         *    |    a   |              |   B     |   )
                         *    |    a   |   ‐          |   B     |
                         *    |    a   |   ‐          |   B     |   )
                         *    |    A   |   ‐          |   B     |   )
                         *    |    a   |   ‐          |   C     |
                         *    |    A   |   ‐          |   C     |    & E)
                         *    |    A   |   ‐          |   C     |   , & E)
                         *    |    A   |   ‐          |   C     |   )
                         *    |    a   |   ) & (Part  |   B     |   )
                         *    |    a   |   ) & (Part  |   C     |   )
                         *    |    a   |   &          |   B     |
                         *    |    a   |   &          |   C     |
                         *    |    A   |   &          |   Pt    |   . B
                         *    |    a   |   and        |   B     |   )
                         *    |    B   |              |         |
                         *    |    I   |              |         |   ) ‐ (Part Iii)
                         *    |    I   |              |   Ii    |
                         *    |    I   |              |   Ii    |    & Iii)
                         *    |    I   |              |   Ii    |   )
                         *    |    I   |   ‐          |   Ii    |
                         *    |    I   |   ‐          |   Ii    |   )
                         *    |    I   |   ‐          |   Iii   |
                         *    |    I   |   ‐          |   Iii   |    & v)
                         *    |    I   |   ‐          |   Iii   |   , & v)
                         *    |    I   |   ‐          |   Iii   |   )
                         *    |    I   |   ) & (Part  |   Ii    |   )
                         *    |    I   |   ) & (Part  |   Iii   |   )
                         *    |    I   |   &          |   Ii    |
                         *    |    I   |   &          |   Iii   |
                         *    |    I   |   &          |   Pt    |   . Ii
                         *    |    I   |   and        |   Ii    |   )
                         *    |    Ii  |              |         |    (the Text)
                         *    |    Ii  |              |   the   |    Subtitle
                         *    |    X   |              |         |   )
                         *    |    Xi  |              |         |
                         ************************************************************
                         * Happily, all of p2 is worthless for the moment, so we
                         * can ignore p2 for now.  Ignoring what the part number type
                         * is for the moment, here are the patterns that leaves:
                         **********************************************************
                         *               1   |         |
                         *               1   |   1     |
                         *               1   |   1     |   1
                         *               1   |         |    (the Text)
                         *               1   |         |    / Bar
                         *               1   |         |   : Parttitle
                         *               1   |         |   )
                         *               1   |         |   ) ‐ (Part 1)
                         *               1   |         |   ) / Bar
                         *               1   |   1     |    & 1)
                         *               1   |   1     |   , & 1)
                         *               1   |   1     |   )
                         *               1   |   Pt    |   . 1
                         *               1   |   the   |    Subtitle
                         ***********************************************************
                         * First, to clean out p4...
                         ***********************************************************/
                          p4 = jQuery.trim(p4.replace(/[\(\.,&\)]/g,"")            // Do not remove the colons or dashes, but remove all ( . , & )
                                     .replace(/\bp(?:ar)?ts?\.?\s/i,""));           // and all those unneeded "Part"s.
                         /***********************************************************
                          *               1    |       |
                          *               1    |  1    |
                          *               1    |   1   |  1
                          *               1    |       |  1
                          *               1    |       |  - 1
                          *               1    |       |  : bar
                          *               1    |       |  : Parttitle
                          *               1    |       |  bar
                          *               1    |       |  the Text
                          *               1    |  Pt   |  1
                          *               1    |  the  |  Subtitle
                          *               1    |  the  |  Subtitle
                          ***********************************************************
                          * and then p1 and p3...
                          ***********************************************************/
                          p1 = jQuery.trim(p1);                                        // Any spaces that happen to be hanging around.
                          p3 = jQuery.trim(p3.replace(/\bp(?:ar)?ts?\.?\s?/i,""));     // All those unneeded "Part"s.
                         /***********************************************************
                          *                 1    |     |
                          *                 1    |  1  |
                          *                 1    |  1  |  1
                          *                 1    |     |  1
                          *                 1    |     |  - 1
                          *                 1    |     |  : Bar
                          *                 1    |     |  , - 3: the Subtitle
                          *                 1    |     |  : Parttitle
                          *                 1    |     |  Bar
                          *                 1    |     |  the Text
                          *                 1    | the |  Subtitle
                          ***********************************************************
                          * Now we need to split out Subtitles.  It's assumed that
                          * each part does not have its own subtitle.
                          ***********************************************************/
                          var partSubtitle = "";
                          if (new RegExp("^[\\/:]").test(p4)) {
                              partSubtitle = jQuery.trim(p4.replace(/:/," "));  // Found a colon or slash starting p4, store p4,
                              p4 = "";                                          // then empty out p4.
                          }
                         /***********************************************************
                          * Now check p2 and p4, looking for range
                          * indicators: to, through, -, ‐, –
                          ***********************************************************/
                          var RangeBetweenOneTwo = false,
                              RangeBetweenTwoThree = false,
                              RangeIndicator = new RegExp("^((?:to)|(?:through)|\\-|\\‐|\\–)");
                           if (RangeIndicator.test(p2)) {
                               RangeBetweenOneTwo = true;                         // Found a range indicator in p2, store that info.
                           }
                           p4 = jQuery.trim(p4.replace(new RegExp("^[,&]?\\s?"), ""));  // Remove any extra crud from p4 that would cause the next check to fail.  (", - 3: the Subtitle", etc.)
                           if (RangeIndicator.test(p4)) {
                               RangeBetweenTwoThree = true;                       // Found a range indicator in p4, store that info,
                               p4 = jQuery.trim(p4.replace(RangeIndicator," "));  // then remove it.
                           }
                         /***********************************************************
                          * More subtitle detection, protection, and capture.
                          ***********************************************************/
                           if (new RegExp("\uDBC0\uDC01").test(p4)) {  // If \uDBC0\uDC01 is in p4, we have a protected slash, plus all of the next part title(s) in p4.
                               partSubtitle = " \uDBC0\uDC01 " + partSubtitle;
                               p4 = p4.replace("\uDBC0\uDC01","");
                           }
                           if (new RegExp("\\s","g").test(p4)) {  // If p4 still has a space in it, there's at least part of the subtitle stuck in there.
                               var tempP4 = p4.split(" ");
                               p4 = tempP4.shift().replace(":","");
                               partSubtitle = partSubtitle + tempP4.join(" ");
                           }
                         /***********************************************************
                          *                 1    |     |
                          *                 1    |  1  |
                          *                 1    |  1  |  1
                          *                 1    |     |  1
                          *                 1    |     |  : Bar
                          *                 1    |     |  : Parttitle
                          *                 1    |     |  Bar
                          *                 1    |     |  the Text
                          *                 1    | the |  Subtitle
                          ***********************************************************
                          * Now to test for any of the valid part formations:
                          *
                          * Roman Numerals
                          * Numbers
                          * Letters
                          * Letters + Numbers
                          * Spelled out numbers (if applicable for the language)
                          *
                          ***********************************************************/
                          var Part1 = "",
                              Part2 = "",
                              Part3 = "",
                              Part1Type = "",
                              Part2Type = "",
                              Part3Type = "";
                         /***********************************************************
                          * Roman Numbers
                          ***********************************************************/
                          if (ruleSet.usesRomanNumerals) {  // Does the currently set language use Roman numerals?
                              if (typeof(p1) != "undefined") {
                                  var toTest = p1.toMusicBrainzUpperCase();
                                  if (validateRoman(toTest)) {
                                      if (convertRomanToArabic(toTest) < 49) {  // It's much more likely that L and C are used as letters, not Roman numerals.
                                          Part1 = toTest;
                                          p1 = "";
                                          Part1Type = "Roman";
                                      }
                                  }
                              }
                              if (typeof(p3) != "undefined") {
                                  toTest = p3.toMusicBrainzUpperCase();
                                  if (validateRoman(toTest)) {
                                      if (convertRomanToArabic(toTest) < 49) {  // It's much more likely that L and C are used as letters, not Roman numerals.
                                          Part2 = p3.toMusicBrainzUpperCase();
                                          p3 = "";
                                          Part2Type = "Roman";
                                      }
                                  }
                              }
                              if (typeof(p4) != "undefined") {
                                  toTest = p4.toMusicBrainzUpperCase();
                                  if (validateRoman(toTest)) {
                                      if (convertRomanToArabic(toTest) < 49) {  // It's much more likely that L and C are used as letters, not Roman numerals.
                                          if (Part2 === "") {
                                              Part2 = p4.toMusicBrainzUpperCase();
                                              p4 = "";
                                              Part2Type = "Roman";
                                          } else {
                                              Part3 = p4.toMusicBrainzUpperCase();
                                              p4 = "";
                                              Part3Type = "Roman";
                                          }
                                      }
                                  }
                              }
                          }
                         /***********************************************************/
                          function searchForType(pattern, partType, searchSwitch) {
                              var searchRange = new RegExp(pattern, searchSwitch);
                              if (p1.length > 0) {
                                  if (searchRange.test(p1)) {
                                      if (Part1 === "") {
                                          Part1 = p1;
                                          p1 = "";
                                          Part1Type = partType;
                                      } else {
                                          Part2 = p1;
                                          p1 = "";
                                          Part2Type = partType;
                                      }
                                  }
                              }
                              if (p3.length > 0) {
                                  if (searchRange.test(p3)) {
                                      if (Part2 === "") {
                                          Part2 = p3;
                                          p3 = "";
                                          Part2Type = partType;
                                      } else {
                                          Part3 = p3;
                                          p3 = "";
                                          Part3Type = partType;
                                      }
                                  }
                              }
                              if (p4.length > 0) {
                                  if (searchRange.test(p4)) {
                                      if (Part2 === "") {
                                          Part2 = p4;
                                          p4 = "";
                                          Part2Type = partType;
                                      } else if (Part3 === "") {
                                          Part3 = p4;
                                          p4 = "";
                                          Part3Type = partType;
                                      } else { // Should never actually happen, but protects the data in case it does.
                                          Part3 = Part3+", "+p4;
                                          p4 = "";
                                      }
                                  }
                              }
                          }
                         /***********************************************************
                          * Numbers
                          ***********************************************************/
                          searchForType("^[\\d]+$", "Arabic", "");
                         /***********************************************************
                          * Spelled out numbers (if applicable for the language)
                          ***********************************************************/
                          if (ruleSet.numberWords.length > 0) {
                              searchForType("^" + numberTextStrings + "$", "Spelled", "i");
                          }
                         /***********************************************************
                          * Letters + Numbers
                          ***********************************************************/
                          searchForType("^[" + allFoldableChars + "\\d]+$", "Mixed", "i");
                          if (Part1Type == "Mixed" && !new RegExp("\\d").test(Part1)) {
                              Part1Type = "Letters";  // Avoid mismatch between Part 1a & 1b, Part A: The Subtitle, and Part A: 1b
                          }
                          if (Part2Type == "Mixed" && !new RegExp("\\d").test(Part2)) {
                              Part2Type = "Letters";
                          }
                          if (Part3Type == "Mixed" && !new RegExp("\\d").test(Part3)) {
                              Part3Type = "Letters";
                          }
                          if (typeof(Part1) == "undefined") {
                              Part1 = "";
                          }
                          if (typeof(Part2) == "undefined") {
                              Part2 = "";
                          }
                          if (typeof(Part3) == "undefined") {
                              Part3 = "";
                          }
                          if (typeof(Part1Type) == "undefined") {
                              Part1Type = "";
                          }
                          if (typeof(Part2Type) == "undefined") {
                              Part2Type = "";
                          }
                          if (typeof(Part3Type) == "undefined") {
                              Part3Type = "";
                          }
                         /***************************************************************************
                          * Now to filter those into text to return.
                          ***************************************************************************
                          *      Part 1    Part 2   Part 3      Pt 1 Type     Pt 2 Type   Pt3 Type
                          *    ---------------------------------------------------------------------
                          *    |    1    |        |          |    Arabic    |           |          |
                          *    |    X    |        |          |    Roman     |           |          |
                          *    |    XI   |        |          |    Roman     |           |          |
                          *    |    1B   |        |          |    Mixed     |           |          |
                          *    |    3    |        |          |    Arabic    |           |          |
                          *    |    B    |        |          |    Letters   |           |          |
                          *    |    a    |        |          |    Letters   |           |          |
                          *    |    II   |        |          |    Roman     |           |          |
                          *    |    One  |        |          |    Spelled   |           |          |
                          *    ---------------------------------------------------------------------
                          *    |    1    |  2     |          |    Arabic    | Arabic    |          |
                          *    |    1    |  3     |          |    Arabic    | Arabic    |          |
                          *    |    a    |  B     |          |    Letters   | Letters   |          |
                          *    |    A    |  B     |          |    Letters   | Letters   |          |
                          *    |    I    |  II    |          |    Roman     |  Roman    |          |
                          *    |    I    |  III   |          |    Roman     |  Roman    |          |
                          *    |    One  |  Two   |          |    Spelled   | Spelled   |          |
                          *    |    A    |  C     |          |    Letters   | Letters   |          |
                          *    |    a    |  C     |          |    Letters   | Letters   |          |
                          *    |    A    |  Bar   |          |    Letters   | Letters   |          |
                          *    ---------------------------------------------------------------------
                          *    |    1    |  Bar   |          |    Arabic    | Letters   |          |
                          *    ---------------------------------------------------------------------
                          *    |    1    |  2     |   3      |    Arabic    | Arabic    | Arabic   |
                          *    |    1    |  3     |   5      |    Arabic    | Arabic    | Arabic   |
                          *    |    a    |  B     |   C      |    Letters   | Letters   | Letters  |
                          *    |    A    |  C     |   E      |    Letters   | Letters   | Letters  |
                          *    |    I    |  III   |   V      |    Roman     |  Roman    | Roman    |
                          *    |    One  |  Two   | Three    |    Spelled   | Spelled   | Spelled  |
                          *    ---------------------------------------------------------------------
                          *    |    II   |  the   | Subtitle |    Roman     | Letters   | Letters  |
                          *    |    1    |  the   | Subtitle |    Arabic    | Letters   | Letters  |
                          *    |    1    |  2     |  Live    |    Arabic    | Arabic    | Letters  |
                          ***************************************************************************/
                         /***********************************************************
                          * testChronological: true if partA + 1 == partB, else false.
                          ***********************************************************/
                          var testChronological = function(partType, partA, partB) {
                              switch (partType) {
                                  case "Arabic":
                                      if ((parseInt(partA, 10) + 1) == parseInt(partB, 10)) {
                                          return true;
                                      } else {
                                          return false;
                                      }
                                      return false;
                                  case "Roman":
                                      if ((convertRomanToArabic(partA) + 1) == convertRomanToArabic(partB)) {
                                          return true;
                                      } else {
                                          return false;
                                      }
                                      return false;
                                  case "Spelled":
                                      if ((jQuery.inArray(partA.toMusicBrainzLowerCase(), ruleSet.numberWords) + 1) == jQuery.inArray(partB.toMusicBrainzLowerCase(), ruleSet.numberWords)) {
                                          return true;
                                      }
                                      return false;
                                  case "Letters":
                                      /* Note: This next check is not very Unicode friendly, but the second check at least avoids our accidentally */
                                      /* possibly adding 1 to "B" and getting "A" as the next *higher* letter in sequence in various scripts.      */
                                      if ((parseInt(partA.charCodeAt(partA.length-1), 10) + 1) == parseInt(partB.charCodeAt(partB.length-1), 10) && partA < partB) {
                                          if (partA.length == partB.length) {
                                              return true;
                                          } else if (partA[0] == partB[0]) {
                                              return true;
                                          } else {
                                              return false;
                                          }
                                      }
                                      return false;
                                  case "Mixed":
                                      if (partA.slice(0,1) == partB.slice(0,1)) {
                                          if (partA.length == partB.length) {
                                              if (partA.length > 1) {
                                                  var lenA, bitA, bitB;
                                                  lenA = partA.length;
                                                  if (lenA > 1) {  // Check for 2 byte character input.
                                                      if (partA.slice(lenA-2,lenA-1).charCodeAt(0) >= NON_BMP_CHAR_CODES.BOTTOM && partA.slice(lenA-2,lenA-1).charCodeAt(0) <= NON_BMP_CHAR_CODES.TOP) {
                                                          bitA = partA.slice(lenA-2,lenA);
                                                          bitB = partB.slice(lenA-2,lenA);
                                                      } else {
                                                          bitA = partA.slice(lenA-1,lenA);
                                                          bitB = partB.slice(lenA-1,lenA);
                                                      }
                                                  } else {
                                                      bitA = partA.slice(lenA-1,lenA);
                                                      bitB = partB.slice(lenA-1,lenA);
                                                  }
                                                  return testChronological("Letters", bitA, bitB);  // Even if it's a case ending in a number,  like
                                                                                                    // A1, A2, the letters test will still work here.
                                              } else {
                                                  return true;  // Self-identification match - parts A & A should use &, not -.
                                              }
                                          }
                                      }
                                      return false;
                                  default:
                                      return false;
                                }
                          },
                              fixCaps = function(str) {  // Turn variations on "a1a1a" into "A1A1a"
                                if (new RegExp("\\d").test(str)) {
                                    str = jQuery.trim(str.toMusicBrainzUpperCase())
                                                .replace(/^((?:.+)?\d+)([^\d]+)$/i,
                                                    function (str, sliceA, sliceB) {
                                                         return sliceA + sliceB.toMusicBrainzLowerCase();
                                                     }
                                                );
                                }
                                          return str;
                          },
                              twoParts = function(spacer) {
                              if (typeof(spacer) == "undefined") {
                                  spacer = " ";
                              }
                              if (RangeBetweenOneTwo || RangeBetweenTwoThree) {
                                  if (testChronological(Part1Type,Part1,Part2)) {  // Parts 1 & 2
                                      return partString + "s " + Part1 + " & " + Part2;
                                  } else { // Parts 1 - 3
                                      return partString + "s " + Part1 + spacer + ruleSet.dashRange + spacer + Part2;
                                  }
                              } else {
                                  return partString + "s " + Part1 + " & " + Part2;
                              }
                          },
                              threeParts = function(partType, spacer) {
                              if (typeof(spacer) == "undefined") {
                                  spacer = " ";
                              }
                              if (RangeBetweenOneTwo) {
                                  if (RangeBetweenTwoThree) {  // Parts 1 - 3 - 5 => Parts 1 - 5
                                      return partString + "s " + Part1 + spacer + ruleSet.dashRange + spacer + Part3;
                                  } else {
                                      if (testChronological(partType,Part2,Part3)) {  // Parts 1 - 3, 4 => Parts 1 - 4
                                          return partString + "s " + Part1 + spacer + ruleSet.dashRange + spacer + Part3;
                                      } else {  // Parts 1 - 3, 5
                                          return partString + "s " + Part1 + spacer + ruleSet.dashRange + spacer + Part2 + ", " + Part3;
                                      }
                                  }
                              } else if (RangeBetweenTwoThree) {
                                  if (testChronological(partType,Part1,Part2)) {  // Parts 1, 2 - 5 => // Parts 1 - 5
                                      return partString + "s " + Part1 + spacer + ruleSet.dashRange + spacer + Part3;
                                  } else {  // Parts 1, 3 - 5
                                      return partString + "s " + Part1 + ", " + Part2 + spacer + ruleSet.dashRange + spacer + Part3;
                                  }
                              } else if (testChronological(partType,Part1,Part2)) {
                                  if (testChronological(partType,Part2,Part3)) {  // Parts 1, 2, & 3 => Parts 1 - 3
                                      return partString + "s " + Part1 + spacer + ruleSet.dashRange + spacer + Part3;
                                  } else {  // Parts 1, 2, & 5
                                      return partString + "s " + Part1 + ", " + Part2 + ", & " + Part3;
                                  }
                              } else {  // Parts 1, 3, & 5
                                  return partString + "s " + Part1 + ", " + Part2 + ", & " + Part3;
                              }
                          },
                          partString;
                          if (beforepunct !== "") {
                              partString = " Part";  // Avoid adding the comma to a case like Foo... - Part 3
                          } else {
                              partString = ", Part";
                          }
                          if (Part1Type == "Roman") {
                              Part1 = Part1.toMusicBrainzUpperCase();
                          }
                          if (Part2Type == "Roman") {
                              Part2 = Part2.toMusicBrainzUpperCase();
                          }
                          if (Part3Type == "Roman") {
                              Part3 = Part3.toMusicBrainzUpperCase();
                          }
                          PartFilter:
                          switch (Part1Type) {
                              case "":  // Should never happen, but just in case
                                 return str;  // If have still have no part number 1, then somehow a non-part "Part" slipped through, so simply return it.
                              case "Arabic":
                                  // Valid PartNumberStyle outputs for part numbers starting with an arabic number first part number are:
                                  //     1: Part 1
                                  //     2: Part 1 & 2
                                  //     3: Part 1 - 3
                                  //     4: Part 1 & 3
                                  //     6: Part 1 - 3, 4
                                  //     5: Part 1, 3 - 4
                                  //     7: Part 1, 3 & 4
                                  switch (Part2Type) {
                                      case "":
                                          if (Part3Type === "") { //  Part 1 is Arabic, Parts 2 and 3 are empty
                                              partString = partString +  " " + Part1;  // Part 1
                                              break PartFilter;
                                          } else {
                                              /* These next only might happen if the input was REALLY poor, such that      */
                                              /* a one-word-only subtitle slipped into the p4 column, and if that one-word */
                                              /* happened to also be a valid number type.                                  */
                                                  partSubtitle = jQuery.trim(Part2 + " " + Part3 + " " + partSubtitle);
                                                  partString = partString + " " + Part1;
                                              break PartFilter;
                                          }
                                          break PartFilter;
                                      case "Arabic":
                                          switch (Part3Type) {
                                              case "":  // Arabic, Arabic, empty
                                                  partString = twoParts();
                                                  break PartFilter;
                                              case "Arabic":  // Arabic, Arabic, Arabic
                                                  partString = threeParts(Part3Type);
                                                  break PartFilter;
                                              default:
                                                  partSubtitle = jQuery.trim(Part3 + " " + partSubtitle);
                                                  partString = twoParts();
                                                  break PartFilter;
                                          }
                                          break PartFilter;
                                     /* Anything for Part1Type = Arabic, but Part2Type and/or Part3Type != Arabic     *
                                      * is not a valid Part number*s* formulation.  Combine Part2 and Part3, add them *
                                      * to p4, and set that as the value for partSubtitle.                            *
                                      * Note, not using partSubtitle directly, as it would inset an extra colon       *
                                      * between Part3 and partSubtitle.                                               */
                                      default:
                                          partSubtitle = jQuery.trim(Part2 + " " + Part3 + " " + partSubtitle);
                                          partString = partString + " " + Part1;
                                          break PartFilter;
                                  }
                                  break PartFilter;
                              case "Roman":
                                  Part1 = Part1.toMusicBrainzUpperCase();
                                  switch (Part2Type) {
                                  // Valid PartNumberStyle outputs for part numbers starting with a Roman numeral first part number are:
                                  //     1: Part I
                                  //     2: Parts I & II
                                  //     3: Parts I - III
                                  //     4: Parts I & III
                                  //     6: Parts I - III, V
                                  //     5: Parts I, III - IV
                                  //     7: Parts I, III & IV
                                      case "":
                                          if (Part3Type === "") {  //  Part 1 is Roman, Parts 2 and 3 are empty
                                              partString = partString +  " " + Part1;  // Part 1
                                              break PartFilter;
                                          } else {
                                              partSubtitle = jQuery.trim(Part2 + " " + Part3 + " " + partSubtitle);
                                              partString = partString + " " + Part1;
                                              break PartFilter;
                                          }
                                          break PartFilter;
                                      case "Roman":
                                          Part2 = Part2.toMusicBrainzUpperCase();
                                          switch (Part3Type) {
                                              case "":  // Roman, Roman, empty
                                                  partString = twoParts();
                                                  break PartFilter;
                                              case "Roman":  // Roman, Roman, Roman
                                                  Part3 = Part3.toMusicBrainzUpperCase();
                                                  partString = threeParts(Part3Type);
                                                  break PartFilter;
                                              default:
                                                  partSubtitle = jQuery.trim(Part3 + " " + partSubtitle);
                                                  partString = twoParts();
                                                  break PartFilter;
                                          }
                                          break PartFilter;
                                     /* Anything for Part1Type = Roman, but Part2Type and/or Part3Type != Roman       *
                                      * is not a valid Part number*s* formulation.  Combine Part2 and Part3, add them *
                                      * to p4, and set that as the value for partSubtitle.                            *
                                      * Note, not using partSubtitle directly, as it would inset an extra colon       *
                                      * between Part3 and partSubtitle.                                               */
                                      default:
                                          partSubtitle = jQuery.trim(Part2 + " " + Part3 + " " + partSubtitle);
                                          partString = partString + " " + Part1;
                                          break PartFilter;
                                  }
                                  break PartFilter;
                              case "Letters":
                                      Part1 = Part1.toMusicBrainzUpperCase();
                                      if (Part2Type == "Letters") {
                                          switch (Part3Type) {
                                          case "":
                                              // Letters, Letters, empty
                                              if (Part1.length == Part2.length) { // Part A The should become Part A: The, not Parts A & The
                                                  Part2 = Part2.toMusicBrainzUpperCase();
                                                  partString = twoParts();
                                                  break PartFilter;
                                              } else {
                                                  partSubtitle = jQuery.trim(Part2 + " " + partSubtitle);
                                                  partString = partString + " " + Part1;
                                                  break PartFilter;
                                              }
                                              break PartFilter;
                                          case "Letters":
                                              // Letters, Letters, Letters
                                              if (Part1.length == Part2.length) { // Part A The Foo should become Part A: The Foo, not Parts A, The, & Foo
                                                  Part2 = Part2.toMusicBrainzUpperCase();
                                                  if (Part1.length != Part3.length) { // Part A B The should become Parts A & B: The, not Parts A, B & The
                                                      partString = twoParts();
                                                      partSubtitle = jQuery.trim(Part3 + " " + partSubtitle);
                                                      break PartFilter;
                                                  } else { // Parts A, B, & D or Parts A, B & C --> Parts A - C
                                                      Part3 = Part3.toMusicBrainzUpperCase();
                                                      partString = threeParts(Part3Type);
                                                      break PartFilter;
                                                  }
                                              } else {
                                                  partSubtitle = jQuery.trim(Part2 + " " + Part3 + " " + partSubtitle);
                                                  partString = partString + " " + Part1;
                                                  break PartFilter;
                                              }
                                              break PartFilter;
                                          default:
                                              partSubtitle = jQuery.trim(Part2 + " " + Part3 + " " + partSubtitle);
                                              partString = partString + " " + Part1;
                                              break PartFilter;
                                          }
                                      } else {
                                         /* Anything for Part1Type = Letters, but Part2Type and/or Part3Type != Letters   *
                                          * is not a valid Part number*s* formulation.  Combine Part2 and Part3, add them *
                                          * to p4, and set that as the value for partSubtitle.                            *
                                          * Note, not using partSubtitle directly, as it would inset an extra colon       *
                                          * between Part3 and partSubtitle.                                               */
                                          partSubtitle = jQuery.trim(Part2 + " " + Part3 + " " + partSubtitle);
                                          partString = partString + " " + Part1;
                                          break PartFilter;
                                      }
                                      break PartFilter;
                              case "Spelled":
                                  switch (Part2Type) {
                                      case "":
                                          if (Part3Type === "") {  //   Spelled, empty, empty
                                              partString = partString +  " " + Part1;  // Part 1
                                              break PartFilter;
                                          } else {
                                              partSubtitle = jQuery.trim(Part3 + " " + partSubtitle);
                                              partString = partString + " " + Part1;
                                              break PartFilter;
                                          }
                                          break PartFilter;
                                      case "Spelled":
                                          switch (Part3Type) {
                                              case "":
                                                  partString = twoParts();
                                                  break PartFilter;
                                              case "Spelled":
                                                  partString = threeParts(Part3Type);
                                                  break PartFilter;
                                              default:
                                                  partSubtitle = jQuery.trim(Part3 + " " + partSubtitle);
                                                  partString = twoParts();
                                                  break PartFilter;
                                          }
                                          break PartFilter;
                                     /* Anything for Part1Type = Spelled, but Part2Type and/or Part3Type != Spelled   *
                                      * is not a valid Part number*s* formulation.  Combine Part2 and Part3, add them *
                                      * to p4, and set that as the value for partSubtitle.                            *
                                      * Note, not using partSubtitle directly, as it would inset an extra colon       *
                                      * between Part3 and partSubtitle.                                               */
                                      default:
                                          partSubtitle = jQuery.trim(Part2 + " " + Part3 + " " + partSubtitle);
                                          partString = partString + " " + Part1;
                                          break PartFilter;
                                  }
                                  break PartFilter;
                              case "Mixed":
                                  Part1 = fixCaps(Part1);
                                  switch (Part2Type) {
                                      case "":
                                          if (Part3Type === "") {  //  Part 1 is mixed, Parts 2 and 3 are empty
                                              partString = partString +  " " + Part1;  // Part 1
                                              break PartFilter;
                                          } else {
                                              partSubtitle = jQuery.trim(Part2 + " " + Part3 + " " + partSubtitle);
                                              partString = partString + " " + Part1;
                                              break PartFilter;
                                          }
                                          break PartFilter;
                                      case "Arabic":
                                      case "Mixed":
                                          if (!new RegExp("\\d").test(Part3)) {
                                              Part3Type = "Letters";  // We check for Mixed type before we check for Letters type - avoid 
                                          }                           // a mis-match on Parts 1a 1b The Subtitle
                                          Part2 = fixCaps(Part2);
                                          switch (Part3Type) {
                                              case "":
                                                  partString = twoParts();
                                                  break PartFilter;
                                              case "Arabic":   // Parts 1a, 1b, & 3
                                              case "Mixed":    // Parts 1a, 1b, & 1d
                                                  Part3 = fixCaps(Part3);
                                                  partString = threeParts(Part3Type);
                                                  break PartFilter;
                                              default:
                                                  Part2 = fixCaps(Part2);
                                                  partSubtitle = jQuery.trim(Part3 + " " + partSubtitle);
                                                  partString = twoParts();
                                                  break PartFilter;
                                          }
                                          break PartFilter;
                                      default:
                                          Part1 = fixCaps(Part1);
                                          partSubtitle = jQuery.trim(Part2 + " " + Part3 + " " + partSubtitle);
                                          partString = partString + " " + Part1;
                                          break PartFilter;
                                  }
                                  break PartFilter;
                          }
                          partSubtitle = jQuery.trim(jQuery.trim(partSubtitle) + " " + p5).replace(/^\s*[\-‐]+\s*/,"");
                          partSubtitle = jQuery.trim(partSubtitle).replace(/^:[\s\‐]*/,"");
                          if (partSubtitle !== "") {
                              if (partSubtitle.slice(0,1) == "/") {
                                  partString += " " + partSubtitle;
                              } else  {
                                  if (partSubtitle.length > 1) {
                                      if (partSubtitle.slice(0,2) == "\uDBC0\uDC01") {
                                          partString += " " + partSubtitle;
                                      } else if (partString.charCodeAt(0) >= NON_BMP_CHAR_CODES.BOTTOM && partString.charCodeAt(0) <= NON_BMP_CHAR_CODES.TOP) { 
                                          partString += titleCaseString(partSubtitle.slice(0,2)) + partSubtitle.slice(2);
                                      } else {
                                          partString += ": " + titleCaseString(partSubtitle.slice(0,1)) + partSubtitle.slice(1);
                                      }
                                  } else {
                                      partString += ": " + titleCaseString(partSubtitle.slice(0,1));
                                  }
                                  partString = partString.replace(": :",":");
                              }        // Capitalize the first word of the subtitle, in case it wasn't already (words like "the"), and get rid
                          }            // of the duplicated colon, if there is one.  (In case one got caught in p5, plus the one we just added.)
                          partString = jQuery.trim(partString.replace(/\s\s/g," "))
                                             .replace(/:\s\//,"/");  // Slash separators were protected, but still had the colon added.  Remove it.
                          if (beforepunct == ":") {  // Ticket 1518
                              return ", " + partString;
                          } else {
                              return beforepunct + " " + partString;
                          }
                     }
                );
            /* ---------------------------------------------------------------------*/
            /* Remove the comma before Part or Volume, if it would be right after   */
            /* other punctuation marks.  Also remove hyphen between that            */
            /* and Part or Volume, if present.                                      */
            /* ---------------------------------------------------------------------*/
            stringBeingFixed = stringBeingFixed.replace(new RegExp("([" + AllPunctuation + "]),\\s(Part|Volume)", "g"),"$1 $2")
                                               .replace(new RegExp("([" + AllPunctuation + "])\\s?(?:\\-|\\–|\\‐)\\s?(Part|Volume)", "g"),"$1 $2")
                                               .replace(/\s\sPart/,", Part")  // Add the comma back in - gets lost in the above line for cases like This Is a Song - (Parts 1 2): The Subtitle
            /* ---------------------------------------------------------------------*/
            /* Remove the any punctuation that slipped in before the                */
            /* part : subtitle colon separator.                                     */
            /* ---------------------------------------------------------------------*/
                                               .replace(new RegExp("([" + AllPunctuation + "])+:", "g"),":");
            /* ---------------------------------------------------------------------*/
            /* DiscNumberStyle.                                                     */
            /* ---------------------------------------------------------------------*/
            stringBeingFixed = stringBeingFixed.replace(/\(cd(\d)/i,"(cd $1")  // Safer to do this than to try and catch it in the big regexp,
                                               .replace(/\s(cd)\s?(\d)/gi," disc $2") // where removing this \/ \b would also then catch (disco)
                                               .replace(new RegExp("\\b\\,?(\\s)?[\\(\\[]?(bonus\\s)?(?:(?:dis(?:c|k))|(?:cd))(?:(?:\\b:?\\s?([" + allFoldableChars + "\\d]+):?(?:\\s(.+))?[\\)\\]]?)|$)", "i"),
                                                   function(str, p1, p2, p3, p4) {
                                                       if (!isNaN(parseInt(p3, 10))) { // Strip leading zeros
                                                           p3 = parseInt(p3, 10);
                                                       }
                                                       var tempString;
                                                       if (typeof(p4) !== "undefined") {
                                                           tempString = p4.replace(/[\(\)\[\]]/g, "");
                                                           if (p4.length > 1) {
                                                               tempString = titleCaseString(tempString);
                                                           }
                                                       }
                                                       if (jQuery.trim(p2) == "Bonus" || jQuery.trim(p2) == "bonus") {
                                                           var bonusName = jQuery.trim(p3 + " " + tempString);
                                                           if (bonusName.length > 0) {  // The bonus disc has a title
                                                               return p1 + "(bonus disc: " + bonusName + ")";
                                                           } else {  // The bonus disc has no title
                                                               return p1 + "(bonus disc)";
                                                           }
                                                       } else {
                                                           if (p4 === "" || typeof(tempString) == "undefined") { // The disc has no title
                                                               return p1 + "(disc " + p3 + ")";
                                                           } else {  // The disc has a title
                                                               return p1 + "(disc " + p3 + ": " + tempString + ")";
                                                           }
                                                       }
                                                   }
            ).replace(/:?\s+\(\s?\(/g," (").replace(/\s\)/g,")");
            /* ---------------------------------------------------------------------*/
            /* BoxSetStyle.                                                         */
            /* ---------------------------------------------------------------------*/
            stringBeingFixed = stringBeingFixed.replace(/\,?(?:\s)?[\(\[]?box\s(\d+)[\:\,\s](.+)?\(/i,
                function(str, p1, p2) {
                    if (typeof(p2) === "undefined" || p2 === "" || p2 === " ") {
                        return " (box "+p1+", ";
                    } else {
                        return " (box "+p1+": "+p2+", ";
                    }
                }
            );
            stringBeingFixed = stringBeingFixed.replace(/\s\,/,",");
            /* ---------------------------------------------------------------------*/
            /* Uppercase x's in date placeholders.                                  */
            /* ---------------------------------------------------------------------*/
            stringBeingFixed = stringBeingFixed.replace(/(\d[\dx]{3}(?:-[\dx]{2}){2})/gi,
                function(str,p1) {
                    return p1.toMusicBrainzUpperCase();
                }
            );
            /* ---------------------------------------------------------------------*/
            /* Fix commonly misspelled musical terms.                               */
            /* ---------------------------------------------------------------------*/
            stringBeingFixed = stringBeingFixed.replace(/(\b)[\s,]+(Op|Opus)[\s\.#]+($|\b)/i, ", Op. " ) // Opus
                                               .replace("accoustic","acoustic")
            /* Don't include # in the next regexp - it causes too many negative side effects. */
                                               .replace(/\,?\s+(?:no\.|Nᵒ|№|n|num|nr)[\s\.]+(\d+)/gi, ", "+ruleSet.numberAbbreviation+" $1" ) // Number
                                               .replace(/(\s|\()([A-H])(b|#|\sflat|\ssharp)(?:\s(major|minor)|\))/i,
                function(str, p1, p2, p3, p4) {
                    p2 = p2.toMusicBrainzUpperCase();
                    if (p3 == "b" || p3 == " Flat") {
                        return " "+p2+"-flat "+p4;
                    } else {
                        return " "+p2+"-sharp "+p4;
                    }
                }
            );
            /* ---------------------------------------------------------------------*/
            /* Remove useless ExtraTitleInformation.                                */
            /* ---------------------------------------------------------------------*/
            stringBeingFixed = stringBeingFixed.replace(/[\(\[]?bonus(\s+track)?s?\s*[\)\]]?$/i,"")
                                               .replace(/[\(\[]?(previously\s)?unreleaseds?\s*[\)\]]?$/i,"")
                                               .replace(/[\(\[]?secret(\s+track)?s?\s*[\)\]]?$/i,"")
                                               .replace(/[\(\[]?hidden(\s+track)?s?\s*[\)\]]?$/i,"")
                                               .replace(/[\(\[]?retail(\s+version)?\s*[\)\]]?$/i,"")
                                               .replace(/[\(\[]?encores?\s*[\)\]]?$/i,"");
            /* ---------------------------------------------------------------------*/
            /* Lowercase roles.                                                     */
            /* ---------------------------------------------------------------------*/
            stringBeingFixed = stringBeingFixed.replace(new RegExp("(\\(.*)" + ruleSet.roleWords + ":\\s?", "ig"),
                function(all, prior, word) {
                    return prior + word.toMusicBrainzLowerCase() + ": ";
                }
             );

            /* ---------------------------------------------------------------------*
            * Handle "Live". 
            * This next bit is a bit confusing.  It uses a statistical analysis
            * based on a January 2009 dump of every single track with "Live" at the
            * end of the title, breaking it into three categories:
            * 1) "Live" is correct (non-ETI)
            * 2) "Live" is a misspelling for "Life" or "Lives" (quite many of these!)
            * 3) "Live" is ETI.
            * This next bit captures all of #1 and #2, protects #1 and fixes #2
            * before running the ETI section.  Then after the ETI section,
            * we unprotect those in #1.  Testing this against the entire database,
            * applicable section of the database, it had not a single mismatch.
            * ---------------------------------------------------------------------*
            * Patterns fitting #1:
            *  & let live
            *  & live
            *  and let live
            *  and live
            *  as i live
            *  broadcasting live
            *  but live
            *  can't live
            *  foo's live
            *  gonna live
            *  gotta live
            *  he won't live
            *  i live
            *  i'll live
            *  is live
            *  let me live
            *  let's live
            *  lets live
            *  live, live
            *  saturday night live
            *  shall live
            *  she won't live
            *  ta live
            *  that they may live
            *  then you live
            *  they live
            *  to live
            *  wanna live
            *  want to live
            *  we live
            *  what they live
            *  where i live
            *  where u live
            *  where you live
            *  you never live
            * 
            * Patterns fitting #2 (or somehow otherwise misspelled):
            *  all my live
            *  for your live
            *  goes my live
            *  in my live
            *  it's my live
            *  livin' my live
            *  living my live
            *  of live
            *  of my live
            *  of our live
            *  road of live
            *  saturday nights' live
            *  saturday nite live
            *  save a live
            *  saved my live
            *  the good live
            *  want from live
            *  your live
            * ---------------------------------------------------------------------*
            * Fix #2 issues first:
            * ---------------------------------------------------------------------*/
            stringBeingFixed = stringBeingFixed.replace(/\s((?:all\smy|for\syour|goes\smy|i(?:t\'s|n)\smy|livin[\'g]\smy|of(?:\s(?:my|our))?|road\sof|sa(?:turday\sni(?:ghts\'|te)|ve(?:\sa|d\smy))|the\sgood|want\sfrom|your))\slive($|\s\/|\s\()/gi,
                function(str, p1, p2) {
                    switch (p1.toLowerCase()) {
                        case "of our":
                            return " " + p1 + " Lives" + p2;
                        case "saturday nights' live":
                        case "saturday nite live":
                            return " Saturday Night Live" + p2;
                        default:
                            return " " + p1 + " Life" + p2;
                    }
                }
            );
           /* ---------------------------------------------------------------------*
            * Now protect those in #1.
            * ---------------------------------------------------------------------*/
            stringBeingFixed = stringBeingFixed.replace(/\s((?:&(?:\slet)?|a(?:nd(?:\slet)?|s\si)|b(?:roadcasting|ut)|can\'t|foo\'s|go(?:nn|tt)a|he\swon\'t|i(?:\'ll|s)?|let(?:\sme|\'s|s)|s(?:aturday\snight|h(?:all|e\swon\'t))|t(?:h(?:at\sthey\smay|e(?:n\syou|y))|[ao])|w(?:an(?:na|t\sto)|h(?:at\sthey|ere\s(?:you|[iu]))|e)|you\snever)|live,)\slive($|\s\/|\s\()/gi, " $1 \uDBC0\uDC10 $2");
            stringBeingFixed = stringBeingFixed.replace(/^Live$/,"\uDBC0\uDC10");  // Live as 1-word title of a track
           /* ---------------------------------------------------------------------*
            * And strip punctuation crud that typically preceeds ETI Live.
            * ---------------------------------------------------------------------*/
            stringBeingFixed = stringBeingFixed.replace(/(([,-\/]\s?|→+|-+)l|\.L)ive$/," Live");
            /* --------------------------------------------------------------------------------------- */
            /* ExtraTitleInformationStyle.                                                             */
            /* --------------------------------------------------------------------------------------- */
            /* The only case which should still be missed is one that cannot be done programmatically, */
            /* as we don't know where the artist's name ends and the other ExtraTitleInfo begins:      */
            /* "Blah Ft. Erroll Flynn Some Remixname Remix" should become                              */
            /* "Blah (feat. Erroll Flynn) (Some remix Name) (remix)", but the best we can do is        */
            /* "Blah (feat. Erroll Flynn Some remix Name) (remix)".                                    */
            /* *****************************************************************************************/
            /* Create a new var stringInProgress.                                                      */
            /* ----------------------------------------------------------------------------------------*/
            /* Start with       Foo (bar) (baz) bap tim (bit) boo bum / Fuz (fam)                      */
            /* ----------------------------------------------------------------------------------------*/
            /* Split on /       Foo (bar) (baz) bap tim (bit) boo bum => stringPieces[0]               */
            /* ----------------------------------------------------------------------------------------*/
            /* For each in stringPieces[], create a new array stringBits[].                            */
            /* ----------------------------------------------------------------------------------------*/
            /* Split on (       Foo |bar) |baz) bap tim |bit) boo bum => stringBits[]                  */
            /* ----------------------------------------------------------------------------------------*/
            /* For each in stringBits[], create a new array spaceBits[].                               */
            /* ----------------------------------------------------------------------------------------*/
            /* Split on space:  Foo   stringPieces[0] stringBits[0] spaceBits[0]                       */
            /*                  bar)  stringPieces[0] stringBits[1] spaceBits[0]                       */
            /*                  baz)  stringPieces[0] stringBits[2] spaceBits[0]                       */
            /*                  bap   stringPieces[0] stringBits[2] spaceBits[1]                       */
            /*                  tim   stringPieces[0] stringBits[2] spaceBits[2]                       */
            /*                  bit)  stringPieces[0] stringBits[3] spaceBits[0]                       */
            /*                  boo   stringPieces[0] stringBits[3] spaceBits[1]                       */
            /*                  bum   stringPieces[0] stringBits[3] spaceBits[2]                       */
            /*                  Fuz   stringPieces[1] stringBits[0] spaceBits[0]                       */
            /*                  fam)  stringPieces[1] stringBits[1] spaceBits[0]                       */
            /* ----------------------------------------------------------------------------------------*/
            /* Create a new array etiBits[].                                                           */
            /* ----------------------------------------------------------------------------------------*/
            /* Walk through stringPieces[], starting from 0 and moving up.                             */
            /* Walk through stringBits[], starting from 0 and moving up.                               */
            /* Walk through spaceBits[], starting from the top and moving down to 0.                   */
            /* If the word does not end in a ), as long as the word in spaceBits[n] is an              */
            /* ExtraTitleInformation word, pop it from spaceBits[] and push it into etiBits[].         */
            /* When spaceBits[n] contains a word not in the ExtraTitleInformation list, stop.          */
            /* ----------------------------------------------------------------------------------------*/
            /* If spaceBits.length > 0, append it to stringInProgress.                                 */
            /* ----------------------------------------------------------------------------------------*/
            /* Now, if etiBits.length > 0, reverse() etiBits[], then .join(" ") it.                    */
            /* Then wrap it in () and append it to stringInProgress.                                   */
            /* ----------------------------------------------------------------------------------------*/
            /* Set stringBeingFixed equal to the newly built stringInProgress string.                  */
            /* *****************************************************************************************/
            stringBeingFixed = stringBeingFixed.replace(/(takes?)\s?(\d+)/gi,"$1$2"); // turn it into a single word, for the moment
            /* Use etiRemixerNames for compound words, like remixer names.  (Don't forget to add a bit down below to reverse it!)  */
            var etiRemixerNames = "a cappella|bonus beats|armand van helden|dirty south|ferry corsten|flip & fill|paul oakenfield",
                etiRemixers = etiRemixerNames.replace(/\s/g,""),
                /* Use notAloneETIWords for words that only appear if other ETI words from extraTitleInformationWords follow them. */
                notAloneETIWords = "dance|dialogue|disco|clean|extract|house|long|original|radio|short|studio|video|take|club",
                extraTitleInformationWords = "(acoustic|airplay|album|alternative|bonus|clubmix|composition|compositions|cut|" +
                                              "cuts|demo|demos|dirty|dub|dubs|edit|edits|excerpt|excerpts|extended|feat.|instrumental|" +
                                              "interlude|interludes|intro|karaoke|live|main|maxi|medley|megamix|megamixes|mix|mixes|" +
                                              "orchestral|outro|outtake|outtakes|re-edit|re-edited|re-edits|rehearsal|reinterpreted|" +
                                              "reinterpretation|reinterpretations|remake|remakes|remix|remixes|remixed|reprise|reprises|" +
                                              "rework|reworked|session|sessions|single|skit|skits|unplugged|version|versions|vocal|vs.|" +
                                              '12"|10"|7"|incomplete|interrupted|traditional|loop|interview|' +
                                              "takes?\\d+|" + notAloneETIWords + "|" + etiRemixers + "|" + ruleSet.extraTitleInfoWords,
                compoundETIWords = "(" + notAloneETIWords + ")";
                /* Prep the string for etiRemixerNames listings. */
                stringBeingFixed = stringBeingFixed.replace(new RegExp("(\\b|^|\\s|\\()(" + etiRemixerNames.replace(/\s/g,"\\s") + ")(\\b|$|\\s|\\))", "gi"),
                                                   function(str, p1, p2, p3) {
                                                       return p1+p2.toMusicBrainzLowerCase().replace(/\s/g,"")+p3;
                                                   }
                                               );
            var wordsToMatch = new RegExp("^"+extraTitleInformationWords+"(?:\\)|$)", "i"),
                stringInProgress = "",
                stringPieces = stringBeingFixed.split("/");
            jQuery.each(stringPieces, function(i) {
                var stringBits = jQuery.trim(stringPieces[i]).split("(");
                jQuery.each(stringBits, function(j) {
                    var spaceBits = jQuery.trim(stringBits[j]).split(" "),
                        etiBits = [];
                    for (var y = spaceBits.length-1; y > -1; y--) {
                        if (spaceBits[y].charAt(spaceBits[y].length-1) != ")" && wordsToMatch.test(spaceBits[y])) {  // Word is ETI and we're not inside another ()
                            etiBits.push(spaceBits.pop());
                        } else {
                            break;
                        }
                    }
                    if (j > 0) {
                        stringInProgress += " (";  // Add back the parentheses
                    }
                    if (spaceBits.length > 0) {  // Put the non ETI part back together.
                        var inETI = false,
                            lastWord = spaceBits[spaceBits.length-1],
                            nonETIString = "";
                        if (lastWord.charAt(lastWord.length-1) == ")" && wordsToMatch.test(spaceBits[y])) {  // Fix that final "ETIword)" that was already in ().
                            spaceBits[spaceBits.length-1] = lastWord.toMusicBrainzLowerCase();
                            inETI = true;
                        }
                        if (spaceBits.length > 0) {  // If the entire track title section was not wrapped in a () to begin with.
                            nonETIString = spaceBits.join(" ")  // Add it to stringInProgress.
                                                    .replace(/\sfeat\.\s(.+)/i,
                                                        function(str, p1) {
                                                            return " (feat. "+p1+")";
                                                        }
                                                    );
                        }
                        if (!inETI) { // TitleCaps-style
                            if (ruleSet.changeCapitalization) {
                                nonETIString = nonETIString.replace(/\bacappella\b/gi,"A Cappella"); // Turn it back into two words (non-ETI)
                            } else {  // Sentence-style
                                nonETIString = nonETIString.replace(/\bacappella\b/gi,"a cappella"); // Turn it back into two words (ETI)
                            }
                        } else {
                                nonETIString = nonETIString.replace(/\bacappella\b/gi,"a cappella"); // Turn it back into two words (ETI)
                        }
                        stringInProgress += nonETIString.replace(/bonusbeats/gi,"Bonus Beats"); // Turn it back into 2 words. - bonus beats
                    }
                    if (etiBits.length > 0) {  // Put the ETI part back together.
                        etiBits.reverse();     // We were pushing into the array while working backwards. Reverse the array to put the words back in the right order.
                        var tempHolder = " (" + etiBits.join(" ")  // Add it to stringInProgress.
                                                          .replace(/\bacappella\b/gi,"a cappella") // Turn it back into two words
                                                          .replace(/bonusbeats/gi,"bonus beats") // Turn it back into 2 words. - bonus beats
                                                          .toMusicBrainzLowerCase();  // And lowercase all the ETI.
                        if (j == (stringBits.length-1)) {
                            tempHolder += ")";
                        }
                        stringInProgress += tempHolder;
                    }
                });
                if (i != (stringPieces.length-1)) {
                    stringInProgress += " / ";  // Add back the slash
                }
            });
            stringBeingFixed = stringInProgress.replace(/([\b\s\(])(\d+)\"\)/,'$1$2" mix)') // Don't leave vinyl types dangling as (12")
                                               .replace(/\(\)/g,"") // "Foo (" becomes "Foo ()" - get rid of the empty ().
                                               .replace(/(?:\-|\‐)(acoustic|electric|Acoustic|Electric)(?:\-|\‐)/gi,
                                                   function (str,p1) {
                                                       return " ("+p1.toMusicBrainzLowerCase()+")";
                                                   }
                                               )
                                               /* Lowercase ETI words right up against a (. (Fixes those which were  */
                                               /* already in (), and thus got handled as if nonETI above.)           */
                                               .replace(new RegExp("(\\(" + extraTitleInformationWords + "[\\s\\)])", "gi"),
                                                   function(str, p1) {
                                                       return p1.toMusicBrainzLowerCase();
                                                   }
                                               );

//            stringBeingFixed = stringBeingFixed.replace("\\(([" + allFoldableChars + "])",
  //              function(str, p1) {
    //                return "(" + p1.toMusicBrainzUpperCase();
      //          }
        //    );

            if (ruleSet.changeCapitalization) {
                stringBeingFixed = stringBeingFixed.replace(new RegExp(compoundETIWords + "\\s(?!" + extraTitleInformationWords + ")", "gi"),
                    function(str, p1, p2) {
                        return p1.substr(0, 1).toMusicBrainzUpperCase() + p1.substr(1) + " " + p2;  // Titlecase ETI compound words if not followed by another ETI word
                    }
                );
//.replace(new RegExp(compoundETIWords + "\\s" + extraTitleInformationWords, "gi"),
  //                  function(str, p1, p2) {
    //                    return p1.toMusicBrainzLowerCase() + " " + p2;  // lowercase ETI compound words that are ETI if not followed by another ETI word
      //              }
        //        );
            }
            stringBeingFixed = stringBeingFixed.replace(/\(A\sCappella\)\svs\./g, "(a cappella) vs.")  // Treat vs. as a sentence split for A Cappella
                                               .replace(/\(feat\./gi, "(feat.")  // Don't capitalize feat.'s that already had () around them...
                                               .replace(/\(a\scappella\s\(/gi, "A Cappella (")  // Fix (a cappella (
                                               .replace(/\s(7|10|12)\"\s/gi, ' ($1" ')  // Fix 7/10/12" remix) (paren on the right, but not on the left, in original input)
                                               .replace(/\(remix/gi, "(remix")  // ...same for Remixes that already had () around them.
                                               .replace(/\((and|$)\)/gi, "$1")  // "and" isn't ETI when by itself.
                                               .replace(/\(megamix(es)?\)/gi, "Megamix$1")  // Megamix isn't ETI when by itself.
                                               .replace(/\(session(s)?\)/gi, "Session$1")  // Session(s) isn't ETI when by itself.
                                               .replace(/\(composition(s)?\)/gi, "Composition$1")  // Composition(s) isn't ETI when by itself.
                                               .replace(/(\((?:dance\s?)+\))$/gi,  // Dance isn't ETI when by itself.
                                                   function (str, p1) {
                                                       return p1.replace(/dance/g,"Dance").replace(/[\(\)]/g,"");
                                                   }
                                               ).replace(/\(dance\s\(/gi,"Dance (")
                                               .replace(/\)\)/g, ")")
                                               .replace(new RegExp("(\\b|^|\\s|\\()(" + etiRemixers + ")(\\b|$|\\s|\\))", "gi"),
                                                   function(str, p1, p2, p3) {
                                                       switch(p2) {
                                                           case "armandvanhelden" : return p1+"Armand van Helden"+p3;
                                                           case "dirtysouth"      : return p1+"Dirty South"+p3;
                                                           case "ferrycorsten"    : return p1+"Ferry Corsten"+p3;
                                                           case "flip&fill"       : return p1+"Flip & Fill"+p3;
                                                           case "pauloakenfold"   : return p1+"Paul Oakenfield"+p3;
                                                           default                : return p1+p2+p3;
                                                       }
                                                   }
                                               )
                                               .replace(/(takes?)(\d+)/gi,"$1 $2")    // Re-space the number.
                                               .replace("Oc (remix)", "OC ReMix")    // Fix OC ReMixes
                                               .replace("Encore (live)", "(live encore)")    // Fix word order
                                               .replace(/\(\s\(/gi, "(")  // '( (' -> '(' Happens if the entire title was ETI and wrapped in () to begin with.
                                               .replace(/(\([^\)]+)\s\(feat\./g,"$1 feat.")  //  Don't add extra ('s before feat. if the feat. is already inside a ().
                                               .replace(new RegExp("\\b" + ruleSet.lowerCaseWordsEndWords +  // fix lowerCaseWordsEndWords.  (Now I've Come *O*n, I'll Go)
                                                        "(\\" + ruleSet.sentenceEndingPunctuation.join("|\\") + "|,|$)", "ig"),
                                                        function (str, p1, p2) {
                                                            return titleCaseString(p1) + p2;
                                                        }
                                                    ).replace(new RegExp("(\\" + ruleSet.sentenceEndingPunctuation.join("|\\") + "|,|$)\\s" + 
                                                        ruleSet.lowerCaseWordsEndWords + "\\b", "ig"),  // fix lowerCaseWordsEndWords.   (Now I've Come, *O*n I'll Go)
                                                        function (str, p1, p2) {
                                                            return p1 + " " + titleCaseString(p2);
                                                        }
                                                    ).replace(new RegExp("\\b" + ruleSet.lowerCaseWordsEndWords +  // fix lowerCaseWordsEndWords.  (Now I've Come *O*n and I'll Go)
                                                        "\\s(and|&|or|vs.)", "ig"),
                                                        function (str, p1, p2) {
                                                            return titleCaseString(p1) + " " + p2;
                                                        }
                                                    );
           /* ---------------------------------------------------------------------*
            * Now unprotect those in "Live" group #1.
            * ---------------------------------------------------------------------*/
            stringBeingFixed = stringBeingFixed.replace(/\uDBC0\uDC10/g, "Live");
            /* ---------------------------------------------------------------------*/
            /* Warn about "incl."                                                   */
            /* ---------------------------------------------------------------------*/
            if (new RegExp("Incl.", "i").test(stringBeingFixed)) {
                storeError(text.including, type, number);
            }
            /* ---------------------------------------------------------------------*/
            /* Warn about covers.                                                   */
            /* ---------------------------------------------------------------------*/
            if (new RegExp("Cover\\)", "i").test(stringBeingFixed)) {
                storeError(text.covers, type, number);
            }
            /* ---------------------------------------------------------------------*/
            /* Fix the Netherlands.                                                 */
            /* ---------------------------------------------------------------------*/
            stringBeingFixed = stringBeingFixed.replace(/,\sthe\snetherlands/i, ", The Netherlands");
            /* ---------------------------------------------------------------------*/
            /* A-flat and A-sharp are not the word A.                               */
            /* ---------------------------------------------------------------------*/
            stringBeingFixed = stringBeingFixed.replace(/a(.Flat|Sharp)/,"A$1")
                                               .replace(/in\sa\,/,"in A,");
            /* ---------------------------------------------------------------------*/
            /* -flat and -sharp should always be lowercase.                         */
            /* ---------------------------------------------------------------------*/
            stringBeingFixed = stringBeingFixed.replace(/(\-|\‐)sharp/gi,"$1sharp")
                                               .replace(/(\-|\‐)flat/gi,"$1flat");
            /* ---------------------------------------------------------------------*/
            /* Remove times trapped in the track title.                             */
            /* ---------------------------------------------------------------------*/
            stringBeingFixed = stringBeingFixed.replace(/\((\d{1,2})\:\s?(\d{2})\)$/,
                function (str,p1,p2) {
                    storeError(text.timeRemoved+" "+p1+":"+p2, type, number);
                    return "";
                }
            );
            /* ---------------------------------------------------------------------*/
            /* Remove years included at the end of the track title.                 */
            /* ---------------------------------------------------------------------*/
            stringBeingFixed = stringBeingFixed.replace(/\(((?:19|20)\d{2})\)$/,
                function (str,p1) {
                    storeError(text.yearIncludedA+" ("+p1+") "+text.yearIncludedB, type, number);
                    return "";
                }
            );
            /* ---------------------------------------------------------------------*/
            /* Remove extra space between doubled periods.                          */
            /* ---------------------------------------------------------------------*/
            stringBeingFixed = stringBeingFixed.replace(/\.\s\./g,"..");
            /* ---------------------------------------------------------------------*/
            /* Fix square bracketed cases - ending [remix], [mix] and [feat. Foo].  */
            /* ---------------------------------------------------------------------*/
            stringBeingFixed = stringBeingFixed.replace(/\[\sRemix\]$/,"(remix)")
                                               .replace(/\[\sMix\]$/,"(mix)")
                                               .replace(/\[\s\(feat\.(.+)\]\)/,"(feat.$1)");
            /* ---------------------------------------------------------------------*/
            /* Various other cleanup.                                               */
            /* ---------------------------------------------------------------------*/
            stringBeingFixed = stringBeingFixed.replace(/(\s(\-|\‐|\:)|(\-|\‐|\:)\s)\s\(/," (")  // foo: (bar) and foo - live
                                               .replace(/(Symphony|Concerto),/g,"$1") // Symphony No. 1, not Symphony, No. 1
                                               .replace(/[\/:](?:\s+)?$/,"") // Trailing / and :
                                               .replace(/:\s\(/g," (") // Foo: (Bar
                                               .replace(/\(\s/g,"(") // ( Foo
                                               .replace(/\ba\.k\.a\.\b/gi,"a.k.a.");  // a.k.a. (Bypass *every* other acronym and "a" and "A" rule.)
            /* ---------------------------------------------------------------------*/
            /* UntitledTrackStyle                                                   */
            /* ---------------------------------------------------------------------*/
            switch (testString) {
                /* UntitledTrackStyle: untitled */
                case "":
                case "n/a":
                case "no title":
                case "none":
                case "untitled":
                case "untitled track":
                case "untitled blues":
                case "untitled i":
                case "untitled ii":
                case "untitled no.1":
                case "untitled no.2":
                case "untitled no.3":
                case "untitled no. 1":
                case "untitled no. 2":
                case "untitled no. 3":
                case "untitled one":
                case "(bonus live)":
                case "(bonus)":
                    stringBeingFixed = "[untitled]";
                    storeError(text.UntitledTrackUntitled, type, number);
                    break;
            /* UntitledTrackStyle: guitar solo */
                case "guitar solo":
                    stringBeingFixed = "[guitar solo]";
                    break;
            /* UntitledTrackStyle: applause */
                case "applause":
                case "clapping":
                    stringBeingFixed = "[applause]";
                    break;
            /* UntitledTrackStyle: crowd noise */
                case "‐‐ encore break‐‐":
                case "- encore break-":
                case "-encore break-":
                case "encore break":
                case "break":
                    stringBeingFixed = "[break]";
                    break;
                case "audience":
                case "crowd":
                case "crowd noise":
                case "encore crowd":
                    stringBeingFixed = "[crowd noise]";
                    break;
            /* UntitledTrackStyle: silence */
                case "silent track":
                case "blank":
                case "unused":
                case "no audio":
                case "silence":
                case "silent":
                    stringBeingFixed = "[silence]";
                    storeError(text.UntitledTrackSilence, type, number);
                    break;
            /* UntitledTrackStyle: unknown */
                case '"Unknown"':
                case "bonus track":
                case "bonus":
                case "hidden track":
                case "hidden":
                case "not known":
                case "unknown":
                case "[hidden bonus track]":
                case "hidden track 1":
                case "hidden track 2":
                case "hidden track 3":
                case "?":
                case "??":
                case "???":
                case "untitled hidden track":
                    stringBeingFixed = "[unknown]";
                    storeError(text.UntitledTrackUnknown, type, number);
                    break;
            /* UntitledTrackStyle: various common untitled track encapsulations */
                case "band introduction":
                case "band intro":
                case "band intro.":
                    stringBeingFixed = "[band introductions]";
                    break;
                case "introduction":
                case "-intro-":
                case "intro":
                case "intro.":
                    stringBeingFixed = "[introduction]";
                    break;
                case "outro":
                    stringBeingFixed = "[outro]";
                    break;
                case "encore":
                case '"encore"':
                    stringBeingFixed = "[encore]";
                    break;
                case "[ intermission ]":
                    stringBeingFixed = "[intermission]";
                    break;
                case "interview":
                    stringBeingFixed = "[interview]";
                    break;
                case "discussion":
                    stringBeingFixed = "[discussion]";
                    break;
                case "lecture":
                    stringBeingFixed = "[lecture]";
                    break;
                case "dialog from movie":
                case "dialog":
                case "dialogue":
                case "film dialogue":
                case "movie dialogue":
                    stringBeingFixed = "[dialogue]";
                    break;
                case "(banter)":
                case "banter":
                case "[banter]":
                    stringBeingFixed = "[banter]";
                    break;
                case "dj banter":
                    stringBeingFixed = "[DJ banter]";
                    break;
                case "announcements":
                    stringBeingFixed = "[announcements]";
                    break;
                case "skit":
                    stringBeingFixed = "[skit]";
                    break;
                case "speach":
                case "speech":
                    stringBeingFixed = "[speech]";
                    break;
                case "talk":
                case "talking":
                    stringBeingFixed = "[talking]";
                    break;
                case "radio skit":
                    stringBeingFixed = "[radio skit]";
                    break;
                case "studio announcer":
                    stringBeingFixed = "[studio announcer]";
                    break;
                case "radio announcer":
                    stringBeingFixed = "[radio announcer]";
                    break;
                default:
            }
            break;
        case "textartist":
        case "artist":
            switch (testString) {
                /* SpecialPurposeArtist style: anonymous */
                case "anon.":
                case "anon.":
                case "anon":
                case "anoniem":
                case "anonim":
                case "anonimo":
                case "anonym":
                case "anonyme":
                case "anonymous":
                case "anonymus":
                case "english anonymous":
                case "佚名":
                    stringBeingFixed = "[anonymous]";
                    storeError(text.spaAnon, type, number);
                    break;
                case "bollywood":
                    stringBeingFixed = "[bollywood]";
                    storeError(text.spaBollywood, type, number);
                    break;
                /* SpecialPurposeArtist style: Christmas music */
                case "christmas":
                case "christmas music":
                    stringBeingFixed = "[Christmas music]";
                    storeError(text.spaXmas, type, number);
                    break;
                /* SpecialPurposeArtist style: dialogue */
                case "announcer":
                case "radio announcer":
                case "banter":
                case "announcements":
                case "dj banter":
                case "対話":
                case "barfuss filmdialog":
                case "dialog":
                case "dialogue":
                case "film dialogue":
                case "movie dialogue":
                case "radio skit":
                case "skit":
                case "speach":
                case "speech":
                case "studio announcer":
                case "talk":
                case "talking":
                    stringBeingFixed = "[dialogue]";
                    storeError(text.spaDialogue, type, number);
                    break;
                /* SpecialPurposeArtist style: Disney */
                case "christmas with disney ":
                case "classic disney":
                case "disney babies":
                case "disney big band":
                case "disney cast":
                case "disney channel circle of stars":
                case "disney channel":
                case "disney characters":
                case "disney children's favorites":
                case "disney choir":
                case "disney pictures":
                case "disney princesses":
                case "disney records":
                case "disney soundtrack":
                case "disney soundtracks":
                case "disney studio chorus":
                case "disney's christmas":
                case "disney":
                case "disny":
                case "The disney big band":
                case "The disney chorus":
                case "The disney studio chorus":
                case "walt disney music company":
                case "walt disney pictures":
                case "walt disney records":
                case "walt disney world":
                case "walt disney's classic":
                case "walt disney's":
                case "walt disney":
                    stringBeingFixed = "Disney";
                    storeError(text.spaDisney, type, number);
                    break;
                /* SpecialPurposeArtist style: gregorian chant */
                case "canto gregoriano":
                case "chant":
                case "gregorian chant":
                case "gregorian chants":
                case "gregorian monks":
                case "gregoriano":
                case "gregorien":
                case "grégorien":
                case "schola gregoriana mediolanensis":
                    stringBeingFixed = "[gregorian chant]";
                    storeError(text.spaChant, type, number);
                    break;
                /* SpecialPurposeArtist style: musical */
                case "broadway cast recording":
                case "broadway cast":
                case "broadway":
                case "cast recording":
                case "ensemble":
                case "ensemble cast":
                case "london cast recording":
                case "london cast":
                case "new broadway cast recording":
                case "orginal cast recording":
                case "original australian cast recording":
                case "original broadway cast recording":
                case "original broadway cast":
                case "original cast recording":
                case "original cast recording":
                case "original cast":
                case "original london & broadway cast":
                case "original london cast":
                case "the musicals collection":
                case "the orginal cast":
                case "the original broadway cast":
                case "the original cast":
                case "the original caste":
                    stringBeingFixed = "[musical]";
                    storeError(text.spaMusical, type, number);
                    break;
                /* SpecialPurposeArtist style: nature sounds */
                case "echoes of nature":
                case "echos of nature":
                case "escape to serenity":
                case "gentle persuasion":
                case "gentle persuation":
                case "magic moods":
                case "natural wonders":
                case "nature":
                case "nature music":
                case "nature recordings":
                case "nature's relaxing sounds":
                case "natures ensemble":
                case "new world company":
                case "relax with":
                case "relax with…":
                case "relax with...":
                case "relaxation collection":
                case "relaxation soundscape":
                case "sound of nature":
                case "sounds of nature":
                case "soundscape":
                case "soundscapes":
                case "the relaxation collection":
                case "the sounds of nature":
                    stringBeingFixed = "[nature sounds]";
                    storeError(text.spaNature, type, number);
                    break;
                /* NoArtist style */
                case "":
                case "bass tones":
                case "n / a":
                case "n /a":
                case "n/ a":
                case "n/a":
                case "no artist":
                case "no-artist":
                case "noartist":
                case "none given":
                case "none listed":
                case "none":
                case "sound effect":
                case "sound effects":
                case "sound ideas":
                case "virtual audio environments":
                case "芸術家はありません":
                case "芸術家はない":
                case "音響効果":
                    stringBeingFixed = "[no artist]";
                    storeError(text.NoArtist, type, number);
                    break;
                /* SpecialPurposeArtist style: soundtrack */
                case "20th century fox":
                case "b.o. film":
                case "cartoni animati":
                case "cartoon network":
                case "cinema century":
                case "film st":
                case "full cast":
                case "movie love songs":
                case "movie score":
                case "original motion picture cast":
                case "original motion picture soundtrack":
                case "original motion picture soundtrak":
                case "original score":
                case "original sound track":
                case "original soundtack":
                case "original soundtrack score":
                case "original soundtrack":
                case "ost":
                case "ＴＶサントラ":
                case "ゲーム・ミュージック":
                case "サウンドトラック":
                case "サントラ":
                case "soundtrack":
                    stringBeingFixed = "[soundtrack]";
                    storeError(text.spaSoundtrack, type, number);
                    break;
                /* SpecialPurposeArtist style: spiritual */
                case "spiritual":
                case "[spiritual]":
                    stringBeingFixed = "[spiritual]";
                    storeError(text.spaSpiritual, type, number);
                    break;
                /* SpecialPurposeArtist style: traditional */
                case "geleneksel":
                case "olde english carol":
                case "tautas dziesma":
                case "tautasdziesma":
                case "trad":
                case "trad.":
                case "tradition":
                case "traditional artists":
                case "traditional english":
                case "traditional native american music":
                case "traditional prayer":
                case "traditional":
                case "traditionale":
                case "traditionnel":
                case "tradizionale":
                    stringBeingFixed = "[traditional]";
                    storeError(text.spaTrad, type, number);
                    break;
                /* UnknownArtistStyle */
                case "hidden artist":
                case "hòa tấu":
                case "inconnu":
                case "instr.":
                case "instrumental music":
                case "instrumental score":
                case "instrumental version":
                case "instrumental":
                case "intro":
                case "musical interlude":
                case "neznámý":
                case "nieznany":
                case "ningún artista":
                case "not known":
                case "numerous artist":
                case "onbekend":
                case "originaldarsteller":
                case "outro":
                case "performers unknown":
                case "several":
                case "sierra on-line":
                case "tuntematon":
                case "tuntetamon":
                case "ukjent":
                case "unbekannt":
                case "unidentified Performers":
                case "unidentified":
                case "unknown artist":
                case "unknown group":
                case "unknown guitarists":
                case "unknown singer":
                case "unknown trio":
                case "unknown":
                case "unknown":
                case "unkown":
                case "unlisted artist":
                case "unlisted":
                case "unnamed artist":
                case "unown":
                case "アーティスト情報なし":
                case "ワンダーミンツ":
                case "不詳":
                case "佚名.":
                case "書香音樂系列一":
                case "未知":
                case "未知の芸術家":
                case "沒有歌星":
                case "韓國群星":
                    stringBeingFixed = "[unknown]";
                    storeError(text.spaUnknown, type, number);
                    break;
                case "va":
                case "various artists":
                    stringBeingFixed = "Various Artists";
                    break;
                default:
            }
            break;
        case "label":
            switch (stringBeingFixed.toMusicBrainzLowerCase()) {
                case "no label":
                case "none":
                case "n/a":
                case "white label":
                case "self release":
                case "self-release":
                case "self released":
                case "self-released":
                case "auto-release":
                case "blank":
                case "not on label":
                case "auto-product":
                    stringBeingFixed = "[no label]";
                    storeError(text.NoLabel, type, number);
                    break;
                case "unknown":
                    stringBeingFixed = "";
                    storeError(text.UnknownLabel, type, number);
                    break;
                default:
            }
            break;
        default:
    }
    var parenCount = [],
        currentChar;
    for (var z = 0; z < 38; z++) {
        parenCount[z] = 0;
    }
    for (var i = 0; i < stringBeingFixed.length; i++) {
        currentChar = stringBeingFixed.charAt(i);
        switch (currentChar) {
        case "(":
            parenCount[0]++;
            break;
        case ")":
            parenCount[1]++;
            break;
        case "{":
            parenCount[2]++;
            break;
        case "}":
            parenCount[3]++;
            break;
        case "[":
            parenCount[4]++;
            break;
        case "]":
            parenCount[5]++;
            break;
        case "<":
            parenCount[6]++;
            break;
        case ">":
            parenCount[7]++;
            break;
        case "〈":
            parenCount[8]++;
            break;
        case "〉":
            parenCount[9]++;
            break;
        case "《":
            parenCount[10]++;
            break;
        case "》":
            parenCount[11]++;
            break;
        case "«":
            parenCount[12]++;
            break;
        case "»":
            parenCount[13]++;
            break;
        case "‹":
            parenCount[14]++;
            break;
        case "›":
            parenCount[15]++;
            break;
        case "「":
            parenCount[16]++;
            break;
        case "」":
            parenCount[17]++;
            break;
        case "『":
            parenCount[18]++;
            break;
        case "』":
            parenCount[19]++;
            break;
        case "〔":
            parenCount[20]++;
            break;
        case "〕":
            parenCount[21]++;
            break;
        case "｛":
            parenCount[22]++;
            break;
        case "｝":
            parenCount[23]++;
            break;
        case "〈":
            parenCount[24]++;
            break;
        case "〉":
            parenCount[25]++;
            break;
        case "《":
            parenCount[26]++;
            break;
        case "》":
            parenCount[27]++;
            break;
        case "【":
            parenCount[28]++;
            break;
        case "】":
            parenCount[29]++;
            break;
        case "〖":
            parenCount[30]++;
            break;
        case "〗":
            parenCount[31]++;
            break;
        case "〘":
            parenCount[32]++;
            break;
        case "〙":
            parenCount[33]++;
            break;
        case "〚":
            parenCount[34]++;
            break;
        case "〛":
            parenCount[35]++;
            break;
        case "⁅":
            parenCount[36]++;
            break;
        case "⁆":
            parenCount[37]++;
            break;
        default:
        }
    }
    if (reportErrors) {
        var checkBalance = function(countA, countB, textName, charA, charB) {
            if (parenCount[countA] > parenCount[countB]) {
                storeError(text.TextContains+' ' + Math.abs((parenCount[countA] - parenCount[countB])) + ' '+textName+" "+charA, type, number);
            } else if (parenCount[countB] > parenCount[countA]) {
                storeError(text.TextContains+' ' + Math.abs((parenCount[countB] - parenCount[countA])) + ' '+textName+" "+charB, type, number);
            }
        };
        checkBalance(0,1,text.Parens,"(",")");
        checkBalance(2,3,text.Braces,"{","}");
        checkBalance(4,5,text.SquareBrackets,"[","]");
        checkBalance(6,7,text.Chevrons,"<",">");
        checkBalance(8,9,text.Angle,"〈","〉");
        checkBalance(10,11,text.DoubleAngle,"《","》");
        if(ruleSet.mirroredGuillemets) {
            checkBalance(12,13,text.Guillemets,"«","»");
            checkBalance(14,15,text.Guillemets,"‹","›");
        }
        checkBalance(16,17,text.Hook,"「","」");
        checkBalance(18,19,text.Corner,"『","』");
        checkBalance(20,21,text.Tortoise,"〔","〕");
        checkBalance(22,23,text.Braces,"｛","｝");
        checkBalance(24,25,text.Hill,"〈","〉");
        checkBalance(26,27,text.HillDouble,"《","》");
        checkBalance(28,29,text.Kakko,"【","】");
        checkBalance(30,31,text.Lenticular,"〖","〗");
        checkBalance(32,33,text.TortoiseWhite,"〘","〙");
        checkBalance(34,35,text.SquareWhite,"〚","〛");
        checkBalance(34,35,text.SquareWhite,"〚","〛");
        checkBalance(34,35,text.SquareQuill,"⁅","⁆");
    }
    /* ---------------------------------------------------------------------*
     * Unprotect slashes.                                                   *
     * ---------------------------------------------------------------------*/
    stringBeingFixed = stringBeingFixed.replace(/\uDBC0\uDC01(.?)/g,
        function(str, p1) {
            if (ruleSet.changeCapitalization) {
                return "/" + p1.toMusicBrainzUpperCase();  // We protected the / as non-punctuation, so any letter just after it wouldn't have received the normal capitalization.
            } else {
                return "/" + p1;
            }
        }
    );
    /* ---------------------------------------------------------------------* 
     * Special spacings / phrases.  Done last, to avoid case changes 
     * at beginnings of sentences, etc.
     * ---------------------------------------------------------------------*/
    stringBeingFixed = stringBeingFixed.replace(/R&\sb/i, "R&B")            // R&B
                                       .replace(/\so'\s/gi," o' ")          // o'
                                       .replace(/'o'/gi,"'O'")              // 'O'
                                       .replace(/\bt'\s/gi,"t' ")            // t'
                                       .replace(/\b't\s/gi,"'t ")           // 't
                                       .replace(/\'n\'/gi," 'n' ")          // 'n'
                                       .replace(/\"a([\s\"])/gi,'"A$1')     // "A and "A"
                                       .replace(/(\s)?$H/g,"$1$h")          // $H -> $h  (Ca$h, $hort, etc.)
                                       .replace(/a([\-\‐])/gi,'A$1')        // A-
                                       .replace(/\s{2,}/g," ");
    return jQuery.trim(stringBeingFixed);
}
/*************************************************************************************
 * Function: fixDuration ( GC group type, track number / event number, string to be  *
 *                         processed, optional: string containing a duration from a  *
 *                         prior pass by fixDuration )                               *
 *                                                                                   *
 * Special mode of Guess Case, fixes common issues in track duration fields.         *
 *************************************************************************************/
function fixDuration(type, number, stringBeingFixed, originalDuration) {
    stringBeingFixed = stringBeingFixed.replace(/s/g, "");
    /* --------------------------------------------------------------------- */
    /* Carry over original string information, for reporting purposes,       */
    /* when running recursively.                                             */
    /* --------------------------------------------------------------------- */
    if (typeof(originalDuration) == "undefined") {
        originalDuration = stringBeingFixed;
    }
    /* --------------------------------------------------------------------- */
    /* Test for an empty duration string.                                    */
    /* --------------------------------------------------------------------- */
    if (stringBeingFixed.length === 0) {
        if (reportErrors) {
            clearErrors(type, number);
            storeError('Warning: The duration field cannot be left empty.', type, number);
        }
        return stringBeingFixed;
    }
    /* --------------------------------------------------------------------- */
    /* Correct for invalid separator punctuation.                            */
    /* --------------------------------------------------------------------- */
    stringBeingFixed = stringBeingFixed.replace(/[,\.;\'\"~`]/, ":");
    if (reportErrors) {
        if (stringBeingFixed != originalDuration) {
            storeError('Warning: track duration was corrected from ' + originalDuration + ' to ' + stringBeingFixed + ".", type, number);
        }
    }
    /* --------------------------------------------------------------------- */
    /* Test for a (hhhh:)(mmm)m:ss input string structure.                   */
    /* --------------------------------------------------------------------- */
    if (new RegExp(/^((:\d{0,4}|\d{0,4}:){0,2})?(\d{1,2})$/).test(stringBeingFixed)) {
        var times = stringBeingFixed.split(":"),
            seconds = 0;
        switch (times.length) {
        case 1:
            seconds = parseInt(times[0], 10);
            break;
        case 2:
            seconds = parseInt(times[0], 10) * 60 + parseInt(times[1], 10);
            break;
        case 3:
            seconds = parseInt(times[0], 10) * 3600 + parseInt(times[1], 10) * 60 + parseInt(times[2], 10);
            break;
        default:
            if (reportErrors) {
                storeError('Caution: Invalid time format', type, number);
            }
            seconds = null;
        }
        if (seconds < 2147483 && seconds !== null) {
            var minutes = Math.floor(seconds / 60);
            seconds = seconds % 60;
            if (seconds < 10) {
                stringBeingFixed = minutes + ":0" + seconds;
            } else {
                stringBeingFixed = minutes + ":" + seconds;
            }
            if (reportErrors) {
                if (originalDuration != stringBeingFixed) {
                    clearErrors(type, number);
                    storeError('Warning: track duration was corrected from ' + originalDuration + ' to ' + stringBeingFixed + ".", type, number);
                }
            }
            return stringBeingFixed;
        } else if (seconds !== null) {
            if (reportErrors) {
                clearErrors(type, number);
                storeError('Sorry, the database cannot store track durations longer than 24 days, 20 hours, 31 minutes, and 23 seconds.', type, number);
            }
        }
        /* --------------------------------------------------------------------- *
         * Turn "111" and "1111" into "1:11" and "11:11".                       
         *                                                                       
         * Note: This uses slice in a way that  will break wide chars if run on them.     
         * On the other hand, wide characters would not be valid durations anyhow.
         * --------------------------------------------------------------------- */
    } else if (new RegExp(/^\d{3,10}/).test(stringBeingFixed)) {
        switch (stringBeingFixed.length) {
        case 3:
            stringBeingFixed = stringBeingFixed.slice(0, 1) + ":" + stringBeingFixed.slice(1);
            if (reportErrors) {
                clearErrors(type, number);
                storeError('Warning: track duration was corrected from ' + originalDuration + ' to ' + stringBeingFixed + ".", type, number);
            }
            break;
        case 4:
            stringBeingFixed = stringBeingFixed.slice(0, 2) + ":" + stringBeingFixed.slice(2);
            if (reportErrors) {
                clearErrors(type, number);
                storeError('Warning: track duration was corrected from ' + originalDuration + ' to ' + stringBeingFixed + ".", type, number);
            }
            break;
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
        case 10:
            if (reportErrors) {
                clearErrors(type, number);
                storeError("Error: invalid track duration.");
            }
            return stringBeingFixed;
        default:
        }
        /* --------------------------------------------------------------------- */
        /* Recheck, to catch cases like "177".                                   */
        /* --------------------------------------------------------------------- */
        return fixDuration(type, number, stringBeingFixed, originalDuration);
    } else {
        if (reportErrors) {
            clearErrors(type, number);
            storeError('Caution: Invalid time format', type, number);
        }
    }
    return stringBeingFixed;
}
/*************************************************************************************
 * Function: fixIotaSubstrings ( string )                                            *
 *                                                                                   *
 * Special mode of Guess Case, fixes varying character capitalization in   *
 * ancient Greek (not used in modern Greek, so safe to use on any string).           *
 *************************************************************************************/
function fixIotaSubstrings(stringToFix) {
    var iotaCharacters = "(ᾼ|ᾈ|ᾉ|ᾌ|ᾊ|ᾎ|ᾍ|ᾋ|ᾏ|ῌ|ᾘ|ᾙ|ᾜ|ᾚ|ᾞ|ᾝ|ᾛ|ᾟ|ῼ|ᾨ|ᾩ|ᾬ|ᾪ|ᾮ|ᾭ|ᾫ|ᾯ|αι|άι|ὰι|ᾶι|ἀι|" +
                           "ἁι|ἄι|ἂι|ἆι|ἅι|ἃι|ἇι|ηι|ήι|ὴι|ῆι|ἠι|ἡι|ἤι|ἢι|ἦι|ἥι|ἣι|ἧι|ωι|ώι|ὼι|ῶι|" +
                           "ὠι|ὡι|ὤι|ὢι|ὦι|ὥι|ὣι|ὧι)";
    stringToFix = stringToFix.replace(new RegExp("([\\u0370-\\u03FF\\u1F00-\\u1FFF])" + iotaCharacters, "gi"),
        function(str, p1, p2) {
            switch (p2) {
                case "ᾼ":
                    return p1+"Αι";
                case "ᾈ":
                    return p1+"Ἀι";
                case "ᾉ":
                    return p1+"Ἁι";
                case "ᾌ":
                    return p1+"Ἄι";
                case "ᾊ":
                    return p1+"Ἂι";
                case "ᾎ":
                    return p1+"Ἆι";
                case "ᾍ":
                    return p1+"Ἅι";
                case "ᾋ":
                    return p1+"Ἃι";
                case "ᾏ":
                    return p1+"Ἇι";
                case "ῌ":
                    return p1+"Ηι";
                case "ᾘ":
                    return p1+"Ἠι";
                case "ᾙ":
                    return p1+"Ἡι";
                case "ᾜ":
                    return p1+"Ἤι";
                case "ᾚ":
                    return p1+"Ἢι";
                case "ᾞ":
                    return p1+"Ἦι";
                case "ᾝ":
                    return p1+"Ἥι";
                case "ᾛ":
                    return p1+"Ἣι";
                case "ᾟ":
                    return p1+"Ἧι";
                case "ῼ":
                    return p1+"Ωι";
                case "ᾨ":
                    return p1+"Ὠι";
                case "ᾩ":
                    return p1+"Ὡι";
                case "ᾬ":
                    return p1+"Ὤι";
                case "ᾪ":
                    return p1+"Ὢι";
                case "ᾮ":
                    return p1+"Ὦι";
                case "ᾭ":
                    return p1+"Ὥι";
                case "ᾫ":
                    return p1+"Ὣι";
                case "ᾯ":
                    return p1+"Ὧι";
                case "αι":
                    return p1+"ᾳ";
                case "άι":
                    return p1+"ᾴ";
                case "ὰι":
                    return p1+"ᾲ";
                case "ᾶι":
                    return p1+"ᾷ";
                case "ἀι":
                    return p1+"ᾀ";
                case "ἁι":
                    return p1+"ᾁ";
                case "ἄι":
                    return p1+"ᾄ";
                case "ἂι":
                    return p1+"ᾂ";
                case "ἆι":
                    return p1+"ᾆ";
                case "ἅι":
                    return p1+"ᾅ";
                case "ἃι":
                    return p1+"ᾃ";
                case "ἇι":
                    return p1+"ᾇ";
                case "ηι":
                    return p1+"ῃ";
                case "ήι":
                    return p1+"ῄ";
                case "ὴι":
                    return p1+"ῂ";
                case "ῆι":
                    return p1+"ῇ";
                case "ἠι":
                    return p1+"ᾐ";
                case "ἡι":
                    return p1+"ᾑ";
                case "ἤι":
                    return p1+"ᾔ";
                case "ἢι":
                    return p1+"ᾒ";
                case "ἦι":
                    return p1+"ᾖ";
                case "ἥι":
                    return p1+"ᾕ";
                case "ἣι":
                    return p1+"ᾓ";
                case "ἧι":
                    return p1+"ᾗ";
                case "ωι":
                    return p1+"ῳ";
                case "ώι":
                    return p1+"ῴ";
                case "ὼι":
                    return p1+"ῲ";
                case "ῶι":
                    return p1+"ῷ";
                case "ὠι":
                    return p1+"ᾠ";
                case "ὡι":
                    return p1+"ᾡ";
                case "ὤι":
                    return p1+"ᾤ";
                case "ὢι":
                    return p1+"ᾢ";
                case "ὦι":
                    return p1+"ᾦ";
                case "ὥι":
                    return p1+"ᾥ";
                case "ὣι":
                    return p1+"ᾣ";
                case "ὧι":
                    return p1+"ᾧ;";
            }
        }
    );
    return stringToFix;
}
/*************************************************************************************
 * Function: fixCommonItalianProblems ( string )                                     *
 *                                                                                   *
 * Special mode of Guess Case, fixes common minor accent issues with Italian.        *
 *************************************************************************************/
function fixCommonItalianProblems(stringToFix, type, number) {
    stringToFix = stringToFix.replace(/(\s|^)(p)erch(?:è|e\')(\W|$)/gi,"$1$2erché$3"); // perche', perchè -> perché
    stringToFix = stringToFix.replace(/(\s|^)(p)oich(?:è|e\')(\W|$)/gi,"$1$2oiché$3"); // poiche', poichè -> poiché
    stringToFix = stringToFix.replace(/(\s|^)(s)ara\'(\W|$)/gi,"$1$2arà$3"); // sara' -> sarà
    stringToFix = stringToFix.replace(/(\s|^)(s)i\'(\W|$)/gi,"$1$2ì$3"); // si' -> sì
    if (new RegExp("e\\'(\\W|$)", "i").test(stringToFix)) {  // -e' --> either -é or -è
        storeError(text.WrongAccent, type, number);
    }
    return stringToFix;
}
/*************************************************************************************
 * Function: warnGerman ( string )                                                   *
 *                                                                                   *
 * Special mode of Guess Case, warns about making "SS" lowercased.                   *
 *************************************************************************************/
function warnGerman(stringToFix, type, number) {
    if (new RegExp("SS").test(stringToFix)) {
        storeError(text.esGerman, type, number);
    }
}
/*************************************************************************************
 * Function: guessMyCase (GC group type, track number / event number, string to      *
 *                        be processed )                                             *
 *                                                                                   *
 * Main interface function for the Guess Case routines.                              *
 *************************************************************************************/
function guessMyCase(type, number, stringToFix, language, mode, keepUpperCased) {
    if (typeof(mode) !== "undefined") {
        $mode = mode;
    }
    if (typeof(keepUpperCased) !== "undefined") {
        $gckeepUppercased = keepUpperCased;
    }
    stringToFix = fullWidthConverter(stringToFix);
    switch (language) {
        case "34":  //  Azerbaijani
        case "94":  //  Crimean Tatar
        case "211": //  Kazakh
        case "408": //  Tatar
        case "433": //  Turkish
            TurkishI = true;
            break;
        default:
            TurkishI = false;
    }
    // If Turkish I option is selected, override the default language setting for Turkish I mode.
    if (typeof($gcTurkishI) != "undefined") {
        if ($gcTurkishI == true) {
            TurkishI = true;
        }
    }
    if (stringToFix.length > 0) {
        var ruleSet = loadRuleSet(type, $mode),
            finalString;
        if (type == "duration") {
            finalString = fixDuration(type, number, stringToFix);
            addErrorReport(type, number);
            return finalString;
        } else {
            if (validateRuleSet(ruleSet, $mode) === true) {
                switch (language) {
                    case "145": // German
                        warnGerman(stringToFix, type, number);
                        break;
                    case "195": // Italian
                        finalString = fixCommonItalianProblems(finalString, type, number);
                        break;
                    default:
                }
                finalString = applyGuidelines(
                    ruleSet,
                    type,
                    number,
                    fixCapitalization(
                        ruleSet,
                        type,
                        number,
                        findBasicErrors(
                            ruleSet,
                            type,
                            number,
                            stringToFix,
                            $mode,
                            $gckeepUppercased),
                        $mode,
                        $gckeepUppercased),
                    $mode);
                finalString = fixIotaSubstrings(finalString);
                addErrorReport(type, number);
                return finalString;
            }
        }
    }
    return "";
}
