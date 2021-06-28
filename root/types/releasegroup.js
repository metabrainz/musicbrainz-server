/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare type ReleaseGroupSecondaryTypeT =
  OptionTreeT<'release_group_secondary_type'>;

// MusicBrainz::Server::Entity::ReleaseGroup::TO_JSON
declare type ReleaseGroupT = $ReadOnly<{
  ...AnnotationRoleT,
  ...ArtistCreditRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'release_group'>,
  ...RatableRoleT,
  ...TypeRoleT<ReleaseGroupTypeT>,
  +cover_art?: ArtworkT,
  +firstReleaseDate: string | null,
  +l_type_name: string | null,
  +primaryAlias?: string | null,
  +release_count: number,
  +release_group?: ReleaseGroupT,
  +review_count: ?number,
  +secondaryTypeIDs: $ReadOnlyArray<number>,
  +typeID: number | null,
  +typeName: string | null,
}>;

declare type ReleaseGroupTypeT = {
  ...OptionTreeT<'release_group_type'>,
  +historic: false,
};

declare type ReleaseGroupHistoricTypeT = {
  +historic: true,
  +id: number,
  +name: string,
};
