/*
 * @flow strict
 * Copyright (C) 2020 Anirudh Jain
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DescriptiveLink from
  '../../static/scripts/common/components/DescriptiveLink.js';
import ExpandedArtistCredit from
  '../../static/scripts/common/components/ExpandedArtistCredit.js';
import formatTrackLength from
  '../../static/scripts/common/utility/formatTrackLength.js';
import yesNo from '../../static/scripts/common/utility/yesNo.js';
import Diff from '../../static/scripts/edit/components/edit/Diff.js';
import FullChangeDiff from
  '../../static/scripts/edit/components/edit/FullChangeDiff.js';
import WordDiff from '../../static/scripts/edit/components/edit/WordDiff.js';

type Props = {
  +edit: EditRecordingEditT,
};

const EditRecording = ({edit}: Props): React.Element<'table'> => {
  const display = edit.display_data;
  const name = display.name;
  const comment = display.comment;
  const length = display.length;
  const video = display.video;
  const artistCredit = display.artist_credit;
  return (
    <table className="details edit-recordiing">
      <tbody>
        <tr>
          <th>{addColonText(l('Recording'))}</th>
          <td colSpan="2">
            <DescriptiveLink entity={display.recording} />
          </td>
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
        {length ? (
          <Diff
            label={addColonText(l('Length'))}
            newText={formatTrackLength(length.new)}
            oldText={formatTrackLength(length.old)}
          />
        ) : null}
        {video ? (
          <FullChangeDiff
            label={addColonText(l('Video'))}
            newContent={yesNo(video.new)}
            oldContent={yesNo(video.old)}
          />
        ) : null}
        {artistCredit ? (
          <tr>
            <th>{addColonText(l('Artist'))}</th>
            <td className="old">
              <ExpandedArtistCredit
                artistCredit={artistCredit.old}
              />
            </td>
            <td className="new">
              <ExpandedArtistCredit
                artistCredit={artistCredit.new}
              />
            </td>
          </tr>
        ) : null}
      </tbody>
    </table>
  );
};

export default EditRecording;
