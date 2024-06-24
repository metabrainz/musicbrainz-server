/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink.js';
import {DeletedLink}
  from '../../static/scripts/common/components/EntityLink.js';

export component HistoricReleaseListContent(
  releases: $ReadOnlyArray<ReleaseT | null>,
) {
  return (
    <ul>
      {releases.length ? (
        releases.map((release, index) => (
          <li key={index}>
            {release?.id
              ? <DescriptiveLink entity={release} />
              : <DeletedLink allowNew={false} name={release?.name ?? null} />}
          </li>
        ))
      ) : (
        <DeletedLink allowNew={false} name={null} />
      )}
    </ul>
  );
}

component HistoricReleaseList(
  colSpan?: string,
  label?: string,
  ...contentProps: React.PropsOf<HistoricReleaseListContent>
) {
  return (
    <tr>
      <th>{nonEmpty(label) ? label : addColonText(l('Releases'))}</th>
      <td colSpan={colSpan}>
        <HistoricReleaseListContent {...contentProps} />
      </td>
    </tr>
  );
}

export default HistoricReleaseList;
