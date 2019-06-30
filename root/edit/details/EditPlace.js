import React from 'react';

import DescriptiveLink from '../../static/scripts/common/components/DescriptiveLink';
import Diff from '../../static/scripts/edit/components/edit/Diff';
import FullChangeDiff from '../../static/scripts/edit/components/edit/FullChangeDiff';
import { formatCoordinates } from '../../utility/coordinates';
import formatDate from '../../static/scripts/common/utility/formatDate';
import yesNo from '../../static/scripts/common/utility/yesNo';

const EditPlace = ({edit}) => {
  console.log(edit);
  const display = edit.display_data;
  const entity = display["place"];
  return (
    <table className="details edit-place">
      <tr>
        <th>{l('Place:')}</th>
        <td><DescriptiveLink entity={entity} /></td>
      </tr>

      <Diff
        label={l('Name:')}
        oldText={display.name.old}
        newText={display.name.new}
        split='\s+'
      />
      <Diff 
        label={addColon(l('Disambiguation'))}
        oldText={display.comment.old}
        newText={display.comment.new}
        split='\s+'
      />
      <FullChangeDiff label={l('Type:')} oldText={display.type.old.name} newText={display.type.new.name}/>
      <Diff label={l('Address:')} oldText={display.address.old} newText={display.address.new} split='\s+'/>
      <FullChangeDiff label={l('Area:')}
        oldText={display.area.old ? <DescriptiveLink entity={display.area.old} />: ''}
        newText={display.area.new ? <DescriptiveLink entity={display.area.new} />: ''}
      />
      <Diff 
        label={l('Coordinates:')}
        oldText={formatCoordinates(display.coordinates.old)}
        newText={formatCoordinates(display.coordinates.new)}
      />
      <Diff
        label={l('Begin date:')}
        oldText={formatDate(display.begin_date.old)}
        newText={formatDate(display.begin_date.new)}
        split='-'
      />
      <Diff
        label={l('End date:')}
        oldText={formatDate(display.end_date.old)}
        newText={formatDate(display.end_date.new)}
        split='-'
      />
      {display.ended ? (
        <FullChangeDiff
          label={l('Ended:')}
          oldText={yesNo(display.ended.old)}
          newText={yesNo(display.ended.new)}
        />
      ): null}

    </table>
  )
};

export default EditPlace;