/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {captureException} from '@sentry/browser';
import * as React from 'react';

import mediumHasMultipleArtists
  from '../../../../utility/mediumHasMultipleArtists.js';
import {
  type LinkedEntitiesT,
  mergeLinkedEntities,
} from '../../common/linkedEntities.mjs';
import {uniqBy} from '../../common/utility/arrays.js';
import pThrottle, {
  ThrottleAbortError,
} from '../../common/utility/pThrottle.js';
import type {
  LazyReleaseActionT,
} from '../../release/types.js';
import MediumDescription from '../components/MediumDescription.js';

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

type PagedMediumTableVarsT = {
  +columnCount: number,
  +loadedTrackCount: number,
  +mediumHeaderLink: React$MixedElement,
  +pagingElements: React$MixedElement,
  +showArtists: boolean,
};

const throttleFunc = pThrottle<[number, number], Response>({
  interval: 1000,
  limit: 1,
});

const fetchTracks = throttleFunc((mediumId: number, page: number) => {
  return fetch('/ws/js/tracks/' + mediumId + '?page=' + page);
});

export default function usePagedMediumTable(
  args: {
    dispatch: (LazyReleaseActionT) => void,
    getColumnCount: (boolean) => number,
    handleLinkedEntities?:
      (update: ?$ReadOnly<Partial<LinkedEntitiesT>>) => void,
    hasUnloadedTracks: boolean,
    isExpanded: boolean,
    medium: MediumWithRecordingsT,
    noScript?: boolean,
    release: ReleaseWithMediumsT,
    tracks: ?$ReadOnlyArray<TrackWithRecordingT>,
  },
): PagedMediumTableVarsT {
  const {
    dispatch,
    getColumnCount,
    handleLinkedEntities = mergeLinkedEntities,
    hasUnloadedTracks,
    isExpanded,
    medium,
    noScript = false,
    release,
    tracks,
  } = args;

  const [loadingMessage, setLoadingMessage] =
    React.useState('');

  const [loadAllTracks, setLoadAllTracks] =
    React.useState(false);

  const showArtists = React.useMemo(
    () => mediumHasMultipleArtists(release, tracks),
    [release, tracks],
  );

  const mediumPosition = String(medium.position);
  const columnCount = getColumnCount(showArtists);
  const loadedTrackCount = (tracks?.length) ?? 0;
  const canLoadMoreTracks = isExpanded && hasUnloadedTracks;
  const isLoading = (
    canLoadMoreTracks &&
    (loadedTrackCount === 0 || loadAllTracks)
  );

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

          handleLinkedEntities(result.linked_entities);

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
    handleLinkedEntities,
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

  const handleMediumToggle = (
    event: SyntheticMouseEvent<HTMLAnchorElement>,
  ): void => {
    // Prevent the browser from following the link.
    event.preventDefault();
    dispatch({medium, type: 'toggle-medium'});
  };

  const mediumHeaderLink = (
    <a
      className="expand-medium"
      href={
        '/release/' + release.gid +
        '/disc/' + mediumPosition +
        '#disc' + mediumPosition
      }
      id={'disc' + mediumPosition}
      onClick={handleMediumToggle}
    >
      <span className="expand-triangle">
        {isExpanded ? '\u25BC' : '\u25B6'}
      </span>
      {' '}
      <MediumDescription medium={medium} />
    </a>
  );

  const pagingElements = (
    <>
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
    </>
  );

  return {
    columnCount,
    loadedTrackCount,
    mediumHeaderLink,
    pagingElements,
    showArtists,
  };
}
