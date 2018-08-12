/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {l} from '../../static/scripts/common/i18n';
import Layout from '../../layout';

const DiscourseUnconfirmedEmailAddress = () => (
  <Layout fullWidth title={l('Unconfirmed Email Address')}>
    <h2>{l('Unconfirmed Email Address')}</h2>
    <p>
      {l('You must verify your email address before you can log in to {discourse|MetaBrainz Community Discourse}.',
        {__react: true, discourse: 'https://community.metabrainz.org/'})}
    </p>
  </Layout>
);

export default DiscourseUnconfirmedEmailAddress;
