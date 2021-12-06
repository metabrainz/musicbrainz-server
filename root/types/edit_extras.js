/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// EditMedium
declare type TracklistChangesAddT = {
  +change_type: '+',
  +new_track: TrackWithRecordingT,
  +old_track: null,
};

declare type TracklistChangesChangeT = {
  +change_type: 'c' | 'u',
  +new_track: TrackWithRecordingT,
  +old_track: TrackWithRecordingT,
};

declare type TracklistChangesRemoveT = {
  +change_type: '-',
  +new_track: null,
  +old_track: TrackWithRecordingT,
};

// EditReleaseEvents (historic)
declare type OldReleaseEventCompT = {
  +barcode: CompT<string | null>,
  +catalog_number: CompT<string | null>,
  +country?: CompT<AreaT>,
  +date: CompT<PartialDateT>,
  +format: CompT<MediumFormatT | null>,
  +label?: CompT<LabelT>,
  +release: ReleaseT | null,
};

declare type OldReleaseEventT = {
  +barcode: string | null,
  +catalog_number: string | null,
  +country?: AreaT,
  +date: PartialDateT,
  +format: MediumFormatT | null,
  +label?: LabelT,
  +release: ReleaseT | null,
};
