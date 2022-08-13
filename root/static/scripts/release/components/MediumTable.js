/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import {captureException} from '@sentry/browser';

import Paginator from '../../../../components/Paginator.js';
import mediumHasMultipleArtists
  from '../../../../utility/mediumHasMultipleArtists.js';
import DataTrackIcon
  from '../../common/components/DataTrackIcon.js';
import MediumDescription
  from '../../common/components/MediumDescription.js';
import {uniqBy} from '../../common/utility/arrays.js';
import pThrottle, {
  ThrottleAbortError,
} from '../../common/utility/pThrottle.js';
import type {CreditsModeT, ActionT} from '../types.js';
import {
  mergeLinkedEntities,
} from '../../common/linkedEntities.mjs';

import MediumTrackRow from './MediumTrackRow.js';

type PropsT = {
  +creditsMode: CreditsModeT,
  +dispatch: (ActionT) => void,
  +hasUnloadedTracks: boolean,
  +isExpanded: boolean,
  +medium: MediumWithRecordingsT,
  +noScript: boolean,
  +release: ReleaseWithMediumsT,
  +tracks: $ReadOnlyArray<TrackWithRecordingT> | null,
};

type TracksResponseT = {
  +linked_entities: {
    link_attribute_type: {
      [linkAttributeTypeIdOrGid: StrOrNum]: LinkAttrTypeT,
    },
    link_type: {
      [linkTypeIdOrGid: StrOrNum]: LinkTypeT,
    },
  },
  +pager: PagerT,
  +tracks: $ReadOnlyArray<TrackWithRecordingT>,
};

const throttleFunc = pThrottle<[number, number], Response>({
  interval: 1000,
  limit: 1,
});

const fetchTracks = throttleFunc((mediumId: number, page: number) => {
  return fetch('/ws/js/tracks/' + mediumId + '?page=' + page);
});

