/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

declare type CritiqueBrainzUserT = {
  readonly id: string,
  readonly name: string,
};

declare type CritiqueBrainzReviewT = {
  readonly author: CritiqueBrainzUserT,
  readonly body: string,
  readonly created: string,
  readonly id: string,
  readonly rating: number | null,
};

declare type ReviewableT =
  | ArtistT
  | EventT
  | LabelT
  | PlaceT
  | RecordingT
  | ReleaseGroupT
  | WorkT;

declare type ReviewableRoleT = {
  readonly review_count?: number,
};
