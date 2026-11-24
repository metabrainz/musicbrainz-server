/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

// MusicBrainz::Server::Entity::AggregatedTag::TO_JSON
declare type AggregatedTagT = {
  readonly count: number,
  readonly tag: TagT,
};

// MusicBrainz::Server::Entity::Tag::TO_JSON
declare type TagT = {
  readonly entityType: 'tag',
  readonly genre?: GenreT,
  readonly id: number | null,
  readonly name: string,
};

// MusicBrainz::Server::Entity::UserTag::TO_JSON
declare type UserTagT = {
  readonly count: number,
  readonly tag: TagT,
  readonly vote: 1 | 0 | -1,
};
