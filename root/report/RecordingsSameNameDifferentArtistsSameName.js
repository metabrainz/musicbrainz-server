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
import bracketed from '../static/scripts/common/utility/bracketed';
import EntityLink from '../static/scripts/common/components/EntityLink';

import FilterLink from './FilterLink';
import type {ReportDataT, ReportRecordingT} from './types';

const RecordingsSameNameDifferentArtistsSameName = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportRecordingT>) => (
  <Layout fullWidth title={l('Recordings with the same name by different artists with the same name')}>
    <h1>{l('Recordings with the same name by different artists with the same name')}</h1>

    <ul>
      <li>
        {l(`This report shows all recordings with the same name that have
            different artists (having different MBIDs) with the same name.`)}
      </li>
      <li>
        {exp.l(`These are most likely cases where the {ac|artist credit} is
            incorrect for at least one of the recordings.`,
        {ac: '/doc/Artist_Credits'})}
      </li>
      <li>
        {l(`Currently, this report only works with recordings that have
            one artist.`)}
      </li>
      <li>{texp.l('Total recordings found: {count}', {count: pager.total_entries})}</li>
      <li>{texp.l('Generated on {date}', {date: formatUserDate($c.user, generated)})}</li>

      {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
    </ul>

    <PaginatedResults pager={pager}>
      <table className="tbl">
        <thead>
          <tr>
            <th>{l('Artist')}</th>
            <th>{l('Recording')}</th>
          </tr>
        </thead>
        <tbody>
          {items.map((item, index) => (
            <tr className={loopParity(index)} key={item.recording.gid}>
              <td>
                <ArtistCreditLink
                  artistCredit={item.recording.artistCredit}
                />
                <span className="comment">
                  <bdi key="comment">
                    {
                      ' ' +
                      bracketed(item.recording.artistCredit[0].artist.comment)
                    }
                  </bdi>
                </span>
              </td>
              <td>
                <EntityLink entity={item.recording} />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </PaginatedResults>
  </Layout>
);

export default withCatalystContext(
  RecordingsSameNameDifferentArtistsSameName,
);
