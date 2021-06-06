/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// MusicBrainz::Server::Entity::Alias::TO_JSON
declare type AliasT = {
  ...DatePeriodRoleT,
  ...EditableRoleT,
  ...EntityRoleT<'alias'>,
  ...TypeRoleT<AliasTypeT>,
  +locale: string | null,
  +name: string,
  +primary_for_locale: boolean,
  +sort_name: string,
};

declare type AliasTypeT = OptionTreeT<'alias_type'>;
