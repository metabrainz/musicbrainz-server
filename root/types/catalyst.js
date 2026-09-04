/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

// Most of these types are serialized in the MusicBrainz::Server package.

declare type CatalystActionT = {
  readonly name: string,
};

declare type CatalystContextT = {
  readonly action: CatalystActionT,
  readonly flash: {
    readonly message?: string,
  },
  readonly relative_uri: string,
  readonly req: CatalystRequestContextT,
  readonly session: CatalystSessionT | null,
  readonly sessionid: string | null,
  readonly stash: CatalystStashT,
  readonly user?: UnsanitizedEditorT,
};

declare type CatalystRequestContextT = {
  readonly body_params: {readonly [param: string]: string},
  readonly headers: {readonly [header: string]: string},
  readonly method: string,
  readonly query_params: {readonly [param: string]: string},
  readonly secure: boolean,
  readonly uri: string,
};

declare type CatalystSessionT = {
  readonly merger?: MergeQueueT,
  readonly tport?: number,
};

declare type CatalystStashT = {
  readonly alert?: string,
  readonly alert_mtime?: number | null,
  readonly artist_credit?: ArtistCreditT,
  readonly artist_credit_field?: ArtistCreditFieldT,
  readonly can_delete?: boolean,
  readonly collaborative_collections?: ReadonlyArray<CollectionT>,
  readonly commons_image?: CommonsImageT | null,
  readonly containment?: {
    [collectionId: number]: ?1,
  },
  readonly current_action_requires_auth?: boolean,
  readonly current_isrcs?: ReadonlyArray<string>,
  readonly current_iswcs?: ReadonlyArray<string>,
  readonly current_language: string,
  readonly current_language_html: string,
  readonly entity?: RelatableEntityT,
  readonly event_artwork?: EventArtT,
  readonly event_artwork_count?: number,
  readonly genre_map?: {readonly [genreName: string]: GenreT, ...},
  readonly globals_script_nonce?: string,
  readonly has_content_security_policy?: boolean,
  readonly hide_merge_helper?: boolean,
  readonly jsonld_data?: {...},
  readonly last_replication_date?: string,
  readonly legacy_browser?: boolean,
  readonly makes_no_changes?: boolean,
  readonly more_tags?: boolean,
  readonly new_edit_notes?: boolean,
  readonly new_edit_notes_mtime?: number | null,
  readonly number_of_collections?: number,
  readonly number_of_revisions?: number,
  readonly overlong_string?: boolean,
  readonly own_collections?: ReadonlyArray<CollectionT>,
  readonly release_artwork?: ReleaseArtT,
  readonly release_artwork_count?: number,
  readonly release_cdtoc_count?: number,
  readonly seeded_relationships?: ?ReadonlyArray<SeededRelationshipT>,
  readonly seeded_release_data?: ReleaseEditorSeedT,
  readonly series_ordering_types?:
    {readonly [id: number]: SeriesOrderingTypeT},
  readonly server_languages?: ReadonlyArray<ServerLanguageT>,
  readonly source_entity?: ?SourceEntityDataT,
  readonly subscribed?: boolean,
  readonly to_merge?: ReadonlyArray<MergeableEntityT>,
  readonly top_tags?: ReadonlyArray<AggregatedTagT>,
  readonly user_tags?: ReadonlyArray<UserTagT>,
  readonly within_dialog?: boolean,
};

// MusicBrainz::Server::MergeQueue::TO_JSON
declare type MergeQueueT = {
  readonly entities: ReadonlyArray<number>,
  readonly ready_to_merge: boolean,
  readonly type: MergeableEntityTypeT,
};

// root/utility/sanitizedContext.mjs
declare type SanitizedCatalystSessionT = {
  readonly tport?: number,
};

declare type SanitizedCatalystContextT = {
  readonly action: {
    readonly name: string,
  },
  readonly relative_uri: string,
  readonly req: {
    readonly method: string,
    readonly query_params: {readonly [param: string]: string},
    readonly uri: string,
  },
  readonly session: SanitizedCatalystSessionT | null,
  readonly stash: {
    readonly artist_credit?: ArtistCreditT,
    readonly artist_credit_field?: ArtistCreditFieldT,
    readonly current_isrcs?: ReadonlyArray<string>,
    readonly current_iswcs?: ReadonlyArray<string>,
    readonly current_language: string,
    readonly genre_map?: {readonly [genreName: string]: GenreT, ...},
    readonly seeded_relationships?: ?ReadonlyArray<SeededRelationshipT>,
    readonly seeded_release_data?: ReleaseEditorSeedT,
    readonly series_ordering_types?:
      {readonly [id: number]: SeriesOrderingTypeT},
    readonly server_languages?: ReadonlyArray<ServerLanguageT>,
    readonly source_entity?: ?SourceEntityDataT,
  },
  readonly user: ActiveEditorT | null,
};

declare type ServerLanguageT = {
  readonly id: number,
  readonly name: string,
  readonly native_language: string,
  readonly native_territory: string,
};

declare type SourceEntityDataT =
  | RelatableEntityT
  | {
      readonly entityType: RelatableEntityTypeT,
      readonly isNewEntity: true,
      readonly name?: string,
      readonly orderingTypeID?: number,
    };
