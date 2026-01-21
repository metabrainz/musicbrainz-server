/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type ReleaseGroupFormT = FormT<{
    +artist_credit: ArtistCreditFieldT,
    +comment: FieldT<string>,
    +edit_note: FieldT<string>,
    +make_votable: FieldT<boolean>,
    +name: FieldT<string | null>,
    +primary_type_id: FieldT<string>,
    +secondary_type_ids: FieldT<Array<string>>,
  }>;

export type SetCoverArtFormT = FormT<{
  +edit_note: FieldT<string>,
  +make_votable: FieldT<boolean>,
  +release: FieldT<string>,
}>;
