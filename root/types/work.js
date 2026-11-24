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
declare type WorkT = Readonly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...RelatableEntityRoleT<'work'>,
  ...RatableRoleT,
  ...ReviewableRoleT,
  ...TypeRoleT<WorkTypeT>,
  readonly _fromBatchCreateWorksDialog?: boolean,
  readonly artists: ReadonlyArray<ArtistCreditT>,
  readonly attributes: ReadonlyArray<WorkAttributeT>,
  readonly authors: ReadonlyArray<{
    readonly credit: string,
    readonly entity: ArtistT,
    readonly roles: ReadonlyArray<string>,
  }>,
  readonly iswcs: ReadonlyArray<IswcT>,
  readonly languages: ReadonlyArray<WorkLanguageT>,
  readonly other_artists: ReadonlyArray<{
    readonly credit: string,
    readonly entity: ArtistT,
    readonly roles: ReadonlyArray<string>,
  }>,
  readonly primaryAlias?: string | null,
  readonly related_artists?: {
    readonly artists: AppearancesT<string>,
    readonly authors: AppearancesT<string>,
  },
}>;

declare type WorkTypeT = OptionTreeT<'work_type'>;

// MusicBrainz::Server::Entity::WorkLanguage::TO_JSON
declare type WorkLanguageT = {
  readonly language: LanguageT,
};
