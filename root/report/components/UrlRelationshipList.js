/*
 * @flow
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
import EntityLink from '../../static/scripts/common/components/EntityLink';
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
            <td>
              {item.url ? (
                <EntityLink entity={item.url} />
              ) : (
                l('This URL no longer exists.')
              )}
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  </PaginatedResults>
);

export default UrlRelationshipList;
