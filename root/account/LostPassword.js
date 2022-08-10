/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FormCsrfToken from '../components/FormCsrfToken.js';
import FormRow from '../components/FormRow.js';
import FormRowText from '../components/FormRowText.js';
import FormRowEmailLong from '../components/FormRowEmailLong.js';
import FormSubmit from '../components/FormSubmit.js';
import Layout from '../layout/index.js';

type LostPasswordFormT = FormT<{
  +email: ReadOnlyFieldT<string>,
  +username: ReadOnlyFieldT<string>,
}>;

type Props = {
  +form: LostPasswordFormT,
};

const LostPassword = (props: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Lost Password')}>
    <h1>{l('Lost Password')}</h1>
    <p>
      {exp.l(
        `Enter your username and email below. We will send you an
         email with a link to reset your password. If you have
         forgotten your username, {link|retrieve it} first and then
         reset your password.`,
        {link: '/lost-username'},
      )}
    </p>
    <form method="post">
      <FormCsrfToken form={props.form} />
      <FormRowText
        field={props.form.field.username}
        label={l('Username:')}
        required
        uncontrolled
      />
      <FormRowEmailLong
        field={props.form.field.email}
        label={addColonText(l('Email'))}
        required
        uncontrolled
      />
      <FormRow hasNoLabel>
        <FormSubmit label={l('Reset Password')} />
      </FormRow>
    </form>
  </Layout>
);

export default LostPassword;
