/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import sortByEntityName
  from '../static/scripts/common/utility/sortByEntityName.js';
import FieldErrors from '../static/scripts/edit/components/FieldErrors.js';
import RecordingList from '../components/list/RecordingList.js';
import Layout from '../layout/index.js';
import EnterEdit from '../static/scripts/edit/components/EnterEdit.js';
import EnterEditNote
  from '../static/scripts/edit/components/EnterEditNote.js';

type Props = {
  +form: MergeFormT,
  +isrcsDiffer?: boolean,
  +toMerge: $ReadOnlyArray<RecordingWithArtistCreditT>,
};

const RecordingMerge = ({
  form,
  isrcsDiffer = false,
  toMerge,
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Merge recordings')}>
    <div id="content">
      <h1>{l('Merge recordings')}</h1>
      <p>
        {l(`You are about to merge all these recordings into a single one.
            Please select the recording all others should be merged into:`)}
      </p>
      {isrcsDiffer ? (
        <div className="warning warning-isrcs-differ">
          <p>
            {exp.l(
              `<strong>Warning:</strong> Some of the recordings you're
                merging have different ISRCs. Please make sure they are
                indeed the same recordings and you wish to continue with
                the merge.`,
            )}
          </p>
        </div>
      ) : null}
      <form method="post">
        <RecordingList
          mergeForm={form}
          recordings={sortByEntityName(toMerge)}
          showAcoustIds
          showExpandedArtistCredits
        />
        <FieldErrors field={form.field.target} />

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
  </Layout>
);

export default RecordingMerge;
