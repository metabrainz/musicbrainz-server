/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {QUALITY_NAMES} from '../../static/scripts/common/constants.js';
import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink.js';

type Props = {
  +edit: ChangeReleaseQualityEditT,
};

const ChangeReleaseQuality = ({edit}: Props): React.Element<'table'> => {
  const oldQuality = QUALITY_NAMES.get(edit.display_data.quality.old);
  const newQuality = QUALITY_NAMES.get(edit.display_data.quality.new);
  return (
    <table className="details change-release-quality">
      <tr>
        <th>{addColonText(l('Release'))}</th>
        <td colSpan="2">
          <DescriptiveLink entity={edit.display_data.release} />
        </td>
      </tr>
      <tr>
        <th>{addColonText(l('Data Quality'))}</th>
        <td className="old">{oldQuality ? oldQuality() : ''}</td>
        <td className="new">{newQuality ? newQuality() : ''}</td>
      </tr>
    </table>
  );
};

export default ChangeReleaseQuality;
