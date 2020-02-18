/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {withCatalystContext} from '../context';
import Layout from '../layout';
import formatUserDate from '../utility/formatUserDate';
import PaginatedResults from '../components/PaginatedResults';
import loopParity from '../utility/loopParity';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink';
import EntityLink from '../static/scripts/common/components/EntityLink';

import FilterLink from './FilterLink';
import type {ReportDataT, ReportRecordingTrackT} from './types';

const RecordingTrackDifferentName = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportRecordingTrackT>) => (
  <Layout
    fullWidth
    title={l('Recordings with a different name than their only track')}
  >
    <h1>
      {l('Recordings with a different name than their only track')}
    </h1>

    <ul>
      <li>
        {l(`This report shows recordings that are linked to only one track,
            yet have a different name than the track. This might mean
            one of the two needs to be renamed to match the other.`)}
      </li>
      <li>
        {texp.l('Total recordings found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c, generated)})}
      </li>

      {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
    </ul>

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
  </Layout>
);

export default withCatalystContext(RecordingTrackDifferentName);
