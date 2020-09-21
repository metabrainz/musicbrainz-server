/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import formatUserDate from '../utility/formatUserDate';
import PaginatedResults from '../components/PaginatedResults';
import loopParity from '../utility/loopParity';
import EntityLink from '../static/scripts/common/components/EntityLink';

import FilterLink from './FilterLink';
import type {ReportDataT, ReportReleaseReleaseGroupT} from './types';

const ReleaseRgDifferentName = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseReleaseGroupT>): React.Element<typeof Layout> => (
  <Layout
    $c={$c}
    fullWidth
    title={l('Releases with a different name than their release group')}
  >
    <h1>{l('Releases with a different name than their release group')}</h1>

    <ul>
      <li>
        {l(
          `This report shows releases which are the only ones in their release
           group, yet have a different name than the group. This might mean
           one of the two needs to be renamed to match the other.`,
        )}
      </li>
      <li>
        {texp.l('Total releases found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c, generated)})}
      </li>

      {canBeFiltered ? <FilterLink $c={$c} filtered={filtered} /> : null}
    </ul>

    <PaginatedResults pager={pager}>
      <table className="tbl">
        <thead>
          <tr>
            <th>{l('Release')}</th>
            <th>{l('Release Group')}</th>
          </tr>
        </thead>
        <tbody>
          {items.map((item, index) => (
            <tr className={loopParity(index)} key={item.release_id}>
              {item.release ? (
                <td>
                  <EntityLink entity={item.release} />
                </td>
              ) : (
                <td>
                  {l('This release no longer exists.')}
                </td>
              )}
              {item.release_group ? (
                <td>
                  <EntityLink entity={item.release_group} />
                </td>
              ) : (
                <td>
                  {l('This release group no longer exists.')}
                </td>
              )}
            </tr>
          ))}
        </tbody>
      </table>
    </PaginatedResults>

  </Layout>
);

export default ReleaseRgDifferentName;
