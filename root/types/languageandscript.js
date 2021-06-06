/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare type LanguageT = {
  +entityType: 'language',
  +frequency: number,
  +id: number,
  +iso_code_1: string | null,
  +iso_code_2b: string | null,
  +iso_code_2t: string | null,
  +iso_code_3: string | null,
  +name: string,
};

declare type ScriptT = {
  +entityType: 'script',
  +frequency: number,
  +id: number,
  +iso_code: string,
  +iso_number: string | null,
  +name: string,
};
