/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare type CDTocT = $ReadOnly<{
  ...EntityRoleT<'cdtoc'>,
  +discid: string,
}>;

declare type MediumCDTocT = $ReadOnly<{
  ...EntityRoleT<'medium_cdtoc'>,
  +cdtoc: CDTocT,
  +editsPending: boolean,
}>;

declare type MediumFormatT = {
  ...OptionTreeT<'medium_format'>,
  +has_discids: boolean,
  +year: ?number,
};

// MusicBrainz::Server::Entity::Medium::TO_JSON
declare type MediumT = $ReadOnly<{
  ...EntityRoleT<'track'>,
  ...LastUpdateRoleT,
  +cdtocs: $ReadOnlyArray<MediumCDTocT>,
  +editsPending: boolean,
  +format: MediumFormatT | null,
  +format_id: number,
  +name: string,
  +position: number,
  +release_id: number,
  +track_count: number | null,
  +tracks?: $ReadOnlyArray<TrackT>,
  +tracks_pager?: PagerT,
}>;

declare type MediumWithRecordingsT = $ReadOnly<{
  ...MediumT,
  +tracks?: $ReadOnlyArray<TrackWithRecordingT>,
}>;
