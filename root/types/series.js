/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare type SeriesEntityTypeT =
  | 'artist'
  | 'event'
  | 'recording'
  | 'release'
  | 'release_group'
  | 'work';

// MusicBrainz::Server::Entity::Series::TO_JSON
declare type SeriesT = $ReadOnly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'series'>,
  ...TypeRoleT<SeriesTypeT>,
  +orderingTypeID: number,
  +primaryAlias?: string | null,
  +type?: SeriesTypeT,
}>;

declare type SeriesItemNumbersRoleT = {
  +seriesItemNumbers?: $ReadOnlyArray<string>,
};

declare type SeriesOrderingTypeT = OptionTreeT<'series_ordering_type'>;

declare type SeriesTypeT = $ReadOnly<{
  ...OptionTreeT<'series_type'>,
  item_entity_type: SeriesEntityTypeT,
}>;
