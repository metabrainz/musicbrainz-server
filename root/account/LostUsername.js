/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FormRow from '../components/FormRow';
import FormRowEmailLong from '../components/FormRowEmailLong';
import FormSubmit from '../components/FormSubmit';
import Layout from '../layout';

type LostUsernameFormT = FormT<{|
  +email: ReadOnlyFieldT<string>,
|}>;

type Props = {|
  +form: LostUsernameFormT,
|};

const LostUsername = (props: Props) => (
  <Layout fullWidth title={l('Lost Username')}>
    <h1>{l('Lost Username')}</h1>
    <p>
      {l(`Enter your email address below and we will send you an email with
          your MusicBrainz account information.`)}
    </p>
    <form method="post">
      <FormRowEmailLong
        field={props.form.field.email}
        label={addColonText(l('Email'))}
        required
      />
      <FormRow hasNoLabel>
        <FormSubmit label={l('Send Email')} />
      </FormRow>
    </form>
  </Layout>
);

export default LostUsername;
