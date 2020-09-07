/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
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
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink';

import FilterLink from './FilterLink';
import type {ReportDataT, ReportReleaseCatNoT} from './types';

const CatNoLooksLikeLabelCode = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseCatNoT>): React.Element<typeof Layout> => (
  <Layout
    $c={$c}
    fullWidth
    title={l('Releases with catalog numbers that look like Label Codes')}
  >
    <h1>{l('Releases with catalog numbers that look like Label Codes')}</h1>

    <ul>
      <li>
        {exp.l(
          `This report shows releases which have catalog numbers that look
           like {doc_link|Label Codes}. This is often wrong, since the two
           are often confused: label codes apply to the label, not to a
           specific release. If you confirm this is a label code (check
           the label page to see if they match, for example), remove it or,
           even better, try to find the actual catalog number.`,
          {doc_link: '/doc/Label/Label_Code'},
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
            <th>{l('Catalog Number')}</th>
            <th>{l('Release')}</th>
            <th>{l('Artist')}</th>
          </tr>
        </thead>
        <tbody>
          {items.map((item, index) => (
            <tr className={loopParity(index)} key={item.release_id}>
              {item.release ? (
                <>
                  <td>{item.catalog_number}</td>
                  <td>
                    <EntityLink entity={item.release} />
                  </td>
                  <td>
                    <ArtistCreditLink
                      artistCredit={item.release.artistCredit}
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

export default CatNoLooksLikeLabelCode;
