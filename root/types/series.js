/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

declare type SeriesEntityTypeT =
  | 'artist'
  | 'event'
  | 'recording'
  | 'release'
  | 'release_group'
  | 'series'
  | 'work';

// MusicBrainz::Server::Entity::Series::TO_JSON
declare type SeriesT = Readonly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...RelatableEntityRoleT<'series'>,
  ...TypeRoleT<SeriesTypeT>,
  readonly entity_count?: number,
  readonly orderingTypeID: number,
  readonly primaryAlias?: string | null,
  readonly type?: SeriesTypeT,
}>;

declare type SeriesItemNumbersRoleT = {
  readonly seriesItemNumbers?: ReadonlyArray<string>,
};

declare type SeriesOrderingTypeT = OptionTreeT<'series_ordering_type'>;

declare type SeriesTypeT = Readonly<{
  ...OptionTreeT<'series_type'>,
  item_entity_type: SeriesEntityTypeT,
}>;
