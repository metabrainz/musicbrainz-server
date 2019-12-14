/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React, {useEffect, useState} from 'react';

import loopParity from '../../../../utility/loopParity';
import hydrate from '../../../../utility/hydrate';

function orderTracks(a, b) {
  if (a.disabled && !b.disabled) {
    return 1;
  }
  if (!a.disabled && b.disabled) {
    return -1;
  }
  return a.id - b.id;
}

const FingerprintTable = ({recording}: {recording: RecordingT}) => {
  const [tracks, setTracks] = useState([]);
  const [isLoaded, setIsLoaded] = useState(false);

  // We ensure fetch only runs client-side since it's not in node
  useEffect(() => {
    fetch(
      '//api.acoustid.org/v2/track/list_by_mbid' +
      `?format=json&disabled=1&jsoncallback=?&mbid=${recording.gid}`,
    ).then(
      function (response) {
        return response.json();
      },
    ).then(
      function (data) {
        data.tracks.sort(orderTracks);
        setTracks(data.tracks);
        setIsLoaded(true);
      },
    );
  }, [recording.gid]);

  return (
    tracks && tracks.length ? (
      <table className="tbl">
        <thead>
          <tr>
            <th>{'AcoustID'}</th>
            <th className="actions">{l('Actions')}</th>
          </tr>
        </thead>
        <tbody>
          {tracks.map((track, index) => (
            <tr className={loopParity(index)} key={track.id}>
              <td>
                <code>
                  <a
                    className={'external' +
                      (track.disabled ? ' disabled-acoustid' : '')}
                    href={`//acoustid.org/track/${track.id}`}
                  >
                    {track.id}
                  </a>
                </code>
              </td>
              <td className="actions">
                <a
                  className="external"
                  href={
                    '//acoustid.org/edit/toggle-track-mbid' +
                    `?track_gid=${track.id}&mbid=${recording.gid}` +
                    `&state=${track.disabled ? '0' : '1'}`}
                >
                  {track.disabled ? l('Link') : l('Unlink')}
                </a>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    ) : isLoaded ? (
      <p>{l('This recording does not have any associated AcoustIDs')}</p>
    ) : <p className="loading-message">{l('Loading...')}</p>
  );
};

export default hydrate<{recording: RecordingT}>(
  'div.acoustid-fingerprints',
  FingerprintTable,
);
