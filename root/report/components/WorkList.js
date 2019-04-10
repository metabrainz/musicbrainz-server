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
import type {ReportWorkT} from '../types';

const WorkList = ({
  items,
  pager,
}: {items: $ReadOnlyArray<ReportWorkT>, pager: PagerT}) => (
  <PaginatedResults pager={pager}>
    <table className="tbl">
      <thead>
        <tr>
          <th>{l('Work')}</th>
        </tr>
      </thead>
      <tbody>
        {items.map((item, index) => (
          <tr className={loopParity(index)} key={item.work.gid}>
            <td>
              <EntityLink entity={item.work} />
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  </PaginatedResults>
);

export default WorkList;
