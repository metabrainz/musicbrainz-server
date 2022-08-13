/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type InlineResultsPropsT<T> = {
  +pager: PagerT,
  +query: string,
  +results: $ReadOnlyArray<SearchResultT<T>>,
};

export type ResultsPropsT<T> = {
  ...InlineResultsPropsT<T>,
  +form: SearchFormT,
  +lastUpdated?: string,
};

export type SearchResultT<T> = {
  +entity: T,
  +extra: $ReadOnlyArray<{
    +medium_position: number,
    +medium_track_count: number,
    +release: ReleaseT,
    +track_position: number,
  }>,
  +position: number,
  +score: number,
};
