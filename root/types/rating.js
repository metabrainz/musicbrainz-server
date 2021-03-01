/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// MusicBrainz::Server::Entity::Role::Rating::TO_JSON
declare type RatableRoleT = {
  +rating?: number,
  +rating_count?: number,
  +user_rating?: number,
};

declare type RatableT =
  | ArtistT
  | EventT
  | LabelT
  | PlaceT
  | RecordingT
  | ReleaseGroupT
  | WorkT;

// MusicBrainz::Server::Entity::Rating::TO_JSON
declare type RatingT = {
  +editor: EditorT,
  +rating: number,
};
