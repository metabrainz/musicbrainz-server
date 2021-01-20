/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// MusicBrainz::Server::Entity::Area::TO_JSON
declare type AreaT = $ReadOnly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'area'>,
  ...DatePeriodRoleT,
  ...TypeRoleT<AreaTypeT>,
  +containment: $ReadOnlyArray<AreaT> | null,
  +country_code: string,
  +iso_3166_1_codes: $ReadOnlyArray<string>,
  +iso_3166_2_codes: $ReadOnlyArray<string>,
  +iso_3166_3_codes: $ReadOnlyArray<string>,
  +primary_code: string,
  +primaryAlias?: string | null,
}>;

declare type AreaTypeT = OptionTreeT<'area_type'>;
