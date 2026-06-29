/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type OtherLookupFormT = FormT<{
  readonly 'artist-ipi': FieldT<string>,
  readonly 'artist-isni': FieldT<string>,
  readonly 'barcode': FieldT<string>,
  readonly 'catno': FieldT<string>,
  readonly 'discid': FieldT<string>,
  readonly 'freedbid': FieldT<string>,
  readonly 'isrc': FieldT<string>,
  readonly 'iswc': FieldT<string>,
  readonly 'label-ipi': FieldT<string>,
  readonly 'label-isni': FieldT<string>,
  readonly 'mbid': FieldT<string>,
  readonly 'url': FieldT<string>,
}>;
