/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

// MusicBrainz::Server::Entity::Collection::TO_JSON
declare type CollectionT = Readonly<{
  ...EntityRoleT<'collection'>,
  ...TypeRoleT<CollectionTypeT>,
  readonly collaborators: ReadonlyArray<EditorT>,
  readonly description: string,
  readonly description_html: string,
  readonly editor: EditorT | null,
  readonly entity_count: number,
  readonly gid: string,
  readonly item_entity_type?: CollectableEntityTypeT,
  readonly name: string,
  readonly public: boolean,
  readonly subscribed?: boolean,
}>;

declare type CollectionTypeT = {
  ...OptionTreeT<'collection_type'>,
  item_entity_type: string,
};
