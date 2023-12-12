/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type OtherLookupFormT = FormT<{
  +'artist-ipi': FieldT<string>,
  +'artist-isni': FieldT<string>,
  +'barcode': FieldT<string>,
  +'catno': FieldT<string>,
  +'discid': FieldT<string>,
  +'freedbid': FieldT<string>,
  +'isrc': FieldT<string>,
  +'iswc': FieldT<string>,
  +'label-ipi': FieldT<string>,
  +'label-isni': FieldT<string>,
  +'mbid': FieldT<string>,
  +'url': FieldT<string>,
}>;
