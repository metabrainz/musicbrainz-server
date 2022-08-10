/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../components/PaginatedResults.js';
import {CatalystContext} from '../context.mjs';
import {formatCount} from '../statistics/utilities.js';
import loopParity from '../utility/loopParity.js';

import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT} from './types.js';

type ReportEntryT = {
  +count: number,
  +row_number: number,
  +url: ?UrlT,
  +url_id: number,
};

const WikidataLinksWithMultipleEntities = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportEntryT>): React.Element<typeof ReportLayout> => {
  const $c = React.useContext(CatalystContext);

  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l(
        `This report shows Wikidata URLs that are linked to multiple
         entities. In general, Wikidata entities should match 1 to 1
         with MusicBrainz entities, so most of these should indicate
         either an error in MusicBrainz or a too-wide Wikidata page.`,
      )}
      entityType="url"
      filtered={filtered}
      generated={generated}
      title={l('Wikidata URLs linked to multiple entities')}
      totalEntries={pager.total_entries}
    >
      <PaginatedResults pager={pager}>
        <table className="tbl">
          <thead>
            <tr>
              <th>{l('URL')}</th>
              <th>{l('URL Entity')}</th>
              <th>{l('Usage count')}</th>
            </tr>
          </thead>
          <tbody>
            {items.map((item, index) => (
              <tr className={loopParity(index)} key={item.url_id}>
                {item.url ? (
                  <>
                    <td>
                      <a href={item.url.name}>
                        {item.url.name}
                      </a>
                    </td>
                    <td>
                      <a href={'/url/' + item.url.gid}>
                        {item.url.gid}
                      </a>
                    </td>
                    <td>
                      {formatCount($c, item.count)}
                    </td>
                  </>
                ) : (
                  <td colSpan="3">
                    {l('This URL no longer exists.')}
                  </td>
                )}
              </tr>
            ))}
          </tbody>
        </table>
      </PaginatedResults>
    </ReportLayout>
  );
};

export default WikidataLinksWithMultipleEntities;
