/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type InlineResultsReactTablePropsT<T> = {
  +$c: CatalystContextT,
  +entities: $ReadOnlyArray<T>,
  +pager: PagerT,
  +query: string,
  +resultsNumber: number,
  +scores: {[gid: string]: number},
};

export type ResultsReactTablePropsT<T> = {
  ...InlineResultsReactTablePropsT<T>,
  +form: SearchFormT,
  +lastUpdated?: string,
};

export type ResultsReactTablePropsWithContextT<T> = {
  ...InlineResultsReactTablePropsT<T>,
  +$c: CatalystContextT,
  +form: SearchFormT,
  +lastUpdated?: string,
};

export type InlineResultsPropsT<T> = {
  +$c?: CatalystContextT,
  +pager: PagerT,
  +query: string,
  +results: $ReadOnlyArray<SearchResultT<T>>,
};

export type InlineResultsPropsWithContextT<T> = {
  +$c: CatalystContextT,
  +pager: PagerT,
  +query: string,
  +results: $ReadOnlyArray<SearchResultT<T>>,
};

export type ResultsPropsT<T> = {
  ...InlineResultsPropsT<T>,
  +form: SearchFormT,
  +lastUpdated?: string,
};

export type ResultsPropsWithContextT<T> = {
  ...InlineResultsPropsT<T>,
  +$c: CatalystContextT,
  +form: SearchFormT,
  +lastUpdated?: string,
};
