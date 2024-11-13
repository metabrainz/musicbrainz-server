/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

// MusicBrainz::Server::Entity::Work::TO_JSON
declare type WorkT = $ReadOnly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...RelatableEntityRoleT<'work'>,
  ...RatableRoleT,
  ...TypeRoleT<WorkTypeT>,
  +_fromBatchCreateWorksDialog?: boolean,
  +artists: $ReadOnlyArray<ArtistCreditT>,
  +attributes: $ReadOnlyArray<WorkAttributeT>,
  +iswcs: $ReadOnlyArray<IswcT>,
  +languages: $ReadOnlyArray<WorkLanguageT>,
  +primaryAlias?: string | null,
  +related_artists?: {
    +artists: AppearancesT<string>,
    +writers: AppearancesT<string>,
  },
  +writers: $ReadOnlyArray<{
    +credit: string,
    +entity: ArtistT,
    +roles: $ReadOnlyArray<string>,
  }>,
}>;

declare type WorkTypeT = OptionTreeT<'work_type'>;

// MusicBrainz::Server::Entity::WorkLanguage::TO_JSON
declare type WorkLanguageT = {
  +language: LanguageT,
};
