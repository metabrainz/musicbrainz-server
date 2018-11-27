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
import {l} from '../static/scripts/common/i18n';
import PaginatedResults from '../components/PaginatedResults';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink';
import EntityLink from '../static/scripts/common/components/EntityLink';
import formatTrackLength
  from '../static/scripts/common/utility/formatTrackLength';

import FilterLink from './FilterLink';
import type {ReportDataT, ReportIsrcT} from './types';


const ISRCsWithManyRecordings = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportIsrcT>) => {
  let lastISRC = 0;
  let currentISRC = 0;

  return (
    <Layout fullWidth title={l('ISRCs with multiple recordings')}>
      <h1>{l('ISRCs with multiple recordings')}</h1>

      <ul>
        <li>{l('This report lists {isrc|ISRCs} that are attached to more than one recording. If \
              the recordings are the same, this usually means they should be merged \
              (ISRCs can be wrongly assigned so care should still be taken to make sure \
              they really are the same). If the recordings are parts of a larger \
              recording, the ISRCs are probably correct and should be left alone. If the \
              same ISRC appears on two unrelated recordings on the same release, this is \
              usually means there was an error when reading the disc.',
              {__react: true, isrc: '/doc/ISRC'})}
        </li>
        <li>{l('Total ISRCs found: {count}', {__react: true, count: pager.total_entries})}</li>
        <li>{l('Generated on {date}', {__react: true, date: formatUserDate($c.user, generated)})}</li>

        {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
      </ul>

      <PaginatedResults pager={pager}>
        <table className="tbl">
          <thead>
            <tr>
              <th>{l('ISRC')}</th>
              <th>{l('Artist')}</th>
              <th>{l('Recording')}</th>
              <th>{l('Length')}</th>
            </tr>
          </thead>
          <tbody>
            {items.map((item, index) => {
              lastISRC = currentISRC;
              currentISRC = item.isrc;

              return (
                <>
                  {lastISRC !== item.isrc ? (
                    <tr className="even" key={item.isrc}>
                      <td>
                        <a href={'/isrc/' + item.isrc}>{item.isrc}</a>
                        <span>{' (' + item.recordingcount + ')'}</span>
                      </td>
                      <td colSpan="5" />
                    </tr>
                  ) : null}
                  <tr key={item.recording.gid}>
                    <td />
                    <td>
                      <ArtistCreditLink artistCredit={item.recording.artistCredit} />
                    </td>
                    <td>
                      <EntityLink entity={item.recording} />
                    </td>
                    <td>{formatTrackLength(item.length)}</td>
                  </tr>
                </>
              );
            })}
          </tbody>
        </table>
      </PaginatedResults>
    </Layout>
  );
};

export default withCatalystContext(ISRCsWithManyRecordings);
