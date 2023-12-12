/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import UserAccountLayout, {
  type AccountLayoutUserT,
} from '../components/UserAccountLayout.js';
import EditorLink from '../static/scripts/common/components/EditorLink.js';
import FormCsrfToken
  from '../static/scripts/edit/components/FormCsrfToken.js';
import FormRowCheckbox
  from '../static/scripts/edit/components/FormRowCheckbox.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';

type DeleteUserFormT = FormT<{
  ...SecureConfirmFormT,
  +allow_reuse: ReadOnlyFieldT<boolean>,
}>;

type Props = {
  +form: DeleteUserFormT,
  +user: AccountLayoutUserT,
};

const DeleteUser = ({
  form,
  user,
}: Props): React$Element<typeof UserAccountLayout> => {
  return (
    <UserAccountLayout
      entity={user}
      page="delete"
      title="Delete account"
    >
      <h2>{'Delete account'}</h2>
      <p>
        {exp.l_admin(
          `Are you sure you want to delete all information about {e}?
           This cannot be undone!`,
          {e: <EditorLink editor={user} />},
        )}
      </p>
      <form id="delete-account-form" method="post">
        <FormCsrfToken form={form} />

        <FormRowCheckbox
          field={form.field.allow_reuse}
          hasNoMargin
          label={texp.l_admin(
            'Allow the name “{editor_name}” to be reused.',
            {editor_name: user.name},
          )}
          uncontrolled
        />

        <div className="row no-margin">
          <FormSubmit
            inputClassName="negative"
            label={texp.l_admin('Delete {e}', {e: user.name})}
          />
        </div>
      </form>
    </UserAccountLayout>
  );
};

export default DeleteUser;
