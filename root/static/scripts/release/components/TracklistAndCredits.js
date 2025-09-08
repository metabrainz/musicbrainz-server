/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {isIrrelevantLinkType}
  from '../../../../components/GroupedTrackRelationships.js';
import MediumDescription
  from '../../common/components/MediumDescription.js';
import Relationships from '../../common/components/Relationships.js';
import StaticRelationshipsDisplay
  from '../../common/components/StaticRelationshipsDisplay.js';
import WarningIcon from '../../common/components/WarningIcon.js';
import {l} from '../../common/i18n.js';
import type {LinkedEntitiesT} from '../../common/linkedEntities.mjs';
import {
  mergeLinkedEntities,
} from '../../common/linkedEntities.mjs';
import groupRelationships, {
  type RelationshipTargetTypeGroupT,
} from '../../common/utility/groupRelationships.js';
import setCookie from '../../common/utility/setCookie.js';
import type {
  ActionT,
  CreditsModeT,
  LazyReleaseActionT,
  LazyReleaseStateT,
  LoadedTracksMapT,
  StateT,
} from '../types.js';

import MediumTable from './MediumTable.js';
import MediumToolbox from './MediumToolbox.js';

export function runLazyReleaseReducer(
  newState: {...LazyReleaseStateT, ...},
  action: LazyReleaseActionT,
): void {
  match (action) {
    {type: 'toggle-medium', const medium} => {
      const newExpandedMediums = new Map(newState.expandedMediums);
      newExpandedMediums.set(
        medium.position,
        !isMediumExpanded(newExpandedMediums, medium),
      );
      newState.expandedMediums = newExpandedMediums;
    }
    {type: 'toggle-all-mediums', const expanded, const mediums} => {
      const newExpandedMediums = new Map(newState.expandedMediums);
      for (const medium of mediums) {
        newExpandedMediums.set(medium.position, expanded);
      }
      newState.expandedMediums = newExpandedMediums;
    }
    {type: 'load-tracks', const medium, const tracks} => {
      const newLoadedTracks = new Map(newState.loadedTracks);
      newLoadedTracks.set(medium.position, tracks);
      newState.loadedTracks = newLoadedTracks;
    }
  }
}

function reducer(
  state: StateT,
  action: ActionT,
): StateT {
  const newState: {...StateT} = {...state};

  match (action) {
    {type: 'toggle-credits-mode'} => {
      if (state.creditsMode === 'bottom') {
        setCookie('bottom-credits', 0);
        newState.creditsMode = 'inline';
      } else {
        setCookie('bottom-credits', 1);
        newState.creditsMode = 'bottom';
      }
    }
    _ as action => {
      runLazyReleaseReducer(newState, action);
    }
  }

  return newState;
}

export function createInitialLazyReleaseState(): $Exact<LazyReleaseStateT> {
  return {
    /*
     * This information is stored separate from the medium objects
     * to maintain referential equality of those and minimize the
     * number of component updates.
     */
    expandedMediums: new Map(),
    loadedTracks: new Map(),
  };
}

function createInitialState(creditsMode: CreditsModeT) {
  return {
    creditsMode,
    ...createInitialLazyReleaseState(),
  };
}

export function isMediumExpanded(
  expandedMediums: $ReadOnlyMap<number, boolean>,
  medium: MediumWithRecordingsT,
): boolean {
  const expanded = expandedMediums.get(medium.position);
  return expanded == null
    ? (medium.tracks != null)
    : expanded;
}

export function getMediumTracks(
  loadedTracks: LoadedTracksMapT,
  medium: MediumWithRecordingsT,
): $ReadOnlyArray<TrackWithRecordingT> | null {
  return loadedTracks.get(medium.position) || medium.tracks || null;
}

const combinedTrackRelsCache = new WeakMap<
  $ReadOnlyArray<TrackWithRecordingT>,
  $ReadOnlyArray<RelationshipTargetTypeGroupT>,
>();

function getCombinedTrackRelationships(
  tracks: $ReadOnlyArray<TrackWithRecordingT> | null,
): $ReadOnlyArray<RelationshipTargetTypeGroupT> | null {
  if (!tracks) {
    return null;
  }

  let result = combinedTrackRelsCache.get(tracks);
  if (result) {
    return result;
  }

  const allRelationships = [];
  // Maps relationships to the tracks they're associated with.
  const trackMapping = new Map<string, Set<TrackT>>();

  const pushRelationship = (
    relationship: RelationshipT,
    track: TrackWithRecordingT,
  ) => {
    const relationshipId = relationship.linkTypeID + '-' + relationship.id;

    const associatedTracks = trackMapping.get(relationshipId);
    if (associatedTracks) {
      associatedTracks.add(track);
    } else {
      trackMapping.set(relationshipId, new Set([track]));
    }

    allRelationships.push(relationship);
  };

  for (const track of tracks) {
    const recording = track.recording;
    if (!recording) {
      continue;
    }

    const recordingRelationships = recording.relationships;
    if (recordingRelationships) {
      for (const relationship of recordingRelationships) {
        const target = relationship.target;

        if (!isIrrelevantLinkType(
          relationship, target.entityType,
        )) {
          pushRelationship(relationship, track);
        }

        if (target.entityType === 'work') {
          const workRelationships = target.relationships;
          if (workRelationships) {
            for (const workRelationship of workRelationships) {
              if (!isIrrelevantLinkType(
                workRelationship, target.entityType,
              )) {
                pushRelationship(workRelationship, track);
              }
            }
          }
        }
      }
    }
  }

  result = groupRelationships(allRelationships, {trackMapping});
  combinedTrackRelsCache.set(tracks, result);
  return result;
}

