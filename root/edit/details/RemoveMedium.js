/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {EDIT_STATUS_OPEN} from '../../constants.js';
import MediumTracklist
  from '../../medium/MediumTracklist.js';
import MediumLink
  from '../../static/scripts/common/components/MediumLink.js';
import Warning from '../../static/scripts/common/components/Warning.js';
import {
  artistCreditsAreEqual,
} from '../../static/scripts/common/immutable-entities.js';
import {arraysEqual} from '../../static/scripts/common/utility/arrays.js';

type Props = {
  +allowNew?: boolean,
  +edit: RemoveMediumEditT,
};

const areTracksEqual = (a: TrackT, b: TrackT) => (
  a.name === b.name &&
  artistCreditsAreEqual(a.artistCredit, b.artistCredit) &&
  a.length === b.length
);

const RemoveMedium = ({
  edit,
}: Props): React$Element<typeof React.Fragment> => {
  const display = edit.display_data;
  const originalTracklist = display.tracks ?? [];
  const currentTracklist = display.medium.tracks ?? [];
  let showTracklistAndWarning = false;
  let hasLengthChanges = false;
  if (edit.status === EDIT_STATUS_OPEN) {
    hasLengthChanges =
      originalTracklist.length !== currentTracklist.length;
    const areTracklistsEqual = arraysEqual(
      originalTracklist,
      currentTracklist,
      areTracksEqual,
    );
    showTracklistAndWarning = !areTracklistsEqual;
  }

  return (
    <>
      {showTracklistAndWarning ? (
        <Warning
          message={hasLengthChanges
            ? l(`The number of tracks on the medium being removed
                 has changed since the removal edit was entered.
                 Please check the changes and ensure the removal
                 is still correct.`)
            : l(`Some track lengths, titles or artists have changed
                 since the removal edit was entered. Please check the changes
                 and ensure the removal is still correct.`)
          }
        />
      ) : null}

      <table className="details remove-medium">
        <tr>
          <th>{addColonText(l('Medium'))}</th>
          <td>
            <MediumLink medium={display.medium} />
          </td>
        </tr>

        <tr>
          <th>
            {showTracklistAndWarning
              ? addColonText(l('Original tracklist'))
              : addColonText(l('Tracklist'))}
          </th>
          <td>
            <table className="tbl">
              <tbody>
                {originalTracklist.length ? (
                  <MediumTracklist
                    showArtists
                    tracks={originalTracklist}
                  />
                ) : l('The tracklist for this medium is unknown.')}
              </tbody>
            </table>
          </td>
        </tr>

        {showTracklistAndWarning ? (
          <tr>
            <th>{addColonText(l('Current tracklist'))}</th>
            <td>
              <table className="tbl">
                <tbody>
                  {currentTracklist.length ? (
                    <MediumTracklist
                      showArtists
                      tracks={currentTracklist}
                    />
                  ) : l('The tracklist for this medium is unknown.')}
                </tbody>
              </table>
            </td>
          </tr>
        ) : null}
      </table>
    </>
  );
};

export default RemoveMedium;
