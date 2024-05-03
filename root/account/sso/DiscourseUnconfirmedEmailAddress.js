/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../../layout/index.js';

component DiscourseUnconfirmedEmailAddress() {
  return (
    <Layout fullWidth title={lp('Unverified email address', 'header')}>
      <h2>{lp('Unverified email address', 'header')}</h2>
      <p>
        {exp.l(
          `You must verify your email address before you can
           log in to {discourse|MetaBrainz Community Discourse}.`,
          {discourse: 'https://community.metabrainz.org/'},
        )}
      </p>
    </Layout>
  );
}

export default DiscourseUnconfirmedEmailAddress;
