/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// MusicBrainz::Server::Entity::Track::TO_JSON
declare type TrackT = $ReadOnly<{
  ...EntityRoleT<'track'>,
  ...LastUpdateRoleT,
  +artist: string,
  +artistCredit: ArtistCreditT,
  +editsPending: boolean,
  +gid: string,
  +isDataTrack: boolean,
  +length: number,
  +medium: MediumT | null,
  +medium_id: number | null,
  +name: string,
  +number: string,
  +position: number,
  +recording?: RecordingT,
}>;

declare type TrackWithRecordingT = $ReadOnly<{
  ...TrackT,
  +recording: RecordingT,
}>;
