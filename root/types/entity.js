/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

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

declare type EntityWithAliasesTypeT = EntityWithAliasesT['entityType'];

declare type EntityWithSeriesMapT = {
  'artist': ArtistT,
  'event': EventT,
  'recording': RecordingT,
  'release': ReleaseT,
  'release_group': ReleaseGroupT,
  'series': SeriesT,
  'work': WorkT,
};

declare type EntityWithSeriesT = Values<EntityWithSeriesMapT>;

declare type EntityWithSeriesTypeT = keyof EntityWithSeriesMapT;

declare type AppearancesT<T> = {
  readonly hits: number,
  readonly results: ReadonlyArray<T>,
};

declare type CommentRoleT = {
  readonly comment: string,
};

declare type RelatableEntityRoleT<out T> = {
  ...EntityRoleT<T>,
  ...LastUpdateRoleT,
  ...PendingEditsRoleT,
  readonly gid: string,
  readonly name: string,
  readonly paged_relationship_groups?: {
    readonly [targetType: RelatableEntityTypeT]: PagedTargetTypeGroupT | void,
  },
  readonly relationships?: ReadonlyArray<RelationshipT>,
};

declare type CollectableEntityT =
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

declare type CollectableEntityTypeT = CollectableEntityT['entityType'];

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

declare type EditableEntityTypeT = EditableEntityT['entityType'];

declare type EntityWithArtistCreditsT =
  | RecordingT
  | ReleaseGroupT
  | ReleaseT
  | TrackT;

declare type EntityWithArtistCreditsTypeT =
  EntityWithArtistCreditsT['entityType'];

declare type EntityWithAutoCleanupTypeT =
  | 'artist'
  | 'event'
  | 'label'
  | 'place'
  | 'release_group'
  | 'series'
  | 'work';

declare type DatePeriodRoleT = {
  readonly begin_date: PartialDateT | null,
  readonly end_date: PartialDateT | null,
  readonly ended: boolean,
};

declare type ManuallyRemovableEntityT =
  | AreaT
  | GenreT
  | InstrumentT
  | RecordingT
  | ReleaseT;

declare type MergeableEntityT =
  | AreaT
  | ArtistT
  | CollectionT
  | EventT
  | InstrumentT
  | LabelT
  | PlaceT
  | RecordingT
  | ReleaseGroupT
  | ReleaseT
  | SeriesT
  | WorkT;

declare type MergeableEntityTypeT = MergeableEntityT['entityType'];

declare type PendingEditsRoleT = {
  readonly editsPending: boolean,
};

declare type EntityRoleT<out T> = {
  readonly entityType: T,
  readonly id: number,
};

declare type LastUpdateRoleT = {
  readonly last_updated: string | null,
};

declare type MinimalEntityT = {
  readonly entityType: string,
  readonly gid: string,
};

declare type PartialDateT = {
  readonly day?: ?number,
  readonly month?: ?number,
  readonly year?: ?number,
};

declare type PartialDateStringsT = {
  readonly day?: string,
  readonly month?: string,
  readonly year?: string,
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
  NonUrlRelatableEntityT['entityType'];

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

declare type SubscribableEntityTypeT = SubscribableEntityT['entityType'];

declare type TaggableEntityT =
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

declare type TaggableEntityTypeT = TaggableEntityT['entityType'];

declare type TypeRoleT<T> = {
  readonly typeID: number | null,
  readonly typeName?: string,
};

declare type WikipediaExtractT = {
  readonly content: string,
  readonly url: string,
};
