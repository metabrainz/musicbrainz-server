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
import {DeletedLink}
  from '../../static/scripts/common/components/EntityLink';

type Props = {
  label?: string,
  releases: $ReadOnlyArray<ReleaseT | null>,
};

const HistoricReleaseList = ({
  label,
  releases,
}: Props) => (
  <tr>
    <th>{label || l('Releases:')}</th>
    <td>
      <ul>
        {releases.length ? (
          releases.map((release, index) => (
            <li key={index}>
              {release
                ? <DescriptiveLink entity={release} />
                : <DeletedLink allowNew={false} name={null} />}
            </li>
          ))
        ) : (
          <DeletedLink allowNew={false} name={null} />
        )}
      </ul>
    </td>
  </tr>
);

export default HistoricReleaseList;
