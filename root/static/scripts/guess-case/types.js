/*
 * @flow
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type GuessCaseInput from './MB/GuessCase/Input';
import type GuessCaseOutput from './MB/GuessCase/Output';

export type GuessCaseModeT = {
  +description: string,
  +doWord: () => boolean,
  +fixVinylSizes: (string) => string,
  +isLowerCaseWord: (string) => boolean,
  +isRomanNumber: (string) => boolean,
  +isSentenceCaps: () => boolean,
  +isUpperCaseWord: (string) => boolean,
  +name: string,
  +prepExtraTitleInfo: (Array<string>) => Array<string>,
  +preProcessTitles: (string) => string,
  +runPostProcess: (string) => string,
  +toLowerCase: (string) => string,
  +toUpperCase: (string) => string,
};

export type GuessCaseT = {
  CFG_KEEP_UPPERCASED: boolean,
  +input: GuessCaseInput,
  +mode: GuessCaseModeT,
  +output: GuessCaseOutput,
  +regexes: {
    [regexName: string]: RegExp,
  },
};
