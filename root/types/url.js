/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// MusicBrainz::Server::Entity::URL::TO_JSON
declare type UrlT = {
  ...CentralEntityRoleT<'url'>,
  ...EditableRoleT,
  +decoded: string,
  +href_url: string,
  +pretty_name: string,
  +show_in_external_links?: boolean,
  +show_license_in_sidebar?: boolean,
  +sidebar_name?: string,
};
