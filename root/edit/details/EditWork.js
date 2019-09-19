import React from 'react';

import DescriptiveLink from '../../static/scripts/common/components/DescriptiveLink';
import WordDiff from '../../static/scripts/edit/components/edit/WordDiff';
import Diff from '../../static/scripts/edit/components/edit/Diff';
import FullChangeDiff from '../../static/scripts/edit/components/edit/FullChangeDiff';
import commaOnlyList from '../../static/scripts/common/i18n/commaOnlyList';

// All the Commented out code has to be reviewed

const EditWork = ({edit}) => {
  console.log(edit);
  console.log(edit.display_data);
  return (
    <table className="details edit-work">
      <tr>
        <th>{l('Work:')}</th>
        <td colSpan="2"><DescriptiveLink entity={edit.display_data.work} /></td>
      </tr>
      <WordDiff
        label={l('Name:')}
        newText={edit.display_data.name.new}
        oldText={edit.display_data.name.old}
      />
      <WordDiff
        label={addColon(l('Disambiguation'))}
        newText={edit.display_data.comment.new}
        oldText={edit.display_data.comment.old}
      />
      {/* <Diff
        label={l('ISWC:')}
        newText={edit.display_data.iswc.new}
        oldText={edit.display_data.iswc.old}
      /> */}
      <FullChangeDiff
        label={l('Work type:')}
        newText={edit.display_data.type.new.name}
        oldText={edit.display_data.type.old.name}
      />
      {/* <FullChangeDiff
        label={l('Language:')}
        newText={edit.display_data.language.new.name}
        oldText={edit.display_data.language.old.name}
      /> */}
      <Diff
        label={addColon(l('Lyrics Languages'))}
        newText={commaOnlyList(edit.display_data.languages.new)}
        oldText={commaOnlyList(edit.display_data.languages.old)}
        split=", "
      />
    </table>
  );
};

export default EditWork;
