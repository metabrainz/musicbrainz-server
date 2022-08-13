/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import sortByEntityName
  from '../static/scripts/common/utility/sortByEntityName.js';
import EnterEdit from '../components/EnterEdit.js';
import EnterEditNote from '../components/EnterEditNote.js';
import FieldErrors from '../components/FieldErrors.js';
import WorkList from '../components/list/WorkList.js';
import Layout from '../layout/index.js';

type Props = {
  +form: MergeFormT,
  +iswcsDiffer?: boolean,
  +toMerge: $ReadOnlyArray<WorkT>,
};

const WorkMerge = ({
  form,
  iswcsDiffer = false,
  toMerge,
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Merge works')}>
    <div id="content">
      <h1>{l('Merge works')}</h1>
      <p>
        {l(`You are about to merge all these works into a single one.
            Please select the work all others should be merged into:`)}
      </p>
      {iswcsDiffer ? (
        <div className="warning warning-iswcs-differ">
          <p>
            {exp.l(
              `<strong>Warning:</strong> Some of the works you’re
               merging have different ISWCs. Please make sure they are
               indeed the same works and you wish to continue with
               the merge.`,
            )}
          </p>
        </div>
      ) : null}
      <form method="post">
        <WorkList
          mergeForm={form}
          works={sortByEntityName(toMerge)}
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

export default WorkMerge;
