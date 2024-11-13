/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

// MusicBrainz::Server::Entity::Artist::TO_JSON
declare type ArtistT = $ReadOnly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...RelatableEntityRoleT<'artist'>,
  ...DatePeriodRoleT,
  ...IpiCodesRoleT,
  ...IsniCodesRoleT,
  ...RatableRoleT,
  ...TypeRoleT<ArtistTypeT>,
  +area: AreaT | null,
  +begin_area: AreaT | null,
  +begin_area_id: number | null,
  +end_area: AreaT | null,
  +end_area_id: number | null,
  +gender: GenderT | null,
  +gender_id: number | null,
  +primaryAlias?: string | null,
  +sort_name: string,
}>;

declare type ArtistTypeT = OptionTreeT<'artist_type'>;

declare type GenderT = OptionTreeT<'gender'>;
