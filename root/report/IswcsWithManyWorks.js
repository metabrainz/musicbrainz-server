/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../components/PaginatedResults.js';
import {WorkListRow}
  from '../static/scripts/common/components/WorkListEntry.js';
import {bracketedText} from '../static/scripts/common/utility/bracketed.js';

import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportIswcT} from './types.js';

const IswcsWithManyWorks = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportIswcT>): React$Element<typeof ReportLayout> => {
  let lastIswc: string = '';
  let currentIswc: string = '';

  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={exp.l(
        `This report lists {iswc|ISWCs} that are attached to more than
         one work. If the works are the same, this usually means
         they should be merged.`,
        {iswc: '/doc/ISWC'},
      )}
      entityType="iswc"
      filtered={filtered}
      generated={generated}
      title={l('ISWCs with multiple works')}
      totalEntries={pager.total_entries}
    >
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
                <React.Fragment key={item.iswc + '-' + item.work_id}>
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
                    {item.work ? (
                      <>
                        <td />
                        <WorkListRow work={item.work} />
                      </>
                    ) : (
                      <>
                        <td />
                        <td colSpan="5">
                          {l('This work no longer exists.')}
                        </td>
                      </>
                    )}
                  </tr>
                </React.Fragment>
              );
            })}
          </tbody>
        </table>
      </PaginatedResults>
    </ReportLayout>
  );
};

export default IswcsWithManyWorks;
