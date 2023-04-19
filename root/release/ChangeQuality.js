/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {QUALITY_NAMES} from '../static/scripts/common/constants.js';
import EnterEdit from '../static/scripts/edit/components/EnterEdit.js';
import EnterEditNote
  from '../static/scripts/edit/components/EnterEditNote.js';
import FormRowSelect
  from '../static/scripts/edit/components/FormRowSelect.js';

import ReleaseLayout from './ReleaseLayout.js';

type ChangeQualityFormT = ReadOnlyFormT<{
  +edit_note: ReadOnlyFieldT<string>,
  +make_votable: ReadOnlyFieldT<boolean>,
  +quality: ReadOnlyFieldT<'advanced' | 'direct' | 'indexed'>,
  +submit: ReadOnlyFieldT<string>,
}>;

type Props = {
  +artwork: ArtworkT,
  +form: ChangeQualityFormT,
  +release: ReleaseT,
};

const ChangeQuality = ({
  form,
  release,
}: Props): React$Element<typeof ReleaseLayout> => {
  const title = l('Change release data quality');
  const qualityOptions = {
    grouped: false,
    options: [
      {label: QUALITY_NAMES.get(0), value: 0},
      {label: QUALITY_NAMES.get(1), value: 1},
      {label: QUALITY_NAMES.get(2), value: 2},
    ],
  };

  return (
    <ReleaseLayout entity={release} fullWidth title={title}>
      <h2>{title}</h2>
      <form method="post">
        <FormRowSelect
          field={form.field.quality}
          label={addColonText(l('Data Quality'))}
          // $FlowIgnore[incompatible-type] we know these .get return a string
          options={qualityOptions}
          uncontrolled
        />
        <EnterEditNote field={form.field.edit_note} />
        <EnterEdit form={form} />
      </form>
    </ReleaseLayout>
  );
};

export default ChangeQuality;
