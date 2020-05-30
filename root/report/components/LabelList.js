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
import type {ReportLabelT} from '../types';

type Props = {
  +items: $ReadOnlyArray<ReportLabelT>,
  +pager: PagerT,
};

const LabelList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => (
  <PaginatedResults pager={pager}>
    <table className="tbl">
      <thead>
        <tr>
          <th>{l('Label')}</th>
        </tr>
      </thead>
      <tbody>
        {items.map((item, index) => (
          <tr className={loopParity(index)} key={item.label_id}>
            <td>
              {item.label ? (
                <EntityLink entity={item.label} />
              ) : (
                l('This label no longer exists.')
              )}
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  </PaginatedResults>
);

export default LabelList;
