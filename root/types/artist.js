/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// MusicBrainz::Server::Entity::Artist::TO_JSON
declare type ArtistT = $ReadOnly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...RelatableEntityRoleT<'artist'>,
  ...DatePeriodRoleT,
  ...IpiCodesRoleT,
  ...IsniCodesRoleT,
  ...RatableRoleT,
  ...ReviewableRoleT,
  ...TypeRoleT<ArtistTypeT>,
  +area: AreaT | null,
  +begin_area: AreaT | null,
  +end_area: AreaT | null,
  +gender: GenderT | null,
  +primaryAlias?: string | null,
  +sort_name: string,
}>;

declare type ArtistTypeT = OptionTreeT<'artist_type'>;

declare type GenderT = OptionTreeT<'gender'>;
