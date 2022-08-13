/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FormCsrfToken from '../../components/FormCsrfToken.js';
import FormRowText from '../../components/FormRowText.js';
import FormRowTextLong from '../../components/FormRowTextLong.js';
import FormSubmit from '../../components/FormSubmit.js';
import Layout from '../../layout/index.js';

type Props = {
  +form: FormT<{
    +csrf_token: FieldT<string>,
    +page: FieldT<string>,
    +version: FieldT<string>,
  }>,
};

const CreateWikiDoc = ({
  form,
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Add Page')}>
    <div id="content">
      <h1>{l('Add Page')}</h1>
      <form method="post">
        <FormCsrfToken form={form} />
        <FormRowTextLong
          field={form.field.page}
          label={l('Page:')}
          required
          uncontrolled
        />
        <FormRowText
          field={form.field.version}
          label={l('Version:')}
          required
          type="number"
          uncontrolled
        />
        <div className="row no-label">
          <FormSubmit label={l('Create')} />
        </div>
      </form>
    </div>
  </Layout>
);

export default CreateWikiDoc;
