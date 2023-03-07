/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare type AnnotatedEntityT =
  | AreaT
  | ArtistT
  | EventT
  | GenreT
  | InstrumentT
  | LabelT
  | PlaceT
  | RecordingT
  | ReleaseGroupT
  | ReleaseT
  | SeriesT
  | WorkT;

declare type AnnotatedEntityTypeT = AnnotatedEntityT['entityType'];

// MusicBrainz::Server::Entity::Role::Annotation::TO_JSON
declare type AnnotationRoleT = {
  +latest_annotation?: AnnotationT,
};

// MusicBrainz::Server::Entity::Annotation::TO_JSON
declare type AnnotationT = {
  +changelog: string,
  +creation_date: string,
  +editor: EditorT | null,
  +html: string,
  +id: number,
  +parent: AnnotatedEntityT | null,
  +text: string | null,
};
