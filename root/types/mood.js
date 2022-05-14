/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// MusicBrainz::Server::Entity::Mood::TO_JSON
declare type MoodT = $ReadOnly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'mood'>,
  +primaryAlias?: string | null,
}>;
