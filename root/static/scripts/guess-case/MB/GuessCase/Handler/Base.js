/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (c) 2005 Stefan Kestenholz (keschte)
   Copyright (C) 2010 MetaBrainz Foundation

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
MB.GuessCase.Handler = (MB.GuessCase.Handler) ? MB.GuessCase.Handler : {};

/**
 * Base class of the type specific handlers
 *
 * @see GcArtistHandler
 * @see GcLabelHandler
 * @see GcReleaseHandler
 * @see GcTrackHandler
 */
MB.GuessCase.Handler.Base = function () {
    var self = {};

    // ----------------------------------------------------------------------------
    // member variables
    // ---------------------------------------------------------------------------

    // Values of the specialcases defined in
    self.NOT_A_SPECIALCASE = -1;

    // artist cases
    self.SPECIALCASE_UNKNOWN = 10;          // [unknown]

    // release cases
    self.SPECIALCASE_DATA_TRACK = 20;       // [data track]

    // track cases
    self.SPECIALCASE_DATA_TRACK = 30;       // [data track]
    self.SPECIALCASE_SILENCE = 31;          // [silence]
    self.SPECIALCASE_UNTITLED = 32;         // [untitled]
    self.SPECIALCASE_CROWD_NOISE = 33;      // [crowd noise]
    self.SPECIALCASE_GUITAR_SOLO = 34;      // [guitar solo]
    self.SPECIALCASE_DIALOGUE= 35;          // [dialogue]

    // ----------------------------------------------------------------------------
    // member functions
    // ---------------------------------------------------------------------------

    /**
     * Returns true if the number corresponds to a special case.
     **/
    self.isSpecialCase = function (num) {
    return (num != self.NOT_A_SPECIALCASE);
    };

    /**
     * Returns the correctly formatted string of the
     * special case, or the input string if num
     * does not correspond to a special case
     **/
    self.getSpecialCaseFormatted = function (is, num) {
        switch (num) {
            case self.SPECIALCASE_DATA_TRACK:
                return "[data track]";

            case self.SPECIALCASE_SILENCE:
                return "[silence]";

            case self.SPECIALCASE_UNTITLED:
                return "[untitled]";

            case self.SPECIALCASE_UNKNOWN:
                return "[unknown]";

            case self.SPECIALCASE_CROWD_NOISE:
                return "[crowd noise]";

            case self.SPECIALCASE_GUITAR_SOLO:
                return "[guitar solo]";

            case self.SPECIALCASE_DIALOGUE:
                return "[dialogue]";

            case self.NOT_A_SPECIALCASE:
            default:
                return is;
        }
    };

    /**
     * Processes the next word from the GuessCaseInput
     * returns true, if there are more words, else false.
     **/
    self.processWord = function () {
        if (self.doWhiteSpace()) {
        } else {
            // dump information if in debug mode.

            // try to decide if we need to check all the special cases,
            // or if it's possibly just a plain word. this should improve
            // performance a bit, since we don't have to go through all
            // the regex expressions to find that we didn't have to
            // check them.
            var handled = false;
            if (!gc.re.SPECIALCASES) {
                gc.re.SPECIALCASES = /(&|¿|¡|\?|\!|;|:|'|‘|’|"|\-|\+|,|\*|\.|#|%|\/|\(|\)|\{|\}|\[|\])/;
            }
            if (gc.i.matchCurrentWord(gc.re.SPECIALCASES)) {
                handled = true;

                if (self.doDoubleQuote()) {
                } else if (self.doSingleQuote()) {
                } else if (self.doOpeningBracket()) {
                } else if (self.doClosingBracket()) {
                } else if (self.doComma()) {
                } else if (self.doPeriod()) {
                } else if (self.doLineStop()) {
                } else if (self.doAmpersand()) {
                } else if (self.doSlash()) {
                } else if (self.doColon()) {
                } else if (self.doHyphen()) {
                } else if (self.doInvertedMarks()) {
                } else if (self.doPlus()) {
                } else if (self.doAsterix()) {
                } else if (self.doDiamond()) {
                } else if (self.doPercent()) {
                } else {
                    handled = false;
                }
            }
            if (!handled) {
                if (self.doDigits()) {
                } else if (self.doAcronym()) {
                } else {
                    self.doWord();
                }
            }
        }
        gc.i.nextIndex();
    };

    /**
     * Delegate function for Artist/Release/Track specific handlers
     **/
    self.doWord = function () {};

    /**
     * Deal with whitespace (\t)
     * primarily we only look at whitespace for context purposes
     **/
    self.doWhiteSpace = function () {
        if (!gc.re.WHITESPACE) {
            gc.re.WHITESPACE = " ";
        }
        if (gc.i.matchCurrentWord(gc.re.WHITESPACE)) {
            gc.f.whitespace = true;
            gc.f.spaceNextWord = true;
            if (gc.f.openingBracket) {
                gc.f.spaceNextWord = false;
            }
            return true;
        }
        return false;
    };

    /**
     * Deal with colons (:)
     * Colons are used as a sub-title split,and also for disc/box name splits
     **/
    self.doColon = function () {
        if (!gc.re.COLON) {
            gc.re.COLON = ":";
        }

        if (gc.i.matchCurrentWord(gc.re.COLON)) {
            // capitalize the last word before the colon (it's a line stop)
            // -- handle special case feat. "role" lowercase.
            var featIndex = gc.o.getLength()-3;
            var role;
            if (gc.f.slurpExtraTitleInformation &&
                featIndex > 0 &&
                gc.o.getWordAtIndex(featIndex) == "feat." &&
                (role = gc.o.getLastWord()) != "") {

                gc.o.setWordAtIndex(gc.o.getLength()-1, role.toLowerCase());
            } else {
                // force capitalization of the last word,
                // because we are starting a new subtitle
                gc.o.capitalizeLastWord(!gc.mode.isSentenceCaps());
            }

            // from next position on, skip spaces and dots.
            var skip = false;
            var pos = gc.i.getPos();
            var len = gc.i.getLength();
            if (pos < len-2) {
                var nword = gc.i.getWordAtIndex(pos+1);
                var naword = gc.i.getWordAtIndex(pos+2);
                if (nword.match(gc.re.OPENBRACKET)) {
                    skip = true;
                    gc.f.spaceNextWord = true;
                }
                if (gc.i.isNextWord(" ") &&
                    naword.match(gc.re.OPENBRACKET)) {
                    gc.f.spaceNextWord = true;
                    skip = true;
                    gc.i.nextIndex();
                }
            }
            if (!skip) {
                // no whitespace before colons
                gc.o.appendCurrentWord();
                gc.f.resetContext();
                gc.f.forceCaps = true;
                gc.f.colon = true;
                gc.f.spaceNextWord = (gc.i.isNextWord(" "));
            }
            return true;
        }
        return false;
    };

    /**
     * Deal with asterix (*)
     **/
    self.doAsterix = function () {
        if (!gc.re.ASTERIX) {
            gc.re.ASTERIX = "*";
        }
        if (gc.i.matchCurrentWord(gc.re.ASTERIX)) {
            gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: true});
            gc.f.resetContext();
            return true;
        }
        return false;
    };

    /**
     * Deal with diamond (#)
     **/
    self.doDiamond = function () {
        if (!gc.re.DIAMOND) {
            gc.re.DIAMOND = "#";
        }
        if (gc.i.matchCurrentWord(gc.re.DIAMOND)) {
            gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: true});
            gc.f.resetContext();
            return true;
        }
        return false;
    };

    /**
     * Deal with percent signs (%)
     * TODO: lots of methods for special chars look the same, combine?
     **/
    self.doPercent = function () {
        if (!gc.re.PERCENT) {
            gc.re.PERCENT = "%";
        }
        if (gc.i.matchCurrentWord(gc.re.PERCENT)) {
            gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: true});
            gc.f.resetContext();
            return true;
        }
        return false;
    };

    /**
     * Deal with ampersands (&)
     **/
    self.doAmpersand = function () {
        if (!gc.re.AMPERSAND) {
            gc.re.AMPERSAND = "&";
        }
        if (gc.i.matchCurrentWord(gc.re.AMPERSAND)) {
            gc.f.resetContext();
            gc.f.forceCaps = true;
            gc.o.appendSpace(); // add a space,and remember to
            gc.f.spaceNextWord = true; // add one before the next word
            gc.o.appendCurrentWord();
            return true;
        }
        return false;
    };

    /**
     * Deal with line terminators (?!;)
     * (other than the period).
     **/
    self.doLineStop = function () {
        if (!gc.re.LINESTOP) {
            gc.re.LINESTOP = /[\?\!\;]/;
        }
        if (gc.i.matchCurrentWord(gc.re.LINESTOP)) {
            gc.f.resetContext();

            // force caps on word before the colon, if
            // the mode is not sentencecaps
            gc.o.capitalizeLastWord(!gc.mode.isSentenceCaps());

            gc.f.forceCaps = true;
            gc.f.spaceNextWord = true;
            gc.o.appendCurrentWord();
            return true;
        }
        return false;
    };

    /**
     * Deal with hyphens (-)
     * if a hyphen has a space near it,then it should be spaced out and treated
     * similar to a sentence pause,otherwise it's a part of a hyphenated word.
     * unfortunately it's not practical to implement real em-dashes,however we'll
     * treat a spaced hyphen as an em-dash for the purposes of caps.
     **/
    self.doHyphen = function () {
        if (!gc.re.HYPHEN) {
            gc.re.HYPHEN = "-";
        }
        if (gc.i.matchCurrentWord(gc.re.HYPHEN)) {
            gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: true});
            gc.f.resetContext();

            // don't capitalize next word after hyphen in sentence mode.
            gc.f.forceCaps = !gc.mode.isSentenceCaps();
            gc.f.hypen = true;
            return true;
        }
        return false;
    };

    /**
     * Deal with inverted question (¿) and exclamation marks (¡).
     **/
    self.doInvertedMarks = function () {
        if (!gc.re.INVERTEDMARKS) {
            gc.re.INVERTEDMARKS = /(¿|¡)/;
        }
        if (gc.i.matchCurrentWord(gc.re.INVERTEDMARKS)) {
            gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: false});
            gc.f.resetContext();

            // next word is start of a new sentence.
            gc.f.forceCaps = true;
            return true;
        }
        return false;
    };

    /**
     * Deal with plus symbol    (+)
     **/
    self.doPlus = function () {
        if (!gc.re.PLUS) {
            gc.re.PLUS = "+";
        }
        if (gc.i.matchCurrentWord(gc.re.PLUS)) {
            gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: true});
            gc.f.resetContext();
            return true;
        }
        return false;
    };

    /**
     * Deal with slashes (/,\)
     * If a slash has a space near it, pad it out, otherwise leave as is.
     **/
    self.doSlash = function () {
        if (!gc.re.SLASH) {
            gc.re.SLASH = /[\\\/]/;
        }
        if (gc.i.matchCurrentWord(gc.re.SLASH)) {
            gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: true});
            gc.f.resetContext();
            gc.f.forceCaps = true;
            return true;
        }
        return false;
    };

    /**
     * Deal with double quotes (")
     **/
    self.doDoubleQuote = function () {
        if (!gc.re.DOUBLEQUOTE) {
            gc.re.DOUBLEQUOTE = "\"";
        }
        if (gc.i.matchCurrentWord(gc.re.DOUBLEQUOTE)) {
            // changed 05/2006: do not force capitalization before quotes
            gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: false});

            // changed 05/2006: do not force capitalization after quotes
            gc.f.resetContext();
            gc.f.forceCaps = !gc.i.isNextWord(" ");
            return true;
        }
        return false;
    };

    /**
     * Deal with single quotes (')
     * * need to keep context on whether gc.re.inside quotes or not.
     * * Look for contractions (see contractions_words for a list of
     *   Contractions that are handled,and format the right part (after)
     *   the (') as lowercase.
     **/
    self.doSingleQuote = function () {
        if (!gc.re.SINGLEQUOTE) {
            gc.re.SINGLEQUOTE = /['‘’]/;
        }

        if (gc.i.matchCurrentWord(gc.re.SINGLEQUOTE)) {
            gc.f.forceCaps = false;
            var a = gc.i.isPreviousWord(" ");
            var b = gc.i.isNextWord(" ");
            var state = gc.f.openedSingleQuote;

            // preserve whitespace before opening singlequote.
            // -- if it's a "Asdf 'Text in Quotes'"
            if (a && !b) {
                gc.o.appendSpace();
                gc.f.openedSingleQuote = true;
                gc.f.forceCaps = true;

            // preserve whitespace after closing singlequote.
            } else  if (!a && b) {
                if (state) {
                    gc.f.forceCaps = true;
                    gc.f.openedSingleQuote = false;
                } else {

                }
                gc.o.capitalizeLastWord();
            }
            gc.f.spaceNextWord = b; // and keep whitespace intact
            gc.o.appendCurrentWord(); // append current word

            // if there is a space after the ' assume its a closing singlequote
            // do not force capitalization per default, else for "Rollin' on",
            // the "On" will be titled.
            gc.f.resetContext();

            // default, if singlequote state was not modified, is
            // not forcing caps.
            if (state == gc.f.openedSingleQuote) {
                gc.f.forceCaps = false;
            }
            gc.f.singlequote = true;
            return true;
        }
        return false;
    };

    /**
     * Deal with opening parenthesis    (([{<)
     * Knowing whether gc.re.inside parenthesis (and multiple levels thereof) is
     * important for determining what words should be capped or not.
     **/
    self.doOpeningBracket = function () {
        if (!gc.re.OPENBRACKET) {
            gc.re.OPENBRACKET = /[\(\[\{\<]/;
        }
        if (gc.i.matchCurrentWord(gc.re.OPENBRACKET)) {
            // force caps on last word before the opending bracket,
            // if the current mode is not sentence mode.
            gc.o.capitalizeLastWord(!gc.mode.isSentenceCaps());

            // register current bracket as openening bracket
            gc.f.pushBracket(gc.i.getCurrentWord());
            var cb = gc.f.getCurrentCloseBracket();
            var forcelowercase = false;
            var pos = gc.i.getPos()+1;
            for (var i = pos; i < gc.i.getLength(); i++) {
                var w = (gc.i.getWordAtIndex(i) || "");
                if (w != " ") {
                    if ((gc.u.isLowerCaseBracketWord(w)) ||
                        (w.match(/^featuring$|^ft$|^feat$/i) != null)) {
                        gc.f.slurpExtraTitleInformation = true;

                        if (i == pos) {
                            forcelowercase = true;
                        }
                    }
                    if (w == cb) {
                        break;
                    }
                }
            }
            gc.o.appendSpace(); // always space brackets
            gc.f.resetContext();
            gc.f.spaceNextWord = false;
            gc.f.openingBracket = true;
            gc.f.forceCaps = !forcelowercase;
            gc.o.appendCurrentWord();
            gc.f.part = false;
            gc.f.volume = false;
            return true;
        }
        return false;
    };

    /**
     * Deal with closing parenthesis    (([{<)
     * knowing whether gc.re.inside parenthesis (and multiple levels thereof) is
     * important for determining what words should be capped or not.
     **/
    self.doClosingBracket = function () {
        if (!gc.re.CLOSEBRACKET) {
            gc.re.CLOSEBRACKET = /[\)\]\}\>]/;
        }
        if (gc.i.matchCurrentWord(gc.re.CLOSEBRACKET)) {
            // capitalize the last word, if forceCaps was
            // set, else leave it like it is.
            gc.o.capitalizeLastWord();

            if (gc.f.isInsideBrackets()) {
                gc.f.popBracket();
                gc.f.slurpExtraTitleInformation = false;
            }
            gc.f.resetContext();
            gc.f.forceCaps = !gc.mode.isSentenceCaps();
            gc.f.spaceNextWord = true;
            gc.o.appendCurrentWord();
            return true;
        }
        return false;
    };

    /**
     * Deal with commas.            (,)
     * commas can mean two things: a sentence pause,or a number split. We
     * need context to guess which one it's meant to be, thus the digit
     * triplet checking later on. Multiple commas are removed.
     **/
    self.doComma = function () {
        if (!gc.re.COMMA) {
            gc.re.COMMA = ",";
        }
        if (gc.i.matchCurrentWord(gc.re.COMMA)) {
            // skip duplicate commas.
            if (gc.o.getLastWord() != ",") {
                // capitalize the last word before the colon.
                // -- do words before comma need to be titled?
                // -- see http://bugs.musicbrainz.org/ticket/1317

                // handle comma
                gc.f.resetContext();
                gc.f.spaceNextWord = true;
                gc.f.forceCaps = false;
                gc.o.appendCurrentWord();
            }
            return true;
        }
        return false;
    };

    /**
     * Deal with periods.         (.)
     * Periods can also mean four things:
     *   * a sentence break (full stop);
     *   * a number split in some countries
     *   * part of an ellipsis (...)
     *   * an acronym split.
     * We flag digits and digit triplets in the words routine.
     **/
    self.doPeriod = function () {
        if (!gc.re.PERIOD) {
            gc.re.PERIOD = ".";
        }

        if (gc.i.matchCurrentWord(gc.re.PERIOD)) {
            if (gc.o.getLastWord() == ".") {
                if (!gc.f.ellipsis) {
                    gc.o.appendWord("..");
                    while (gc.i.isNextWord(".")) {
                        gc.i.nextIndex(); // skip trailing (.)
                    }
                    gc.f.resetContext();
                    gc.f.ellipsis = true;
                }
                gc.f.forceCaps = true; // capitalize next word in any case.
                gc.f.spaceNextWord = true;
            } else {
                if (!gc.i.hasMoreWords() || gc.i.getNextWord() != ".") {
                    // capitalize the last word, if forceCaps was
                    // set, else leave it like it is.
                    gc.o.capitalizeLastWord();
                }
                gc.o.appendWord(".");
                gc.f.resetContext();
                gc.f.forceCaps = true; // force caps on next word
                gc.f.spaceNextWord = (gc.i.isNextWord(" "));
            }
            return true;
        }
        return false;
    };

    /**
     * Check for an acronym
     **/
    self.doAcronym = function () {
        if (!gc.re.ACRONYM) {
            gc.re.ACRONYM = /^\w$/;
        }

        // acronym handling was made less strict to
        // fix broken acronyms which look like this: "A. B. C."
        // the variable gc.f.gotPeriod,is used such that such
        // cases do not yield false positives:
        // The method works as follows:
        // "A.B.C. I Love You"          => "A.B.C. I Love You"
        // "A. B. C. I Love You"        => "A.B.C. I Love You"
        // "A.B.C I Love You"           => "A.B. C I Love You"
        // "P.S I Love You"             => "P. S I Love You"
        var subIndex, tmp = [];
        if (gc.i.matchCurrentWord(gc.re.ACRONYM)) {
            var cw = gc.i.getCurrentWord();
            tmp.push(cw.toUpperCase()); // add current word
            gc.f.expectWord = false;
            gc.f.gotPeriod = false;

            acronymloop:
            for (subIndex = gc.i.getPos() + 1; subIndex < gc.i.getLength();) {
                cw = gc.i.getWordAtIndex(subIndex); // remember current word.

                if (gc.f.expectWord && cw.match(gc.re.ACRONYM)) {
                    tmp.push(cw.toUpperCase()); // do character
                    gc.f.expectWord = false;
                    gc.f.gotPeriod = false;
                } else {
                    if (cw == "." && !gc.f.gotPeriod) {
                        tmp[tmp.length] = "."; // do dot
                        gc.f.gotPeriod = true;
                        gc.f.expectWord = true;
                    } else {
                        if (gc.f.gotPeriod && cw == " ") {
                            gc.f.expectWord = true; // do a single whitespace
                        } else {
                            if (tmp[tmp.length-1] != ".") {
                                tmp.pop(); // loose last of the acronym
                                subIndex--; // its for example "P.S. I" love you
                            }
                            break acronymloop; // found something which is not part of the acronym
                        }
                    }
                }
                subIndex++;
            }
        }

        if (tmp.length > 2) {
            var s = tmp.join(""); // yes,we have an acronym, get string
            s = s.replace(/(\.)*$/,"."); // replace any number of trailing "." with ". "

            gc.o.appendSpaceIfNeeded();
            gc.o.appendWord(s);

            gc.f.resetContext();
            gc.f.acronym = true;
            gc.f.spaceNextWord = true;
            gc.f.forceCaps = false;
            gc.i.setPos(subIndex-1); // set pointer to after acronym
            return true;
        }
        return false;
    };

    /**
     * Check for a digit only string
     **/
    self.doDigits = function () {
        if (!gc.re.DIGITS) {
            gc.re.DIGITS = /^\d+$/;
            gc.re.DIGITS_NUMBERSPLIT = /[,.]/;
            gc.re.DIGITS_DUPLE = /^\d\d$/;
            gc.re.DIGITS_TRIPLE = /^\d\d\d$/;
            gc.re.DIGITS_NTUPLE = /^\d\d\d\d+$/;
        }

        var subIndex = null, tmp = [];
        if (gc.i.matchCurrentWord(gc.re.DIGITS)) {
            tmp.push(gc.i.getCurrentWord());
            gc.f.numberSplitExpect = true;

            numberloop:
            for (subIndex = gc.i.getPos() + 1; subIndex < gc.i.getLength();) {
                if (gc.f.numberSplitExpect) {
                    if (gc.i.matchWordAtIndex(subIndex, gc.re.DIGITS_NUMBERSPLIT)) {
                        tmp.push(gc.i.getWordAtIndex(subIndex)); // found a potential number split
                        gc.f.numberSplitExpect = false;
                    } else {
                        break numberloop;
                    }
                } else {
                    // look for a group of 3 digits
                    if (gc.i.matchWordAtIndex(subIndex, gc.re.DIGITS_TRIPLE)) {
                        if (gc.f.numberSplitChar == null) {
                            gc.f.numberSplitChar = tmp[tmp.length - 1]; // confirmed number split
                        }
                        tmp.push(gc.i.getWordAtIndex(subIndex));
                        gc.f.numberSplitExpect = true;
                    } else {
                        if (gc.i.matchWordAtIndex(subIndex, gc.re.DIGITS_DUPLE)) {
                            if (tmp.length > 2 && gc.f.numberSplitChar != tmp[tmp.length - 1]) {
                                // check for the opposite number splitter (,or .)
                                // because numbers are generally either
                                // 1,000,936.00 or 1.300.402,00 depending on
                                // the country
                                tmp.push(gc.i.getWordAtIndex(subIndex++));
                            } else {
                                tmp.pop(); // stand-alone number pair
                                subIndex--;
                            }
                        } else {
                            if (gc.i.matchWordAtIndex(subIndex, gc.re.DIGITS_NTUPLE)) {
                                // big number at the end,probably a decimal point,
                                // end of number in any case
                                tmp.push(gc.i.getWordAtIndex(subIndex++));
                            } else {
                                tmp.pop(); // last number split was not
                                subIndex--; // actually a number split
                            }
                        }
                        break numberloop;
                    }
                }
                subIndex++;
            }
            gc.i.setPos(subIndex-1);
            var number = tmp.join("");

            if (gc.f.part || gc.f.volume) {
                // delete leading '0',if last word was a seriesnumberstyle word.
                // e.g. disc 02 -> disc 2
                number = number.replace(/^0*/,"");
            }

            // add : after disc with number,with more words following
            // only if there is a string which is assumed to be the
            // disc title.
            // e.g. Releasename cd 4 -> Releasename (disc 4)
            // but  Releasename cd 4 the name -> Releasename (disc 4: The Name)
            var addcolon = false;
            if (gc.f.volume) {
                var pos = gc.i.getPos();
                if (pos < gc.i.getLength()-2) {
                    var nword = gc.i.getWordAtIndex(pos+1);
                    var naword = gc.i.getWordAtIndex(pos+2);
                    var nwordm = nword.match(/[\):\-&]/);
                    var nawordm = naword.match(/[\(:\-&]/);

                    // only add a colon,if the next word is not ")",":","-","&"
                    // and the word after the next is not "-","&","("
                    if (nwordm == null && nawordm == null) {
                        addcolon = true;
                    }
                }
                gc.f.spaceNextWord = true;
                gc.f.forceCaps = true;
            }

            gc.o.appendSpaceIfNeeded();
            gc.o.appendWord(number);

            // clear the flags (for the colon-handling after volume,part
            // added (flawed implementation, but it works i guess)
            // and disc,even if no digit followed (and thus no colon was
            gc.f.resetSeriesNumberStyleFlags();
            gc.f.resetContext();
            if (addcolon) {
                gc.o.appendWord(":");     // if there is no colon already present,add a colon
                gc.f.forceCaps = true;
                gc.f.colon = true;
            } else {
                gc.f.forceCaps = false;
                gc.f.number = true;
            }
            return true;
        }
        return false;
    };

    /**
     * Correct vs.
     **/
    self.doVersusStyle = function () {
        if (!gc.re.VERSUSSTYLE) {
            gc.re.VERSUSSTYLE = "vs";
        }

        if (gc.i.matchCurrentWord(gc.re.VERSUSSTYLE)) {
            // capitalize the last word, if forceCaps was
            // set, else leave it like it is.
            gc.o.capitalizeLastWord();

            if (!gc.f.openingBracket) {
                gc.o.appendSpace();
            }
            gc.o.appendWord("vs");
            gc.o.appendWord(".");
            if (gc.i.isNextWord(".")) {
                gc.i.nextIndex(); // skip trailing (.)
            }
            gc.f.resetContext();
            gc.f.forceCaps = true;
            gc.f.spaceNextWord = true;
            return true;
        }
        return false;
    };

    /**
     * Handle "Vol","Vol.","Volume" -> ", Volume"
     **/
    self.doVolumeNumberStyle = function () {
        if (!gc.re.VOLUMENUMBERSTYLE) {
            gc.re.VOLUMENUMBERSTYLE = /^(volumes|volume)$/i;
        }
        if (gc.i.matchCurrentWord(gc.re.VOLUMENUMBERSTYLE) && gc.i.hasMoreWords()) {
            if (self.doSeriesNumberStyle("Volume")) {
                gc.f.volume = true;
                return true;
            }
        }
        return false;
    };

    /**
     * Handle "Pt","Pt.","Part" -> ", Part"
     **/
    self.doPartNumberStyle = function () {
        if (!gc.re.PARTNUMBERSTYLE) {
            gc.re.PARTNUMBERSTYLE = /^(parts|part)$/i;
        }
        if (gc.i.matchCurrentWord(gc.re.PARTNUMBERSTYLE) && gc.i.hasMoreWords()) {
            if (self.doSeriesNumberStyle("Part")) {
                gc.f.part = true;
                return true;
            }
        }
        return false;
    };

    /**
     * Do the common work for handleVolume, handlePart
     **/
    self.doSeriesNumberStyle = function (seriesType) {
        // from next position on, skip spaces and dots.
        var pos = gc.i.getPos();
        var len = gc.i.getLength();
        var wi = pos+1, si = wi;

        while ((wi < len-1) && (gc.i.getWordAtIndex(wi).match(gc.re.SPACES_DOTS) != null)) {
            wi++;
        }

        var w = (gc.i.getWordAtIndex(wi) || "");

        // only do the conversion if ...,(volume|part) is followed
        // by a digit or a roman number
        if (w.match(gc.re.SERIES_NUMBER)) {
            // if no other punctuation char present
            if (gc.i.getPos() >= 1 && !gc.u.isPunctuationChar(gc.o.getLastWord())) {
                // check if there was a hypen (+whitespace) before,and drop it.
                var droppedwords = false;
                while (gc.o.getLength() > 0 && (gc.o.getLastWord() || "").match(/ |-/i)) {
                    gc.o.dropLastWord();
                    droppedwords = true;
                }

                // force capitalization of the last word,
                // because we are starting a new styleguideline
                // specialcase (or sentence).
                gc.o.capitalizeLastWord(true);
                gc.o.appendWord(",");
            } else {
                // capitalize last word before punctuation char.
                var pos = gc.o.getLength()-2;
                gc.o.capitalizeWordAtIndex(pos, true);
            }

            // check if we have to add a colon (SubTitleStyle)
            var addcolon = false;
            if (wi < gc.i.getLength()-2) {
                var nword = gc.i.getWordAtIndex(wi+1);
                var naword = gc.i.getWordAtIndex(wi+2);
                var nwordm = nword.match(/[\):\-&,\/]/);
                var nawordm = naword.match(/[\(:\-&,\/]/);

                // alert(nword+"="+nwordm+"    "+naword+"="+nawordm);
                // only add a colon,if the next word is not [ ) : - & / , ]
                // and the word after the next is not [ ) : - & / , ]
                if (nwordm == null && nawordm == null) {
                    addcolon = true;
                } else if (seriesType.match(/part|parts/i) &&
                           (nword.match(/,/) || naword.match(/&|-|,|\d+/))) {
                    seriesType = "Parts"; // make multiple parts
                }
            }

            // append the current seriestype to output.
            gc.o.appendSpaceIfNeeded();
            gc.o.appendWord(seriesType);

            // add space, and number
            gc.o.appendSpace();
            gc.o.appendWord(w);
            gc.f.resetContext();

            // if there is no colon already present,add a colon
            if (addcolon) {
                gc.o.appendWord(":");
                gc.f.forceCaps = true;
                gc.f.spaceNextWord = true;
                gc.f.colon = true;
            } else {
                gc.f.spaceNextWord = false;
                gc.f.forceCaps = true;
                gc.f.number = true;
            }
            gc.i.setPos(wi);
            return true;
        }
        return false;
    };

    /**
     * Do not change the caps of certain words
     * ---------------------------------------------------
     * warp        2011-08-13        first version
     **/
    self.doIgnoreWords = function () {
        // deciBel
        if (gc.i.getCurrentWord() === 'dB') {
            gc.o.appendSpaceIfNeeded();
            gc.o.appendCurrentWord();
            return true;
        }
        return false;
    }

    /**
     * Detect featuring,f., ft[.], feat[.] and add parentheses as needed.
     * keschte        2005-11-10        added ^f\.$ to cases
     *                                  which are added converted to feat.
     * ---------------------------------------------------
     **/
    self.doFeaturingArtistStyle = function () {
        if (!gc.re.FEAT) {
            gc.re.FEAT = /^featuring$|^f$|^ft$|^feat$/i;
            gc.re.FEAT_F = /^f$/i; // match word "f"
        }
        if (gc.i.matchCurrentWord(gc.re.FEAT)) {
            // special case (f.), have to check if next word is a "."
            if ((gc.i.getCurrentWord().match(gc.re.FEAT_F)) && !gc.i.isNextWord(".")) {
                return false;
            }

            // only try to convert to feat. if there are
            // enough words after the keyword
            if (gc.i.getPos() < gc.i.getLength() - 2) {

                if (!gc.f.openingBracket && !gc.f.isInsideBrackets()) {

                    if (gc.f.isInsideBrackets()) {
                        // close open parentheses before the feat. part.
                        var closebrackets = new Array();
                        while (gc.f.isInsideBrackets()) {
                            // close brackets that were opened before
                            var cb = gc.f.popBracket();
                            gc.o.appendWord(cb);
                            if (gc.i.getWordAtIndex(gc.i.getLength()-1) == cb) {
                                gc.i.dropLastWord();
                                // get rid of duplicate bracket at the end (will be
                                // added again by closeOpenBrackets if they wern't
                                // closed before (e.g. using feat.)
                            }
                        }
                    }

                    // handle case:
                    // Blah ft. Erroll Flynn Some Remixname remix
                    // -> pre-processor added parentheses such that the string is:
                    // Blah ft. erroll flynn Some Remixname (remix)
                    // -> now there are parentheses needed before remix, we can't
                    //    guess where the artist name ends, and the remixname starts
                    //    though :]
                    // Blah (feat. Erroll Flynn Some Remixname) (remix)
                    var pos = gc.i.getPos();
                    var len = gc.i.getLength();
                    for (var i = pos; i < len; i++) {
                        if (gc.i.getWordAtIndex(i) == "(") {
                            break;
                        }
                    }

                    // we got a part, but not until the end of the string
                    // close feat. part, and add space to next set of brackets
                    if (i != pos && i < len-1) {
                        gc.i.insertWordsAtIndex(i, [")", " "]);
                    }
                    gc.i.updateCurrentWord("(");
                    self.doOpeningBracket();
                } else {
                    gc.o.appendWord(" ");
                }

                // gc.o.appendSpaceIfNeeded();
                gc.o.appendWord("feat.");

                gc.f.resetContext();
                gc.f.forceCaps = true;
                gc.f.openingBracket = false;
                gc.f.spaceNextWord = true;
                gc.f.slurpExtraTitleInformation = true;
                gc.f.feat = true;
                if (gc.i.isNextWord(".")) {
                    gc.i.nextIndex();  // skip trailing (.)
                }
                return true;
            }
        }
        return false;
    };

    return self;
};
