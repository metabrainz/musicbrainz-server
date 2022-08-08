/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// MusicBrainz::Server::Entity::Coordinates::TO_JSON
declare type CoordinatesT = {
  +latitude: number,
  +longitude: number,
};

// MusicBrainz::Server::Entity::Place::TO_JSON
declare type PlaceT = $ReadOnly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'place'>,
  ...DatePeriodRoleT,
  ...RatableRoleT,
  ...ReviewableRoleT,
  ...TypeRoleT<PlaceTypeT>,
  +address: string,
  +area: AreaT | null,
  +coordinates: CoordinatesT | null,
  +primaryAlias?: string | null,
}>;

declare type PlaceTypeT = OptionTreeT<'place_type'>;
