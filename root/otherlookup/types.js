/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type OtherLookupFormT = FormT<{
  +'artist-ipi': ReadOnlyFieldT<string>,
  +'artist-isni': ReadOnlyFieldT<string>,
  +'barcode': ReadOnlyFieldT<string>,
  +'catno': ReadOnlyFieldT<string>,
  +'discid': ReadOnlyFieldT<string>,
  +'freedbid': ReadOnlyFieldT<string>,
  +'isrc': ReadOnlyFieldT<string>,
  +'iswc': ReadOnlyFieldT<string>,
  +'label-ipi': ReadOnlyFieldT<string>,
  +'label-isni': ReadOnlyFieldT<string>,
  +'mbid': ReadOnlyFieldT<string>,
  +'url': ReadOnlyFieldT<string>,
}>;
