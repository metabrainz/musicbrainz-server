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
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';

type LostUsernameFormT = FormT<{
  +email: ReadOnlyFieldT<string>,
}>;

type Props = {
  +form: LostUsernameFormT,
};

const LostUsername = (props: Props): React$Element<typeof Layout> => (
  <Layout fullWidth title={l('Lost Username')}>
    <h1>{l('Lost Username')}</h1>
    <p>
      {l(`Enter your email address below and we will send you an email with
          your MusicBrainz account information.`)}
    </p>
    <form method="post">
      <FormCsrfToken form={props.form} />
      <FormRowEmailLong
        field={props.form.field.email}
        label={addColonText(l('Email'))}
        required
        uncontrolled
      />
      <FormRow hasNoLabel>
        <FormSubmit label={l('Send Email')} />
      </FormRow>
    </form>
  </Layout>
);

export default LostUsername;
