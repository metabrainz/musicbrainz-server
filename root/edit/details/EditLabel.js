import React from 'react';

import EntityLink from '../../static/scripts/common/components/EntityLink';
import Diff from '../../static/scripts/edit/components/edit/Diff';
import FullChangeDiff from '../../static/scripts/edit/components/edit/FullChangeDiff';
import formatDate from '../../static/scripts/common/utility/formatDate';
import yesNo from '../../static/scripts/common/utility/yesNo';
import DescriptiveLink from '../../static/scripts/common/components/DescriptiveLink';
import commaOnlyList from '../../static/scripts/common/i18n/commaOnlyList';

const EditLabel = ({edit}) => {
  const display = edit.display_data;
  return (
    <table className="details edit-label">
      <tbody>
        <tr>
          <th>{l('Label:')}</th>
          <td colSpan="2"><EntityLink entity={display.label} /></td>
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
        {/* {display.label_code ? (
          <Diff
            label={l('Label code:')}
            newText={display.label_code.new}
            oldText={display.label_code.old}
          />
        ) : null} */}
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
            oldText={yesNo()}
          />
        ) : null}
        {display.area.new.gid === display.area.old.gid ? null : (
          <FullChangeDiff
            label={l('Area:')}
            newText={<DescriptiveLink entity={display.area.new} />}
            oldText={<DescriptiveLink entity={display.area.old} />}
          />
        )}
        {display.ipi_codes ? (
          <Diff
            label={l('IPI codes:')}
            newText={commaOnlyList(display.ipi_codes.new)}
            oldText={commaOnlyList(display.ipi_codes.old)}
            split=", "
          />
        ) : null}
        {display.isni_codes ? (
          <Diff
            label={l('ISNI codes:')}
            newText={commaOnlyList(display.isni_codes.new)}
            oldText={commaOnlyList(display.isni_codes.old)}
            split=", "
          />
        ) : null}
      </tbody>
    </table>
  );
};

export default EditLabel;
