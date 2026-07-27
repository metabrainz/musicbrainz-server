/*
 * @flow strict
 * Copyright (C) 2019 Anirudh Jain
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type AliasEditFormT = FormT<{
  readonly edit_note: FieldT<string>,
  readonly locale: FieldT<string>,
  readonly make_votable: FieldT<boolean>,
  readonly name: FieldT<string | null>,
  readonly period: DatePeriodFieldT,
  readonly primary_for_locale: FieldT<boolean>,
  readonly sort_name: FieldT<string | null>,
  readonly type_id: FieldT<string>,
}>;
