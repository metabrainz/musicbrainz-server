/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../../layout/index.js';

const DiscourseUnconfirmedEmailAddress = (): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Unverified Email Address')}>
    <h2>{l('Unverified Email Address')}</h2>
    <p>
      {exp.l(
        `You must verify your email address before you can
         log in to {discourse|MetaBrainz Community Discourse}.`,
        {discourse: 'https://community.metabrainz.org/'},
      )}
    </p>
  </Layout>
);

export default DiscourseUnconfirmedEmailAddress;
