/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

declare type CDTocT = $ReadOnly<{
  ...EntityRoleT<'cdtoc'>,
  +discid: string,
  +freedb_id: string,
  +leadout_offset: number,
  +length: number,
  +track_count: number,
  +track_details: $ReadOnlyArray<{
    +end_sectors: number,
    +end_time: number,
    +length_sectors: number,
    +length_time: number,
    +start_sectors: number,
    +start_time: number,
  }>,
  +track_offset: $ReadOnlyArray<number>,
}>;

declare type MediumCDTocT = $ReadOnly<{
  ...EntityRoleT<'medium_cdtoc'>,
  +cdtoc: CDTocT,
  +editsPending: boolean,
  +medium?: MediumT,
}>;

declare type MediumFormatT = {
  ...OptionTreeT<'medium_format'>,
  +has_discids: boolean,
  +year: ?number,
};

// MusicBrainz::Server::Entity::Medium::TO_JSON
declare type MediumT = $ReadOnly<{
  ...EntityRoleT<'medium'>,
  ...LastUpdateRoleT,
  +cdtoc_track_count: number | null,
  +cdtoc_track_lengths?: $ReadOnlyArray<number | null>,
  +cdtoc_tracks?: $ReadOnlyArray<TrackT>,
  +cdtocs: $ReadOnlyArray<string>,
  +data_track_lengths?: $ReadOnlyArray<number | null>,
  +editsPending: boolean,
  +format: MediumFormatT | null,
  +format_id: number | null,
  +gid: string,
  +may_have_discids: boolean,
  +name: string,
  +position: number,
  +pregap_length?: $ReadOnlyArray<number | null>,
  +release_id: number,
  +track_count: number | null,
  +tracks?: $ReadOnlyArray<TrackT>,
  +tracks_pager?: PagerT,
}>;

declare type MediumWithRecordingsT = $ReadOnly<{
  ...MediumT,
  +tracks?: $ReadOnlyArray<TrackWithRecordingT>,
}>;
