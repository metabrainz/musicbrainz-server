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
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink';
import EntityLink from '../static/scripts/common/components/EntityLink';
import formatTrackLength
  from '../static/scripts/common/utility/formatTrackLength';
import {bracketedText} from '../static/scripts/common/utility/bracketed';

import FilterLink from './FilterLink';
import type {ReportDataT, ReportIsrcT} from './types';

const IsrcsWithManyRecordings = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportIsrcT>) => {
  let lastIsrc = 0;
  let currentIsrc = 0;

  return (
    <Layout fullWidth title={l('ISRCs with multiple recordings')}>
      <h1>{l('ISRCs with multiple recordings')}</h1>

      <ul>
        <li>
          {exp.l(
            `This report lists {isrc|ISRCs} that are attached to more than
             one recording. If the recordings are the same, this usually
             means they should be merged (ISRCs can be wrongly assigned
             so care should still be taken to make sure they really are
             the same). If the recordings are parts of a larger recording,
             the ISRCs are probably correct and should be left alone. If the
             same ISRC appears on two unrelated recordings on the same
             release, this is usually means there was an error when reading
             the disc.`,
            {isrc: '/doc/ISRC'},
          )}
        </li>
        <li>
          {texp.l('Total ISRCs found: {count}',
                  {count: pager.total_entries})}
        </li>
        <li>
          {texp.l('Generated on {date}',
                  {date: formatUserDate($c.user, generated)})}
        </li>

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
            {items.map((item) => {
              lastIsrc = currentIsrc;
              currentIsrc = item.isrc;

              return (
                <React.Fragment key={item.isrc + '-' + item.recording.gid}>
                  {lastIsrc === item.isrc ? null : (
                    <tr className="even">
                      <td>
                        <a href={'/isrc/' + item.isrc}>{item.isrc}</a>
                        {' ' + bracketedText(item.recordingcount)}
                      </td>
                      <td colSpan="5" />
                    </tr>
                  )}
                  <tr>
                    <td />
                    <td>
                      <ArtistCreditLink
                        artistCredit={item.recording.artistCredit}
                      />
                    </td>
                    <td>
                      <EntityLink entity={item.recording} />
                    </td>
                    <td>{formatTrackLength(item.length)}</td>
                  </tr>
                </React.Fragment>
              );
            })}
          </tbody>
        </table>
      </PaginatedResults>
    </Layout>
  );
};

export default withCatalystContext(IsrcsWithManyRecordings);
