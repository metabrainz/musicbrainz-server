/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Paginator from '../../../../components/Paginator.js';
import DataTrackIcon
  from '../../common/components/DataTrackIcon.js';
import usePagedMediumTable from '../../common/hooks/usePagedMediumTable.js';
import type {ActionT, CreditsModeT} from '../types.js';

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
  const tableVars = usePagedMediumTable({
    dispatch,
    getColumnCount: (showArtists) => 4 + (showArtists ? 1 : 0),
    release,
    medium,
    tracks,
    hasUnloadedTracks,
    isExpanded,
  });

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

  const columnCount = tableVars.columnCount;
  const tracksPager = medium.tracks_pager;

  return (
    <table className="tbl medium">
      <thead>
        <tr className={medium.editsPending ? 'mp' : null}>
          <th colSpan={columnCount}>
            {tableVars.mediumHeaderLink}
          </th>
        </tr>
      </thead>

      <tbody style={isExpanded ? null : {display: 'none'}}>
        {tableVars.loadedTrackCount ? (
          <>
            <tr className="subh">
              <th className="pos t">{l('#')}</th>
              <th>{l('Title')}</th>
              {tableVars.showArtists ? (
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
                showArtists={tableVars.showArtists}
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
                    showArtists={tableVars.showArtists}
                    track={track}
                  />
                ))}
              </>
            ) : null}
          </>
        ) : null}

        {tableVars.pagingElements}
      </tbody>
    </table>
  );
}): React.AbstractComponent<PropsT>);

export default MediumTable;