const MediumTable = (React.memo<PropsT>(({
  creditsMode,
  dispatch,
  hasUnloadedTracks,
  isExpanded,
  medium,
  noScript,
  release,
  tracks,
}: PropsT) => {
  const [loadingMessage, setLoadingMessage] =
    React.useState('');

  const [loadAllTracks, setLoadAllTracks] =
    React.useState(false);

  const showArtists = React.useMemo(
    () => mediumHasMultipleArtists(release, tracks),
    [release, tracks],
  );

  const loadedTrackCount = (tracks?.length) ?? 0;
  const canLoadMoreTracks = isExpanded && hasUnloadedTracks;
  const isLoading = (
    canLoadMoreTracks &&
    (loadedTrackCount === 0 || loadAllTracks)
  );

  const [audioTracks, dataTracks] = React.useMemo(() => {
    const audioTracks = [];
    const dataTracks = [];
    if (tracks) {
      for (const track of tracks) {
        if (track.isDataTrack) {
          dataTracks.push(track);
        } else {
          audioTracks.push(track);
        }
      }
    }
    return [audioTracks, dataTracks];
  }, [tracks]);

  const pagerRef = React.useRef<?PagerT>(medium.tracks_pager);

  const loadMoreTracks = React.useCallback(() => {
    if (canLoadMoreTracks) {
      setLoadingMessage(l('Loading...'));

      const pager = pagerRef.current;
      const nextPage = (pager?.next_page) ?? 1;

      const throttleResult = fetchTracks(medium.id, nextPage);

      throttleResult.promise
        .then<TracksResponseT>(response => response.json())
        .then(result => {
          const pager = result.pager;
          pagerRef.current = pager;

          mergeLinkedEntities(result.linked_entities);

          dispatch({
            medium,
            tracks: uniqBy(
              (tracks || []).concat(result.tracks),
              x => x.position,
            ),
            type: 'load-tracks',
          });

          setLoadingMessage('');
        })
        .catch((error) => {
          if (!(error instanceof ThrottleAbortError)) {
            captureException(error);
            console.error(error);
            setLoadingMessage(l('Failed to load the medium.'));
            setLoadAllTracks(false);
          }
        });

      return throttleResult;
    }

    return null;
  }, [
    canLoadMoreTracks,
    tracks,
    setLoadingMessage,
    medium,
    dispatch,
  ]);

  React.useEffect(() => {
    let throttleResult;

    if (isLoading) {
      throttleResult = loadMoreTracks();
    }

    return () => {
      throttleResult?.abort();
    };
  }, [
    isLoading,
    loadMoreTracks,
  ]);

  function toggleMedium(event: SyntheticMouseEvent<HTMLAnchorElement>) {
    // Prevent the browser from following the link.
    event.preventDefault();
    dispatch({medium, type: 'toggle-medium'});
  }

  const position = String(medium.position);
  const columnCount = 4 + (showArtists ? 1 : 0);
  const tracksPager = medium.tracks_pager;

  return (
    <table className="tbl medium">
      <thead>
        <tr className={medium.editsPending ? 'mp' : null}>
          <th colSpan={columnCount}>
            <a
              className="expand-medium"
              href={
                '/release/' + release.gid +
                '/disc/' + position +
                '#disc' + position
              }
              id={'disc' + position}
              onClick={toggleMedium}
            >
              <span className="expand-triangle">
                {isExpanded ? '\u25BC' : '\u25B6'}
              </span>
              <MediumDescription medium={medium} />
            </a>
          </th>
        </tr>
      </thead>

      <tbody style={isExpanded ? null : {display: 'none'}}>
        {loadedTrackCount ? (
          <>
            <tr className="subh">
              <th className="pos t">{l('#')}</th>
              <th>{l('Title')}</th>
              {showArtists ? (
                <th>{l('Artist')}</th>
              ) : null}
              <th className="rating c">{l('Rating')}</th>
              <th className="treleases">{l('Length')}</th>
            </tr>

            {(
              noScript &&
              tracksPager &&
              tracksPager.last_page > tracksPager.first_page
            ) ? (
              <tr>
                <td colSpan={columnCount} style={{padding: '1em'}}>
                  <p>
                    {l(
                      `This medium has too many tracks to load at once,
                       so it’s been paginated.`,
                    )}
                  </p>
                  <Paginator
                    hash={'medium' + medium.position}
                    pager={tracksPager}
                  />
                </td>
              </tr>
              ) : null}

            {audioTracks.map((track, index) => (
              <MediumTrackRow
                creditsMode={creditsMode}
                index={index}
                key={track.id}
                showArtists={showArtists}
                track={track}
              />
            ))}

            {dataTracks.length ? (
              <>
                <tr className="subh">
                  <td colSpan="6">
                    <DataTrackIcon />
                    {l('Data Tracks')}
                  </td>
                </tr>
                {dataTracks.map((track, index) => (
                  <MediumTrackRow
                    creditsMode={creditsMode}
                    index={index}
                    key={track.id}
                    showArtists={showArtists}
                    track={track}
                  />
                ))}
              </>
            ) : null}
          </>
        ) : null}

        {(
          loadedTrackCount &&
          canLoadMoreTracks &&
          !noScript &&
          !(isLoading && loadingMessage)
        ) ? (
          <tr>
            <td colSpan={columnCount} style={{padding: '1em'}}>
              {texp.l(
                `This medium has too many tracks to load at once;
                 currently showing {loaded_track_count} out of
                 {total_track_count} total.`,
                {
                  loaded_track_count: loadedTrackCount,
                  total_track_count: medium.track_count || 0,
                },
              )}
              {' '}
              <a
                className="load-tracks"
                href="#"
                onClick={(event) => {
                  event.preventDefault();
                  setLoadAllTracks(true);
                }}
              >
                {l('Load all tracks...')}
              </a>
            </td>
          </tr>
          ) : null}

        {loadingMessage ? (
          <tr>
            <td
              colSpan={columnCount}
              style={{padding: '1em'}}
            >
              <div className="loading-message">
                {loadingMessage}
              </div>
            </td>
          </tr>
        ) : null}
      </tbody>
    </table>
  );
}): React.AbstractComponent<PropsT>);

export default MediumTable;
