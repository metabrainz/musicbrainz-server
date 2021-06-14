/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// MusicBrainz::Server::Entity::Application::TO_JSON
declare type ApplicationT = {
  ...EntityRoleT<'application'>,
  +is_server: boolean,
  +name: string,
  +oauth_id: string,
  +oauth_redirect_uri?: string,
  +oauth_secret: string,
  +oauth_type: string,
};

// MusicBrainz::Server::Entity::EditorOAuthToken::TO_JSON
declare type EditorOAuthTokenT = {
  ...EntityRoleT<empty>,
  +application: ApplicationT,
  +editor: EditorT | null,
  +granted: string,
  +is_offline: boolean,
  +permissions: $ReadOnlyArray<string>,
  +scope: number,
};
