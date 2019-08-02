import React from 'react';

import EntityLink from '../../static/scripts/common/components/EntityLink';
import Diff from '../../static/scripts/edit/components/edit/Diff';
import FullChangeDiff from '../../static/scripts/edit/components/edit/FullChangeDiff';


const EditSeries = ({edit}) => {
  return (
    <table className="details edit-series">
      <tr>
        <th>{l('Series:')}</th>
        <td colSpan="2"><EntityLink entity={edit.display_data.series} /></td>
      </tr>
      <Diff
        label={l('Name')}
        newText={edit.display_data.name.new}
        oldText={edit.display_data.name.old}
        split="\s+"
      />
      <Diff
        label={addColon(l('Disambiguation'))}
        newText={edit.display_data.comment.new}
        oldText={edit.display_data.comment.old}
        split="\s+"
      />
      <FullChangeDiff
        label={l('Type:')}
        newText={edit.display_data.type.new.name}
        oldText={edit.display_data.type.old.name}
      />
      <FullChangeDiff
        label={l('Ordering Type:')}
        newText={edit.display_data.ordering_type.new.name}
        oldText={edit.display_data.ordering_type.old.name}
      />
    </table>
  );
};

export default EditSeries;
