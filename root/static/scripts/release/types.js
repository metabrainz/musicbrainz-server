/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {LinkedEntitiesT} from '../common/linkedEntities';

export type CreditsModeT = 'bottom' | 'inline';

export type ActionT =
  | {+type: 'toggle-credits-mode'}
  | {+medium: MediumWithRecordingsT, +type: 'toggle-medium'}
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

export type PropsT = {
  +initialCreditsMode: CreditsModeT,
  +initialLinkedEntities: $ReadOnly<$Partial<LinkedEntitiesT>>,
  +noScript: boolean,
  +release: ReleaseWithMediumsT,
};

export type StateT = {
  +creditsMode: CreditsModeT,
  +expandedMediums: Map<number, boolean>,
  +loadedTracks: Map<number, $ReadOnlyArray<TrackWithRecordingT>>,
};
