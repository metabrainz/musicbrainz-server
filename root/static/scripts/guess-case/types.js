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

declare type GuessCaseModeT = any;

export type GuessCaseT = {
  CFG_KEEP_UPPERCASED: boolean,
  input: GuessCaseInput,
  mode: GuessCaseModeT,
  output: GuessCaseOutput,
  regexes: {
    [regexName: string]: RegExp,
  },
};
