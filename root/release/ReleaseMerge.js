/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseList from '../components/list/ReleaseList.js';
import Layout from '../layout/index.js';
import * as manifest from '../static/manifest.mjs';
import linkedEntities from '../static/scripts/common/linkedEntities.mjs';
import sortByEntityName
  from '../static/scripts/common/utility/sortByEntityName.js';
import EnterEdit from '../static/scripts/edit/components/EnterEdit.js';
import EnterEditNote
  from '../static/scripts/edit/components/EnterEditNote.js';
import FieldErrors from '../static/scripts/edit/components/FieldErrors.js';
import ReleaseMergeStrategy
  from '../static/scripts/edit/components/ReleaseMergeStrategy.js';

type Props = {
  +badRecordingMerges?:
    $ReadOnlyArray<$ReadOnlyArray<RecordingWithArtistCreditT>>,
  +form: MergeReleasesFormT,
  +mediums: $ReadOnlyArray<MediumT>,
  +toMerge: $ReadOnlyArray<ReleaseT>,
};

const ReleaseMerge = ({
  badRecordingMerges,
  form,
  mediums,
  toMerge,
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Merge releases')}>
    <div id="content">
      <h1>{l('Merge releases')}</h1>
      <p>
        {l(`You are about to merge the following releases into a single
            release. Please select the release which you would
            like other releases to be merged into:`)}
      </p>
      <form method="post">
        <ReleaseList
          mergeForm={form}
          releases={sortByEntityName(toMerge)}
        />
        <FieldErrors field={form.field.target} />

        <ReleaseMergeStrategy
          badRecordingMerges={badRecordingMerges}
          form={form}
          mediums={mediums}
          releases={linkedEntities.release}
        />

        <EnterEditNote field={form.field.edit_note} />

        <EnterEdit form={form}>
          <button
            className="negative"
            name="submit"
            type="submit"
            value="cancel"
          >
            {l('Cancel')}
          </button>
        </EnterEdit>
      </form>
    </div>

    {manifest.js('edit')}
  </Layout>
);

export default ReleaseMerge;
