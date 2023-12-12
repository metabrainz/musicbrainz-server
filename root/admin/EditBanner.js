/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';
import {l_admin} from '../static/scripts/common/i18n/admin.js';
import FormCsrfToken
  from '../static/scripts/edit/components/FormCsrfToken.js';
import FormRowTextArea
  from '../static/scripts/edit/components/FormRowTextArea.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';

type Props = {
  +form: ReadOnlyFormT<{
    +csrf_token: ReadOnlyFieldT<string>,
    +message: ReadOnlyFieldT<string>,
  }>,
};

const EditBanner = ({form}: Props): React$Element<typeof Layout> => (
  <Layout fullWidth title="Edit banner message">
    <div id="content">
      <h1>{'Edit banner message'}</h1>
      <p>
        {l_admin(`This will set the banner message that is shown at the top
                  of each page. An empty string removes the banner.`)}
      </p>
      <form action="/admin/banner/edit" method="post">
        <FormCsrfToken form={form} />
        <FormRowTextArea
          field={form.field.message}
          label="Banner message:"
        />
        <div className="row no-label">
          <FormSubmit label="Update" />
        </div>
      </form>
    </div>
  </Layout>
);

export default EditBanner;
