/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import CDTocLink from '../../static/scripts/common/components/CDTocLink.js';
import MediumLink
  from '../../static/scripts/common/components/MediumLink.js';
import {arraysEqual} from '../../static/scripts/common/utility/arrays.js';
import formatTrackLength
  from '../../static/scripts/common/utility/formatTrackLength.js';
import {HistoricReleaseListContent}
  from '../components/HistoricReleaseList.js';
import TrackDurationChanges from '../components/TrackDurationChanges.js';

type Props = {
  +edit: SetTrackLengthsEditT,
};

const SetTrackLengths = ({edit}: Props): React.Element<'table'> => {
  const display = edit.display_data;
  const medium = display.medium;
  const cdtoc = display.cdtoc;
  const oldLengths = display.length.old;
  const newLengths = display.length.new;
  const areFormattedLengthsEqual = arraysEqual(
    oldLengths,
    newLengths,
    (a, b) => formatTrackLength(a) === formatTrackLength(b),
  );

  return (
    <table className="details set-track-lengths">
      {medium ? (
        <tr>
          <th>{addColonText(l('Medium'))}</th>
          <td colSpan="2">
            <MediumLink medium={medium} />
          </td>
        </tr>
      ) : (
        <tr>
          <th>{addColonText(l('Releases'))}</th>
          <td colSpan="2">
            <HistoricReleaseListContent releases={display.releases} />
          </td>
        </tr>
      )}
      <tr>
        <th>{addColonText(l('Disc ID'))}</th>
        <td colSpan="2">
          {cdtoc ? (
            <CDTocLink cdToc={cdtoc} />
          ) : l('[removed]')}
        </td>
      </tr>

      <tr>
        <th>{l('Track lengths:')}</th>
        <td>
          <TrackDurationChanges
            newLengths={newLengths}
            oldLengths={oldLengths}
          />
        </td>
      </tr>

      {areFormattedLengthsEqual ? (
        <tr>
          <th>{addColonText(l('Note'))}</th>
          <td colSpan="2">
            {l('This edit makes subsecond changes to track lengths')}
          </td>
        </tr>
      ) : null}
    </table>
  );
};

export default SetTrackLengths;
