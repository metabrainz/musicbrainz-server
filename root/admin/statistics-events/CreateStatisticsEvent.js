/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../../layout/index.js';

import StatisticsEventEditForm from './StatisticsEventEditForm.js';

component CreateStatisticsEvent(form: StatisticsEventFormT) {
  return (
    <Layout fullWidth title="Add a new statistics event">
      <div id="content">
        <h1>{'Add a new statistics event'}</h1>
        <StatisticsEventEditForm form={form} />
      </div>
    </Layout>
  );
}

export default CreateStatisticsEvent;
