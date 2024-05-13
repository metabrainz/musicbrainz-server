/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../../layout/index.js';
import type {ApplicationFormT}
  from '../../static/scripts/account/components/ApplicationForm.js';
import ApplicationForm
  from '../../static/scripts/account/components/ApplicationForm.js';

component EditApplication(form: ApplicationFormT) {
  return (
    <Layout fullWidth title={lp('Edit application', 'header')}>
      <h1>{lp('Edit application', 'header')}</h1>
      <ApplicationForm
        action="edit"
        form={form}
        submitLabel={lp('Update', 'verb, data, interactive')}
      />
    </Layout>
  );
}

export default EditApplication;
