/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import UserAccountLayout, {
  sanitizedAccountLayoutUser,
} from '../components/UserAccountLayout';
import {CONTACT_URL, DONATE_URL} from '../constants';

type Props = {
  +days: number,
  +nag: boolean,
  +user: UnsanitizedEditorT,
};

const Donation = ({
  days,
  nag,
  user,
}: Props): React.Element<typeof UserAccountLayout> => (
  <UserAccountLayout
    entity={sanitizedAccountLayoutUser(user)}
    page="donation"
    title={l('Donation Check')}
  >
    <h2>{l('Donation Check')}</h2>
    {nag
      ? (
        <>
          <p>
            {l(`We have not received a donation from you recently. If you have
                just made a PayPal donation, then we have not received a
                notification from PayPal yet. Please wait a few minutes and
                reload this page to check again.`)}
          </p>
          <p>
            {exp.l(
              `If you would like to make a donation,
                {donate|you can do that here}. If you have donated, but
                you are still being nagged, please {contact|contact us}.`,
              {contact: CONTACT_URL, donate: DONATE_URL},
            )}
          </p>
        </>
      ) : (
        <>
          <p>
            {l('Thank you for contributing to MusicBrainz.')}
          </p>
          {days > 0
            ? (
              <p>
                {texp.l(
                  'You will not be nagged for another {days} days.',
                  {days: days},
                )}
              </p>
            ) : (
              <p>
                {l('You will never be nagged again!')}
              </p>
            )}
        </>
      )}
  </UserAccountLayout>
);

export default Donation;
