/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CONTACT_URL} from '../constants';
import UserAccountLayout, {
  type AccountLayoutUserT,
} from '../components/UserAccountLayout';
import FormCsrfToken from '../components/FormCsrfToken';
import FormRow from '../components/FormRow';
import FormRowCheckbox from '../components/FormRowCheckbox';
import FormRowSelect from '../components/FormRowSelect';
import FormRowTextArea from '../components/FormRowTextArea';
import FormSubmit from '../components/FormSubmit';

type ReportReasonT =
  | 'enforcing_guidelines'
  | 'ignoring_guidelines'
  | 'other'
  | 'spam'
  | 'unresponsiveness'
  | 'voting';

type Props = {
  +$c: CatalystContextT,
  +form: FormT<{
    +csrf_token: FieldT<string>,
    +message: FieldT<string>,
    +reason: FieldT<ReportReasonT>,
    +reveal_address: FieldT<boolean>,
  }>,
  +user: AccountLayoutUserT,
};

const reportReasonOptions = {
  grouped: false,
  options: [
    {
      label: N_l('Editor is spamming'),
      value: 'spam',
    },
    {
      label: N_l('Editor is unresponsive to edit notes'),
      value: 'unresponsiveness',
    },
    {
      label: N_l('Editor intentionally ignores accepted guidelines'),
      value: 'ignoring_guidelines',
    },
    {
      label: N_l('Editor is overzealous in enforcing guidelines as rules'),
      value: 'enforcing_guidelines',
    },
    {
      label: N_l('Editor engages in overzealous or abusive yes/no voting'),
      value: 'voting',
    },
    {
      label: N_l(
        'Editor has violated some other part of our Code of Conduct',
      ),
      value: 'other',
    },
  ],
};

const ReportUser = ({
  $c,
  form,
  user,
}: Props): React.Element<typeof UserAccountLayout> => (
  <UserAccountLayout
    entity={user}
    page="report"
    title={l('Report User')}
  >
    <h2>{l('Report User')}</h2>

    {user.deleted ? (
      <p>
        {exp.l(
          `This user account has already been deleted,
           so there’s probably no need to report it.
           If you feel there’s a problem that still needs action,
           please {link|contact us}.`,
          {link: CONTACT_URL},
        )}
      </p>
    ) : (
      <>
        <p>
          {exp.l(
            `Please review our {uri|Code of Conduct} before
             sending a report.`,
            {uri: {href: '/doc/Code_of_Conduct', target: '_blank'}},
          )}
        </p>

        <p>
          {exp.l(
            `Your report will be sent to our {uri|account administrators},
             who will decide what action to take.`,
            {uri: {href: '/privileged', target: '_blank'}},
          )}
        </p>

        <p>
          <strong>{addColonText(l('Note'))}</strong>
          {' '}
          {exp.l(
            `Be sure to provide direct links to examples of the behaviour
             you’re reporting (for example, use
             “<code>https://musicbrainz.org/edit/23</code>”
             instead of “edit #23”, and use
             “<code>https://musicbrainz.org/edit/42</code> and
             <code>https://musicbrainz.org/edit/43</code>”
             instead of
             “<code>https://musicbrainz.org/user/SomeUser/edits</code>”).
             Providing links makes it much easier for the recipients of the
             report to look into the issues; a report without links is
             unlikely to be acted on fast, since it will require a lot of
             additional research.`,
          )}
        </p>

        <form action={$c.req.uri} className="report-form" method="post">
          <FormCsrfToken form={form} />

          <FormRowSelect
            field={form.field.reason}
            label={addColonText(l('Reason'))}
            options={reportReasonOptions}
            uncontrolled
          />

          <FormRowTextArea
            cols={50}
            field={form.field.message}
            label={addColonText(l('Message'))}
            required
            rows={10}
          />

          <FormRowCheckbox
            field={form.field.reveal_address}
            help={
              <p>
                {exp.l(
                  `If you don’t want our admins to contact you further
                   regarding this report, you can uncheck the checkbox above.
                   <br />
                   We recommend leaving it checked, so that you can be
                   contacted if the report is resolved or the admins
                   need more information.`,
                )}
              </p>
            }
            label={l('Reveal my email address')}
            uncontrolled
          />

          <FormRow hasNoLabel>
            <FormSubmit label={l('Send')} />
          </FormRow>
        </form>
      </>
    )}
  </UserAccountLayout>
);

export default ReportUser;
