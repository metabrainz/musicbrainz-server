/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../../components/PaginatedResults';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import loopParity from '../../utility/loopParity';
import type {ReportWorkRelationshipT} from '../types';

const WorkRelationshipList = ({
  items,
  pager,
}: {items: $ReadOnlyArray<ReportWorkRelationshipT>, pager: PagerT}) => (
  <PaginatedResults pager={pager}>
    <table className="tbl">
      <thead>
        <tr>
          <th>{l('Relationship Type')}</th>
          <th>{l('Work')}</th>
        </tr>
      </thead>
      <tbody>
        {items.map((item, index) => (
          <tr className={loopParity(index)} key={item.work.gid}>
            <td>
              <a href={'/relationship/' + item.link_gid}>{l_relationships(item.link_name)}</a>
            </td>
            <td>
              <EntityLink entity={item.work} />
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  </PaginatedResults>
);

export default WorkRelationshipList;
