/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

// MusicBrainz::Server::Entity::URL::TO_JSON
declare type UrlT = {
  ...RelatableEntityRoleT<'url'>,
  readonly decoded: string,
  readonly href_url: string,
  readonly pretty_name: string,
  readonly show_in_external_links?: boolean,
  readonly show_license_in_sidebar?: boolean,
  readonly sidebar_name?: string,
};
