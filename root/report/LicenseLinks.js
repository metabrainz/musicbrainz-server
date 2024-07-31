/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
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

const LicenseLinks = ({
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
        `This report shows URLs that are used in license relationships.
         License relationship types are often misused, so many entries here,
         especially the ones with only one or two uses, are likely to be
         incorrect and should be changed to a different relationship type,
         moved to a different entity (for example, from a release to a
         release group) or removed altogether. Do make sure the link is not
         actually to a license though, since in some rare cases an artist
         might really have a one-off license for a release or work specifying
         what can be done with it.`,
      )}
      entityType="url"
      filtered={filtered}
      generated={generated}
      title={l('URLs used in license relationships')}
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

export default LicenseLinks;
