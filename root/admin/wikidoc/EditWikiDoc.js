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
import FormSubmit from '../../components/FormSubmit';
import Layout from '../../layout';

type Props = {
  +$c: CatalystContextT,
  +currentVersion: number,
  +form: FormT<{
    +csrf_token: FieldT<string>,
    +version: FieldT<string>,
  }>,
  +page: string,
};

const EditWikiDoc = ({
  $c,
  currentVersion,
  form,
  page,
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Update Page')}>
    <div id="content">
      <h1>{l('Update Page')}</h1>
      <form action={$c.req.uri} method="post">
        <FormCsrfToken form={form} />
        <div className="row">
          <label>{l('Page:')}</label>
          <span>{page}</span>
        </div>
        <div className="row">
          <label>{l('Current version:')}</label>
          <span>{currentVersion}</span>
        </div>
        <FormRowText
          field={form.field.version}
          label={l('New version:')}
          required
          type="number"
          uncontrolled
        />
        <div className="row no-label">
          <FormSubmit label={l('Update')} />
        </div>
      </form>
    </div>
  </Layout>
);

export default EditWikiDoc;
