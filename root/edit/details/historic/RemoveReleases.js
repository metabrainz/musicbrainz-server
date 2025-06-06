/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import DescriptiveLink
  from '../../../static/scripts/common/components/DescriptiveLink.js';

component RemoveReleases(edit: RemoveReleasesHistoricEditT) {
  return (
    <table className="details remove-releases">
      <tr>
        <th>{addColonText(l('Releases'))}</th>
        <td colSpan={2}>
          <ul>
            {edit.display_data.releases.map((release, index) => (
              <li key={index}>
                <DescriptiveLink entity={release} />
              </li>
            ))}
          </ul>
        </td>
      </tr>
    </table>
  );
}

export default RemoveReleases;
