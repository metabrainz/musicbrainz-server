/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare type CritiqueBrainzUserT = {
  +id: string,
  +name: string,
};

declare type CritiqueBrainzReviewT = {
  +author: CritiqueBrainzUserT,
  +body: string,
  +created: string,
  +id: string,
  +rating: number | null,
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
  +review_count?: number,
};
