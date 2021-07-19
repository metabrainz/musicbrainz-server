/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../../layout';

import StatisticsEventEditForm from './StatisticsEventEditForm';
import type {StatisticsEventFormT} from './types';

type PropsT = {
  +form: StatisticsEventFormT,
};

const EditStatisticsEvent = ({
  form,
}: PropsT): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Edit statistics event')}>
    <StatisticsEventEditForm form={form} />
  </Layout>
);

export default EditStatisticsEvent;
