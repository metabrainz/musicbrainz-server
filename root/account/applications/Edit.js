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
import type {ApplicationFormT}
  from '../../static/scripts/account/components/ApplicationForm.js';
import ApplicationForm
  from '../../static/scripts/account/components/ApplicationForm.js';

type Props = {
  +form: ApplicationFormT,
};

const EditApplication = (props: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Edit Application')}>
    <h1>{l('Edit Application')}</h1>
    <ApplicationForm
      action="edit"
      form={props.form}
      submitLabel={l('Update')}
    />
  </Layout>
);

export default EditApplication;
