/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink.js';
import EntityLink
  from '../../static/scripts/common/components/EntityLink.js';

component AddReleaseLabel(edit: AddReleaseLabelEditT) {
  const display = edit.display_data;

  return (
    <table className="details add-release-label">
      {edit.preview /*:: === true */ ? null : (
        <tr>
          <th>{addColonText(l('Release'))}</th>
          <td>
            {display.release
              ? <DescriptiveLink entity={display.release} />
              : null}
          </td>
        </tr>
      )}
      <tr>
        <th>{addColonText(l('Label'))}</th>
        <td>
          {display.label
            ? <EntityLink entity={display.label} />
            : null}
        </td>
      </tr>
      <tr>
        <th>{addColonText(l('Catalog number'))}</th>
        <td>{display.catalog_number}</td>
      </tr>
    </table>
  );
}

export default AddReleaseLabel;
