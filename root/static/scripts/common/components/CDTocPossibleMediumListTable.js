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

import CDTocPossibleMediumListRow from './CDTocPossibleMediumListRow.js';

component CDTocPossibleMediumListTable(
  possibleMediums: $ReadOnlyArray<MediumT>,
  releaseMap: {[releaseId: number]: ReleaseT},
) {
  const $c = React.useContext(SanitizedCatalystContext);
  const showTagger = Boolean($c?.session?.tport);

  return (
    <table className="tbl">
      <thead>
        <tr>
          <th />
          <th>{l('Release')}</th>
          <th>{l('Medium')}</th>
          <th>{l('Artist')}</th>
          <th>{l('Country') + lp('/', 'and') + l('Date')}</th>
          <th>{l('Label')}</th>
          <th>{l('Catalog#')}</th>
          <th>{l('Barcode')}</th>
          {showTagger ? (
            <th>{lp('Tagger', 'audio file metadata')}</th>
          ) : null}
        </tr>
      </thead>
      <tbody>
        {possibleMediums.map((medium, index) => (
          <CDTocPossibleMediumListRow
            index={index}
            key={index}
            medium={medium}
            releaseMap={releaseMap}
            showTagger={showTagger}
          />
        ))}
      </tbody>
    </table>
  );
}

export default (hydrate<React.PropsOf<CDTocPossibleMediumListTable>>(
  'div.cd-toc-possible-medium-list-table-container',
  CDTocPossibleMediumListTable,
): component(...React.PropsOf<CDTocPossibleMediumListTable>));
