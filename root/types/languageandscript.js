/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

declare type LanguageT = {
  readonly entityType: 'language',
  readonly frequency: 0 | 1 | 2,
  readonly id: number,
  readonly iso_code_1: string | null,
  readonly iso_code_2b: string | null,
  readonly iso_code_2t: string | null,
  readonly iso_code_3: string | null,
  readonly name: string,
};

declare type ScriptT = {
  readonly entityType: 'script',
  readonly frequency: 1 | 2 | 3 | 4,
  readonly id: number,
  readonly iso_code: string,
  readonly iso_number: string | null,
  readonly name: string,
};
