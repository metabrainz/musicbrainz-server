/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare type EntityWithAliasesT =
  | AreaT
  | ArtistT
  | EventT
  | GenreT
  | InstrumentT
  | LabelT
  | PlaceT
  | RecordingT
  | ReleaseGroupT
  | ReleaseT
  | SeriesT
  | WorkT;

declare type EntityWithAliasesTypeT =
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

declare type CollectableEntityT =
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

declare type CollectableEntityTypeT =
  | 'area'
  | 'artist'
  | 'event'
  | 'instrument'
  | 'label'
  | 'place'
  | 'recording'
  | 'release_group'
  | 'release'
  | 'series'
  | 'work';

declare type NonUrlCoreEntityT =
  | AreaT
  | ArtistT
  | EventT
  | GenreT
  | InstrumentT
  | LabelT
  | PlaceT
  | RecordingT
  | ReleaseGroupT
  | ReleaseT
  | SeriesT
  | WorkT;

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

declare type EditableEntityT =
  | AreaT
  | ArtistT
  | EventT
  | GenreT
  | InstrumentT
  | LabelT
  | PlaceT
  | RecordingT
  | ReleaseGroupT
  | ReleaseT
  | SeriesT
  | UrlT
  | WorkT;

declare type EditableEntityTypeT =
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
  | 'url'
  | 'work';

declare type EntityWithArtistCreditsT =
  | RecordingT
  | ReleaseGroupT
  | ReleaseT
  | TrackT;

declare type DatePeriodRoleT = {
  +begin_date: PartialDateT | null,
  +end_date: PartialDateT | null,
  +ended: boolean,
};

declare type PendingEditsRoleT = {
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

declare type PartialDateStringsT = {
  +day?: string,
  +month?: string,
  +year?: string,
};

declare type NonUrlRelatableEntityT =
  | AreaT
  | ArtistT
  | EventT
  | GenreT
  | InstrumentT
  | LabelT
  | PlaceT
  | RecordingT
  | ReleaseGroupT
  | ReleaseT
  | SeriesT
  | WorkT;

declare type RelatableEntityT =
  | NonUrlRelatableEntityT
  | UrlT;

declare type NonUrlRelatableEntityTypeT =
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

declare type RelatableEntityTypeT =
  | NonUrlRelatableEntityTypeT
  | 'url';

declare type SubscribableEntityT =
  | SubscribableEntityWithSidebarT
  | CollectionT
  | EditorT;

declare type SubscribableEntityWithSidebarT =
  | ArtistT
  | LabelT
  | SeriesT;

declare type SubscribableEntityTypeT =
  | 'artist'
  | 'collection'
  | 'editor'
  | 'label'
  | 'series';

declare type TypeRoleT<T> = {
  +typeID: number | null,
  +typeName?: string,
};

declare type WikipediaExtractT = {
  +content: string,
  +url: string,
};
