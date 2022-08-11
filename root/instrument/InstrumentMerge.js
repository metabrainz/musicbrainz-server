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
import InstrumentList from '../components/list/InstrumentList.js';
import Layout from '../layout/index.js';

type Props = {
  +$c: CatalystContextT,
  +form: MergeFormT,
  +toMerge: $ReadOnlyArray<InstrumentT>,
};

const InstrumentMerge = ({
  $c,
  form,
  toMerge,
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Merge instruments')}>
    <div id="content">
      <h1>{l('Merge instruments')}</h1>
      <p>
        {l(`You are about to merge all these instruments into a single one.
            Please select the instrument all others should be merged into:`)}
      </p>
      <form action={$c.req.uri} method="post">
        <InstrumentList
          instruments={sortByEntityName(toMerge)}
          mergeForm={form}
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

export default InstrumentMerge;
