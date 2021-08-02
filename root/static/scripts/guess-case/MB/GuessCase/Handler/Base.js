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

  self.getWordsForProcessing =
    gc.input.splitWordsAndPunctuation.bind(gc.input);

  self.process = function (is) {
    gc.output.init();
    gc.input.init(is, self.getWordsForProcessing(is));
    while (!gc.input.isIndexAtEnd()) {
      self.processWord();
    }
    return gc.mode.runPostProcess(gc.output.getOutput());
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
      if (!gc.regexes.SPECIALCASES) {
        gc.regexes.SPECIALCASES = /(&|¿|¡|\?|\!|;|:|'|‘|’|‹|›|"|“|”|„|“|«|»|\-|\+|,|\*|\.|#|%|\/|\(|\)|\{|\}|\[|\])/;
      }
      if (gc.input.matchCurrentWord(gc.regexes.SPECIALCASES)) {
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
    gc.input.nextIndex();
  };

  // Delegate function for Artist/Release/Track specific handlers
  self.doWord = function () {};

  self.doNormalWord = function () {
    gc.output.appendSpaceIfNeeded();
    gc.input.capitalizeCurrentWord();
    gc.output.appendCurrentWord();
    flags.resetContext();
    flags.context.forceCaps = false;
    flags.context.spaceNextWord = true;
  };

  /*
   * Deal with whitespace (\t)
   * Primarily we only look at whitespace for context purposes
   */
  self.doWhiteSpace = function () {
    if (!gc.regexes.WHITESPACE) {
      gc.regexes.WHITESPACE = ' ';
    }
    if (gc.input.matchCurrentWord(gc.regexes.WHITESPACE)) {
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
    if (!gc.regexes.COLON) {
      gc.regexes.COLON = ':';
    }

    if (gc.input.matchCurrentWord(gc.regexes.COLON)) {
      /*
       * Capitalize the last word before the colon (it's a line stop)
       * -- handle special case feat. "role" lowercase.
       */
      var featIndex = gc.output.getLength() - 3;
      var role;
      if (flags.context.slurpExtraTitleInformation &&
          featIndex > 0 &&
          gc.output.getWordAtIndex(featIndex) == 'feat.' &&
          (role = gc.output.getLastWord()) != '') {
        gc.output.setWordAtIndex(
          gc.output.getLength() - 1,
          role.toLowerCase(),
        );
      } else {
        /*
         * Force capitalization of the last word,
         * because we are starting a new subtitle
         */
        gc.output.capitalizeLastWord(!gc.mode.isSentenceCaps());
      }

      // from next position on, skip spaces and dots.
      var skip = false;
      var pos = gc.input.getCursorPosition();
      var len = gc.input.getLength();
      if (pos < len - 2) {
        var nword = gc.input.getWordAtIndex(pos + 1);
        var naword = gc.input.getWordAtIndex(pos + 2);
        if (nword.match(gc.regexes.OPENBRACKET)) {
          skip = true;
          flags.context.spaceNextWord = true;
        }
        if (gc.input.isNextWord(' ') &&
          naword.match(gc.regexes.OPENBRACKET)) {
          flags.context.spaceNextWord = true;
          skip = true;
          gc.input.nextIndex();
        }
      }
      if (!skip) {
        // No whitespace before colons
        gc.output.appendCurrentWord();
        flags.resetContext();
        flags.context.forceCaps = true;
        flags.context.colon = true;
        flags.context.spaceNextWord = (gc.input.isNextWord(' '));
      }
      return true;
    }
    return false;
  };

  // Deal with asterisk (*)
  self.doAsterix = function () {
    if (!gc.regexes.ASTERIX) {
      gc.regexes.ASTERIX = '*';
    }
    if (gc.input.matchCurrentWord(gc.regexes.ASTERIX)) {
      gc.output.appendWordPreserveWhiteSpace({apply: true, capslast: true});
      flags.resetContext();
      return true;
    }
    return false;
  };

  // Deal with diamond (#)
  self.doDiamond = function () {
    if (!gc.regexes.DIAMOND) {
      gc.regexes.DIAMOND = '#';
    }
    if (gc.input.matchCurrentWord(gc.regexes.DIAMOND)) {
      gc.output.appendWordPreserveWhiteSpace({apply: true, capslast: true});
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
    if (!gc.regexes.PERCENT) {
      gc.regexes.PERCENT = '%';
    }
    if (gc.input.matchCurrentWord(gc.regexes.PERCENT)) {
      gc.output.appendWordPreserveWhiteSpace({apply: true, capslast: true});
      flags.resetContext();
      return true;
    }
    return false;
  };

  // Deal with ampersands (&)
  self.doAmpersand = function () {
    if (!gc.regexes.AMPERSAND) {
      gc.regexes.AMPERSAND = '&';
    }
    if (gc.input.matchCurrentWord(gc.regexes.AMPERSAND)) {
      flags.resetContext();
      flags.context.forceCaps = true;
      gc.output.appendSpace(); // Add a space,and remember to
      flags.context.spaceNextWord = true; // Add one before the next word
      gc.output.appendCurrentWord();
      return true;
    }
    return false;
  };

  // Deal with line terminators other than the period (?!;)
  self.doLineStop = function () {
    if (!gc.regexes.LINESTOP) {
      gc.regexes.LINESTOP = /[\?\!\;]/;
    }
    if (gc.input.matchCurrentWord(gc.regexes.LINESTOP)) {
      flags.resetContext();

      /*
       * Force caps on word before the colon, if
       * the mode is not sentencecaps
       */
      gc.output.capitalizeLastWord(!gc.mode.isSentenceCaps());

      flags.context.forceCaps = true;
      flags.context.spaceNextWord = true;
      gc.output.appendCurrentWord();
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
    if (!gc.regexes.HYPHEN) {
      gc.regexes.HYPHEN = '-';
    }
    if (gc.input.matchCurrentWord(gc.regexes.HYPHEN)) {
      gc.output.appendWordPreserveWhiteSpace({apply: true, capslast: true});
      flags.resetContext();

      // Don't capitalize next word after hyphen in sentence mode.
      flags.context.forceCaps = !gc.mode.isSentenceCaps();
      flags.context.hyphen = true;
      return true;
    }
    return false;
  };

  // Deal with inverted question (¿) and exclamation marks (¡).
  self.doInvertedMarks = function () {
    if (!gc.regexes.INVERTEDMARKS) {
      gc.regexes.INVERTEDMARKS = /(¿|¡)/;
    }
    if (gc.input.matchCurrentWord(gc.regexes.INVERTEDMARKS)) {
      gc.output.appendWordPreserveWhiteSpace({apply: true, capslast: false});
      flags.resetContext();

      // Next word is start of a new sentence.
      flags.context.forceCaps = true;
      return true;
    }
    return false;
  };

  // Deal with plus symbol    (+)
  self.doPlus = function () {
    if (!gc.regexes.PLUS) {
      gc.regexes.PLUS = '+';
    }
    if (gc.input.matchCurrentWord(gc.regexes.PLUS)) {
      gc.output.appendWordPreserveWhiteSpace({apply: true, capslast: true});
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
    if (!gc.regexes.SLASH) {
      gc.regexes.SLASH = /[\\\/]/;
    }
    if (gc.input.matchCurrentWord(gc.regexes.SLASH)) {
      gc.output.appendWordPreserveWhiteSpace({apply: true, capslast: true});
      flags.resetContext();
      flags.context.forceCaps = true;
      return true;
    }
    return false;
  };

  // Deal with double quotes (")
  self.doDoubleQuote = function () {
    if (!gc.regexes.DOUBLEQUOTE) {
      gc.regexes.DOUBLEQUOTE = /["“”„“«»]/;
    }
    if (gc.input.matchCurrentWord(gc.regexes.DOUBLEQUOTE)) {
      // Changed 05/2006: do not force capitalization before quotes
      gc.output.appendWordPreserveWhiteSpace({apply: true, capslast: false});

      // Changed 05/2006: do not force capitalization after quotes
      flags.resetContext();
      flags.context.forceCaps = !gc.input.isNextWord(' ');
      return true;
    }
    return false;
  };

  /*
   * Deal with single quotes (')
   * * Need to keep context on whether gc.regexes.inside quotes or not.
   * * Look for contractions (see contractions_words for a list of
   *   contractions that are handled), and format the right part (after)
   *   the (') as lowercase.
   */
  self.doSingleQuote = function () {
    if (!gc.regexes.SINGLEQUOTE) {
      gc.regexes.SINGLEQUOTE = /['‘’‹›]/;
    }

    if (gc.input.matchCurrentWord(gc.regexes.SINGLEQUOTE)) {
      flags.context.forceCaps = false;
      var a = gc.input.isPreviousWord(' ');
      var b = gc.input.isNextWord(' ');
      var state = flags.context.openedSingleQuote;

      /*
       * Preserve whitespace before opening singlequote.
       * -- if it's a "Asdf 'Text in Quotes'"
       */
      if (a && !b) {
        gc.output.appendSpace();
        flags.context.openedSingleQuote = true;
        flags.context.forceCaps = true;

        // Preserve whitespace after closing singlequote.
      } else if (!a && b) {
        if (state) {
          flags.context.forceCaps = true;
          flags.context.openedSingleQuote = false;
        }
        gc.output.capitalizeLastWord();
      }
      flags.context.spaceNextWord = b; // and keep whitespace intact
      gc.output.appendCurrentWord(); // append current word

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
   * Knowing whether we are inside parenthesis (and multiple levels thereof)
   * is important for determining what words should be capped or not.
   */
  self.doOpeningBracket = function () {
    if (!gc.regexes.OPENBRACKET) {
      gc.regexes.OPENBRACKET = /[\(\[\{\<]/;
    }
    if (gc.input.matchCurrentWord(gc.regexes.OPENBRACKET)) {
      /*
       * Force caps on last word before the opending bracket,
       * if the current mode is not sentence mode.
       */
      gc.output.capitalizeLastWord(!gc.mode.isSentenceCaps());

      // register current bracket as openening bracket
      flags.pushBracket(gc.input.getCurrentWord());
      var cb = flags.getCurrentCloseBracket();
      var forcelowercase = false;
      var pos = gc.input.getCursorPosition() + 1;
      for (var i = pos; i < gc.input.getLength(); i++) {
        var w = (gc.input.getWordAtIndex(i) || '');
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
      gc.output.appendSpace(); // Always space brackets
      flags.resetContext();
      flags.context.spaceNextWord = false;
      flags.context.openingBracket = true;
      flags.context.forceCaps = !forcelowercase;
      gc.output.appendCurrentWord();
      return true;
    }
    return false;
  };

  /*
   * Deal with closing parenthesis    (([{<)
   * Knowing whether we are inside parenthesis (and multiple levels thereof)
   * is important for determining what words should be capped or not.
   */
  self.doClosingBracket = function () {
    if (!gc.regexes.CLOSEBRACKET) {
      gc.regexes.CLOSEBRACKET = /[\)\]\}\>]/;
    }
    if (gc.input.matchCurrentWord(gc.regexes.CLOSEBRACKET)) {
      /*
       * Capitalize the last word, if forceCaps was
       * set, else leave it like it is.
       */
      gc.output.capitalizeLastWord();

      if (flags.isInsideBrackets()) {
        flags.popBracket();
        flags.context.slurpExtraTitleInformation = false;
      }
      flags.resetContext();
      flags.context.forceCaps = !gc.mode.isSentenceCaps();
      flags.context.spaceNextWord = true;
      gc.output.appendCurrentWord();
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
    if (!gc.regexes.COMMA) {
      gc.regexes.COMMA = ',';
    }
    if (gc.input.matchCurrentWord(gc.regexes.COMMA)) {
      // Skip duplicate commas.
      if (gc.output.getLastWord() != ',') {
        /*
         * Capitalize the last word before the colon.
         * -- Do words before comma need to be titled?
         * -- See http://bugs.musicbrainz.org/ticket/1317
         */

        // Handle comma
        flags.resetContext();
        flags.context.spaceNextWord = true;
        flags.context.forceCaps = false;
        gc.output.appendCurrentWord();
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
    if (!gc.regexes.PERIOD) {
      gc.regexes.PERIOD = '.';
    }

    if (gc.input.matchCurrentWord(gc.regexes.PERIOD)) {
      if (gc.output.getLastWord() == '.') {
        if (!flags.context.ellipsis) {
          gc.output.appendWord('..');
          while (gc.input.isNextWord('.')) {
            gc.input.nextIndex(); // Skip trailing (.)
          }
          flags.resetContext();
          flags.context.ellipsis = true;
        }
        flags.context.forceCaps = true; // Capitalize next word in any case.
        flags.context.spaceNextWord = true;
      } else {
        if (!gc.input.hasMoreWords() || gc.input.getNextWord() != '.') {
          /*
           * Capitalize the last word, if forceCaps was
           * set, else leave it like it is.
           */
          gc.output.capitalizeLastWord();
        }
        gc.output.appendWord('.');
        flags.resetContext();
        flags.context.forceCaps = true; // Force caps on next word
        flags.context.spaceNextWord = (gc.input.isNextWord(' '));
      }
      return true;
    }
    return false;
  };

  // Check for an acronym
  self.doAcronym = function () {
    if (!gc.regexes.ACRONYM) {
      gc.regexes.ACRONYM = /^\w$/;
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
    if (gc.input.matchCurrentWord(gc.regexes.ACRONYM)) {
      var cw = gc.input.getCurrentWord();
      tmp.push(cw.toUpperCase()); // Add current word
      flags.context.expectWord = false;
      flags.context.gotPeriod = false;

      acronymloop:
      for (
        subIndex = gc.input.getCursorPosition() + 1;
        subIndex < gc.input.getLength();
      ) {
        cw = gc.input.getWordAtIndex(subIndex); // Remember current word.

        if (flags.context.expectWord && cw.match(gc.regexes.ACRONYM)) {
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

      gc.output.appendSpaceIfNeeded();
      gc.output.appendWord(s);

      flags.resetContext();
      flags.context.acronym = true;
      flags.context.spaceNextWord = true;
      flags.context.forceCaps = false;
      // Set pointer to after acronym
      gc.input.setCursorPosition(subIndex - 1);
      return true;
    }
    return false;
  };

  // Check for a digit only string
  self.doDigits = function () {
    if (!gc.regexes.DIGITS) {
      gc.regexes.DIGITS = /^\d+$/;
      gc.regexes.DIGITS_NUMBERSPLIT = /[,.]/;
      gc.regexes.DIGITS_DUPLE = /^\d\d$/;
      gc.regexes.DIGITS_TRIPLE = /^\d\d\d$/;
      gc.regexes.DIGITS_NTUPLE = /^\d\d\d\d+$/;
    }

    let subIndex = null;
    const tmp = [];
    if (gc.input.matchCurrentWord(gc.regexes.DIGITS)) {
      tmp.push(gc.input.getCurrentWord());
      flags.context.numberSplitExpect = true;

      numberloop:
      for (
        subIndex = gc.input.getCursorPosition() + 1;
        subIndex < gc.input.getLength();
      ) {
        if (flags.context.numberSplitExpect) {
          if (gc.input.matchWordAtIndex(
            subIndex,
            gc.regexes.DIGITS_NUMBERSPLIT,
          )) {
            // Found a potential number split
            tmp.push(gc.input.getWordAtIndex(subIndex));
            flags.context.numberSplitExpect = false;
          } else {
            break numberloop;
          }
        } else if (gc.input.matchWordAtIndex(
          subIndex,
          gc.regexes.DIGITS_TRIPLE,
        )) {
          // Found for a group of 3 digits
          if (flags.context.numberSplitChar == null) {
            // Confirmed number split
            flags.context.numberSplitChar = tmp[tmp.length - 1];
          }
          tmp.push(gc.input.getWordAtIndex(subIndex));
          flags.context.numberSplitExpect = true;
        } else {
          if (gc.input.matchWordAtIndex(subIndex, gc.regexes.DIGITS_DUPLE)) {
            if (tmp.length > 2 &&
                flags.context.numberSplitChar != tmp[tmp.length - 1]) {
              /*
               * Check for the opposite number splitter (, or .)
               * because numbers are generally either
               * 1,000,936.00 or 1.300.402,00 depending on
               * the country
               */
              tmp.push(gc.input.getWordAtIndex(subIndex++));
            } else {
              tmp.pop(); // stand-alone number pair
              subIndex--;
            }
          } else if (gc.input.matchWordAtIndex(
            subIndex,
            gc.regexes.DIGITS_NTUPLE,
          )) {
            /*
             * Big number at the end, probably a decimal point,
             * end of number in any case
             */
            tmp.push(gc.input.getWordAtIndex(subIndex++));
          } else {
            tmp.pop(); // Last number split was not
            subIndex--; // actually a number split
          }
          break numberloop;
        }
        subIndex++;
      }
      gc.input.setCursorPosition(subIndex - 1);

      gc.output.appendSpaceIfNeeded();
      gc.output.appendWord(tmp.join(''));

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
    if (gc.input.getCurrentWord() === 'dB') {
      gc.output.appendSpaceIfNeeded();
      gc.output.appendCurrentWord();
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
    if (!gc.regexes.FEAT) {
      gc.regexes.FEAT = /^featuring$|^f$|^ft$|^feat$/i;
      gc.regexes.FEAT_F = /^f$/i; // Match word "f"
      gc.regexes.FEAT_FEAT = /^feat$/i; // Match word "feat"
    }
    if (gc.input.matchCurrentWord(gc.regexes.FEAT)) {
      /*
       * Special cases (f.) and (f/),
       * have to check if next word is a "." or a "/"
       */
      if ((gc.input.matchCurrentWord(gc.regexes.FEAT_F)) &&
          gc.input.getNextWord() &&
          !gc.input.getNextWord().match(/^[\/.]$/)) {
        return false;
      }

      /*
       * Only try to convert to feat. if there are
       * enough words after the keyword
       */
      if (gc.input.getCursorPosition() < gc.input.getLength() - 2) {
        const featWord = gc.input.getCurrentWord() + (
          gc.input.isNextWord('.') || gc.input.isNextWord('/')
            ? gc.input.getNextWord()
          // Special case (feat), fix typo by adding a "." if missing
            : gc.input.matchCurrentWord(gc.regexes.FEAT_FEAT) ? '.' : ''
        );

        if (!flags.context.openingBracket && !flags.isInsideBrackets()) {
          if (flags.isInsideBrackets()) {
            // Close open parentheses before the feat. part.
            while (flags.isInsideBrackets()) {
              // Close brackets that were opened before
              var cb = flags.popBracket();
              gc.output.appendWord(cb);
              if (gc.input.getWordAtIndex(gc.input.getLength() - 1) == cb) {
                gc.input.dropLastWord();
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
          const pos = gc.input.getCursorPosition();
          const len = gc.input.getLength();
          let i = pos;
          for (; i < len; i++) {
            if (gc.input.getWordAtIndex(i) == '(') {
              break;
            }
          }

          /*
           * We got a part, but not until the end of the string
           * close feat. part, and add space to next set of brackets
           */
          if (i != pos && i < len - 1) {
            gc.input.insertWordsAtIndex(i, [')', ' ']);
          }
          gc.input.updateCurrentWord('(');
          self.doOpeningBracket();
        } else {
          gc.output.appendWord(' ');
        }

        // gc.output.appendSpaceIfNeeded();
        gc.output.appendWord(featWord);

        flags.resetContext();
        flags.context.forceCaps = true;
        flags.context.openingBracket = false;
        flags.context.spaceNextWord = true;
        flags.context.slurpExtraTitleInformation = true;
        flags.context.feat = true;
        if (gc.input.isNextWord('.') || gc.input.isNextWord('/')) {
          gc.input.nextIndex();  // skip trailing (.) or (/)
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
