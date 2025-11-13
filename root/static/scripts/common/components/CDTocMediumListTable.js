/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../../../../context.mjs';

import CDTocMediumListRow from './CDTocMediumListRow.js';

component CDTocMediumListTable(
  mediumCDTocs: $ReadOnlyArray<MediumCDTocT>,
  releaseMap: {[releaseId: number]: ReleaseT},
  showEditColumn as passedShowEditColumn: boolean = false,
) {
  const $c = React.useContext(SanitizedCatalystContext);
  const showTagger = Boolean($c?.session?.tport);
  const showEditColumn = Boolean($c?.user) && passedShowEditColumn;

  return (
    <table className="tbl">
      <thead>
        <tr>
          <th>{l('Position')}</th>
          <th>{l('Title')}</th>
          <th>{l('Artist')}</th>
          <th>{l('Format')}</th>
          <th>{l('Country') + lp('/', 'and') + l('Date')}</th>
          <th>{l('Label')}</th>
          <th>{l('Catalog#')}</th>
          <th>{l('Barcode')}</th>
          {showTagger ? <th>{lp('Tagger', 'audio file metadata')}</th> : null}
          {showEditColumn ? <th>{lp('Edit', 'verb, header')}</th> : null}
        </tr>
      </thead>
      <tbody>
        {mediumCDTocs.map((mediumCDToc, index) => (
          <CDTocMediumListRow
            index={index}
            key={index}
            mediumCDToc={mediumCDToc}
            releaseMap={releaseMap}
            showEditColumn={showEditColumn}
            showTagger={showTagger}
          />
        ))}
      </tbody>
    </table>
  );
}

export default (hydrate<React.PropsOf<CDTocMediumListTable>>(
  'div.cd-toc-medium-list-table-container',
  CDTocMediumListTable,
): component(...React.PropsOf<CDTocMediumListTable>));
