/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type GenreFormT = FormT<{
  readonly comment: FieldT<string>,
  readonly edit_note: FieldT<string>,
  readonly make_votable: FieldT<boolean>,
  readonly name: FieldT<string | null>,
}>;
