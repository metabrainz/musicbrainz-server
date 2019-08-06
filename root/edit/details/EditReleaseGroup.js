import React from 'react';

import DescriptiveLink from '../../static/scripts/common/components/DescriptiveLink';
import Diff from '../../static/scripts/edit/components/edit/Diff';
import ExpandedArtistCredit from '../../components/ExpandedArtistCredit';
import WordDiff from '../../static/scripts/edit/components/edit/WordDiff';
import FullChangeDiff from '../../static/scripts/edit/components/edit/FullChangeDiff';

const EditReleaseGroup = ({edit}) => {
  const display = edit.display_data;
  return (
    <table className="details edit-release-group">
      <tr>
        <th>{l('Release Group:')}</th>
        <td colSpan="2">
          <DescriptiveLink entity={display.release_group} />
        </td>
      </tr>
      {display.name ? (
        <WordDiff
          label={l('Name:')}
          newText={display.name.new}
          oldText={display.name.old}
        />
      ) : null}
      {display.comment ? (
        <WordDiff
          label={addColon(l('Disambiguation'))}
          newText={display.comment.new}
          oldText={display.comment.old}
        />
      ) : null}
      {display.type ? (
        <FullChangeDiff
          label={l('Primary Type:')}
          newText={display.type.new.name}
          oldText={display.type.old.name}
        />
      ) : null}
      {display.secondary_types ? (
        <Diff
          label={l('Secondary Types:')}
          newText={display.secondary_types.new}
          oldText={display.secondary_types.old}
          split=" \+"
        />
      ) : null}
      {edit.display_data.artist_credit ? (
        <tr>
          <th>{l('Artist:')}</th>
          <td className="old"><ExpandedArtistCredit ac={edit.display_data.artist_credit.old} /></td>
          <td className="new"><ExpandedArtistCredit ac={edit.display_data.artist_credit.new} /></td>
        </tr>
      ) : null}
    </table>
  );
};

export default EditReleaseGroup;