export function useUnloadedTracksMap(
  mediums: $ReadOnlyArray<MediumWithRecordingsT>,
  loadedTracks: LoadedTracksMapT,
): $ReadOnlyMap<number, boolean> {
  return React.useMemo(() => new Map(
    mediums.map(medium => [
      medium.id,
      (
        medium.track_count != null &&
        medium.track_count > 0 &&
        medium.track_count >
          ((getMediumTracks(loadedTracks, medium)?.length) ?? 0)
      ),
    ]),
  ), [loadedTracks, mediums]);
}

export function useReleaseHasUnloadedTracks(
  hasUnloadedTracksPerMedium: $ReadOnlyMap<number, boolean>,
): boolean {
  return React.useMemo(() => {
    for (
      const mediumHasUnloadedTracks of
      hasUnloadedTracksPerMedium.values()
    ) {
      if (mediumHasUnloadedTracks) {
        return true;
      }
    }
    return false;
  }, [hasUnloadedTracksPerMedium]);
}

component _TracklistAndCredits(
  initialCreditsMode: CreditsModeT,
  initialLinkedEntities: $ReadOnly<Partial<LinkedEntitiesT>>,
  noScript: boolean,
  release: ReleaseWithMediumsT,
) {
  const setLinkedEntitiesRef = React.useRef(false);
  if (!setLinkedEntitiesRef.current) {
    mergeLinkedEntities(initialLinkedEntities);
    setLinkedEntitiesRef.current = true;
  }

  const [state, dispatch] = React.useReducer(
    reducer,
    initialCreditsMode,
    createInitialState,
  );

  const mediums = release.mediums;
  const {
    creditsMode,
    expandedMediums,
    loadedTracks,
  } = state;

  const hasUnloadedTracksPerMedium =
    useUnloadedTracksMap(mediums, loadedTracks);

  const hasUnloadedTracks =
    useReleaseHasUnloadedTracks(hasUnloadedTracksPerMedium);

  const bottomMediumCredits = React.useMemo(() => (
    creditsMode === 'bottom'
      ? mediums.map((medium) => (
          getCombinedTrackRelationships(
            getMediumTracks(loadedTracks, medium),
          )
        ))
      : null
  ), [mediums, loadedTracks, creditsMode]);

  const hasBottomMediumCredits =
    (bottomMediumCredits?.some(x => x?.length)) ?? false;
  const hasReleaseCredits = Boolean(release.relationships?.length);
  const hasReleaseGroupCredits =
    Boolean(release.releaseGroup?.relationships?.length);
  const hasBottomCredits = (
    hasBottomMediumCredits ||
    hasReleaseCredits ||
    hasReleaseGroupCredits
  );

  const releaseGroup = release.releaseGroup;

  const mediumTableElements = React.useMemo(
    () => mediums.length ? (
      mediums.map((medium) => (
        <MediumTable
          creditsMode={creditsMode}
          dispatch={dispatch}
          hasUnloadedTracks={
            hasUnloadedTracksPerMedium.get(medium.id) ?? false
          }
          isExpanded={isMediumExpanded(expandedMediums, medium)}
          key={medium.id}
          medium={medium}
          noScript={noScript}
          release={release}
          tracks={getMediumTracks(loadedTracks, medium)}
        />
      ))
    ) : null,
    [
      release,
      mediums,
      creditsMode,
      expandedMediums,
      loadedTracks,
      hasUnloadedTracksPerMedium,
      noScript,
    ],
  );

  const bottomMediumCreditElements = React.useMemo(() => (
    (hasBottomMediumCredits /*:: && bottomMediumCredits */) ? (
      mediums.map((medium, index) => {
        const relationships = bottomMediumCredits[index];
        if (!relationships) {
          return null;
        }
        return (
          <div
            className="bottom-credits"
            data-position={medium.position}
            key={medium.id}
          >
            <h3>
              <MediumDescription medium={medium} />
            </h3>
            <StaticRelationshipsDisplay relationships={relationships} />
          </div>
        );
      })
    ) : null
  ), [
    hasBottomMediumCredits,
    bottomMediumCredits,
    mediums,
  ]);

  return (
    <>
      <h2 className="tracklist">{l('Tracklist')}</h2>

      {mediums?.length ? (
        <>
          {noScript ? null : (
            <MediumToolbox
              creditsMode={creditsMode}
              dispatch={dispatch}
              mediums={mediums}
            />
          )}
          {mediumTableElements}
        </>
      ) : (
        <p>
          {l(`We have no information about this release’s
              media and tracklist.`)}
        </p>
      )}

      {hasBottomCredits ? (
        <div id="bottom-credits">
          <h2>{l('Credits')}</h2>

          {(creditsMode === 'bottom' && hasUnloadedTracks) ? (
            <div className="warning">
              <WarningIcon />
              <p>
                {l(`The credits listed below may be incomplete, as some
                    tracks/mediums haven’t been loaded yet.`)}
              </p>
            </div>
          ) : null}

          {bottomMediumCreditElements}

          {hasReleaseCredits ? (
            <div id="release-relationships">
              <h3>{l('Release')}</h3>
              <Relationships noRelationshipsHeading source={release} />
            </div>
          ) : null}

          {(hasReleaseGroupCredits /*:: && releaseGroup */) ? (
            <div id="release-group-relationships">
              <h3>{l('Release group')}</h3>
              <Relationships noRelationshipsHeading source={releaseGroup} />
            </div>
          ) : null}
        </div>
      ) : null}
    </>
  );
}

const TracklistAndCredits:
  component(...React.PropsOf<_TracklistAndCredits>) =
  React.memo(_TracklistAndCredits);

export default (hydrate<React.PropsOf<_TracklistAndCredits>>(
  'div.tracklist-and-credits',
  TracklistAndCredits,
): component(...React.PropsOf<_TracklistAndCredits>));
