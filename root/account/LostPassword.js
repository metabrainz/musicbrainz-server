/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';
import FormCsrfToken
  from '../static/scripts/edit/components/FormCsrfToken.js';
import FormRow from '../static/scripts/edit/components/FormRow.js';
import FormRowEmailLong
  from '../static/scripts/edit/components/FormRowEmailLong.js';
import FormRowText from '../static/scripts/edit/components/FormRowText.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';

type LostPasswordFormT = FormT<{
  +email: FieldT<string>,
  +username: FieldT<string>,
}>;

component LostPassword(form: LostPasswordFormT) {
  return (
    <Layout fullWidth title={l('Lost password')}>
      <h1>{l('Lost password')}</h1>
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
        <FormCsrfToken form={form} />
        <FormRowText
          field={form.field.username}
          label={addColonText(l('Username'))}
          required
          uncontrolled
        />
        <FormRowEmailLong
          field={form.field.email}
          label={addColonText(l('Email'))}
          required
          uncontrolled
        />
        <FormRow hasNoLabel>
          <FormSubmit label={lp('Reset password', 'interactive')} />
        </FormRow>
      </form>
    </Layout>
  );
}

export default LostPassword;
