/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FormCsrfToken from '../../edit/components/FormCsrfToken.js';
import FormRow from '../../edit/components/FormRow.js';
import FormRowEmailLong from '../../edit/components/FormRowEmailLong.js';
import FormRowText from '../../edit/components/FormRowText.js';
import FormSubmit from '../../edit/components/FormSubmit.js';

export type RegisterFormT = FormT<{
  readonly confirm_password: FieldT<string>,
  readonly email: FieldT<string>,
  readonly password: FieldT<string>,
  readonly username: FieldT<string>,
}>;

component RegisterForm(form: RegisterFormT) {
  return (
    <form method="post">
      <FormCsrfToken form={form} />
      <FormRowText
        autoComplete="username"
        field={form.field.username}
        label={addColonText(l('Username'))}
        required
        uncontrolled
      />
      <div className="row no-label">
        <span className="input-note">
          {l('Your username will be publicly visible.')}
        </span>
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

export default RegisterForm;
