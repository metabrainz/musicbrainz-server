/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type CreditsModeT = 'bottom' | 'inline';

export type LazyReleaseActionT =
  | {
      readonly medium: MediumWithRecordingsT,
      readonly type: 'toggle-medium',
    }
  | {
      readonly expanded: boolean,
      readonly mediums: ReadonlyArray<MediumWithRecordingsT>,
      readonly type: 'toggle-all-mediums',
    }
  | {
      readonly medium: MediumWithRecordingsT,
      readonly tracks: ReadonlyArray<TrackWithRecordingT>,
      readonly type: 'load-tracks',
    };

export type ActionT =
  | {readonly type: 'toggle-credits-mode'}
  | LazyReleaseActionT;

export type LoadedTracksMapT =
  ReadonlyMap<number, ReadonlyArray<TrackWithRecordingT>>;

export type LazyReleaseStateT = {
  readonly expandedMediums: ReadonlyMap<number, boolean>,
  readonly loadedTracks: LoadedTracksMapT,
  ...
};

export type StateT = Readonly<{
  readonly creditsMode: CreditsModeT,
  ...$Exact<LazyReleaseStateT>,
}>;
