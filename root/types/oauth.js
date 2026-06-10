/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

// MusicBrainz::Server::Entity::Application::TO_JSON
declare type ApplicationT = {
  ...EntityRoleT<'application'>,
  readonly is_server: boolean,
  readonly name: string,
  readonly oauth_id: string,
  readonly oauth_redirect_uri?: string,
  readonly oauth_secret: string,
  readonly oauth_type: string,
};

// MusicBrainz::Server::Entity::EditorOAuthToken::TO_JSON
declare type EditorOAuthTokenT = {
  ...EntityRoleT<empty>,
  readonly application: ApplicationT,
  readonly editor: EditorT | null,
  readonly granted: string,
  readonly is_offline: boolean,
  readonly permissions: ReadonlyArray<string>,
  readonly scope: number,
};
