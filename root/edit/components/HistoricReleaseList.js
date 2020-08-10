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

type HistoricReleaseListContentProps = {
  +releases: $ReadOnlyArray<ReleaseT | null>,
};

type HistoricReleaseListProps = {
  +colSpan?: string,
  +label?: string,
  +releases: $ReadOnlyArray<ReleaseT | null>,
};

export const HistoricReleaseListContent = ({
  releases,
}: HistoricReleaseListContentProps): React.Element<'ul'> => (
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
);

const HistoricReleaseList = ({
  colSpan,
  label,
  releases,
}: HistoricReleaseListProps): React.Element<'tr'> => (
  <tr>
    <th>{label || l('Releases:')}</th>
    <td colSpan={colSpan}>
      <HistoricReleaseListContent releases={releases} />
    </td>
  </tr>
);

export default HistoricReleaseList;
