/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ArtistList from '../components/list/ArtistList.js';
import Layout from '../layout/index.js';
import sortByEntityName
  from '../static/scripts/common/utility/sortByEntityName.js';
import FieldErrors from '../static/scripts/edit/components/FieldErrors.js';
import FormRowCheckbox
  from '../static/scripts/edit/components/FormRowCheckbox.js';
import EnterEdit from '../static/scripts/edit/components/EnterEdit.js';
import EnterEditNote
  from '../static/scripts/edit/components/EnterEditNote.js';

type Props = {
  +form: MergeFormT,
  +toMerge: $ReadOnlyArray<ArtistT>,
};

const ArtistMerge = ({
  form,
  toMerge,
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Merge artists')}>
    <div id="content">
      <h1>{l('Merge artists')}</h1>
      <p>
        {l(`You are about to merge all these artists into a single one.
            Please select the artist all others should be merged into:`)}
      </p>
      <form method="post">
        <ArtistList
          artists={sortByEntityName(toMerge)}
          mergeForm={form}
        />
        <FieldErrors field={form.field.target} />

        <FormRowCheckbox
          field={form.field.rename}
          help={
            <>
              <p>
                {l(
                  `You should only use the checkbox above
                   to fix errors (e.g. typos).`,
                )}
              </p>
              <p>
                {exp.l(
                  `If a name appears on the cover of a release, don’t check
                   the box: the artists will still be combined if you don’t,
                   but the {doc_acs|artist credits} will be kept
                   as they are now.`,
                  {doc_acs: '/doc/Artist_Credits'},
                )}
              </p>
            </>
          }
          label={l(`Update matching artist and relationship credits to use
                    the target artist’s name`)}
          uncontrolled
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
  </Layout>
);

export default ArtistMerge;
