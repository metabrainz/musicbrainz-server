/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {l_relationships}
  from '../../static/scripts/common/i18n/relationships';
import PaginatedResults from '../../components/PaginatedResults';
import loopParity from '../../utility/loopParity';
import type {ReportUrlRelationshipT} from '../types';

type Props = {
  +items: $ReadOnlyArray<ReportUrlRelationshipT>,
  +pager: PagerT,
};

const UrlRelationshipList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => (
  <PaginatedResults pager={pager}>
    <table className="tbl">
      <thead>
        <tr>
          <th>{l('Relationship Type')}</th>
          <th>{l('URL')}</th>
          <th>{l('URL Entity')}</th>
        </tr>
      </thead>
      <tbody>
        {items.map((item, index) => (
          <tr className={loopParity(index)} key={item.url_id}>
            <td>
              <a href={'/relationship/' + encodeURIComponent(item.link_gid)}>
                {l_relationships(item.link_name)}
              </a>
            </td>
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
              </>
            ) : (
              <td colSpan="2">
                {l('This URL no longer exists.')}
              </td>
            )}
          </tr>
        ))}
      </tbody>
    </table>
  </PaginatedResults>
);

export default UrlRelationshipList;
