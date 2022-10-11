/*
 * @flow strict
 * Copyright (C) 2020 Anirudh Jain
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DescriptiveLink from
  '../../static/scripts/common/components/DescriptiveLink.js';
import ExpandedArtistCredit from
  '../../static/scripts/common/components/ExpandedArtistCredit.js';

type Props = {
  +allowNew?: boolean,
  +edit: AddReleaseGroupEditT,
};

const AddReleaseGroup = ({allowNew, edit}: Props): React.MixedElement => {
  const display = edit.display_data;
  const type = display.type;
  const secondaryType = display.secondary_types;
  return (
    <>
      <table className="details">
        <tbody>
          <tr>
            <th>{addColonText(l('Release group'))}</th>
            <td>
              <DescriptiveLink
                allowNew={allowNew}
                entity={display.release_group}
              />
            </td>
          </tr>
        </tbody>
      </table>
      <table className="details add-release-group">
        <tbody>
          <tr>
            <th>{addColonText(l('Name'))}</th>
            <td>{display.name}</td>
          </tr>

          <tr>
            <th>{addColonText(l('Artist'))}</th>
            <td>
              <ExpandedArtistCredit
                artistCredit={display.artist_credit}
              />
            </td>
          </tr>

          {display.comment ? (
            <tr>
              <th>{addColonText(l('Disambiguation'))}</th>
              <td>{display.comment}</td>
            </tr>
          ) : null}

          {type ? (
            <tr>
              <th>
                {type.historic
                  ? addColonText(l('Type'))
                  : l('Primary Type:')}
              </th>
              <td>
                {type.historic
                  ? lp_attributes(type.name, 'release_group_secondary_type')
                  : lp_attributes(type.name, 'release_group_primary_type')
                }
              </td>
            </tr>
          ) : null}

          {secondaryType ? (
            <tr>
              <th>{l('Secondary Types:')}</th>
              <td>{secondaryType}</td>
            </tr>
          ) : null}
        </tbody>
      </table>
    </>
  );
};

export default AddReleaseGroup;
