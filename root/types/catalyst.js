/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// Most of these types are serialized in the MusicBrainz::Server package.

declare type CatalystActionT = {
  +name: string,
};

declare type CatalystContextT = {
  +action: CatalystActionT,
  +flash: {
    +message?: string,
  },
  +relative_uri: string,
  +req: CatalystRequestContextT,
  +session: CatalystSessionT | null,
  +sessionid: string | null,
  +stash: CatalystStashT,
  +user?: UnsanitizedEditorT,
};

declare type CatalystRequestContextT = {
  +body_params: {+[param: string]: string},
  +headers: {+[header: string]: string},
  +query_params: {+[param: string]: string},
  +secure: boolean,
  +uri: string,
};

declare type CatalystSessionT = {
  +merger?: MergeQueueT,
  +tport?: number,
};

declare type CatalystStashT = {
  +alert?: string,
  +alert_mtime?: number | null,
  +can_delete?: boolean,
  +collaborative_collections?: $ReadOnlyArray<CollectionT>,
  +commons_image?: CommonsImageT | null,
  +containment?: {
    [collectionId: number]: ?1,
  },
  +current_action_requires_auth?: boolean,
  +current_language: string,
  +current_language_html: string,
  +entity?: CoreEntityT,
  +genre_map?: {+[genreName: string]: GenreT, ...},
  +globals_script_nonce?: string,
  +hide_merge_helper?: boolean,
  +jsonld_data?: {...},
  +last_replication_date?: string,
  +makes_no_changes?: boolean,
  +mood_map?: {+[moodName: string]: MoodT, ...},
  +more_tags?: boolean,
  +new_edit_notes?: boolean,
  +new_edit_notes_mtime?: number | null,
  +number_of_collections?: number,
  +number_of_revisions?: number,
  +own_collections?: $ReadOnlyArray<CollectionT>,
  +release_artwork?: ArtworkT,
  +release_artwork_count?: number,
  +release_cdtoc_count?: number,
  +server_languages?: $ReadOnlyArray<ServerLanguageT>,
  +subscribed?: boolean,
  +to_merge?: $ReadOnlyArray<CoreEntityT>,
  +top_tags?: $ReadOnlyArray<AggregatedTagT>,
  +user_tags?: $ReadOnlyArray<UserTagT>,
};

// MusicBrainz::Server::MergeQueue::TO_JSON
declare type MergeQueueT = {
  +entities: $ReadOnlyArray<number>,
  +ready_to_merge: boolean,
  +type: CoreEntityTypeT,
};

// root/utility/sanitizedContext.js
declare type SanitizedCatalystSessionT = {
  +tport?: number,
};

declare type SanitizedCatalystContextT = {
  +action: {
    +name: string,
  },
  +relative_uri: string,
  +req: {
    +uri: string,
  },
  +session: SanitizedCatalystSessionT | null,
  +stash: {
    +current_language: string,
    +genre_map?: {+[genreName: string]: GenreT, ...},
    +mood_map?: {+[moodName: string]: MoodT, ...},
  },
  +user: ActiveEditorT | null,
};

declare type ServerLanguageT = {
  +id: number,
  +name: string,
  +native_language: string,
  +native_territory: string,
};
