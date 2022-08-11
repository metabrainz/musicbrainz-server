/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DescriptiveLink
  from '../../../static/scripts/common/components/DescriptiveLink.js';
import yesNo from '../../../static/scripts/common/utility/yesNo.js';

type Props = {
  +edit: MergeReleasesHistoricEditT,
};

const MergeReleases = ({edit}: Props): React.MixedElement => (
  <>
    <table className="details merge-releases">
      <tr>
        <th>{l('Old releases:')}</th>
        <td>
          <ul>
            {edit.display_data.releases.old.map((release, index) => (
              <li key={'old-' + index}>
                <DescriptiveLink entity={release} />
              </li>
            ))}
          </ul>
        </td>
      </tr>
      <tr>
        <th>{l('New releases:')}</th>
        <td>
          <ul>
            {edit.display_data.releases.new.map((release, index) => (
              <li key={'new-' + index}>
                <DescriptiveLink entity={release} />
              </li>
            ))}
          </ul>
        </td>
      </tr>
      <tr>
        <th>{l('Merge attributes:')}</th>
        <td>{yesNo(edit.display_data.merge_attributes)}</td>
      </tr>
      <tr>
        <th>{l('Merge language & script:')}</th>
        <td>{yesNo(edit.display_data.merge_language)}</td>
      </tr>
      {edit.historic_type === 25 ? (
        <tr>
          <th>{addColonText(l('Note'))}</th>
          <td>
            {l(`This edit was a "Merge Releases (Various Artists)"
                edit which additionally set the release artist
                to Various Artists.`)}
          </td>
        </tr>
      ) : null}
    </table>
  </>
);

export default MergeReleases;
