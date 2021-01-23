/*
 * @flow strict-local
 * Copyright (C) 2021 Jerome Roy
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../../components/PaginatedResults';
import loopParity from '../../utility/loopParity';
import type {ReportCDTocReleaseT} from '../types';
import ArtistCreditLink
  from '../../static/scripts/common/components/ArtistCreditLink';
import CDTocLink
  from '../../static/scripts/common/components/CDTocLink';
import EntityLink from '../../static/scripts/common/components/EntityLink';

type Props = {
  +items: $ReadOnlyArray<ReportCDTocReleaseT>,
  +pager: PagerT,
};

const CDTocReleaseList = ({
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
            <th>{l('Release')}</th>
            <th>{l('Artist')}</th>
          </tr>
        </thead>
        <tbody>
          {items.map((item, index) => {
            return (
              <tr className={loopParity(index)} key={item.cdtoc_id}>
                {item.cdtoc && item.release ? (
                  <>
                    <td>
                      <CDTocLink
                        cdToc={item.cdtoc}
                        content={item.cdtoc.discid}
                      />
                    </td>
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

export default CDTocReleaseList;
