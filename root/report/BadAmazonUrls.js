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
import EntityLink from '../static/scripts/common/components/EntityLink';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink';

import FilterLink from './FilterLink';
import type {ReportDataT, ReportReleaseUrlT} from './types';

const BadAmazonUrls = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseUrlT>) => (
  <Layout fullWidth title={l('Bad Amazon URLs')}>
    <h1>{l('Bad Amazon URLs')}</h1>

    <ul>
      <li>
        {l(`This report shows releases with Amazon URLs which don't follow
            the expected format. They might still be correct if they're
            archive.org cover links, but in any other case they should
            probably be fixed or removed.`)}
      </li>
      <li>
        {texp.l('Total releases found: {count}',
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
            <th>{l('Release')}</th>
            <th>{l('Artist')}</th>
            <th>{l('URL')}</th>
          </tr>
        </thead>
        <tbody>
          {items.map((item, index) => (
            <tr className={loopParity(index)} key={item.release_id}>
              {item.release ? (
                <>
                  <td>
                    <EntityLink entity={item.release} />
                  </td>
                  <td>
                    <ArtistCreditLink
                      artistCredit={item.release.artistCredit}
                    />
                  </td>
                  <td>
                    <EntityLink
                      content={item.url.href_url}
                      entity={item.url}
                    />
                  </td>
                </>
              ) : (
                <td colSpan="3">
                  {l('This release no longer exists.')}
                </td>
              )}
            </tr>
          ))}
        </tbody>
      </table>
    </PaginatedResults>
  </Layout>
);

export default withCatalystContext(BadAmazonUrls);
