/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {CONTACT_URL} from '../constants';
import {l} from '../static/scripts/common/i18n';
import Frag from '../components/Frag';
import StatusPage from '../components/StatusPage';

type Props = {|
  +days: number,
  +nag: boolean,
|};

const Donation = ({days, nag}: Props) => (
  <StatusPage title={l('Donation Check')}>
    {nag
      ? (
        <Frag>
          <p>
            {l('We have not received a donation from you recently. If you have just made a PayPal donation, then we have not received a notification from PayPal yet. Please wait a few minutes and reload this page to check again.')}
          </p>
          <p>
            {l('If you would like to make a donation, {donate|you can do that here}. If you have donated, but you are still being nagged, please {contact|contact us}.',
              {__react: true, contact: CONTACT_URL, donate: 'https://metabrainz.org/donate'})}
          </p>
        </Frag>
      ) : (
        <Frag>
          <p>
            {l('Thank you for contributing to MusicBrainz.')}
          </p>
          {days > 0
            ? (
              <p>
                {l('You will not be nagged for another {days} days.', {__react: true, days: days})}
              </p>
            ) : (
              <p>
                {l('You will never be nagged again!')}
              </p>
            )}
        </Frag>
      )}
  </StatusPage>
);

export default Donation;
