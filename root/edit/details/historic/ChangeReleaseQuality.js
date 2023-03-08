/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DescriptiveLink
  from '../../../static/scripts/common/components/DescriptiveLink.js';
import {QUALITY_NAMES} from '../../../static/scripts/common/constants.js';

type Props = {
  +edit: ChangeReleaseQualityHistoricEditT,
};

const ChangeReleaseQuality = ({edit}: Props): React$Element<'table'> => (
  <table className="details change-release-quality">
    {edit.display_data.changes.map((change, index) => {
      const oldQuality = QUALITY_NAMES.get(change.quality.old);
      const newQuality = QUALITY_NAMES.get(change.quality.new);
      return (
        <React.Fragment key={index}>
          <tr>
            <th>{l('Releases:')}</th>
            <td colSpan="2">
              <ul>
                {change.releases.map(release => (
                  <li key={release.id}>
                    <DescriptiveLink entity={release} />
                  </li>
                ))}
              </ul>
            </td>
          </tr>
          <tr>
            <th>{addColonText(l('Data Quality'))}</th>
            <td className="old">{oldQuality ? oldQuality() : ''}</td>
            <td className="new">{newQuality ? newQuality() : ''}</td>
          </tr>
        </React.Fragment>
      );
    })}
  </table>
);

export default ChangeReleaseQuality;
