/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DiffSide from '../../static/scripts/edit/components/edit/DiffSide.js';
import {INSERT, DELETE} from '../../static/scripts/edit/utility/editDiff.js';
import formatTrackLength
  from '../../static/scripts/common/utility/formatTrackLength.js';

type Props = {
  +newLabel?: string,
  +newLengths: $ReadOnlyArray<number | null>,
  +oldLabel?: string,
  +oldLengths: $ReadOnlyArray<number | null>,
};

const TrackDurationChanges = ({
  newLabel,
  newLengths,
  oldLabel,
  oldLengths,
}: Props): React.Element<typeof React.Fragment> => {
  const lengthsSize = oldLengths.length;
  const lengthComparisonTables = [];
  for (let i = 0; i < lengthsSize; i++) {
    const newLength = formatTrackLength(newLengths[i]);
    const oldLength = formatTrackLength(oldLengths[i]);
    lengthComparisonTables.push(
      <table className="wrap-block details" key={i}>
        <tr>
          <td className="old">
            <DiffSide
              filter={DELETE}
              newText={newLength}
              oldText={oldLength}
            />
          </td>
        </tr>
        <tr>
          <td className="new">
            <DiffSide
              filter={INSERT}
              newText={newLength}
              oldText={oldLength}
            />
          </td>
        </tr>
      </table>,
    );
  }
  return (
    <>
      {nonEmpty(oldLabel) && nonEmpty(newLabel) ? (
        <table className="wrap-block details">
          <tr>
            <th>{oldLabel}</th>
          </tr>
          <tr>
            <th>{newLabel}</th>
          </tr>
        </table>
      ) : null}
      {lengthComparisonTables}
    </>
  );
};

export default TrackDurationChanges;
