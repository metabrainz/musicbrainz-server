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
import {expect} from '../utility/invariant.js';

import ReleaseLayout from './ReleaseLayout.js';

type ChangeQualityFormT = FormT<{
  +edit_note: FieldT<string>,
  +make_votable: FieldT<boolean>,
  +quality: FieldT<'advanced' | 'direct' | 'indexed'>,
  +submit: FieldT<string>,
}>;

type Props = {
  +artwork: ReleaseArtT,
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
      {label: expect(QUALITY_NAMES.get(0)), value: 0},
      {label: expect(QUALITY_NAMES.get(1)), value: 1},
      {label: expect(QUALITY_NAMES.get(2)), value: 2},
    ],
  };

  return (
    <ReleaseLayout entity={release} fullWidth title={title}>
      <h2>{title}</h2>
      <p>
        {exp.l(
          `{data_quality_doc|Data quality} indicates how good the data
           for a release is. It is not a mark of how good or bad the music
           itself is — for that, use {ratings_doc|ratings}.`,
          {
            data_quality_doc: {
              href: '/doc/Release#Data_quality',
              target: '_blank',
            },
            ratings_doc: {href: '/doc/Rating_System', target: '_blank'},
          },
        )}
      </p>
      <form method="post">
        <FormRowSelect
          field={form.field.quality}
          label={addColonText(l('Data quality'))}
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
