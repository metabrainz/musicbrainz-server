/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// MusicBrainz::Server::Entity::Event::TO_JSON
declare type EventT = $ReadOnly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'event'>,
  ...DatePeriodRoleT,
  ...RatableRoleT,
  ...ReviewableRoleT,
  ...TypeRoleT<EventTypeT>,
  +areas: $ReadOnlyArray<{
    +credit: string,
    +entity: AreaT,
  }>,
  +cancelled: boolean,
  +performers: $ReadOnlyArray<{
    +credit: string,
    +entity: ArtistT,
    +roles: $ReadOnlyArray<string>,
  }>,
  +places: $ReadOnlyArray<{
    +credit: string,
    +entity: PlaceT,
  }>,
  +primaryAlias?: string | null,
  +related_entities?: {
    +areas: AppearancesT<string>,
    +performers: AppearancesT<string>,
    +places: AppearancesT<string>,
  },
  +related_series: $ReadOnlyArray<number>,
  +setlist?: string,
  +time: string,
}>;

declare type EventTypeT = OptionTreeT<'event_type'>;
