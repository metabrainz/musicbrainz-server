/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import MediumTracklist
  from '../../medium/MediumTracklist';
import MediumLink
  from '../../static/scripts/common/components/MediumLink';

type RemoveMediumEditT = {
  ...EditT,
  +display_data: {
    +medium: MediumT,
    +tracks?: $ReadOnlyArray<TrackT>,
  },
};

type Props = {
  +allowNew?: boolean,
  +edit: RemoveMediumEditT,
};

const RemoveMedium = ({edit}: Props): React.Element<'table'> => {
  const display = edit.display_data;

  return (
    <table className="details remove-medium">
      <tr>
        <th>{addColon(l('Medium'))}</th>
        <td>
          <MediumLink medium={display.medium} />
        </td>
      </tr>

      <tr>
        <th>{addColonText(l('Tracklist'))}</th>
        <td>
          <table className="tbl">
            <tbody>
              {display.tracks?.length ? (
                <MediumTracklist
                  showArtists
                  tracks={display.tracks}
                />
              ) : l('The tracklist for this medium is unknown.')}
            </tbody>
          </table>
        </td>
      </tr>

    </table>
  );
};

export default RemoveMedium;
