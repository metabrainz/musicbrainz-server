/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// MusicBrainz::Server::Entity::Collection::TO_JSON
declare type CollectionT = $ReadOnly<{
  ...EntityRoleT<'collection'>,
  ...TypeRoleT<CollectionTypeT>,
  +collaborators: $ReadOnlyArray<EditorT>,
  +description: string,
  +description_html: string,
  +editor: EditorT | null,
  +editor_is_limited: boolean,
  +entity_count: number,
  +gid: string,
  +item_entity_type?: CollectableEntityTypeT,
  +name: string,
  +public: boolean,
  +subscribed?: boolean,
}>;

declare type CollectionTypeT = {
  ...OptionTreeT<'collection_type'>,
  item_entity_type: string,
};
