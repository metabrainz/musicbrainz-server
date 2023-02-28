/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../../layout/index.js';
import * as manifest from '../../static/manifest.mjs';
import type {ApplicationFormT}
  from '../../static/scripts/account/components/ApplicationForm.js';
import ApplicationForm
  from '../../static/scripts/account/components/ApplicationForm.js';

type Props = {
  +form: ApplicationFormT,
};

const RegisterApplication = (props: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Register Application')}>
    <h1>{l('Register Application')}</h1>
    <ApplicationForm
      action="register"
      form={props.form}
      submitLabel={l('Register')}
    />
    {manifest.js('account/applications/register', {async: 'async'})}
  </Layout>
);

export default RegisterApplication;
