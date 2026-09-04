/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// MusicBrainz::Server::Entity::Area::TO_JSON
declare type AreaT = Readonly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...RelatableEntityRoleT<'area'>,
  ...DatePeriodRoleT,
  ...TypeRoleT<AreaTypeT>,
  readonly containment: ReadonlyArray<AreaT> | null,
  readonly country_code: string,
  readonly iso_3166_1_codes: ReadonlyArray<string>,
  readonly iso_3166_2_codes: ReadonlyArray<string>,
  readonly iso_3166_3_codes: ReadonlyArray<string>,
  readonly primary_code: string,
  readonly primaryAlias?: string | null,
}>;

declare type AreaTypeT = OptionTreeT<'area_type'>;
