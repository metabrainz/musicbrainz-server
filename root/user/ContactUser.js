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
import FormCsrfToken
  from '../static/scripts/edit/components/FormCsrfToken.js';
import FormRow from '../static/scripts/edit/components/FormRow.js';
import FormRowCheckbox
  from '../static/scripts/edit/components/FormRowCheckbox.js';
import FormRowTextArea
  from '../static/scripts/edit/components/FormRowTextArea.js';
import FormRowTextLong
  from '../static/scripts/edit/components/FormRowTextLong.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';


type Props = {
  +form: FormT<{
    +body: FieldT<string>,
    +csrf_token: FieldT<string>,
    +reveal_address: FieldT<boolean>,
    +send_to_self: FieldT<boolean>,
    +subject: FieldT<string>,
  }>,
  +user: AccountLayoutUserT,
};

const ContactUser = ({
  form,
  user,
}: Props): React.Element<typeof UserAccountLayout> => (
  <UserAccountLayout
    entity={user}
    page="report"
    title={l('Send Email')}
  >
    <h2>{l('Send Email')}</h2>

    <form className="contact-form" method="post">
      <FormCsrfToken form={form} />

      <FormRowTextLong
        field={form.field.subject}
        label={l('Subject:')}
        required
        uncontrolled
      />

      <FormRowTextArea
        cols={50}
        field={form.field.body}
        label={addColonText(l('Message'))}
        required
        rows={10}
      />

      <FormRowCheckbox
        field={form.field.reveal_address}
        label={l('Reveal my email address')}
        uncontrolled
      />

      <FormRowCheckbox
        field={form.field.send_to_self}
        label={l('Send a copy to my own email address')}
        uncontrolled
      />

      <FormRow hasNoLabel>
        <FormSubmit label={l('Send')} />
      </FormRow>
    </form>
  </UserAccountLayout>
);

export default ContactUser;
