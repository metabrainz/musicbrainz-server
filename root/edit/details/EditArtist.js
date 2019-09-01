import React from 'react';

import {
  artistBeginLabel,
  artistEndLabel,
} from '../../artist/utils';
import Diff from '../../static/scripts/edit/components/edit/Diff';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import FullChangeDiff from '../../static/scripts/edit/components/edit/FullChangeDiff';
import DescriptiveLink from '../../static/scripts/common/components/DescriptiveLink';
import formatDate from '../../static/scripts/common/utility/formatDate';
import yesNo from '../../static/scripts/common/utility/yesNo';
import commaOnlyList from '../../static/scripts/common/i18n/commaOnlyList';

const EditArtist = ({edit}) => {
  let displayTypeId;
  if (edit.display_data.type && (edit.display_data.type.new !== edit.display_data.type.old)) {
    displayTypeId = 0;
  } else {
    displayTypeId = edit.display_data.artist.type_id;
  }
  return (
    <>
      <table className="details">
        <tbody>
          <tr>
            <th>{l('Artist:')}</th>
            <td><EntityLink entity={edit.display_data.artist} /></td>
          </tr>
        </tbody>
      </table>
      <table className="details edit-artist">
        <tbody>
          {edit.display_data.name ? (
            <Diff
              label={l('Name:')}
              newText={edit.display_data.name.new}
              oldText={edit.display_data.name.old}
              split="\s+"
            />
          ) : null}
          {edit.display_data.sort_name ? (
            <Diff
              label={l('Sort name:')}
              newText={edit.display_data.sort_name.new}
              oldText={edit.display_data.sort_name.old}
              split="\s+"
            />
          ) : null}
          {edit.display_data.comment ? (
            <Diff
              label={addColon(l('Disambiguation'))}
              newText={edit.display_data.comment.new}
              oldText={edit.display_data.comment.old}
              split="\s+"
            />
          ) : null}
          {edit.display_data.type ? (
            <FullChangeDiff
              label={l('Type:')}
              newText={edit.display_data.type.new.name}
              oldText={edit.display_data.type.old.name}
            />
          ) : null}
          {edit.display_data.gender.old || edit.display_data.gender.new ? (
            <FullChangeDiff
              label={l('Gender:')}
              newText={edit.display_data.gender.new.name}
              oldText={edit.display_data.gender.old.name}
            />
          ) : null}
          {edit.display_data.area.new.gid === edit.display_data.area.old.gid ? null : (
            <FullChangeDiff
              label={l('Area:')}
              newText={<DescriptiveLink entity={edit.display_data.area.new} />}
              oldText={<DescriptiveLink entity={edit.display_data.area.old} />}
            />
          )}
          {edit.display_data.begin_date ? (
            <Diff
              label={artistBeginLabel(displayTypeId)}
              newText={formatDate(edit.display_data.begin_date.new)}
              oldText={formatDate(edit.display_data.begin_date.old)}
              split="-"
            />
          ) : null}
          {edit.display_data.begin_area.new.gid === edit.display_data.begin_area.old.gid ? null : (
            <FullChangeDiff
              label={l('Begin Area:')}
              newText={<DescriptiveLink entity={edit.display_data.begin_area.new} />}
              oldText={<DescriptiveLink entity={edit.display_data.begin_area.old} />}
            />
          )}
          {edit.display_data.end_date ? (
            <Diff
              label={artistEndLabel(displayTypeId)}
              newText={formatDate(edit.display_data.end_date.new)}
              oldText={formatDate(edit.display_data.end_date.old)}
            />
          ) : null}
          {edit.display_data.end_area.new.gid === edit.display_data.end_area.old.gid ? null : (
            <FullChangeDiff
              label={l('End Area:')}
              newText={<DescriptiveLink entity={edit.display_data.end_area.new} />}
              oldText={<DescriptiveLink entity={edit.display_data.end_area.old} />}
            />
          )}
          {edit.display_data.ended ? (
            <FullChangeDiff
              label={l('Ended:')}
              newText={yesNo(edit.display_data.ended.new)}
              oldText={yesNo(edit.display_data.ended.old)}
            />
          ) : null}
          {/* {edit.display_data.ipi_codes ? (
          <Diff
            label={l('IPI codes:')}
            newText={commaOnlyList(edit.display_data.ipi_codes.new)}
            oldText={commaOnlyList(edit.display_data.ipi_codes.old)}
            split=", "
          />
        ) : null}
        {edit.display_data.isni_codes ? (
          <Diff
            label={l('ISNI codes:')}
            newText={commaOnlyList(edit.display_data.isni_codes.new)}
            oldText={commaOnlyList(edit.display_data.isni_codes.old)}
            split=", "
          />
        ) : null} */}
        </tbody>
      </table>
    </>
  );
};

export default EditArtist;
