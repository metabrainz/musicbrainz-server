/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {HistoricReleaseListContent}
  from '../../components/HistoricReleaseList';

type EditReleaseAttributesEditT = {
  ...EditT,
  +display_data: {
    +changes: $ReadOnlyArray<{
      +releases: $ReadOnlyArray<ReleaseT | null>,
      +status: ReleaseStatusT | null,
      +type: ReleaseGroupTypeT | null,
    }>,
    +status: ReleaseStatusT | null,
    +type: ReleaseGroupTypeT | null,
  },
};

type Props = {
  +edit: EditReleaseAttributesEditT,
};

const EditReleaseAttributes = ({edit}: Props): React.Element<'table'> => (
  <table className="details edit-release">
    <tr>
      <th>{l('Old:')}</th>
      <td>
        <table>
          {edit.display_data.changes.map((change, index) => (
            <tr key={index}>
              <td className="old">
                {texp.l(
                  'Type: {type}, status: {status}',
                  {
                    status: change.status
                      ? lp_attributes(change.status.name, 'release_status')
                      : '?',
                    type: change.type
                      ? lp_attributes(
                        change.type.name,
                        'release_group_primary_type',
                      ) : '?',
                  },
                )}
              </td>
              <td>
                <HistoricReleaseListContent releases={change.releases} />
              </td>
            </tr>
          ))}
        </table>
      </td>
    </tr>

    <tr>
      <th>{l('New Type:')}</th>
      <td className="new" colSpan="2">
        {edit.display_data.type
          ? lp_attributes(
            edit.display_data.type.name,
            'release_group_primary_type',
          ) : '?'}
      </td>
    </tr>

    <tr>
      <th>{l('New Status:')}</th>
      <td className="new" colSpan="2">
        {edit.display_data.status
          ? lp_attributes(edit.display_data.status.name, 'release_status')
          : '?'}
      </td>
    </tr>
  </table>
);

export default EditReleaseAttributes;
