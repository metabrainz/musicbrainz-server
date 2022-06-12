/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare type AppearancesT<T> = {
  +hits: number,
  +results: $ReadOnlyArray<T>,
};

declare type CommentRoleT = {
  +comment: string,
};

declare type CoreEntityRoleT<+T> = {
  ...EntityRoleT<T>,
  ...LastUpdateRoleT,
  +gid: string,
  +name: string,
  +paged_relationship_groups?: {
    +[targetType: CoreEntityTypeT]: PagedTargetTypeGroupT | void,
  },
  +relationships?: $ReadOnlyArray<RelationshipT>,
};

declare type CollectableCoreEntityT =
  | AreaT
  | ArtistT
  | EventT
  | InstrumentT
  | LabelT
  | PlaceT
  | RecordingT
  | ReleaseGroupT
  | ReleaseT
  | SeriesT
  | WorkT;

declare type NonUrlCoreEntityT =
  | CollectableCoreEntityT
  | GenreT;

declare type CoreEntityT =
  | NonUrlCoreEntityT
  | UrlT;

declare type NonUrlCoreEntityTypeT =
  | 'area'
  | 'artist'
  | 'event'
  | 'genre'
  | 'instrument'
  | 'label'
  | 'place'
  | 'recording'
  | 'release_group'
  | 'release'
  | 'series'
  | 'work';

declare type CoreEntityTypeT =
  | NonUrlCoreEntityTypeT
  | 'url';

declare type DatePeriodRoleT = {
  +begin_date: PartialDateT | null,
  +end_date: PartialDateT | null,
  +ended: boolean,
};

declare type EditableRoleT = {
  +editsPending: boolean,
};

declare type EntityRoleT<+T> = {
  +entityType: T,
  +id: number,
};

declare type LastUpdateRoleT = {
  +last_updated: string | null,
};

declare type MinimalCoreEntityT = {
  +entityType: CoreEntityTypeT,
  +gid: string,
};

declare type PartialDateT = {
  +day: number | null,
  +month: number | null,
  +year: number | null,
};

declare type TypeRoleT<T> = {
  +typeID: number | null,
  +typeName?: string,
};

declare type WikipediaExtractT = {
  +content: string,
  +url: string,
};
