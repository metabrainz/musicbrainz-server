/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {isIrrelevantLinkType}
  from '../../../../components/GroupedTrackRelationships';
import Relationships from '../../../../components/Relationships';
import StaticRelationshipsDisplay
  from '../../../../components/StaticRelationshipsDisplay';
import groupRelationships, {
  type RelationshipTargetTypeGroupT,
} from '../../../../utility/groupRelationships';
import hydrate from '../../../../utility/hydrate';
import MediumDescription
  from '../../common/components/MediumDescription';
import WarningIcon from '../../common/components/WarningIcon';
import {l} from '../../common/i18n';
import linkedEntities from '../../common/linkedEntities';
import setCookie from '../../common/utility/setCookie';
import type {
  PropsT,
  StateT,
  ActionT,
  CreditsModeT,
  TrackWithRecordingT,
} from '../types';

import MediumTable from './MediumTable';
import MediumToolbox from './MediumToolbox';

function reducer(
  state: StateT,
  action: ActionT,
): StateT {
  const newState: {...StateT} = {...state};

  switch (action.type) {
    case 'toggle-credits-mode': {
      if (state.creditsMode === 'bottom') {
        setCookie('bottom-credits', 0);
        newState.creditsMode = 'inline';
      } else {
        setCookie('bottom-credits', 1);
        newState.creditsMode = 'bottom';
      }
      break;
    }
    case 'toggle-medium': {
      const medium = action.medium;
      const newExpandedMediums = new Map(state.expandedMediums);
      newExpandedMediums.set(
        medium.position,
        !isMediumExpanded(newExpandedMediums, medium),
      );
      newState.expandedMediums = newExpandedMediums;
      break;
    }
    case 'toggle-all-mediums': {
      const newExpandedMediums = new Map(state.expandedMediums);
      for (const medium of action.mediums) {
        newExpandedMediums.set(medium.position, action.expanded);
      }
      newState.expandedMediums = newExpandedMediums;
      break;
    }
    case 'load-tracks': {
      const medium = action.medium;
      const newLoadedTracks = new Map(state.loadedTracks);
      newLoadedTracks.set(medium.position, action.tracks);
      newState.loadedTracks = newLoadedTracks;
      break;
    }
  }

  return newState;
}

function createInitialState(creditsMode: CreditsModeT) {
  return {
    creditsMode,
    /*
     * This information is stored separate from the medium objects
     * to maintain referential equality of those and minimize the
     * number of component updates.
     */
    expandedMediums: new Map(),
    loadedTracks: new Map(),
  };
}

function isMediumExpanded(expandedMediums, medium) {
  const expanded = expandedMediums.get(medium.position);
  return expanded == null
    ? (medium.tracks != null)
    : expanded;
}

function getMediumTracks(loadedTracks, medium) {
  return loadedTracks.get(medium.position) ?? medium.tracks ?? null;
}

const combinedTrackRelsCache = new WeakMap();

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

  const pushRelationship = (relationship, track) => {
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
        pushRelationship(relationship, track);

        const target = relationship.target;

        if (target.entityType === 'work') {
          const workRelationships = target.relationships;
          if (workRelationships) {
            for (const workRelationship of workRelationships) {
              if (!isIrrelevantLinkType(workRelationship)) {
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

const TracklistAndCredits = React.memo<PropsT>((props: PropsT) => {
  const {
    noScript,
    release,
    initialLinkedEntities,
  } = props;

  const setLinkedEntitiesRef = React.useRef(false);
  if (!setLinkedEntitiesRef.current) {
    linkedEntities.mergeLinkedEntities(initialLinkedEntities);
    setLinkedEntitiesRef.current = true;
  }

  const [state, dispatch] = React.useReducer(
    reducer,
    props.initialCreditsMode,
    createInitialState,
  );

  const mediums = release.mediums;
  const {
    creditsMode,
    expandedMediums,
    loadedTracks,
  } = state;

  const hasUnloadedTracksPerMedium = React.useMemo(() => new Map(
    mediums.map(medium => [
      medium.id,
      (
        medium.track_count > 0 &&
        ((getMediumTracks(loadedTracks, medium)?.length) ?? 0) <
          medium.track_count
      ),
    ]),
  ), [loadedTracks, mediums]);

  const hasUnloadedTracks = React.useMemo(() => {
    for (const value of hasUnloadedTracksPerMedium.values()) {
      if (value) {
        return true;
      }
    }
    return false;
  }, [hasUnloadedTracksPerMedium]);

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
  const hasReleaseCredits = !!(release.relationships?.length);
  const hasReleaseGroupCredits =
    !!(release.releaseGroup?.relationships?.length);
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
            hasUnloadedTracksPerMedium.get(medium.id) ?? false}
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
              <h3>{l('Release Group')}</h3>
              <Relationships noRelationshipsHeading source={releaseGroup} />
            </div>
          ) : null}
        </div>
      ) : null}
    </>
  );
});

export default (hydrate<PropsT>(
  'div.tracklist-and-credits',
  TracklistAndCredits,
): React.AbstractComponent<PropsT>);
