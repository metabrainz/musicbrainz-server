/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {type SearchResultT} from '../search/types';

export type TagLookupFormT = FormT<{
  +artist: ReadOnlyFieldT<string>,
  +duration: ReadOnlyFieldT<string>,
  +filename: ReadOnlyFieldT<string>,
  +release: ReadOnlyFieldT<string>,
  +track: ReadOnlyFieldT<string>,
  +tracknum: ReadOnlyFieldT<string>,
}>;

export type TagLookupPropsT = {
  +form: TagLookupFormT,
  +nag: boolean,
};

export type TagLookupResultsPropsT<T> = {
  +children: React$Node,
  +form: TagLookupFormT,
  +nag: boolean,
  +pager: PagerT,
  +query: string,
  +results: $ReadOnlyArray<SearchResultT<T>>,
};
