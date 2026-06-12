/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

// MusicBrainz::Server::Entity::Event::TO_JSON
declare type EventT = Readonly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...RelatableEntityRoleT<'event'>,
  ...DatePeriodRoleT,
  ...RatableRoleT,
  ...ReviewableRoleT,
  ...TypeRoleT<EventTypeT>,
  readonly areas: ReadonlyArray<{
    readonly credit: string,
    readonly entity: AreaT,
  }>,
  readonly cancelled: boolean,
  readonly event_art_presence: 'absent' | 'present' | 'darkened' | null,
  readonly may_have_event_art?: boolean,
  readonly performers: ReadonlyArray<{
    readonly credit: string,
    readonly entity: ArtistT,
    readonly roles: ReadonlyArray<string>,
  }>,
  readonly places: ReadonlyArray<{
    readonly credit: string,
    readonly entity: PlaceT,
  }>,
  readonly primaryAlias?: string | null,
  readonly related_entities?: {
    readonly areas: AppearancesT<string>,
    readonly performers: AppearancesT<string>,
    readonly places: AppearancesT<string>,
  },
  readonly related_series: ReadonlyArray<number>,
  readonly setlist?: string,
  readonly time: string,
}>;

declare type EventTypeT = OptionTreeT<'event_type'>;
