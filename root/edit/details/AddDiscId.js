/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import CDTocLink from '../../static/scripts/common/components/CDTocLink.js';
import MediumLink
  from '../../static/scripts/common/components/MediumLink.js';

component AddDiscId(allowNew?: boolean, edit: AddDiscIdEditT) {
  const medium = edit.display_data.medium;
  const cdToc = edit.display_data.medium_cdtoc.cdtoc;

  return (
    <table className="details add-disc-id">
      {medium ? (
        <tr>
          <th>{addColonText(l('Medium'))}</th>
          <td colSpan={2}>
            <MediumLink allowNew={allowNew} medium={medium} />
          </td>
        </tr>
      ) : null}
      <tr>
        <th>{addColonText(l('Disc ID'))}</th>
        <td>
          <CDTocLink cdToc={cdToc} />
        </td>
      </tr>
    </table>
  );
}

export default AddDiscId;
