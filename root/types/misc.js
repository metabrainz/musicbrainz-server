/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

declare type DeepReadOnly<T> =
  T extends ReadonlyArray<infer V> ? ReadonlyArray<DeepReadOnly<V>> :
  T extends {...} ? {readonly [K in keyof T]: DeepReadOnly<T[K]>} : T;

/*
 * See http://search.cpan.org/~lbrocard/Data-Page-2.02/lib/Data/Page.pm
 * Serialized in MusicBrainz::Server::TO_JSON.
 */
declare type PagerT = {
  readonly current_page: number,
  readonly entries_per_page: number,
  readonly first_page: 1,
  readonly last_page: number,
  readonly next_page: number | null,
  readonly previous_page: number | null,
  readonly total_entries: number,
};

declare type StrOrNum = string | number;
