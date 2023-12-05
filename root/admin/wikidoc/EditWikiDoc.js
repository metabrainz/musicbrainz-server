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
import FormSubmit from '../../static/scripts/edit/components/FormSubmit.js';

type Props = {
  +currentVersion: number,
  +form: FormT<{
    +csrf_token: FieldT<string>,
    +version: FieldT<string>,
  }>,
  +page: string,
};

const EditWikiDoc = ({
  currentVersion,
  form,
  page,
}: Props): React$Element<typeof Layout> => (
  <Layout fullWidth title="Update Page">
    <div id="content">
      <h1>{'Update Page'}</h1>
      <form method="post">
        <FormCsrfToken form={form} />
        <div className="row">
          <label>{'Page:'}</label>
          <span>{page}</span>
        </div>
        <div className="row">
          <label>{'Current version:'}</label>
          <span>{currentVersion}</span>
        </div>
        <FormRowText
          field={form.field.version}
          label="New version:"
          required
          type="number"
          uncontrolled
        />
        <div className="row no-label">
          <FormSubmit label="Update" />
        </div>
      </form>
    </div>
  </Layout>
);

export default EditWikiDoc;
