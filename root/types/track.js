/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

// MusicBrainz::Server::Entity::Track::TO_JSON
declare type TrackT = Readonly<{
  ...EntityRoleT<'track'>,
  ...LastUpdateRoleT,
  readonly artist: string,
  readonly artistCredit: ArtistCreditT,
  readonly editsPending: boolean,
  readonly gid: string,
  readonly isDataTrack: boolean,
  readonly length: number,
  readonly medium: MediumT | null,
  readonly medium_id: number | null,
  readonly name: string,
  readonly number: string,
  readonly position: number,
  readonly recording?: RecordingT,
}>;

declare type TrackWithRecordingT = Readonly<{
  ...TrackT,
  readonly recording: RecordingT,
}>;
