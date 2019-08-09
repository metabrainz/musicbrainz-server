import React from 'react';

import EntityLink from '../../static/scripts/common/components/EntityLink';
import Diff from '../../static/scripts/edit/components/edit/Diff';
import FullChangeDiff from '../../static/scripts/edit/components/edit/FullChangeDiff';
import yesNo from '../../static/scripts/common/utility/yesNo';
import formatDate from '../../static/scripts/common/utility/formatDate';

const EditEvent = ({edit}) => {
  const display = edit.display_data;
  return (
    <table className="details edit-event">
      <tr>
        <th>{l('Event:')}</th>
        <td colSpan="2"><EntityLink entity={display.event} /></td>
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
      {display.cancelled ? (
        <FullChangeDiff
          label={l('Cancelled:')}
          newText={yesNo(display.cancelled.new)}
          oldText={yesNo(display.cancelled.old)}
        />
      ) : null}
      {display.type ? (
        <FullChangeDiff
          label={l('Type:')}
          newText={display.type.new.name}
          oldText={display.type.old.name}
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
      {display.time ? (
        <FullChangeDiff
          label={l('Time:')}
          newText={display.time.new}
          oldText={display.time.old}
        />
      ) : null}
      {display.setlist ? (
        <Diff
          label={l('Setlist:')}
          newText={display.setlist.new}
          oldText={display.setlist.old}
          split="\s+"
        />
      ) : null}
    </table>
  );
};

export default EditEvent;
