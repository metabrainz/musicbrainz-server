/*
 * @flow strict-local
 * Copyright (C) 2020 Jerome Roy
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../../components/PaginatedResults';
import loopParity from '../../utility/loopParity';
import type {ReportCDTocT} from '../types';
import CDTocLink
  from '../../static/scripts/common/components/CDTocLink';
import formatTrackLength
  from '../../static/scripts/common/utility/formatTrackLength';

type Props = {
  +items: $ReadOnlyArray<ReportCDTocT>,
  +pager: PagerT,
};

const CDTocList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => {
  const colSpan = 3;

  return (
    <PaginatedResults pager={pager}>
      <table className="tbl">
        <thead>
          <tr>
            <th>{l('Disc ID')}</th>
            <th>{l('Format')}</th>
            <th>{l('Length')}</th>
          </tr>
        </thead>
        <tbody>
          {items.map((item, index) => {
            return (
              <tr className={loopParity(index)} key={item.cdtoc_id}>
                {item.cdtoc ? (
                  <>
                    <td>
                      <CDTocLink
                        cdToc={item.cdtoc}
                        content={item.cdtoc.discid}
                      />
                    </td>
                    <td>
                      {item.format}
                    </td>
                    <td>
                      {formatTrackLength(1000 * item.length)}
                    </td>
                  </>
                ) : (
                  <td colSpan={colSpan}>
                    {l('This Disc ID no longer exists.')}
                  </td>
                )}
              </tr>
            );
          })}
        </tbody>
      </table>
    </PaginatedResults>
  );
};

export default CDTocList;
