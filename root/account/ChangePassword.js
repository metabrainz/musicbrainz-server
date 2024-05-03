/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import UserAccountLayout, {sanitizedAccountLayoutUser}
  from '../components/UserAccountLayout.js';
import {CatalystContext} from '../context.mjs';
import Layout from '../layout/index.js';
import FormCsrfToken
  from '../static/scripts/edit/components/FormCsrfToken.js';
import FormRow from '../static/scripts/edit/components/FormRow.js';
import FormRowText from '../static/scripts/edit/components/FormRowText.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';
import HiddenField from '../static/scripts/edit/components/HiddenField.js';

type ChangePasswordFormT = FormT<{
  +confirm_password: FieldT<string>,
  +old_password: FieldT<string>,
  +password: FieldT<string>,
  +username: FieldT<string>,
}>;

component ChangePasswordPageContent(
  form: ChangePasswordFormT,
  isMandatory: boolean = false,
  userExists: boolean = false,
) {
  return (
    <>
      {isMandatory ? (
        <p>
          {exp.l(
            `Please change your password. Unfortunately we\'ve discovered that
             secure hashes user\'s passwords were temporarily available for
             download on our FTP site. While it is extremely unlikely that
             anyone will be able to derive the original passwords from this
             mishap, we are requiring all of our users to change their
             passwords. Sorry for the inconvenience. For more information see
             {blog|the recent blog post}.`,
            {blog: 'http://blog.metabrainz.org/?p=1844'},
          )}
        </p>
      ) : null}

      <p>
        {l(`Please enter your old password below,
            and then your new password.`)}
      </p>

      <form method="post">
        <FormCsrfToken form={form} />
        {userExists ? (
          <HiddenField field={form.field.username} />
        ) : (
          <FormRowText
            autoComplete="username"
            field={form.field.username}
            label={addColonText(l('Username'))}
            required
            uncontrolled
          />
        )}
        <FormRowText
          autoComplete="current-password"
          field={form.field.old_password}
          label={l('Old password:')}
          required
          type="password"
          uncontrolled
        />
        <FormRowText
          autoComplete="new-password"
          field={form.field.password}
          label={l('New password:')}
          required
          type="password"
          uncontrolled
        />
        <FormRowText
          autoComplete="new-password"
          field={form.field.confirm_password}
          label={l('Confirm password:')}
          required
          type="password"
          uncontrolled
        />
        <FormRow hasNoLabel>
          <FormSubmit label={lp('Change password', 'interactive')} />
        </FormRow>
      </form>
    </>
  );
}

component ChangePassword(
  form: ChangePasswordFormT,
  isMandatory?: boolean,
) {
  const $c = React.useContext(CatalystContext);
  const user = $c.user;

  if (user) {
    return (
      <UserAccountLayout
        entity={sanitizedAccountLayoutUser(user)}
        page="change_password"
        title={lp('Change password', 'header')}
      >
        <h2>{lp('Change password', 'header')}</h2>
        <ChangePasswordPageContent
          form={form}
          isMandatory={isMandatory}
          userExists
        />
      </UserAccountLayout>
    );
  }

  return (
    <Layout fullWidth title={lp('Change password', 'header')}>
      <h1>{lp('Change password', 'header')}</h1>
      <ChangePasswordPageContent form={form} isMandatory={isMandatory} />
    </Layout>
  );
}

export default ChangePassword;
