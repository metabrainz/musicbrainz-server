/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare type InstrumentCreditsAndRelTypesRoleT = {
  +instrumentCreditsAndRelTypes?: {
    +[entityGid: string]: $ReadOnlyArray<string>,
  },
};

// MusicBrainz::Server::Entity::Instrument::TO_JSON
declare type InstrumentT = $ReadOnly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'instrument'>,
  ...TypeRoleT<InstrumentTypeT>,
  +description: string,
  +primaryAlias?: string | null,
}>;

declare type InstrumentTypeT = OptionTreeT<'instrument_type'>;
