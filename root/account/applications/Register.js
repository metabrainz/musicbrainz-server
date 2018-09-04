/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../../layout';
import * as manifest from '../../static/manifest';
import {l} from '../../static/scripts/common/i18n';

import RegisterApplicationForm from './RegisterForm';
import type {RegisterApplicationFormPropsT} from './RegisterForm';

const RegisterApplication = (props: RegisterApplicationFormPropsT) => (
  <Layout fullWidth title={l('Applications')}>
    <h1>{l('Register Application')}</h1>
    <RegisterApplicationForm {...props} />
    {manifest.js('account/applications/register.js', {async: 'async'})}
  </Layout>
);

export default RegisterApplication;
