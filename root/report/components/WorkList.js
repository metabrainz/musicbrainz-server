/*
 * @flow strict-local
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

type Props = {
  +items: $ReadOnlyArray<ReportWorkT>,
  +pager: PagerT,
};

const WorkList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => (
  <PaginatedResults pager={pager}>
    <table className="tbl">
      <thead>
        <tr>
          <th>{l('Work')}</th>
          <th>{l('Type')}</th>
        </tr>
      </thead>
      <tbody>
        {items.map((item, index) => (
          <tr className={loopParity(index)} key={item.work_id}>
            {item.work ? (
              <>
                <td>
                  <EntityLink entity={item.work} />
                </td>
                <td>
                  {nonEmpty(item.work.typeName)
                    ? lp_attributes(item.work.typeName, 'work_type')
                    : l('Unknown')}
                </td>
              </>
            ) : (
              <td>
                {l('This work no longer exists.')}
              </td>
            )}
          </tr>
        ))}
      </tbody>
    </table>
  </PaginatedResults>
);

export default WorkList;
