/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../components/PaginatedResults';
import loopParity from '../utility/loopParity';
import EntityLink from '../static/scripts/common/components/EntityLink';
import formatBarcode from '../static/scripts/common/utility/formatBarcode';

import ReportLayout from './components/ReportLayout';
import type {ReportDataT} from './types';

type ReportRowT = {
  +barcode: string,
  +release: ?ReleaseT,
  +release_group: ?ReleaseGroupT,
  +release_group_id: number,
  +release_id: number,
  +row_number: number,
};

const ReleasesSameBarcode = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportRowT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    $c={$c}
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows non-bootleg releases which have
       the same barcode, yet are placed in different release groups.
       Chances are that the releases are duplicates or parts of a set,
       or at least that the release groups should be merged.`,
    )}
    entityType="release"
    filtered={filtered}
    generated={generated}
    title={l('Releases with the same barcode in different release groups')}
    totalEntries={pager.total_entries}
  >
    <PaginatedResults pager={pager}>
      <table className="tbl">
        <thead>
          <tr>
            <th>{l('Barcode')}</th>
            <th>{l('Release')}</th>
            <th>{l('Release Group')}</th>
          </tr>
        </thead>
        <tbody>
          {items.map((item, index) => (
            <tr className={loopParity(index)} key={item.release_id}>
              <td className="barcode-cell">
                {formatBarcode(item.barcode)}
              </td>
              {item.release ? (
                <td>
                  <EntityLink entity={item.release} />
                </td>
              ) : (
                <td>
                  {l('This release no longer exists.')}
                </td>
              )}
              {item.release_group ? (
                <td>
                  <EntityLink entity={item.release_group} />
                </td>
              ) : (
                <td>
                  {l('This release group no longer exists.')}
                </td>
              )}
            </tr>
          ))}
        </tbody>
      </table>
    </PaginatedResults>
  </ReportLayout>
);

export default ReleasesSameBarcode;
