/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../components/PaginatedResults';
import loopParity from '../utility/loopParity';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink';
import EntityLink from '../static/scripts/common/components/EntityLink';

import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportRecordingTrackT} from './types';

const RecordingTrackDifferentName = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportRecordingTrackT>):
React.Element<typeof ReportLayout> => (
  <ReportLayout
    $c={$c}
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows recordings that are linked to only one track,
       yet have a different name than the track. This might mean
       one of the two needs to be renamed to match the other.`,
    )}
    entityType="recording"
    filtered={filtered}
    generated={generated}
    title={l('Recordings with a different name than their only track')}
    totalEntries={pager.total_entries}
  >
    <PaginatedResults pager={pager}>
      <table className="tbl">
        <thead>
          <tr>
            <th>{l('Artist')}</th>
            <th>{l('Recording')}</th>
            <th>{l('Track')}</th>
          </tr>
        </thead>
        <tbody>
          {items.map((item, index) => (
            <tr className={loopParity(index)} key={item.recording_id}>
              {item.recording ? (
                <>
                  <td>
                    <ArtistCreditLink
                      artistCredit={item.recording.artistCredit}
                    />
                  </td>
                  <td>
                    <EntityLink entity={item.recording} />
                  </td>
                </>
              ) : (
                <td colSpan="2">
                  {l('This recording no longer exists.')}
                </td>
              )}
              <td>{item.track_name}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </PaginatedResults>
  </ReportLayout>
);

export default RecordingTrackDifferentName;
