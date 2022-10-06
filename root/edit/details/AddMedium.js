/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import MediumTracklist
  from '../../medium/MediumTracklist.js';
import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink.js';
import ExpandedArtistCredit
  from '../../static/scripts/common/components/ExpandedArtistCredit.js';
import {artistCreditsAreEqual}
  from '../../static/scripts/common/immutable-entities.js';
import loopParity from '../../utility/loopParity.js';

type CondensedTrackACsRowProps = {
  +artistCredit: ArtistCreditT,
  +endNumber?: string,
  +rowCounter: number,
  +startNumber: string,
};

type CondensedTrackACsProps = {
  +tracks?: $ReadOnlyArray<TrackT>,
};

type Props = {
  +allowNew?: boolean,
  +edit: AddMediumEditT,
};

const CondensedTrackACsRow = ({
  artistCredit,
  endNumber,
  rowCounter,
  startNumber,
}: CondensedTrackACsRowProps): React.Element<'tr'> => (
  <tr className={loopParity(rowCounter)}>
    <td className="pos t">
      {nonEmpty(endNumber) && endNumber !== startNumber
        ? startNumber + '-' + endNumber
        : startNumber}
    </td>
    <td>
      <ExpandedArtistCredit artistCredit={artistCredit} />
    </td>
  </tr>
);

const CondensedTrackACs = ({
  tracks,
}: CondensedTrackACsProps):
  Array<React.Element<typeof CondensedTrackACsRow>> => {
  if (!tracks) {
    return [];
  }

  let thisCredit;
  let thisPosition = tracks[0].position - 1;
  let rowCounter = 0;
  let startNumber = tracks[0].number;
  let endNumber;
  const rows = [];

  tracks.map((track, index, array) => {
    const isLast = array.length - 1 === index;
    const isNewArtistCredit = thisCredit &&
      !artistCreditsAreEqual(thisCredit, track.artistCredit);
    const isTherePositionGap = thisPosition + 1 !== +track.position;
    if (isNewArtistCredit || isTherePositionGap) {
      rows.push(
        <CondensedTrackACsRow
          artistCredit={thisCredit}
          endNumber={endNumber}
          rowCounter={rowCounter}
          startNumber={startNumber}
        />,
      );
      rowCounter++;
      startNumber = track.number;
      endNumber = startNumber;
    } else {
      endNumber = track.number;
    }
    thisCredit = track.artistCredit;
    thisPosition = +track.position;
    if (isLast) {
      rows.push(
        <CondensedTrackACsRow
          artistCredit={thisCredit}
          endNumber={endNumber}
          rowCounter={rowCounter}
          startNumber={startNumber}
        />,
      );
    }
  });
  return rows;
};

const AddMedium = ({allowNew, edit}: Props): React.MixedElement => {
  const display = edit.display_data;
  const format = display.format;

  return (
    <table className="details add-medium">
      {edit.preview /*:: === true */ ? null : (
        <tr>
          <th>{addColonText(l('Release'))}</th>
          <td>
            {display.release
              ? <DescriptiveLink entity={display.release} />
              : null}
          </td>
        </tr>
      )}

      <tr>
        <th>{l('Position:')}</th>
        <td>{display.position}</td>
      </tr>

      {nonEmpty(display.name) ? (
        <tr>
          <th>{l('Name:')}</th>
          <td>{display.name}</td>
        </tr>
      ) : null}

      {format ? (
        <tr>
          <th>{l('Format:')}</th>
          <td>
            {lp_attributes(format.name, 'medium_format')}
          </td>
        </tr>
      ) : null}

      <tr>
        <th>{addColonText(l('Tracklist'))}</th>
        <td>
          <table className="tbl">
            <tbody>
              {display.tracks?.length ? (
                <MediumTracklist
                  allowNew={allowNew}
                  showArtists
                  tracks={display.tracks}
                />
              ) : l('The tracklist for this medium is unknown.')}
            </tbody>
          </table>
        </td>
      </tr>

      {display.tracks?.length ? (
        <tr>
          <th>{l('Artist Credits:')}</th>
          <td>
            <table className="tbl">
              <thead>
                <tr>
                  <th className="pos">{l('#')}</th>
                  <th>{l('Artist')}</th>
                </tr>
              </thead>
              <tbody>
                <CondensedTrackACs tracks={display.tracks} />
              </tbody>
            </table>
          </td>
        </tr>
      ) : null}
    </table>
  );
};

export default AddMedium;
