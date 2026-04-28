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
declare type EventT = $ReadOnly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...RelatableEntityRoleT<'event'>,
  ...DatePeriodRoleT,
  ...RatableRoleT,
  ...ReviewableRoleT,
  ...TypeRoleT<EventTypeT>,
  +areas: ReadonlyArray<{
    +credit: string,
    +entity: AreaT,
  }>,
  +cancelled: boolean,
  +event_art_presence: 'absent' | 'present' | 'darkened' | null,
  +may_have_event_art?: boolean,
  +performers: ReadonlyArray<{
    +credit: string,
    +entity: ArtistT,
    +roles: ReadonlyArray<string>,
  }>,
  +places: ReadonlyArray<{
    +credit: string,
    +entity: PlaceT,
  }>,
  +primaryAlias?: string | null,
  +related_entities?: {
    +areas: AppearancesT<string>,
    +performers: AppearancesT<string>,
    +places: AppearancesT<string>,
  },
  +related_series: ReadonlyArray<number>,
  +setlist?: string,
  +time: string,
}>;

declare type EventTypeT = OptionTreeT<'event_type'>;
