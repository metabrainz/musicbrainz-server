// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2005 Stefan Kestenholz (keschte)
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const clean = require('../common/utility/clean');
const flags = require('./flags');

// Words which are *not* converted if they are matched as a single pre-processor word at the end of the sentence.
var preBracketSingleWordsList = [
    'acoustic',
    'airplay',
    'album',
    'alternate',
    'alternative',
    'bonus',
    'clean',
    'club',
    'composition',
    'cut',
    'dance',
    'dirty',
    'disc',
    'disco',
    'dub',
    'extended',
    'feat',
    'instrumental',
    'live',
    'long',
    'main',
    'megamix',
    'mix',
    'original',
    'radio',
    'remixed',
    'rework',
    'reworked',
    'session',
    'short',
    'take',
    'trance',
    'version',
    'video',
    'vocal'
];

var preBracketSingleWords = new RegExp('^(' + preBracketSingleWordsList.join('|') + ')$', 'i');

exports.isPrepBracketSingleWord = function (w) {
    return preBracketSingleWords.test(w);
};

// Words which are written lowercase if in brackets.
var lowerCaseBracketWordsList = [
    'a_cappella',
    'clubmix',
    'demo',
    'dialogue',
    'early',
    'edit',
    'excerpt',
    'interlude',
    'intro',
    'karaoke',
    'maxi',
    'medley',
    'orchestral',
    'outro',
    'outtake',
    'outtakes',
    'piano',
    'rap',
    'reedit',
    'rehearsal',
    'reinterpreted',
    'remake',
    'remix',
    'reprise',
    'single',
    'skit',
    'studio',
    'techno',
    'unplugged',
    'vs',
    'with',
    'without'
].concat(preBracketSingleWordsList);

var lowerCaseBracketWords = new RegExp('^(' + lowerCaseBracketWordsList.join('|') + ')$', 'i');

exports.isLowerCaseBracketWord = function (w) {
    return lowerCaseBracketWords.test(w);
};

// Words which the pre-processor looks for and puts them into brackets if they arent yet.
var prepBracketWords = /^(cd|disk|12["”]|7["”]|a_cappella|re_edit)$/i;

exports.isPrepBracketWord = function (w) {
    return prepBracketWords.test(w) || exports.isLowerCaseBracketWord(w);
};

var sentenceStopChars = /^[:.;?!\/]$/;

exports.isSentenceStopChar = function (w) {
    return sentenceStopChars.test(w);
};

var apostropheChars = /^['’]$/;

exports.isApostrophe = function (w) {
    return apostropheChars.test(w);
};

var punctuationChars = /^[:.;?!,]$/;

exports.isPunctuationChar = function (w) {
    return punctuationChars.test(w);
};

// Trim leading, trailing and running-line whitespace from the given string.
exports.trim = function (is) {
    is = clean(is);
    return is.replace(/([\(\[])\s+/, "$1").replace(/\s+([\)\]])/, "$1");
};

// Upper case first letter of word unless it's one of the words in the lowercase words array.
exports.titleString = function (is, forceCaps) {
    if (!is) {
        return '';
    }

    forceCaps = (forceCaps != null ? forceCaps : flags.context.forceCaps);

    // Get current pointer in word array.
    var len = gc.i.getLength();
    var pos = gc.i.getPos();

    // If pos === len, this means that the pointer is beyond the last position
    // in the wordlist, and that the regular processing is done. We're looking
    // at the last word before collecting the output, and have to adjust pos
    // to the last element of the wordlist again.
    if (pos === len) {
        pos = len - 1;
        gc.i.setPos(pos);
    }

    var os;
    var lc = is.toLowerCase();
    var uc = is.toUpperCase();

    if (is === uc && is.length > 1 && gc.CFG_UC_UPPERCASED) {
        os = uc;
    // we got an 'x (apostrophe),keep the text lowercased
    } else if (lc.length === 1 && exports.isApostrophe(gc.i.getPreviousWord())) {
        os = lc;
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
    } else if (exports.isApostrophe(gc.i.getPreviousWord()) && lc.match(/^(s|round|em|ve|ll|d|cha|re|til|way|all)$/i)) {
        os = lc;
    // we got an Ev'..
    // Every = Ev'ry, lowercase
    // Everything = Ev'rything, lowercase (more cases?)
    } else if (exports.isApostrophe(gc.i.getPreviousWord()) && gc.i.getWordAtIndex(pos - 2) === "Ev") {
        os = lc;
    // Make it O'Titled, Y'All
    } else if (lc.match(/^(o|y)$/i) && exports.isApostrophe(gc.i.getNextWord())) {
        os = uc;
    } else {
        os = exports.titleStringByMode(lc, forceCaps);
        lc = os.toLowerCase();
        uc = os.toUpperCase();

        var nextWord = gc.i.getNextWord();
        var followedByPunctuation = nextWord && nextWord.length === 1 && exports.isPunctuationChar(nextWord);

        // Unless forceCaps is enabled, lowercase the word if it's not followed by punctuation.
        if (!forceCaps && gc.mode.isLowerCaseWord(lc) && !followedByPunctuation) {
            os = lc;
        } else if (gc.mode.isUpperCaseWord(lc)) {
            os = uc;
        } else if (flags.isInsideBrackets() && exports.isLowerCaseBracketWord(lc)) {
            os = lc;
        }
    }

    return os;
};

// Capitalize the string, but check if some characters inside the word need to be uppercased as well.
exports.titleStringByMode = function (is, forceCaps) {
    if (!is) {
        return '';
    }

    var os = is.toLowerCase();

    // See if the word before is a sentence stop character.
    // -- http://bugs.musicbrainz.org/ticket/40
    var opos = gc.o.getLength();
    var wordBefore = '';
    if (opos > 1) {
        wordBefore = gc.o.getWordAtIndex(opos - 2);
    }

    // If in sentence caps mode, and the last char was not punctuation or an
    // opening bracket, keep the work lowercase.
    var doCaps = (
        forceCaps || !gc.mode.isSentenceCaps() ||
        flags.context.slurpExtraTitleInformation || flags.context.openingBracket ||
        gc.i.isFirstWord() || exports.isSentenceStopChar(wordBefore)
    );

    if (doCaps) {
        var chars = os.split('');
        chars[0] = chars[0].toUpperCase();

        if (is.length > 2 && is.substring(0, 2) === 'mc') {
            // Make it McTitled
            chars[2] = chars[2].toUpperCase();
        }

        os = chars.join('');
    }

    return os;
};
