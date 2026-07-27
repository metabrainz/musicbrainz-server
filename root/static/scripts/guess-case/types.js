/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type GuessCaseModeT = {
  readonly description: string,
  readonly doWord: () => boolean,
  readonly fixVinylSizes: (string) => string,
  readonly isLowerCaseWord: (string) => boolean,
  readonly isRomanNumber: (string) => boolean,
  readonly isSentenceCaps: () => boolean,
  readonly isUpperCaseWord: (string) => boolean,
  readonly name: string,
  readonly prepExtraTitleInfo: (Array<string>) => Array<string>,
  readonly preProcessTitles: (string) => string,
  readonly runPostProcess: (string) => string,
  readonly toLowerCase: (string) => string,
  readonly toUpperCase: (string) => string,
};

export type GuessCaseModeNameT =
  | 'English'
  | 'French'
  | 'Sentence'
  | 'Turkish';
