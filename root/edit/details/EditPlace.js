import React from 'react';

import DescriptiveLink from '../../static/scripts/common/components/DescriptiveLink';
import Diff from '../../static/scripts/edit/components/edit/Diff';
import FullChangeDiff from '../../static/scripts/edit/components/edit/FullChangeDiff';
import {formatCoordinates} from '../../utility/coordinates';
import formatDate from '../../static/scripts/common/utility/formatDate';
import yesNo from '../../static/scripts/common/utility/yesNo';

const EditPlace = ({edit}) => {
  const display = edit.display_data;
  const entity = display.place;
  return (
    <table className="details edit-place">
      <tbody>
        <tr>
          <th>{l('Place:')}</th>
          <td><DescriptiveLink entity={entity} /></td>
        </tr>

        {display.name ? (
          <Diff
            label={l('Name:')}
            newText={display.name.new}
            oldText={display.name.old}
            split="\s+"
          />
        ) : null}
        {display.comment ? (
          <Diff
            label={addColon(l('Disambiguation'))}
            newText={display.comment.new}
            oldText={display.comment.old}
            split="\s+"
          />
        ) : null}
        {display.type ? (
          <FullChangeDiff
            label={l('Type:')}
            newText={display.type.new.name}
            oldText={display.type.old.name}
          />
        ) : null}
        {display.address ? (
          <Diff
            label={l('Address:')}
            newText={display.address.new}
            oldText={display.address.old}
            split="\s+"
          />
        ) : null}
        {display.area ? (
          <FullChangeDiff
            label={l('Area:')}
            newText={display.area.new ? <DescriptiveLink entity={display.area.new} /> : ''}
            oldText={display.area.old ? <DescriptiveLink entity={display.area.old} /> : ''}
          />
        ) : null}
        {display.coordinates ? (
          <Diff
            label={l('Coordinates:')}
            newText={formatCoordinates(display.coordinates.new)}
            oldText={formatCoordinates(display.coordinates.old)}
          />
        ) : null}
        {display.begin_date ? (
          <Diff
            label={l('Begin date:')}
            newText={formatDate(display.begin_date.new)}
            oldText={formatDate(display.begin_date.old)}
            split="-"
          />
        ) : null}
        {display.end_date ? (
          <Diff
            label={l('End date:')}
            newText={formatDate(display.end_date.new)}
            oldText={formatDate(display.end_date.old)}
            split="-"
          />
        ) : null}
        {display.ended ? (
          <FullChangeDiff
            label={l('Ended:')}
            newText={yesNo(display.ended.new)}
            oldText={yesNo(display.ended.old)}
          />
        ) : null}
      </tbody>
    </table>
  );
};

export default EditPlace;
