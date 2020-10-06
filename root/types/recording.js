/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// MusicBrainz::Server::Entity::Recording::TO_JSON
declare type RecordingT = $ReadOnly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'recording'>,
  ...RatableRoleT,
  ...ReviewableRoleT,
  +appearsOn?: AppearancesT<{gid: string, name: string}>,
  +artist?: string,
  +artistCredit?: ArtistCreditT,
  +first_release_date?: PartialDateT,
  +isrcs: $ReadOnlyArray<IsrcT>,
  +length: number,
  +primaryAlias?: string | null,
  +related_works: $ReadOnlyArray<number>,
  +video: boolean,
}>;

declare type RecordingWithArtistCreditT =
  $ReadOnly<{...RecordingT, +artistCredit: ArtistCreditT}>;

declare type ReleaseGroupAppearancesT = {
  +hits: number,
  +results: $ReadOnlyArray<ReleaseGroupT>,
};

declare type ReleaseGroupAppearancesRoleT = {
  +releaseGroupAppearances?:
    {+[recordingId: number]: ReleaseGroupAppearancesT},
};
