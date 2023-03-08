/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../../layout/index.js';

type Props = {
  +emailAddress: string,
};

const DiscourseRegistered = ({
  emailAddress,
}: Props): React$Element<typeof Layout> => (
  <Layout fullWidth title={l('Account Created')}>
    <h2>{l('Account Created')}</h2>
    <p style={{fontSize: '1.2em'}}>
      {exp.l(
        `You must verify your email address before you can
         log in to {discourse|MetaBrainz Community Discourse}.`,
        {discourse: 'https://community.metabrainz.org/'},
      )}
    </p>
    <p>
      {exp.l(
        `An email has been sent to {addr}. Please check your
         mailbox and click on the link in the email to verify
         your email address.`,
        {addr: <code>{emailAddress}</code>},
      )}
    </p>
  </Layout>
);

export default DiscourseRegistered;
