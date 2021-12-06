/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {QUALITY_NAMES} from '../../../static/scripts/common/constants';
import DescriptiveLink
  from '../../../static/scripts/common/components/DescriptiveLink';

type Props = {
  +edit: ChangeArtistQualityHistoricEditT,
};

const ChangeArtistQuality = ({edit}: Props): React.Element<'table'> => {
  const oldQuality = QUALITY_NAMES.get(edit.display_data.quality.old);
  const newQuality = QUALITY_NAMES.get(edit.display_data.quality.new);
  return (
    <table className="details change-artist-quality">
      <tr>
        <th>{l('Artist:')}</th>
        <td colSpan="2">
          <DescriptiveLink entity={edit.display_data.artist} />
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

export default ChangeArtistQuality;
