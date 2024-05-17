/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {HistoricReleaseListContent}
  from '../../components/HistoricReleaseList.js';

function getTypeName(
  type: ReleaseGroupTypeT | ReleaseGroupHistoricTypeT | null,
) {
  return type ? (
    type.historic ? lp_attributes(
      type.name,
      'release_group_secondary_type',
    ) : lp_attributes(
      type.name,
      'release_group_primary_type',
    )
  ) : '?';
}

component EditReleaseAttributes(edit: EditReleaseAttributesHistoricEditT) {
  return (
    <table className="details edit-release">
      <tr>
        <th>{addColonText(lp('Old', 'release type and status'))}</th>
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
                      type: getTypeName(change.type),
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
        <th>{l('New type:')}</th>
        <td className="new" colSpan="2">
          {getTypeName(edit.display_data.type)}
        </td>
      </tr>

      <tr>
        <th>{l('New status:')}</th>
        <td className="new" colSpan="2">
          {edit.display_data.status
            ? lp_attributes(edit.display_data.status.name, 'release_status')
            : '?'}
        </td>
      </tr>
    </table>
  );
}

export default EditReleaseAttributes;
