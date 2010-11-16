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
MB.GuessCase.Mode = (MB.GuessCase.Mode) ? MB.GuessCase.Mode : {};

// Tests:
// ---
// Piano concerto "test" in b-flat minor, No. 2 opuss 2
// Test in b minor, No. 2 opuss 2
// Test in b flat minor, No. 2 opuss 2
// Test "Asdf" in Bb major, BWV 12 2. test
// Piano concerto "Test" in A# major No #2 Opus 2 14. murggs

/**
 * Models the "Classical" GuessCase mode.
 **/
MB.GuessCase.Mode.Classical = function () {
    var self = MB.GuessCase.Mode.Base ();

    self.setConfig(
	'Classical',
	'First word titled, lowercase for <i>most</i> of the other '
	    + 'words. Read the [url]description[/url] for more details.',
	'/doc/GuessCaseMode/ClassicalMode');

    self.getUpperCaseWords = function() {
	return [ "bwv", "d", "rv", "j", "hob", "hwv", "wwo", "kv" ];
    };

    /**
     * Handle all the classical mode specific quirks.
     * Note: 	this function is run before release and track guess
     *   		types (not for artist)
     **/
    self.preProcessTitles = function(is) {

	if (!gc.re.PREPROCESS_FIXLIST_XC) {
	    gc.re.PREPROCESS_FIXLIST_XC = [

		// correct tone indication.
		, self.fix ("Handle -sharp.", /(\b)(\s|-)sharp(\s)/i, "-sharp")
		, self.fix ("Handle -flat.", /(\b)(\s|-)flat(\s)/i, "-flat")

		// expand short tone notation. maybe restrict
		// to uppercase tone only?
		, self.fix ("Expand C# -> C-sharp", /(\s[ACDFG])#(\s)/i, "-sharp")
		, self.fix ("Expand Cb -> C-flat", /(\s[ABCDEG])b(\s)/i, "-flat")

		// common misspellings
		, self.fix ("adiago (adagio)", "adiago", "adagio")
		, self.fix ("pocco (poco)", "pocco", "poco"),
		, self.fix ("contabile (cantabile)", "contabile", "cantabile")
		, self.fix ("sherzo (scherzo)", "sherzo", "scherzo")
		, self.fix ("allergro (allegro)", "allergro", "allegro")
		, self.fix ("adante (andante)", "adante", "andante")
		, self.fix ("largetto (larghetto)", "largetto", "larghetto")
		, self.fix ("allgro (allegro)", "allgro", "allegro")
		, self.fix ("tocatta (toccata)", "tocatta", "toccata")
		, self.fix ("allegreto (allegretto)", "allegreto", "allegretto")
		, self.fix ("attaca (attacca)", "attaca", "attacca")

		// detect one word combinations of work numbers and their number
		, self.fix ("split worknumber combination", /(\b)(BWV|D|RV|J|Hob|HWV|WwO|KV)(\d+)(\b|$)/i, "$2 $3")

		// detect one word combinations of work numbers and their number
		, self.fix ("split op. number combination", /(\b)(Op)(\d+)(\b|$)/i, "$2 $3")
		, self.fix ("split no. number combination", /(\b)(No|N)(\d+)(\b|$)/i, "$2 $3")
	    ];
	}

        return self.runFixes(is, gc.re.PREPROCESS_FIXLIST_XC);
    };

    /**
     * Handle all the classical mode specific quirks.
     * Note: 	this function is run before release and track guess
     *   		types (not for artist)
     **/
    self.runPostProcess = function(is) {

	if (!gc.re.POSTPROCESS_FIXLIST_XC) {
	    gc.re.POSTPROCESS_FIXLIST_XC = [

		// correct opus/number
		, self.fix ("Handle Op.", /(\b)[\s,]+(Op|Opus|Opera)[\s\.#]+($|\b)/i, ", Op. " )
		, self.fix ("Handle No.", /(\b)[\s,]+(N|No|Num|Nr)[\s\.#]+($|\b)/i, ", No. " )

		// correct K. -> KV
		, self.fix ("Handle K. -> KV", /(\b)[\s,]+K[\.\s]+($|\b)/i, ", KV " )

		// correct whitespace and comma for work catalog
		// BWV D RV J Hob HWV WwO (Work without Opera) KV
		, self.fix ("Fix whitespace and comma for work catalog", /(\b)[\s,]+(BWV|D|RV|J|Hob|HWV|WwO|KV)\s($|\b)/i, ", $2 " )

		// correct tone indication
		, self.fix ("Handle -sharp.", /(\b)(\s|-)sharp(\s)/i, "-sharp")
		, self.fix ("Handle -flat.", /(\b)(\s|-)flat(\s)/i, "-flat")
	    ];
	}
	
	return self.runFixes(is, gc.re.POSTPROCESS_FIXLIST_XC);
    };

    /**
     * Classical mode specific replacements of movement numbers.
     * - Converts decimal numbers (followed by a dot) to roman numerals.
     * - Adds a colon before existing roman numerals
     **/
    self.runFinalChecks = function(is) {

	if (!gc.re.DECIMALTOROMAN) {
	    gc.re.DECIMALTOROMAN = /[\s,:\-]+(\d+)\.[\s]+/i;
	}
	var matcher = null
	var os = is;
	if ((matcher = os.match(gc.re.DECIMALTOROMAN)) != null) {
	    var mindex = matcher.index;
	    var mlenght = matcher[0].length;
	    var firstPart = os.substring(0, mindex);
	    var lastPart = os.substring(mindex + mlenght, os.length);
	    var parts = []; // compile the vinyl designation.

	    // strip trailing punctuation from first part, colon is added afterwards.
	    firstPart = firstPart.replace(/[\s,:\-\/]+$/gi, "");

	    parts.push(firstPart); // add string before the matched part
	    parts.push(": "); // add colon
	    parts.push(gc.u.convertToRomanNumeral(matcher[1])); // add roman representation.
	    parts.push(". "); // add dot after roman numeral
	    parts.push(lastPart); // add string after the matched part
	    os = parts.join("");
	}

	// add a leading colon to a roman numeral
	// if there is none.
	if (!gc.re.ADD_COLON_TO_ROMAN) {
	    gc.re.ADD_COLON_TO_ROMAN = /([^:])\s+([ivx]+)[\s|\.]+/i;
	}
	if ((matcher = os.match(gc.re.ADD_COLON_TO_ROMAN)) != null) {
	    var mindex = matcher.index;
	    var mlenght = matcher[0].length;
	    var firstPart = os.substring(0, mindex);
	    var lastPart = os.substring(mindex + mlenght, os.length);
	    var parts = []; // compile the vinyl designation.
	    parts.push(firstPart); // add string before the matched part
	    parts.push(matcher[1]); // re-add the first match that was _not_ a colon.
	    parts.push(": "); // add colon
	    parts.push(matcher[2]); // re-add roman numeral
	    parts.push(". "); // add dot after roman numeral
	    parts.push(lastPart); // add string after the matched part
	    os = parts.join("");
	}

	return os;
    };

    /**
     * Delegate function for Mode specific word handling.
     * This is mostly used for context based titling changes.
     *
     * @return	false, such that the normal word handling can
     *			take place for the current word, if that should
     * 			not be done, return true.
     **/
    self.doWord = function() {

	var ipos = gc.i.getPos();
	var cw = gc.i.getCurrentWord();
	var pw = gc.i.getWordAtIndex(ipos-1);
	var ppw = gc.i.getPreviousWord(ipos-2);
	var opos = gc.o.getLength();
	var foundToneIndication = false;

	// if the current word is one of flat|sharp, and the
	// previous word is a hyphen, title the word before
	// is a tone indication.
	if (cw.match(/flat|sharp/i) && pw == "-") {
	    opos = opos-2;
	    foundToneIndication = true;

	    // if the current word is one of the major|minor variants
	    // and the word before the previous is not flat|sharp,
	    // the word before is a tone indication.
	} else if (cw.match(/minor|major|minore|maggiore|mineur/i) &&
		   ppw.match(/flat|sharp/) == null) {
	    opos = opos-1;
	    foundToneIndication = true;

	    // if the current word is one of the german variants
	    // the word before is a tone indication.
	} else if (cw.match(/Moll|Dur/i)) {
	    opos = opos-2;
	    gc.f.forceCaps = true;
	    foundToneIndication = true;
	}
	if (foundToneIndication) {
	    var w = gc.o.getWordAtIndex(opos);

	    gc.o.capitalizeWordAtIndex(opos, true);
	}

	return false;
    };

    return self;
};
