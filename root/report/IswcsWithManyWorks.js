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
import {l, TEXT} from '../static/scripts/common/i18n';
import PaginatedResults from '../components/PaginatedResults';
import {WorkListRow} from '../static/scripts/common/components/WorkListEntry';
import {bracketedText} from '../static/scripts/common/utility/bracketed';

import FilterLink from './FilterLink';
import type {ReportDataT, ReportIswcT} from './types';


const IswcsWithManyWorks = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportIswcT>) => {
  let lastIswc = 0;
  let currentIswc = 0;

  return (
    <Layout fullWidth title={l('ISWCs with multiple works')}>
      <h1>{l('ISWCs with multiple works')}</h1>

      <ul>
        <li>
          {l(`This report lists {iswc|ISWCs} that are attached to more than
              one work. If the works are the same, this usually means
              they should be merged.`,
          {iswc: '/doc/ISWC'})}
        </li>
        <li>{l('Total ISWCs found: {count}', {count: pager.total_entries}, TEXT)}</li>
        <li>{l('Generated on {date}', {date: formatUserDate($c.user, generated)}, TEXT)}</li>

        {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
      </ul>

      <PaginatedResults pager={pager}>
        <table className="tbl">
          <thead>
            <tr>
              <th>{l('ISWC')}</th>
              <th>{l('Work')}</th>
              <th>{l('Writers')}</th>
              <th>{l('Artists')}</th>
              <th>{l('Type')}</th>
              <th>{l('Language')}</th>
            </tr>
          </thead>
          <tbody>
            {items.map((item) => {
              lastIswc = currentIswc;
              currentIswc = item.iswc;

              return (
                <React.Fragment key={item.iswc + '-' + item.work.gid}>
                  {lastIswc === item.iswc ? null : (
                    <tr className="even">
                      <td>
                        <a href={'/iswc/' + item.iswc}>{item.iswc}</a>
                        {' ' + bracketedText(item.workcount)}
                      </td>
                      <td colSpan="5" />
                    </tr>
                  )}
                  <tr>
                    <td />
                    <WorkListRow
                      hasIswcColumn={false}
                      hasMergeColumn={false}
                      work={item.work}
                    />
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

export default withCatalystContext(IswcsWithManyWorks);
