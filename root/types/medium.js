/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

declare type CDTocT = Readonly<{
  ...EntityRoleT<'cdtoc'>,
  readonly discid: string,
  readonly freedb_id: string,
  readonly leadout_offset: number,
  readonly length: number,
  readonly track_count: number,
  readonly track_details: ReadonlyArray<{
    readonly end_sectors: number,
    readonly end_time: number,
    readonly length_sectors: number,
    readonly length_time: number,
    readonly start_sectors: number,
    readonly start_time: number,
  }>,
  readonly track_offset: ReadonlyArray<number>,
}>;

declare type MediumCDTocT = Readonly<{
  ...EntityRoleT<'medium_cdtoc'>,
  readonly cdtoc: CDTocT,
  readonly editsPending: boolean,
  readonly medium?: MediumT,
}>;

declare type MediumFormatT = {
  ...OptionTreeT<'medium_format'>,
  readonly has_discids: boolean,
  readonly year: ?number,
};

// MusicBrainz::Server::Entity::Medium::TO_JSON
declare type MediumT = Readonly<{
  ...EntityRoleT<'medium'>,
  ...LastUpdateRoleT,
  readonly cdtoc_track_count: number | null,
  readonly cdtoc_track_lengths?: ReadonlyArray<number | null>,
  readonly cdtoc_tracks?: ReadonlyArray<TrackT>,
  readonly cdtocs: ReadonlyArray<string>,
  readonly data_track_lengths?: ReadonlyArray<number | null>,
  readonly editsPending: boolean,
  readonly format: MediumFormatT | null,
  readonly format_id: number | null,
  readonly gid: string,
  readonly may_have_discids: boolean,
  readonly name: string,
  readonly position: number,
  readonly pregap_length?: ReadonlyArray<number | null>,
  readonly release_id: number,
  readonly track_count: number | null,
  readonly tracks?: ReadonlyArray<TrackT>,
  readonly tracks_pager?: PagerT,
}>;

declare type MediumWithRecordingsT = Readonly<{
  ...MediumT,
  readonly tracks?: ReadonlyArray<TrackWithRecordingT>,
}>;
