/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import RecordingList from '../../components/list/RecordingList';

type MergeRecordingsEditT = {
  ...EditT,
  +display_data: {
    +large_spread: boolean,
    +new: RecordingWithArtistCreditT,
    +old: $ReadOnlyArray<RecordingWithArtistCreditT>,
  },
};

type Props = {
  +$c: CatalystContextT,
  +edit: MergeRecordingsEditT,
};

const MergeRecordings = ({$c, edit}: Props): React.Element<'table'> => (
  <table className="details merge-recordings">
    <tr>
      <th>{l('Merge:')}</th>
      <td>
        <RecordingList
          $c={$c}
          lengthClass={edit.display_data.large_spread ? 'warn-lengths' : ''}
          recordings={edit.display_data.old}
          showExpandedArtistCredits
        />
      </td>
    </tr>
    <tr>
      <th>{l('Into:')}</th>
      <td>
        <RecordingList
          $c={$c}
          lengthClass={edit.display_data.large_spread ? 'warn-lengths' : ''}
          recordings={[edit.display_data.new]}
          showExpandedArtistCredits
        />
      </td>
    </tr>
  </table>
);

export default MergeRecordings;
