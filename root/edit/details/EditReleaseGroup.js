/*
 * @flow
 * Copyright (C) 2020 Anirudh Jain
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DescriptiveLink from
  '../../static/scripts/common/components/DescriptiveLink';
import Diff from '../../static/scripts/edit/components/edit/Diff';
import ExpandedArtistCredit from
  '../../static/scripts/common/components/ExpandedArtistCredit';
import WordDiff from '../../static/scripts/edit/components/edit/WordDiff';
import FullChangeDiff from
  '../../static/scripts/edit/components/edit/FullChangeDiff';

type EditReleaseGroupEditT = {
  ...EditT,
  +display_data: {
    +artist_credit?: CompT<ArtistCreditT>,
    +comment?: CompT<string | null>,
    +name?: CompT<string>,
    +release_group: ReleaseGroupT,
    +secondary_types: CompT<string>,
    +type?: CompT<ReleaseGroupTypeT | null>,
  },
};

type Props = {
  +edit: EditReleaseGroupEditT,
};

const EditReleaseGroup = ({edit}: Props): React.Element<'table'> => {
  const display = edit.display_data;
  const name = display.name;
  const comment = display.comment;
  const type = display.type;
  const secondaryTypes = display.secondary_types;
  const artistCredit = display.artist_credit;

  return (
    <table className="details edit-release-group">
      <tr>
        <th>{addColonText(l('Release Group'))}</th>
        <td colSpan="2">
          <DescriptiveLink entity={display.release_group} />
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
      {type ? (
        <FullChangeDiff
          label={l('Primary Type:')}
          newContent={type.new?.name
            ? lp_attributes(type.new.name, 'release_group_primary_type')
            : ''}
          oldContent={type.old?.name
            ? lp_attributes(type.old.name, 'release_group_primary_type')
            : ''}
        />
      ) : null}
      {secondaryTypes ? (
        <Diff
          label={l('Secondary Types:')}
          newText={secondaryTypes.new}
          oldText={secondaryTypes.old}
          split=" \+"
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
    </table>
  );
};

export default EditReleaseGroup;
