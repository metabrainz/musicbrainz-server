/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// MusicBrainz::Server::Entity::AggregatedTag::TO_JSON
declare type AggregatedTagT = {
  +count: number,
  +tag: TagT,
};

// MusicBrainz::Server::Entity::Tag::TO_JSON
declare type TagT = {
  +entityType: 'tag',
  +genre?: GenreT,
  +id: number | null,
  +mood?: MoodT,
  +name: string,
};

// MusicBrainz::Server::Entity::UserTag::TO_JSON
declare type UserTagT = {
  +count: number,
  +tag: TagT,
  +vote: 1 | 0 | -1,
};
