import React from 'react';

import DescriptiveLink from '../../static/scripts/common/components/DescriptiveLink';
import Diff from '../../static/scripts/edit/components/edit/Diff';
import formatTrackLength from '../../static/scripts/common/utility/formatTrackLength';
import FullChangeDiff from '../../static/scripts/edit/components/edit/FullChangeDiff';
import yesNo from '../../static/scripts/common/utility/yesNo';
import ExpandedArtistCredit from '../../components/ExpandedArtistCredit';

const EditRecording = ({edit}) => {
  const display = edit.display_data;
  return (
    <table className="details edit-recordiing">
      <tbody>
        <tr>
          <th>{l('Recording:')}</th>
          <td colSpan="2"><DescriptiveLink entity={display.recording} /></td>
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
        {display.length ? (
          <Diff
            label={l('Length:')}
            newText={formatTrackLength(display.length.new)}
            oldText={formatTrackLength(display.length.old)}
          />
        ) : null}
        {display.video ? (
          <FullChangeDiff
            label={l('Video:')}
            newText={yesNo(display.video.new)}
            oldText={yesNo(display.video.old)}
          />
        ) : null}
        {display.artist_credit ? (
          <tr>
            <th>{l('Artist:')}</th>
            <td className="old"><ExpandedArtistCredit ac={display.artist_credit.old} /></td>
            <td className="new"><ExpandedArtistCredit ac={display.artist_credit.new} /></td>
          </tr>
        ) : null}
      </tbody>
    </table>
  );
};

export default EditRecording;
