/*
 * @flow
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type GuessCaseInput from './MB/GuessCase/Input';

declare type GuessCaseInputT = GuessCaseInput;

declare type GuessCaseModeT = any;

declare type GuessCaseOutputT = any;

export type GuessCaseT = {
  CFG_KEEP_UPPERCASED: boolean,
  input: GuessCaseInputT,
  mode: GuessCaseModeT,
  output: GuessCaseOutputT,
  regexes: {
    [regexName: string]: RegExp,
  },
};
