/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

// MusicBrainz::Server::Entity::Recording::TO_JSON
declare type RecordingT = Readonly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...RelatableEntityRoleT<'recording'>,
  ...RatableRoleT,
  ...ReviewableRoleT,
  readonly appearsOn?: AppearancesT<{gid: string, name: string}>,
  readonly artist?: string,
  readonly artistCredit: ArtistCreditT,
  readonly first_release_date?: PartialDateT,
  readonly isrcs: ReadonlyArray<IsrcT>,
  readonly length: number,
  readonly primaryAlias?: string | null,
  readonly related_works: ReadonlyArray<number>,
  readonly video: boolean,
}>;

declare type ReleaseGroupAppearancesT = {
  readonly hits: number,
  readonly results: ReadonlyArray<ReleaseGroupT>,
};

declare type ReleaseGroupAppearancesMapT = {
  readonly [recordingId: number]: ReleaseGroupAppearancesT,
};
