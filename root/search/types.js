/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type InlineResultsPropsT<T> = {
  readonly pager: PagerT,
  readonly query: string,
  readonly results: ReadonlyArray<SearchResultT<T>>,
};

export type ResultsPropsT<T> = Readonly<{
  ...InlineResultsPropsT<T>,
  readonly form: SearchFormT,
  readonly lastUpdated?: string,
}>;

export type SearchResultT<T> = {
  readonly entity: T,
  readonly extra: ReadonlyArray<{
    readonly medium_position: number,
    readonly medium_track_count: number,
    readonly release: ReleaseT,
    readonly track_position: number,
  }>,
  readonly position: number,
  readonly score: number,
};
