/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EntityLink from '../../static/scripts/common/components/EntityLink.js';
import FullChangeDiff from
  '../../static/scripts/edit/components/edit/FullChangeDiff.js';
import WordDiff from '../../static/scripts/edit/components/edit/WordDiff.js';
import IntentionallyRawIcon
  from '../components/IntentionallyRawIcon.js';

type Props = {
  +edit: EditInstrumentEditT,
};

const EditInstrument = ({edit}: Props): React$Element<'table'> => {
  const display = edit.display_data;
  const name = display.name;
  const comment = display.comment;
  const type = display.type;
  const description = display.description;
  const rawIconSection = (
    <>
      {' '}
      <IntentionallyRawIcon />
    </>
  );

  return (
    <table className="details edit-event">
      <tr>
        <th>{addColonText(l('Instrument'))}</th>
        <td colSpan="2"><EntityLink entity={display.instrument} /></td>
      </tr>
      {name ? (
        <WordDiff
          extraNew={rawIconSection}
          extraOld={rawIconSection}
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
      {type ? (
        <FullChangeDiff
          label={addColonText(l('Type'))}
          newContent={type.new
            ? lp_attributes(type.new.name, 'instrument_type')
            : null}
          oldContent={type.old
            ? lp_attributes(type.old.name, 'instrument_type')
            : null}
        />
      ) : null}
      {description ? (
        <WordDiff
          extraNew={nonEmpty(description.new) ? rawIconSection : null}
          extraOld={nonEmpty(description.old) ? rawIconSection : null}
          label={addColonText(l('Description'))}
          newText={description.new ?? ''}
          oldText={description.old ?? ''}
        />
      ) : null}
    </table>
  );
};

export default EditInstrument;
