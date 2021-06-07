/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare type ActiveEditorPreferencesT = {
  +datetime_format: string,
  +timezone: string,
};

/*
 * Only used in cases where the editor being sanitized is logged in;
 * exposes some preferences and misc. metadata.
 */
declare type ActiveEditorT = {
  ...EntityRoleT<'editor'>,
  +gravatar: string,
  +has_confirmed_email_address: boolean,
  +name: string,
  +preferences: ActiveEditorPreferencesT,
  +privileges: number,
};

declare type EditorLanguageT = {
  +fluency: FluencyT,
  +language: LanguageT,
};

// MusicBrainz::Server::Entity::Editor::TO_JSON
declare type EditorT = {
  ...EntityRoleT<'editor'>,
  +deleted: boolean,
  +gravatar: string,
  +is_limited: boolean,
  +name: string,
  +privileges: number,
};

declare type FluencyT =
  | 'basic'
  | 'intermediate'
  | 'advanced'
  | 'native';

declare type UnsanitizedEditorPreferencesT = {
  +datetime_format: string,
  +email_on_no_vote: boolean,
  +email_on_notes: boolean,
  +email_on_vote: boolean,
  +public_ratings: boolean,
  +public_subscriptions: boolean,
  +public_tags: boolean,
  +show_gravatar: boolean,
  +subscribe_to_created_artists: boolean,
  +subscribe_to_created_labels: boolean,
  +subscribe_to_created_series: boolean,
  +subscriptions_email_period: string,
  +timezone: string,
};

// MusicBrainz::Server::unsanitized_editor_json
declare type UnsanitizedEditorT = $ReadOnly<{
  ...EntityRoleT<'editor'>,
  +age: number | null,
  +area: AreaT | null,
  +biography: string | null,
  +birth_date: PartialDateT | null,
  +deleted: boolean,
  +email: string | null,
  +email_confirmation_date: string | null,
  +gender: GenderT | null,
  +gravatar: string,
  +has_confirmed_email_address: boolean,
  +has_email_address: boolean,
  +is_charter: boolean,
  +is_limited: boolean,
  +languages: $ReadOnlyArray<EditorLanguageT> | null,
  +last_login_date: string | null,
  +name: string,
  +preferences: UnsanitizedEditorPreferencesT,
  +privileges: number,
  +registration_date: string,
  +website: string | null,
}>;
