/*
 * @flow strict
 * Copyright (C) 2019 Anirudh Jain
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import DescriptiveLink from
  '../../static/scripts/common/components/DescriptiveLink.js';
import formatDate from '../../static/scripts/common/utility/formatDate.js';
import yesNo from '../../static/scripts/common/utility/yesNo.js';
import Diff from '../../static/scripts/edit/components/edit/Diff.js';
import FullChangeDiff from
  '../../static/scripts/edit/components/edit/FullChangeDiff.js';
import WordDiff from '../../static/scripts/edit/components/edit/WordDiff.js';
import {formatCoordinates} from '../../utility/coordinates.js';

type Props = {
  +edit: EditPlaceEditT,
};

const EditPlace = ({edit}: Props): React$Element<'table'> => {
  const display = edit.display_data;
  const address = display.address;
  const area = display.area;
  const beginDate = display.begin_date;
  const comment = display.comment;
  const coordinates = display.coordinates;
  const endDate = display.end_date;
  const ended = display.ended;
  const place = display.place;
  const oldTypeName = display.type?.old?.name ?? '';
  const newTypeName = display.type?.new?.name ?? '';
  return (
    <table className="details edit-place">
      <tbody>
        <tr>
          <th>{addColonText(l('Place'))}</th>
          <td><DescriptiveLink entity={place} /></td>
        </tr>
        {display.name ? (
          <WordDiff
            label={addColonText(l('Name'))}
            newText={display.name.new}
            oldText={display.name.old}
          />
        ) : null}
        {comment ? (
          <WordDiff
            label={addColonText(l('Disambiguation'))}
            newText={comment.new}
            oldText={comment.old}
          />
        ) : null}
        {display.type ? (
          <FullChangeDiff
            label={addColonText(l('Type'))}
            newContent={newTypeName ? lp_attributes(newTypeName,
                                                    'place_type') : ''}
            oldContent={oldTypeName ? lp_attributes(oldTypeName,
                                                    'place_type') : ''}
          />
        ) : null}
        {address ? (
          <WordDiff
            label={addColonText(l('Address'))}
            newText={address.new}
            oldText={address.old}
          />
        ) : null}
        {area && area.new?.gid !== area.old?.gid ? (
          <FullChangeDiff
            label={addColonText(l('Area'))}
            newContent={area.new
              ? <DescriptiveLink entity={area.new} />
              : ''}
            oldContent={area.old
              ? <DescriptiveLink entity={area.old} />
              : ''}
          />
        ) : null}
        {coordinates ? (
          <Diff
            label={addColonText(l('Coordinates'))}
            newText={formatCoordinates(coordinates.new)}
            oldText={formatCoordinates(coordinates.old)}
          />
        ) : null}
        {beginDate ? (
          <Diff
            label={addColonText(l('Begin date'))}
            newText={formatDate(beginDate.new)}
            oldText={formatDate(beginDate.old)}
            split="-"
          />
        ) : null}
        {endDate ? (
          <Diff
            label={addColonText(l('End date'))}
            newText={formatDate(endDate.new)}
            oldText={formatDate(endDate.old)}
            split="-"
          />
        ) : null}
        {ended ? (
          <FullChangeDiff
            label={addColonText(l('Ended'))}
            newContent={yesNo(ended.new)}
            oldContent={yesNo(ended.old)}
          />
        ) : null}
      </tbody>
    </table>
  );
};

export default EditPlace;
