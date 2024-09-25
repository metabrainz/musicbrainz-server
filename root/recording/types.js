/*
 * @flow strict
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type RecordingFormT = FormT<{
    +artist_credit: ArtistCreditFieldT,
    +comment: FieldT<string>,
    +edit_note: FieldT<string>,
    +isrcs: RepeatableFieldT<FieldT<string>>,
    +length: FieldT<string>,
    +make_votable: FieldT<boolean>,
    +name: FieldT<string | null>,
    +video: FieldT<boolean>,
  }>;
