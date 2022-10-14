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
import {CONTACT_URL} from '../constants.js';
import {CatalystContext} from '../context.mjs';
import EditorLink from '../static/scripts/common/components/EditorLink.js';
import {isAccountAdmin} from '../static/scripts/common/utility/privileges.js';
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
  const $c = React.useContext(CatalystContext);
  const isAdmin = isAccountAdmin($c.user);
  const viewingOwnProfile = Boolean($c.user && $c.user.id === user.id);

  return (
    <UserAccountLayout
      entity={user}
      page="delete"
      title={l('Delete User')}
    >
      <h2>{l('Delete Account')}</h2>
      {isAdmin && !viewingOwnProfile ? (
        <>
          <p>
            {exp.l(
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
              label={texp.l(
                'Allow the name “{editor_name}” to be reused.',
                {editor_name: user.name},
              )}
              uncontrolled
            />

            <div className="row no-margin">
              <FormSubmit
                inputClassName="negative"
                label={texp.l('Delete {e}', {e: user.name})}
              />
            </div>
          </form>
        </>
      ) : (
        <>
          <p>
            {exp.l(
              `For information about the account deletion process,
               please read the {uri|account FAQ}.`,
              {uri: '/doc/Account_FAQ#How_do_I_delete_my_account.3F'},
            )}
          </p>

          <p>
            {l(
              `This will also cancel all your open edits and change
               all of your votes on any edits currently open to Abstain.`,
            )}
          </p>

          {/* TODO: Remove this once MBS-12379 is implemented */}
          <p>
            {exp.l(
              `Keep in mind this process might take a fairly long time
               if you have entered a lot of tags. If the process times out,
               please {contact_url|contact us}.`,
              {contact_url: {href: CONTACT_URL, target: '_blank'}},
            )}
          </p>

          <p>
            {l(
              `Are you sure you want to delete your account?
               This cannot be undone!`,
            )}
          </p>

          <form id="delete-account-form" method="post">
            <FormCsrfToken form={form} />

            <div className="row no-margin">
              <FormSubmit
                inputClassName="negative"
                label={l('Delete my account')}
              />
            </div>
          </form>
        </>
      )}
    </UserAccountLayout>
  );
};

export default DeleteUser;
