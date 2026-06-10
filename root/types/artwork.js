/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

// MusicBrainz::Server::Entity::Artwork::TO_JSON
declare type ArtworkRoleT = Readonly<{
  ...PendingEditsRoleT,
  readonly comment: string,
  readonly event?: EventT,
  readonly filename: string | null,
  readonly huge_ia_thumbnail: string,
  readonly huge_thumbnail: string,
  readonly id: number,
  readonly image: string | null,
  readonly large_ia_thumbnail: string,
  readonly large_thumbnail: string,
  readonly mime_type: string,
  readonly small_ia_thumbnail: string,
  readonly small_thumbnail: string,
  readonly suffix: string,
  readonly types: ReadonlyArray<string>,
}>;

declare type ReleaseArtT = Readonly<{
  ...ArtworkRoleT,
  readonly release?: ReleaseT,
}>;

declare type EventArtT = Readonly<{
  ...ArtworkRoleT,
  readonly event?: EventT,
}>;

declare type ArtworkT =
  | EventArtT
  | ReleaseArtT;

// MusicBrainz::Server::Entity::CommonsImage::TO_JSON
declare type CommonsImageT = {
  readonly page_url: string,
  readonly thumb_url: string,
};

declare type CoverArtTypeT = OptionTreeT<'cover_art_type'>;

declare type EventArtTypeT = OptionTreeT<'event_art_type'>;
