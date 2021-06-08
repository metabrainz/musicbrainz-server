/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FormCsrfToken from '../../components/FormCsrfToken';
import FormRowText from '../../components/FormRowText';
import FormRowTextLong from '../../components/FormRowTextLong';
import FormSubmit from '../../components/FormSubmit';
import Layout from '../../layout';

type Props = {
  +$c: CatalystContextT,
  +form: FormT<{
    +csrf_token: FieldT<string>,
    +page: FieldT<string>,
    +version: FieldT<string>,
  }>,
};

const CreateWikiDoc = ({
  $c,
  form,
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Add Page')}>
    <div id="content">
      <h1>{l('Add Page')}</h1>
      <form action={$c.req.uri} method="post">
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
