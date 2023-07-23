/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Warning from '../../common/components/Warning.js';
import {MTCAPTCHA_PUBLIC_KEY} from '../../common/DBDefs-client.mjs';
import FormCsrfToken from '../../edit/components/FormCsrfToken.js';
import FormRow from '../../edit/components/FormRow.js';
import FormRowEmailLong from '../../edit/components/FormRowEmailLong.js';
import FormRowText from '../../edit/components/FormRowText.js';
import FormSubmit from '../../edit/components/FormSubmit.js';

import MTCaptcha from './MTCaptcha.js';

export type RegisterFormT = FormT<{
  +confirm_password: FieldT<string>,
  +email: FieldT<string>,
  +password: FieldT<string>,
  +username: FieldT<string>,
}>;

function isPossibleEmail(string: string | null) {
  if (string == null) {
    return false;
  }
  return /\w+@\w+\.\w+/.test(string);
}

component RegisterForm(form: RegisterFormT) {
  const [nameField, updateNameField] = React.useState(form.field.username);

  function handleUsernameChange(
    event: SyntheticInputEvent<HTMLInputElement>,
  ) {
    const username = event.currentTarget.value;
    updateNameField({...nameField, value: username});
  }

  return (
    <form method="post">
      <FormCsrfToken form={form} />
      <FormRowText
        autoComplete="username"
        field={nameField}
        label={addColonText(l('Username'))}
        onChange={handleUsernameChange}
        required
      />
      <div className="row no-label">
        <span className="input-note">
          {l('Your username will be publicly visible.')}
        </span>
      </div>
      <div
        className={'row no-label' + (
          isPossibleEmail(nameField.value) ? '' : ' hidden'
        )}
        id="email-username-warning"
      >
        <Warning
          message={
            l(`The username you have entered looks like an email address.
               This is allowed, but please keep in mind that everyone
               will be able to see it. Only use an email address
               as your username if you are completely sure
               you are happy with that.`)
          }
        />
      </div>
      <FormRowText
        autoComplete="new-password"
        field={form.field.password}
        label={l('Password:')}
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
      <FormRowEmailLong
        field={form.field.email}
        label={addColonText(l('Email'))}
        required
        uncontrolled
      />
      <div className="row no-label">
        <span className="input-note">
          {l(`You must provide a working email address
              if you wish to contribute to the database.`)}
        </span>
      </div>
      {nonEmpty(MTCAPTCHA_PUBLIC_KEY) ? (
        <div className="row">
          <label className="required">{addColonText(l('Captcha'))}</label>
          <MTCaptcha />
        </div>
      ) : null}
      <FormRow hasNoLabel>
        <p>
          {exp.l(
            `Please review the {coc|MusicBrainz Code of Conduct}
             before creating an account.`,
            {coc: '/doc/Code_of_Conduct'},
          )}
        </p>
        <FormSubmit label={lp('Create account', 'interactive')} />
      </FormRow>
    </form>
  );
}

export default (hydrate<React.PropsOf<RegisterForm>>(
  'div.register-form',
  RegisterForm,
): component(...React.PropsOf<RegisterForm>));
