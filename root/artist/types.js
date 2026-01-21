/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type EditArtistCreditFormT = FormT<{
  +artist_credit: FieldT<ArtistCreditT>,
  +edit_note: FieldT<string>,
  +make_votable: FieldT<boolean>,
  +preview: FieldT<string>,
}>;
