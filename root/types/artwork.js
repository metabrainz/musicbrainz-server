/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// MusicBrainz::Server::Entity::Artwork::TO_JSON
declare type ArtworkT = {
  ...EditableRoleT,
  +comment: string,
  +filename: string | null,
  +huge_ia_thumbnail: string,
  +huge_thumbnail: string,
  +id: number,
  +image: string | null,
  +large_ia_thumbnail: string,
  +large_thumbnail: string,
  +mime_type: string,
  +release?: ReleaseT,
  +small_ia_thumbnail: string,
  +small_thumbnail: string,
  +suffix: string,
  +types: $ReadOnlyArray<string>,
};

// MusicBrainz::Server::Entity::CommonsImage::TO_JSON
declare type CommonsImageT = {
  +page_url: string,
  +thumb_url: string,
};

declare type CoverArtTypeT = OptionTreeT<'cover_art_type'>;
