/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {LinkedEntitiesT} from '../common/linkedEntities.mjs';

export type CreditsModeT = 'bottom' | 'inline';

export type LazyReleaseActionT =
  | {
      +medium: MediumWithRecordingsT,
      +type: 'toggle-medium',
    }
  | {
      +expanded: boolean,
      +mediums: $ReadOnlyArray<MediumWithRecordingsT>,
      +type: 'toggle-all-mediums',
    }
  | {
      +medium: MediumWithRecordingsT,
      +tracks: $ReadOnlyArray<TrackWithRecordingT>,
      +type: 'load-tracks',
    };

export type ActionT =
  | {+type: 'toggle-credits-mode'}
  | LazyReleaseActionT;

export type PropsT = {
  +initialCreditsMode: CreditsModeT,
  +initialLinkedEntities: $ReadOnly<$Partial<LinkedEntitiesT>>,
  +noScript: boolean,
  +release: ReleaseWithMediumsT,
};

export type LoadedTracksMapT =
  $ReadOnlyMap<number, $ReadOnlyArray<TrackWithRecordingT>>;

export type LazyReleaseStateT = {
  +expandedMediums: $ReadOnlyMap<number, boolean>,
  +loadedTracks: LoadedTracksMapT,
  ...
};

export type StateT = $ReadOnly<{
  +creditsMode: CreditsModeT,
  ...$Exact<LazyReleaseStateT>,
}>;
