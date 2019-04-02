/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {Node as ReactNode} from 'react';

export type TagLookupFormT = FormT<{|
  +artist: ReadOnlyFieldT<string>,
  +duration: ReadOnlyFieldT<string>,
  +filename: ReadOnlyFieldT<string>,
  +release: ReadOnlyFieldT<string>,
  +track: ReadOnlyFieldT<string>,
  +tracknum: ReadOnlyFieldT<string>,
|}>;

export type TagLookupPropsT = {|
  +form: TagLookupFormT,
  +nag: boolean,
|};

export type TagLookupResultsPropsT<T> = {|
  +$c: CatalystContextT,
  +children: ReactNode,
  +form: TagLookupFormT,
  +nag: boolean,
  +pager: PagerT,
  +query: string,
  +results: $ReadOnlyArray<SearchResultT<T>>,
|};
