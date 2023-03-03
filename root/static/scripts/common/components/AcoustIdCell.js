/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

type PropsT = {
  +recordingMbid: string,
};

type AcoustIdTrackT = {
  +disabled?: boolean,
  +id: string,
};

type AcoustIdRequestCallbackT =
  ($ReadOnlyArray<AcoustIdTrackT> | null) => void;

type AcoustIdRequestBatchT = {
  [recordingMbid: string]: AcoustIdRequestCallbackT,
};

const REQUEST_BATCH_TIMEOUT = 25; // ms

let currentBatch: AcoustIdRequestBatchT | null = null;

/*
 * We fetch data in the AcoustIdCell component rather than RecordingList
 * because hydrating RecordingList would require embedding the entire list of
 * recordings as JSON in the page. Hydrating each individual AcoustIdCell
 * only requires the recording MBID for each cell.
 *
 * This has the disadvantage of needing slightly more code to batch requests
 * together, but it's still fairly straightforward. Any AcoustIdCell
 * components that render within a 25 ms interval will have their requests
 * batched below.
 */

function loadAcoustIdData(
  recordingMbid: string,
  callback: AcoustIdRequestCallbackT,
): void {
  if (currentBatch) {
    currentBatch[recordingMbid] = callback;
    return;
  }

  currentBatch = {
    [recordingMbid]: callback,
  };

  const batch: AcoustIdRequestBatchT = currentBatch;

  setTimeout(function () {
    currentBatch = null;

    const recordingMbids = Object.keys(batch);

    const url = '//api.acoustid.org/v2/track/list_by_mbid' +
      '?format=json&disabled=1&batch=1' +
      recordingMbids.map(x => '&mbid=' + x).join('');

    fetch(url)
      .then(resp => resp.json())
      .then((reqData) => {
        for (const obj of reqData.mbids) {
          const callback: AcoustIdRequestCallbackT = batch[obj.mbid];
          if (callback) {
            callback(obj.tracks);
          }
        }
      })
      .finally(() => {
        const callbacks: $ReadOnlyArray<AcoustIdRequestCallbackT> =
          Object.values(batch);

        for (const callback of callbacks) {
          // Passing null to the callback does setLoading(false).
          callback(null);
        }
      });
  }, REQUEST_BATCH_TIMEOUT);
}

const AcoustIdCell = ({
  recordingMbid,
}: PropsT): React.Element<typeof React.Fragment> => {
  const [acoustIdTracks, setAcoustIdTracks] = React.useState<
    $ReadOnlyArray<AcoustIdTrackT> | null,
  >(null);

  const [isLoading, setLoading] = React.useState(true);

  const loadCallback: AcoustIdRequestCallbackT =
    React.useCallback((data) => {
      if (data) {
        setAcoustIdTracks(data);
      } else {
        setLoading(false);
      }
    }, [setAcoustIdTracks, setLoading]);

  React.useEffect(() => {
    loadAcoustIdData(recordingMbid, loadCallback);
  }, [recordingMbid, loadCallback]);

  return (
    <>
      {isLoading ? (
        <p className="loading-message">
          {l('Loading...')}
        </p>
      ) : (
        acoustIdTracks?.length ? (
          <ul>
            {acoustIdTracks.map((track) => (
              <li key={track.id}>
                <code>
                  <a
                    className={'external' +
                      (track.disabled === true ? ' disabled-acoustid' : '')}
                    href={`//acoustid.org/track/${track.id}`}
                  >
                    {track.id.slice(0, 6) + '…'}
                  </a>
                </code>
              </li>
            ))}
          </ul>
        ) : null
      )}
    </>
  );
};

export default (
  hydrate<PropsT>(
    'div.acoustids',
    AcoustIdCell,
  ): React.AbstractComponent<PropsT, void>
);
