/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import WordDiff
  from '../../../static/scripts/edit/components/edit/WordDiff.js';
import HistoricReleaseList from '../../components/HistoricReleaseList.js';

type Props = {
  +edit: EditReleaseNameHistoricEditT,
};

const EditReleaseName = ({edit}: Props): React$Element<'table'> => (
  <table className="details edit-release">
    <HistoricReleaseList colSpan="2" releases={edit.display_data.releases} />
    <WordDiff
      label={addColonText(l('Name'))}
      newText={edit.display_data.name.new}
      oldText={edit.display_data.name.old}
    />
  </table>
);

export default EditReleaseName;
