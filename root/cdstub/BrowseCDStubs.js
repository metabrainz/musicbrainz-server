/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../components/PaginatedResults.js';
import Layout from '../layout/index.js';
import CDStubLink from '../static/scripts/common/components/CDStubLink.js';
import {
  getCDStubAddedAgeAgo,
  getCDStubModifiedAgeAgo,
} from '../utility/getCDStubAge.js';
import loopParity from '../utility/loopParity.js';

type Props = {
  +cdStubs: $ReadOnlyArray<CDStubT>,
  +pager: PagerT,
};

const BrowseCDStubs = ({
  cdStubs,
  pager,
}: Props): React$Element<typeof Layout> => (
  <Layout fullWidth title={l('Top CD Stubs')}>
    <h1>{l('Top CD Stubs')}</h1>
    <PaginatedResults pager={pager} total>
      <table className="tbl">
        <thead>
          <tr>
            <th>{l('Title')}</th>
            <th>{l('Artist')}</th>
            <th>{l('Lookup count')}</th>
            <th>{l('Modify count')}</th>
          </tr>
        </thead>
        <tbody>
          {cdStubs.map((cdStub, index) => (
            <React.Fragment key={index}>
              <tr className={loopParity(index)}>
                <td>
                  <CDStubLink cdstub={cdStub} content={cdStub.title} />
                </td>
                <td>{cdStub.artist ?? l('Various Artists')}</td>
                <td>{cdStub.lookup_count}</td>
                <td>{cdStub.modify_count}</td>
              </tr>
              <tr className={loopParity(index)}>
                <td className="lastupdate" colSpan="4">
                  {exp.l(
                    'Added {add}, last modified {lastmod}',
                    {
                      add: getCDStubAddedAgeAgo(cdStub),
                      lastmod: getCDStubModifiedAgeAgo(cdStub),
                    },
                  )}
                </td>
              </tr>
            </React.Fragment>
          ))}
        </tbody>
      </table>
    </PaginatedResults>
  </Layout>
);

export default BrowseCDStubs;
