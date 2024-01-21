/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FormCsrfToken
  from '../static/scripts/edit/components/FormCsrfToken.js';
import FormRowTextArea
  from '../static/scripts/edit/components/FormRowTextArea.js';
import FormSubmit
  from '../static/scripts/edit/components/FormSubmit.js';
import Layout from '../layout';


type Props = {
  +form: DeleteUsersFormT,
};

const DeleteUsers = ({
  form,
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title="Delete multiple users">
    <div id="content">
      <h1>{'Delete multiple users'}</h1>

      <form action="/admin/delete-users" method="post">
        <FormCsrfToken form={form} />
        <p>
          {'Enter a list of newline-separated usernames.'}
        </p>

        <FormRowTextArea
          field={form.field.users}
          label="Users:"
        />

        <div className="row no-label">
          <FormSubmit
            label="Next"
            name="delete-users.submit"
            value="next"
          />
        </div>
      </form>
    </div>
  </Layout>
);

export default DeleteUsers;
