/*
 * @flow strict-local
 * Copyright (C) 2020 Anirudh Jain
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityLink from '../../static/scripts/common/components/EntityLink';
import Diff from '../../static/scripts/edit/components/edit/Diff';
import FullChangeDiff from
  '../../static/scripts/edit/components/edit/FullChangeDiff';
import WordDiff from '../../static/scripts/edit/components/edit/WordDiff';
import yesNo from '../../static/scripts/common/utility/yesNo';
import formatDate from '../../static/scripts/common/utility/formatDate';

type EditEventEditT = {
  ...EditT,
  +display_data: {
    +begin_date?: CompT<PartialDateT | null>,
    +cancelled?: CompT<boolean>,
    +comment?: CompT<string | null>,
    +end_date?: CompT<PartialDateT | null>,
    +event: EventT,
    +name?: CompT<string>,
    +setlist?: CompT<string | null>,
    +time?: CompT<string | null>,
    +type?: CompT<EventTypeT | null>,
  },
};

type Props = {
  +edit: EditEventEditT,
};

const EditEvent = ({edit}: Props): React.Element<'table'> => {
  const display = edit.display_data;
  const name = display.name;
  const comment = display.comment;
  const cancelled = display.cancelled;
  const type = display.type;
  const beginDate = display.begin_date;
  const endDate = display.end_date;
  const time = display.time;
  const setlist = display.setlist;
  return (
    <table className="details edit-event">
      <tr>
        <th>{addColonText(l('Event'))}</th>
        <td colSpan="2"><EntityLink entity={display.event} /></td>
      </tr>
      {name ? (
        <WordDiff
          label={addColonText(l('Name'))}
          newText={name.new}
          oldText={name.old}
        />
      ) : null}
      {comment ? (
        <WordDiff
          label={addColonText(l('Disambiguation'))}
          newText={comment.new ?? ''}
          oldText={comment.old ?? ''}
        />
      ) : null}
      {cancelled ? (
        <FullChangeDiff
          label={addColonText(l('Cancelled'))}
          newContent={yesNo(cancelled.new)}
          oldContent={yesNo(cancelled.old)}
        />
      ) : null}
      {type ? (
        <FullChangeDiff
          label={addColonText(l('Type'))}
          newContent={type.new
            ? lp_attributes(type.new.name, 'event_type')
            : null}
          oldContent={type.old
            ? lp_attributes(type.old.name, 'event_type')
            : null}
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
      {time ? (
        <FullChangeDiff
          label={addColonText(l('Time'))}
          newContent={time.new ?? ''}
          oldContent={time.old ?? ''}
        />
      ) : null}
      {setlist ? (
        <WordDiff
          label={addColonText(l('Setlist'))}
          newText={setlist.new ?? ''}
          oldText={setlist.old ?? ''}
        />
      ) : null}
    </table>
  );
};

export default EditEvent;
