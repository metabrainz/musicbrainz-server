/*
 * @flow strict
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

component LinksWithMultipleEntities(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportEntryT>) {
  const $c = React.useContext(CatalystContext);

  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l_reports(
        `This report shows URLs that are linked to multiple entities.
         It excludes license relationships (where reuse is expected)
         and Amazon (for releases), Discogs and Wikidata, which have
         their own reports. The links here should be reviewed to see
         whether they are really a good match: for example, a generic
         link to a store page could be replaced with specific
         per-release store links, and a link attached to all movements
         of a classical work might be a better fit for the main
         parent work only.`,
      )}
      entityType="url"
      filtered={filtered}
      generated={generated}
      title={l_reports('URLs linked to multiple entities')}
      totalEntries={pager.total_entries}
    >
      <PaginatedResults pager={pager}>
        <table className="tbl">
          <thead>
            <tr>
              <th>{l('URL')}</th>
              <th>{l_reports('URL entity')}</th>
              <th>{l_reports('Usage count')}</th>
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
                    {l_reports('This URL no longer exists.')}
                  </td>
                )}
              </tr>
            ))}
          </tbody>
        </table>
      </PaginatedResults>
    </ReportLayout>
  );
}

export default LinksWithMultipleEntities;
