/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';
import FormCsrfToken
  from '../static/scripts/edit/components/FormCsrfToken.js';
import FormRow from '../static/scripts/edit/components/FormRow.js';
import FormRowText from '../static/scripts/edit/components/FormRowText.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';

type ResetPasswordFormT = FormT<{
  +confirm_password: FieldT<string>,
  +password: FieldT<string>,
}>;

type Props = {
  +form: ResetPasswordFormT,
};

const ResetPassword = ({
  form,
}: Props): React$Element<typeof Layout> => (
  <Layout fullWidth title={lp('Reset password', 'header')}>
    <h1>{lp('Reset password', 'header')}</h1>

    <p>
      {l('Set a new password for your MusicBrainz account.')}
    </p>

    <form method="post">
      <FormCsrfToken form={form} />
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
        <FormSubmit label={lp('Reset password', 'interactive')} />
      </FormRow>
    </form>
  </Layout>
);

export default ResetPassword;
