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
declare type ArtistT = Readonly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...RelatableEntityRoleT<'artist'>,
  ...DatePeriodRoleT,
  ...IpiCodesRoleT,
  ...IsniCodesRoleT,
  ...RatableRoleT,
  ...ReviewableRoleT,
  ...TypeRoleT<ArtistTypeT>,
  readonly area: AreaT | null,
  readonly begin_area: AreaT | null,
  readonly begin_area_id: number | null,
  readonly end_area: AreaT | null,
  readonly end_area_id: number | null,
  readonly gender: GenderT | null,
  readonly gender_id: number | null,
  readonly primaryAlias?: string | null,
  readonly sort_name: string,
}>;

declare type ArtistTypeT = OptionTreeT<'artist_type'>;

declare type GenderT = OptionTreeT<'gender'>;
