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
import {bracketedText} from '../static/scripts/common/utility/bracketed';
import EntityLink from '../static/scripts/common/components/EntityLink';

import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportRecordingT} from './types';

const RecordingsSameNameDifferentArtistsSameName = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportRecordingT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    $c={$c}
    canBeFiltered={canBeFiltered}
    description={exp.l(
      `This report shows all recordings with the same name that have
       different artists (having different MBIDs) with the same name.
       These are most likely cases where the {ac|artist credit} is
       incorrect for at least one of the recordings.`,
      {ac: '/doc/Artist_Credits'},
    )}
    entityType="recording"
    extraInfo={l(
      `Currently, this report only works
       with recordings that have one artist.`,
    )}
    filtered={filtered}
    generated={generated}
    title={l(
      `Recordings with the same name
       by different artists with the same name`,
    )}
    totalEntries={pager.total_entries}
  >
    <PaginatedResults pager={pager}>
      <table className="tbl">
        <thead>
          <tr>
            <th>{l('Artist')}</th>
            <th>{l('Recording')}</th>
          </tr>
        </thead>
        <tbody>
          {items.map((item, index) => {
            const recording = item.recording;
            return (
              <tr className={loopParity(index)} key={item.recording_id}>
                {recording ? (
                  <>
                    <td>
                      <ArtistCreditLink
                        artistCredit={recording.artistCredit}
                      />
                      <span className="comment">
                        <bdi key="comment">
                          {' ' + bracketedText(
                            recording.artistCredit.names[0].artist.comment,
                          )}
                        </bdi>
                      </span>
                    </td>
                    <td>
                      <EntityLink entity={recording} />
                    </td>
                  </>
                ) : (
                  <td colSpan="2">
                    {l('This recording no longer exists.')}
                  </td>
                )}
              </tr>
            );
          })}
        </tbody>
      </table>
    </PaginatedResults>
  </ReportLayout>
);

export default RecordingsSameNameDifferentArtistsSameName;
