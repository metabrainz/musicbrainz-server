/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

declare type ReleaseGroupSecondaryTypeT =
  OptionTreeT<'release_group_secondary_type'>;

// MusicBrainz::Server::Entity::ReleaseGroup::TO_JSON
declare type ReleaseGroupT = Readonly<{
  ...AnnotationRoleT,
  ...ArtistCreditRoleT,
  ...CommentRoleT,
  ...RelatableEntityRoleT<'release_group'>,
  ...RatableRoleT,
  ...ReviewableRoleT,
  ...TypeRoleT<ReleaseGroupTypeT>,
  readonly cover_art?: ReleaseArtT,
  readonly firstReleaseDate: string | null,
  readonly hasCoverArt: boolean,
  readonly l_type_name: string | null,
  readonly primaryAlias?: string | null,
  readonly release_count: number,
  readonly release_group?: ReleaseGroupT,
  readonly secondaryTypeIDs: ReadonlyArray<number>,
  readonly typeID: number | null,
  readonly typeName: string | null,
}>;

declare type ReleaseGroupTypeT = {
  ...OptionTreeT<'release_group_type'>,
  readonly historic: false,
};

declare type ReleaseGroupHistoricTypeT = {
  readonly historic: true,
  readonly id: number,
  readonly name: string,
};
