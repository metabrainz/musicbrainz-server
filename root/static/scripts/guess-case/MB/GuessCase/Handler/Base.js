/*
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2010 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import MB from '../../../../common/MB';
import * as flags from '../../../flags';
import * as utils from '../../../utils';

MB.GuessCase = (MB.GuessCase) ? MB.GuessCase : {};
MB.GuessCase.Handler = (MB.GuessCase.Handler) ? MB.GuessCase.Handler : {};

/*
 * Base class of the type specific handlers
 *
 * @see GcArtistHandler
 * @see GcLabelHandler
 * @see GcReleaseHandler
 * @see GcTrackHandler
 */
MB.GuessCase.Handler.Base = function (gc) {
  var self = {};

  // Member variables

  // Values of the specialcases defined in
  self.NOT_A_SPECIALCASE = -1;

  // Artist cases
  self.SPECIALCASE_UNKNOWN = 10;          // [unknown]

  // Release cases
  self.SPECIALCASE_DATA_TRACK = 20;       // [data track]

  // Track cases
  self.SPECIALCASE_DATA_TRACK = 30;       // [data track]
  self.SPECIALCASE_SILENCE = 31;          // [silence]
  self.SPECIALCASE_UNTITLED = 32;         // [untitled]
  self.SPECIALCASE_CROWD_NOISE = 33;      // [crowd noise]
  self.SPECIALCASE_GUITAR_SOLO = 34;      // [guitar solo]
  self.SPECIALCASE_DIALOGUE = 35;          // [dialogue]

  // Member functions

  // Returns true if the number corresponds to a special case.
  self.isSpecialCase = function (num) {
    return (num != self.NOT_A_SPECIALCASE);
  };

  /*
   * Returns the correctly formatted string of the
   * special case, or the input string if num
   * does not correspond to a special case
   */
  self.getSpecialCaseFormatted = function (is, num) {
    switch (num) {
      case self.SPECIALCASE_DATA_TRACK:
        return '[data track]';

      case self.SPECIALCASE_SILENCE:
        return '[silence]';

      case self.SPECIALCASE_UNTITLED:
        return '[untitled]';

      case self.SPECIALCASE_UNKNOWN:
        return '[unknown]';

      case self.SPECIALCASE_CROWD_NOISE:
        return '[crowd noise]';

      case self.SPECIALCASE_GUITAR_SOLO:
        return '[guitar solo]';

      case self.SPECIALCASE_DIALOGUE:
        return '[dialogue]';

      case self.NOT_A_SPECIALCASE:
      default:
        return is;
    }
  };

  self.getWordsForProcessing = gc.i.splitWordsAndPunctuation;

  self.process = function (is) {
    gc.o.init();
    gc.i.init(is, self.getWordsForProcessing(is));
    while (!gc.i.isIndexAtEnd()) {
      self.processWord();
    }
    return gc.mode.runPostProcess(gc.o.getOutput());
  };

  /*
   * Processes the next word from the GuessCaseInput
   * returns true, if there are more words, else false.
   */
  self.processWord = function () {
    if (!self.doWhiteSpace()) {
      // Dump information if in debug mode.

      /*
       * Try to decide if we need to check all the special cases,
       * or if it's possibly just a plain word. This should improve
       * performance a bit, since we don't have to go through all
       * the regex expressions to find that we didn't have to
       * check them.
       */
      var handled = false;
      if (!gc.re.SPECIALCASES) {
        gc.re.SPECIALCASES = /(&|¿|¡|\?|\!|;|:|'|‘|’|‹|›|"|“|”|„|“|«|»|\-|\+|,|\*|\.|#|%|\/|\(|\)|\{|\}|\[|\])/;
      }
      if (gc.i.matchCurrentWord(gc.re.SPECIALCASES)) {
        handled = !!(
          self.doDoubleQuote() ||
          self.doSingleQuote() ||
          self.doOpeningBracket() ||
          self.doClosingBracket() ||
          self.doComma() ||
          self.doPeriod() ||
          self.doLineStop() ||
          self.doAmpersand() ||
          self.doSlash() ||
          self.doColon() ||
          self.doHyphen() ||
          self.doInvertedMarks() ||
          self.doPlus() ||
          self.doAsterix() ||
          self.doDiamond() ||
          self.doPercent()
        );
      }
      (
        handled ||
        self.doDigits() ||
        self.doAcronym() ||
        self.doWord()
      );
    }
    gc.i.nextIndex();
  };

  // Delegate function for Artist/Release/Track specific handlers
  self.doWord = function () {};

  self.doNormalWord = function () {
    gc.o.appendSpaceIfNeeded();
    gc.i.capitalizeCurrentWord();
    gc.o.appendCurrentWord();
    flags.resetContext();
    flags.context.forceCaps = false;
    flags.context.spaceNextWord = true;
  };

  /*
   * Deal with whitespace (\t)
   * Primarily we only look at whitespace for context purposes
   */
  self.doWhiteSpace = function () {
    if (!gc.re.WHITESPACE) {
      gc.re.WHITESPACE = ' ';
    }
    if (gc.i.matchCurrentWord(gc.re.WHITESPACE)) {
      flags.context.whitespace = true;
      flags.context.spaceNextWord = true;
      if (flags.context.openingBracket) {
        flags.context.spaceNextWord = false;
      }
      return true;
    }
    return false;
  };

  /*
   * Deal with colons (:)
   * Colons are used as a sub-title split,and also for disc/box name splits
   */
  self.doColon = function () {
    if (!gc.re.COLON) {
      gc.re.COLON = ':';
    }

    if (gc.i.matchCurrentWord(gc.re.COLON)) {
      /*
       * Capitalize the last word before the colon (it's a line stop)
       * -- handle special case feat. "role" lowercase.
       */
      var featIndex = gc.o.getLength() - 3;
      var role;
      if (flags.context.slurpExtraTitleInformation &&
          featIndex > 0 &&
          gc.o.getWordAtIndex(featIndex) == 'feat.' &&
          (role = gc.o.getLastWord()) != '') {
        gc.o.setWordAtIndex(gc.o.getLength() - 1, role.toLowerCase());
      } else {
        /*
         * Force capitalization of the last word,
         * because we are starting a new subtitle
         */
        gc.o.capitalizeLastWord(!gc.mode.isSentenceCaps());
      }

      // from next position on, skip spaces and dots.
      var skip = false;
      var pos = gc.i.getPos();
      var len = gc.i.getLength();
      if (pos < len - 2) {
        var nword = gc.i.getWordAtIndex(pos + 1);
        var naword = gc.i.getWordAtIndex(pos + 2);
        if (nword.match(gc.re.OPENBRACKET)) {
          skip = true;
          flags.context.spaceNextWord = true;
        }
        if (gc.i.isNextWord(' ') &&
          naword.match(gc.re.OPENBRACKET)) {
          flags.context.spaceNextWord = true;
          skip = true;
          gc.i.nextIndex();
        }
      }
      if (!skip) {
        // No whitespace before colons
        gc.o.appendCurrentWord();
        flags.resetContext();
        flags.context.forceCaps = true;
        flags.context.colon = true;
        flags.context.spaceNextWord = (gc.i.isNextWord(' '));
      }
      return true;
    }
    return false;
  };

  // Deal with asterisk (*)
  self.doAsterix = function () {
    if (!gc.re.ASTERIX) {
      gc.re.ASTERIX = '*';
    }
    if (gc.i.matchCurrentWord(gc.re.ASTERIX)) {
      gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: true});
      flags.resetContext();
      return true;
    }
    return false;
  };

  // Deal with diamond (#)
  self.doDiamond = function () {
    if (!gc.re.DIAMOND) {
      gc.re.DIAMOND = '#';
    }
    if (gc.i.matchCurrentWord(gc.re.DIAMOND)) {
      gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: true});
      flags.resetContext();
      return true;
    }
    return false;
  };

  /*
   * Deal with percent signs (%)
   * TODO: lots of methods for special chars look the same, combine?
   */
  self.doPercent = function () {
    if (!gc.re.PERCENT) {
      gc.re.PERCENT = '%';
    }
    if (gc.i.matchCurrentWord(gc.re.PERCENT)) {
      gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: true});
      flags.resetContext();
      return true;
    }
    return false;
  };

  // Deal with ampersands (&)
  self.doAmpersand = function () {
    if (!gc.re.AMPERSAND) {
      gc.re.AMPERSAND = '&';
    }
    if (gc.i.matchCurrentWord(gc.re.AMPERSAND)) {
      flags.resetContext();
      flags.context.forceCaps = true;
      gc.o.appendSpace(); // Add a space,and remember to
      flags.context.spaceNextWord = true; // Add one before the next word
      gc.o.appendCurrentWord();
      return true;
    }
    return false;
  };

  // Deal with line terminators other than the period (?!;)
  self.doLineStop = function () {
    if (!gc.re.LINESTOP) {
      gc.re.LINESTOP = /[\?\!\;]/;
    }
    if (gc.i.matchCurrentWord(gc.re.LINESTOP)) {
      flags.resetContext();

      /*
       * Force caps on word before the colon, if
       * the mode is not sentencecaps
       */
      gc.o.capitalizeLastWord(!gc.mode.isSentenceCaps());

      flags.context.forceCaps = true;
      flags.context.spaceNextWord = true;
      gc.o.appendCurrentWord();
      return true;
    }
    return false;
  };

  /*
   * Deal with hyphens (-)
   * If a hyphen has a space near it, it should be spaced out and treated
   * similar to a sentence pause, if not it's a part of a hyphenated word.
   * Unfortunately it's not practical to implement real em-dashes, however
   * we'll treat a spaced hyphen as an em-dash for the purposes of caps.
   */
  self.doHyphen = function () {
    if (!gc.re.HYPHEN) {
      gc.re.HYPHEN = '-';
    }
    if (gc.i.matchCurrentWord(gc.re.HYPHEN)) {
      gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: true});
      flags.resetContext();

      // Don't capitalize next word after hyphen in sentence mode.
      flags.context.forceCaps = !gc.mode.isSentenceCaps();
      flags.context.hypen = true;
      return true;
    }
    return false;
  };

  // Deal with inverted question (¿) and exclamation marks (¡).
  self.doInvertedMarks = function () {
    if (!gc.re.INVERTEDMARKS) {
      gc.re.INVERTEDMARKS = /(¿|¡)/;
    }
    if (gc.i.matchCurrentWord(gc.re.INVERTEDMARKS)) {
      gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: false});
      flags.resetContext();

      // Next word is start of a new sentence.
      flags.context.forceCaps = true;
      return true;
    }
    return false;
  };

  // Deal with plus symbol    (+)
  self.doPlus = function () {
    if (!gc.re.PLUS) {
      gc.re.PLUS = '+';
    }
    if (gc.i.matchCurrentWord(gc.re.PLUS)) {
      gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: true});
      flags.resetContext();
      return true;
    }
    return false;
  };

  /*
   * Deal with slashes (/,\)
   * If a slash has a space near it, pad it out, otherwise leave as is.
   */
  self.doSlash = function () {
    if (!gc.re.SLASH) {
      gc.re.SLASH = /[\\\/]/;
    }
    if (gc.i.matchCurrentWord(gc.re.SLASH)) {
      gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: true});
      flags.resetContext();
      flags.context.forceCaps = true;
      return true;
    }
    return false;
  };

  // Deal with double quotes (")
  self.doDoubleQuote = function () {
    if (!gc.re.DOUBLEQUOTE) {
      gc.re.DOUBLEQUOTE = /["“”„“«»]/;
    }
    if (gc.i.matchCurrentWord(gc.re.DOUBLEQUOTE)) {
      // Changed 05/2006: do not force capitalization before quotes
      gc.o.appendWordPreserveWhiteSpace({apply: true, capslast: false});

      // Changed 05/2006: do not force capitalization after quotes
      flags.resetContext();
      flags.context.forceCaps = !gc.i.isNextWord(' ');
      return true;
    }
    return false;
  };

  /*
   * Deal with single quotes (')
   * * Need to keep context on whether gc.re.inside quotes or not.
   * * Look for contractions (see contractions_words for a list of
   *   contractions that are handled), and format the right part (after)
   *   the (') as lowercase.
   */
  self.doSingleQuote = function () {
    if (!gc.re.SINGLEQUOTE) {
      gc.re.SINGLEQUOTE = /['‘’‹›]/;
    }

    if (gc.i.matchCurrentWord(gc.re.SINGLEQUOTE)) {
      flags.context.forceCaps = false;
      var a = gc.i.isPreviousWord(' ');
      var b = gc.i.isNextWord(' ');
      var state = flags.context.openedSingleQuote;

      /*
       * Preserve whitespace before opening singlequote.
       * -- if it's a "Asdf 'Text in Quotes'"
       */
      if (a && !b) {
        gc.o.appendSpace();
        flags.context.openedSingleQuote = true;
        flags.context.forceCaps = true;

        // Preserve whitespace after closing singlequote.
      } else if (!a && b) {
        if (state) {
          flags.context.forceCaps = true;
          flags.context.openedSingleQuote = false;
        }
        gc.o.capitalizeLastWord();
      }
      flags.context.spaceNextWord = b; // and keep whitespace intact
      gc.o.appendCurrentWord(); // append current word

      /*
       * If there is a space after the '
       * then assume its a closing singlequote
       * Do not force capitalization per default, else for "Rollin' on",
       * the "On" will be titled.
       */
      flags.resetContext();

      /*
       * Default, if singlequote state was not modified, is
       * not forcing caps.
       */
      if (state == flags.context.openedSingleQuote) {
        flags.context.forceCaps = false;
      }
      flags.context.singlequote = true;
      return true;
    }
    return false;
  };

  /*
   * Deal with opening parenthesis    (([{<)
   * Knowing whether gc.re.inside parenthesis (and multiple levels thereof)
   * is important for determining what words should be capped or not.
   */
  self.doOpeningBracket = function () {
    if (!gc.re.OPENBRACKET) {
      gc.re.OPENBRACKET = /[\(\[\{\<]/;
    }
    if (gc.i.matchCurrentWord(gc.re.OPENBRACKET)) {
      /*
       * Force caps on last word before the opending bracket,
       * if the current mode is not sentence mode.
       */
      gc.o.capitalizeLastWord(!gc.mode.isSentenceCaps());

      // register current bracket as openening bracket
      flags.pushBracket(gc.i.getCurrentWord());
      var cb = flags.getCurrentCloseBracket();
      var forcelowercase = false;
      var pos = gc.i.getPos() + 1;
      for (var i = pos; i < gc.i.getLength(); i++) {
        var w = (gc.i.getWordAtIndex(i) || '');
        if (w != ' ') {
          if ((utils.isLowerCaseBracketWord(w)) ||
              (w.match(/^featuring$|^ft$|^feat$/i) != null)) {
            flags.context.slurpExtraTitleInformation = true;

            if (i == pos) {
              forcelowercase = true;
            }
          }
          if (w == cb) {
            break;
          }
        }
      }
      gc.o.appendSpace(); // Always space brackets
      flags.resetContext();
      flags.context.spaceNextWord = false;
      flags.context.openingBracket = true;
      flags.context.forceCaps = !forcelowercase;
      gc.o.appendCurrentWord();
      return true;
    }
    return false;
  };

  /*
   * Deal with closing parenthesis    (([{<)
   * Knowing whether gc.re.inside parenthesis (and multiple levels thereof)
   * is important for determining what words should be capped or not.
   */
  self.doClosingBracket = function () {
    if (!gc.re.CLOSEBRACKET) {
      gc.re.CLOSEBRACKET = /[\)\]\}\>]/;
    }
    if (gc.i.matchCurrentWord(gc.re.CLOSEBRACKET)) {
      /*
       * Capitalize the last word, if forceCaps was
       * set, else leave it like it is.
       */
      gc.o.capitalizeLastWord();

      if (flags.isInsideBrackets()) {
        flags.popBracket();
        flags.context.slurpExtraTitleInformation = false;
      }
      flags.resetContext();
      flags.context.forceCaps = !gc.mode.isSentenceCaps();
      flags.context.spaceNextWord = true;
      gc.o.appendCurrentWord();
      return true;
    }
    return false;
  };

  /*
   * Deal with commas.            (,)
   * Commas can mean two things: a sentence pause or a number split.
   * We need context to guess which one it's meant to be, thus the digit
   * triplet checking later on. Multiple commas are removed.
   */
  self.doComma = function () {
    if (!gc.re.COMMA) {
      gc.re.COMMA = ',';
    }
    if (gc.i.matchCurrentWord(gc.re.COMMA)) {
      // Skip duplicate commas.
      if (gc.o.getLastWord() != ',') {
        /*
         * Capitalize the last word before the colon.
         * -- Do words before comma need to be titled?
         * -- See http://bugs.musicbrainz.org/ticket/1317
         */

        // Handle comma
        flags.resetContext();
        flags.context.spaceNextWord = true;
        flags.context.forceCaps = false;
        gc.o.appendCurrentWord();
      }
      return true;
    }
    return false;
  };

  /*
   * Deal with periods.         (.)
   * Periods can also mean four things:
   *   * a sentence break (full stop);
   *   * a number split in some countries
   *   * part of an ellipsis (...)
   *   * an acronym split.
   * We flag digits and digit triplets in the words routine.
   */
  self.doPeriod = function () {
    if (!gc.re.PERIOD) {
      gc.re.PERIOD = '.';
    }

    if (gc.i.matchCurrentWord(gc.re.PERIOD)) {
      if (gc.o.getLastWord() == '.') {
        if (!flags.context.ellipsis) {
          gc.o.appendWord('..');
          while (gc.i.isNextWord('.')) {
            gc.i.nextIndex(); // Skip trailing (.)
          }
          flags.resetContext();
          flags.context.ellipsis = true;
        }
        flags.context.forceCaps = true; // Capitalize next word in any case.
        flags.context.spaceNextWord = true;
      } else {
        if (!gc.i.hasMoreWords() || gc.i.getNextWord() != '.') {
          /*
           * Capitalize the last word, if forceCaps was
           * set, else leave it like it is.
           */
          gc.o.capitalizeLastWord();
        }
        gc.o.appendWord('.');
        flags.resetContext();
        flags.context.forceCaps = true; // Force caps on next word
        flags.context.spaceNextWord = (gc.i.isNextWord(' '));
      }
      return true;
    }
    return false;
  };

  // Check for an acronym
  self.doAcronym = function () {
    if (!gc.re.ACRONYM) {
      gc.re.ACRONYM = /^\w$/;
    }

    /*
     * Acronym handling was made less strict to
     * fix broken acronyms which look like this: "A. B. C."
     * The variable flags.context.gotPeriod is used such that such
     * cases do not yield false positives:
     * The method works as follows:
     * "A.B.C. I Love You"          => "A.B.C. I Love You"
     * "A. B. C. I Love You"        => "A.B.C. I Love You"
     * "A.B.C I Love You"           => "A.B. C I Love You"
     * "P.S I Love You"             => "P. S I Love You"
     */
    let subIndex;
    const tmp = [];
    if (gc.i.matchCurrentWord(gc.re.ACRONYM)) {
      var cw = gc.i.getCurrentWord();
      tmp.push(cw.toUpperCase()); // Add current word
      flags.context.expectWord = false;
      flags.context.gotPeriod = false;

      acronymloop:
      for (subIndex = gc.i.getPos() + 1; subIndex < gc.i.getLength();) {
        cw = gc.i.getWordAtIndex(subIndex); // Remember current word.

        if (flags.context.expectWord && cw.match(gc.re.ACRONYM)) {
          tmp.push(cw.toUpperCase()); // Do character
          flags.context.expectWord = false;
          flags.context.gotPeriod = false;
        } else {
          if (cw == '.' && !flags.context.gotPeriod) {
            tmp[tmp.length] = '.'; // Do dot
            flags.context.gotPeriod = true;
            flags.context.expectWord = true;
          } else if (flags.context.gotPeriod && cw == ' ') {
            flags.context.expectWord = true; // Do a single whitespace
          } else if (tmp[tmp.length - 1] != '.') {
            tmp.pop(); // Lose last of the acronym
            subIndex--; // It's for example "P.S. I" love you
          }
          // Found something which is not part of the acronym
          break acronymloop;
        }
        subIndex++;
      }
    }

    if (tmp.length > 2) {
      var s = tmp.join(''); // Yes, we have an acronym, get string
      s = s.replace(/(\.)*$/, '.'); // Replace any number of trailing "." with ". "

      gc.o.appendSpaceIfNeeded();
      gc.o.appendWord(s);

      flags.resetContext();
      flags.context.acronym = true;
      flags.context.spaceNextWord = true;
      flags.context.forceCaps = false;
      gc.i.setPos(subIndex - 1); // Set pointer to after acronym
      return true;
    }
    return false;
  };

  // Check for a digit only string
  self.doDigits = function () {
    if (!gc.re.DIGITS) {
      gc.re.DIGITS = /^\d+$/;
      gc.re.DIGITS_NUMBERSPLIT = /[,.]/;
      gc.re.DIGITS_DUPLE = /^\d\d$/;
      gc.re.DIGITS_TRIPLE = /^\d\d\d$/;
      gc.re.DIGITS_NTUPLE = /^\d\d\d\d+$/;
    }

    let subIndex = null;
    const tmp = [];
    if (gc.i.matchCurrentWord(gc.re.DIGITS)) {
      tmp.push(gc.i.getCurrentWord());
      flags.context.numberSplitExpect = true;

      numberloop:
      for (subIndex = gc.i.getPos() + 1; subIndex < gc.i.getLength();) {
        if (flags.context.numberSplitExpect) {
          if (gc.i.matchWordAtIndex(subIndex, gc.re.DIGITS_NUMBERSPLIT)) {
            // Found a potential number split
            tmp.push(gc.i.getWordAtIndex(subIndex));
            flags.context.numberSplitExpect = false;
          } else {
            break numberloop;
          }
        } else if (gc.i.matchWordAtIndex(subIndex, gc.re.DIGITS_TRIPLE)) {
          // Found for a group of 3 digits
          if (flags.context.numberSplitChar == null) {
            // Confirmed number split
            flags.context.numberSplitChar = tmp[tmp.length - 1];
          }
          tmp.push(gc.i.getWordAtIndex(subIndex));
          flags.context.numberSplitExpect = true;
        } else {
          if (gc.i.matchWordAtIndex(subIndex, gc.re.DIGITS_DUPLE)) {
            if (tmp.length > 2 &&
                flags.context.numberSplitChar != tmp[tmp.length - 1]) {
              /*
               * Check for the opposite number splitter (, or .)
               * because numbers are generally either
               * 1,000,936.00 or 1.300.402,00 depending on
               * the country
               */
              tmp.push(gc.i.getWordAtIndex(subIndex++));
            } else {
              tmp.pop(); // stand-alone number pair
              subIndex--;
            }
          } else if (gc.i.matchWordAtIndex(subIndex, gc.re.DIGITS_NTUPLE)) {
            /*
             * Big number at the end, probably a decimal point,
             * end of number in any case
             */
            tmp.push(gc.i.getWordAtIndex(subIndex++));
          } else {
            tmp.pop(); // Last number split was not
            subIndex--; // actually a number split
          }
          break numberloop;
        }
        subIndex++;
      }
      gc.i.setPos(subIndex - 1);

      gc.o.appendSpaceIfNeeded();
      gc.o.appendWord(tmp.join(''));

      flags.resetContext();
      flags.context.forceCaps = false;
      flags.context.number = true;

      return true;
    }
    return false;
  };

  /*
   * Do not change the caps of certain words
   * ---------------------------------------------------
   * warp        2011-08-13        first version
   */
  self.doIgnoreWords = function () {
    // deciBel
    if (gc.i.getCurrentWord() === 'dB') {
      gc.o.appendSpaceIfNeeded();
      gc.o.appendCurrentWord();
      return true;
    }
    return false;
  };

  /*
   * Detect featuring,f., ft[.], feat[.] and add parentheses as needed.
   * keschte        2005-11-10        added ^f\.$ to cases
   *                                  which are added converted to feat.
   * ---------------------------------------------------
   */
  self.doFeaturingArtistStyle = function () {
    if (!gc.re.FEAT) {
      gc.re.FEAT = /^featuring$|^f$|^ft$|^feat$/i;
      gc.re.FEAT_F = /^f$/i; // Match word "f"
      gc.re.FEAT_FEAT = /^feat$/i; // Match word "feat"
    }
    if (gc.i.matchCurrentWord(gc.re.FEAT)) {
      /*
       * Special cases (f.) and (f/),
       * have to check if next word is a "." or a "/"
       */
      if ((gc.i.matchCurrentWord(gc.re.FEAT_F)) &&
          gc.i.getNextWord() &&
          !gc.i.getNextWord().match(/^[\/.]$/)) {
        return false;
      }

      /*
       * Only try to convert to feat. if there are
       * enough words after the keyword
       */
      if (gc.i.getPos() < gc.i.getLength() - 2) {
        const featWord = gc.i.getCurrentWord() + (
          gc.i.isNextWord('.') || gc.i.isNextWord('/') ? gc.i.getNextWord() :
          // Special case (feat), fix typo by adding a "." if missing
            gc.i.matchCurrentWord(gc.re.FEAT_FEAT) ? '.' : ''
        );

        if (!flags.context.openingBracket && !flags.isInsideBrackets()) {
          if (flags.isInsideBrackets()) {
            // Close open parentheses before the feat. part.
            while (flags.isInsideBrackets()) {
              // Close brackets that were opened before
              var cb = flags.popBracket();
              gc.o.appendWord(cb);
              if (gc.i.getWordAtIndex(gc.i.getLength() - 1) == cb) {
                gc.i.dropLastWord();
                /*
                 * Get rid of duplicate bracket at the end (will be
                 * added again by closeOpenBrackets if they wern't
                 * closed before (e.g. using feat.)
                 */
              }
            }
          }

          /*
           * Handle case:
           * Blah ft. Erroll Flynn Some Remixname remix
           * -> pre-processor added parentheses such that the string is:
           * Blah ft. erroll flynn Some Remixname (remix)
           * -> now there are parentheses needed before remix, we can't
           *    guess where the artist name ends, and the remixname starts
           *    though :]
           * Blah (feat. Erroll Flynn Some Remixname) (remix)
           */
          const pos = gc.i.getPos();
          const len = gc.i.getLength();
          let i = pos;
          for (; i < len; i++) {
            if (gc.i.getWordAtIndex(i) == '(') {
              break;
            }
          }

          /*
           * We got a part, but not until the end of the string
           * close feat. part, and add space to next set of brackets
           */
          if (i != pos && i < len - 1) {
            gc.i.insertWordsAtIndex(i, [')', ' ']);
          }
          gc.i.updateCurrentWord('(');
          self.doOpeningBracket();
        } else {
          gc.o.appendWord(' ');
        }

        // gc.o.appendSpaceIfNeeded();
        gc.o.appendWord(featWord);

        flags.resetContext();
        flags.context.forceCaps = true;
        flags.context.openingBracket = false;
        flags.context.spaceNextWord = true;
        flags.context.slurpExtraTitleInformation = true;
        flags.context.feat = true;
        if (gc.i.isNextWord('.') || gc.i.isNextWord('/')) {
          gc.i.nextIndex();  // skip trailing (.) or (/)
        }
        return true;
      }
    }
    return false;
  };

  self.moveArticleToEnd = function (is) {
    return utils.trim(is).replace(
      /^(The|Los) (.+)$/,
      function (match, article, name) {
        return name + ', ' + article;
      },
    );
  };

  self.sortCompoundName = function (is, callback) {
    is = utils.trim(is);

    var joinPhrase = ' and ';
    joinPhrase = (is.indexOf(' + ') == -1 ? joinPhrase : ' + ');
    joinPhrase = (is.indexOf(' & ') == -1 ? joinPhrase : ' & ');

    return is.split(joinPhrase).map(callback).join(joinPhrase);
  };

  return self;
};
