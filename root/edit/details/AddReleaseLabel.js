/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink';
import EntityLink
  from '../../static/scripts/common/components/EntityLink';

type AddReleaseLabelEditT = {
  ...EditT,
  +display_data: {
    +catalog_number: string,
    +label?: LabelT,
    +release?: ReleaseT,
  },
};

type Props = {
  +edit: AddReleaseLabelEditT,
};

const AddReleaseLabel = ({edit}: Props): React.Element<'table'> => {
  const display = edit.display_data;

  return (
    <table className="details add-release-label">
      {edit.preview ? null : (
        <tr>
          <th>{l('Release:')}</th>
          <td>
            {display.release
              ? <DescriptiveLink entity={display.release} />
              : null}
          </td>
        </tr>
      )}
      <tr>
        <th>{l('Label:')}</th>
        <td>
          {display.label
            ? <EntityLink entity={display.label} />
            : null}
        </td>
      </tr>
      <tr>
        <th>{l('Catalog number:')}</th>
        <td>{display.catalog_number}</td>
      </tr>
    </table>
  );
};

export default AddReleaseLabel;
