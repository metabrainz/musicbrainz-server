/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DescriptiveLink
  from '../../../static/scripts/common/components/DescriptiveLink.js';
import WordDiff
  from '../../../static/scripts/edit/components/edit/WordDiff.js';

type Props = {
  +edit: EditTrackHistoricEditT,
};

const EditTrack = ({edit}: Props): React.Element<'table'> => {
  const display = edit.display_data;
  const artist = display.artist;
  const position = display.position;

  return (
    <table className="details edit-track">
      <tr>
        <th>{addColonText(l('Recording'))}</th>
        <td colSpan="2">
          <DescriptiveLink entity={display.recording} />
        </td>
      </tr>

      {artist ? (
        <tr>
          <th>{addColonText(l('Artist'))}</th>
          <td className="old">
            <DescriptiveLink entity={artist.old} />
          </td>
          <td className="new">
            <DescriptiveLink entity={artist.new} />
          </td>
        </tr>
      ) : null}

      {position ? (
        <WordDiff
          label={addColonText(l('Track number'))}
          newText={position.new.toString()}
          oldText={position.old.toString()}
        />
      ) : null}
    </table>
  );
};

export default EditTrack;
