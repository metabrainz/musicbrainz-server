/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

// EditMedium
declare type TracklistChangesAddT = {
  readonly change_type: '+',
  readonly new_track: TrackWithRecordingT,
  readonly old_track: null,
};

declare type TracklistChangesChangeT = {
  readonly change_type: 'c' | 'u',
  readonly new_track: TrackWithRecordingT,
  readonly old_track: TrackWithRecordingT,
};

declare type TracklistChangesRemoveT = {
  readonly change_type: '-',
  readonly new_track: null,
  readonly old_track: TrackWithRecordingT,
};

// EditReleaseEvents (historic)
declare type OldReleaseEventCompT = {
  readonly barcode: CompT<string | null>,
  readonly catalog_number: CompT<string | null>,
  readonly country?: CompT<AreaT>,
  readonly date: CompT<PartialDateT>,
  readonly format: CompT<MediumFormatT | null>,
  readonly label?: CompT<LabelT>,
  readonly release: ReleaseT | null,
};

declare type OldReleaseEventT = {
  readonly barcode: string | null,
  readonly catalog_number: string | null,
  readonly country?: AreaT,
  readonly date: PartialDateT,
  readonly format: MediumFormatT | null,
  readonly label?: LabelT,
  readonly release: ReleaseT | null,
};
