/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../../layout/index.js';
import FormCsrfToken
  from '../../static/scripts/edit/components/FormCsrfToken.js';
import FormRowText from '../../static/scripts/edit/components/FormRowText.js';
import FormRowTextLong
  from '../../static/scripts/edit/components/FormRowTextLong.js';
import FormSubmit from '../../static/scripts/edit/components/FormSubmit.js';

type CreateWikiDocFormT = FormT<{
  +csrf_token: FieldT<string>,
  +page: FieldT<string>,
  +version: FieldT<string>,
}>;

component CreateWikiDoc(form: CreateWikiDocFormT) {
  return (
    <Layout fullWidth title="Add page">
      <div id="content">
        <h1>{'Add page'}</h1>
        <form method="post">
          <FormCsrfToken form={form} />
          <FormRowTextLong
            field={form.field.page}
            label="Page:"
            required
            uncontrolled
          />
          <FormRowText
            field={form.field.version}
            label="Version:"
            required
            type="number"
            uncontrolled
          />
          <div className="row no-label">
            <FormSubmit label="Add page" />
          </div>
        </form>
      </div>
    </Layout>
  );
}

export default CreateWikiDoc;
